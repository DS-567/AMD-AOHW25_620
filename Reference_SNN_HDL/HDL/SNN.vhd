
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity SNN is
Generic (g_SNN_layer_sizes : integer_array; --number of layers / layer sizes in network
         g_num_timesteps   : integer;       --number of timesteps to stimulate network
         g_num_beta_shifts : integer;       --number of right shifts for beta decay
         g_setup_file_path : string         --base file path to access the network parameters
        );
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      trigger_i : in std_logic;
      data_sample_i : in std_logic_vector(g_SNN_layer_sizes(0)-1 downto 0);
      classes_o : out std_logic_vector(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);    
      ready_o   : out std_logic;
      done_o    : out std_logic
     );
end SNN;

architecture Behavioral of SNN is

attribute keep: boolean;

type State_type is (S_SNN_idle, S_SNN_reset_spike_counters, S_SNN_trigger_network, S_SNN_wait_for_network_done,
                    S_SNN_timestep_count_inc_and_update_spikecounts, S_SNN_reset_spike_ffs, S_SNN_timestep_counter_check,
                    S_SNN_update_output_decoder, S_SNN_done);
                                                            
signal S_SNN_Current_State, S_SNN_Next_State : State_type;

signal num_timesteps : unsigned(f_log2(g_num_timesteps)-1 downto 0);

signal rightmost_array_int : integer;

signal timestep_counter_en : std_logic;
signal timestep_counter_rst : std_logic;
signal timestep_counter : unsigned(f_log2(g_num_timesteps)-1 downto 0);

signal trigger_network : std_logic;
signal reset_membranes : std_logic; 
signal reset_spike_ffs : std_logic;

signal SNN_ready : std_logic;
signal SNN_done  : std_logic;

signal input_layer_spikes : std_logic_vector(g_SNN_layer_sizes(0)-1 downto 0);
attribute keep of input_layer_spikes : signal is true;

signal output_layer_spikes : std_logic_vector(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);
attribute keep of output_layer_spikes : signal is true;

type slv_array is array (integer range <>) of std_logic_vector(f_max_val_in_array(g_SNN_layer_sizes)-1 downto 0); 
signal layer_spike_connections : slv_array (0 to g_SNN_layer_sizes'length-1);

signal output_layer_done  : std_logic;

type sl_array is array (integer range <>) of std_logic; 
signal layer_trigger_connections : sl_array (0 to g_SNN_layer_sizes'length-1);

type output_array is array (0 to f_last_val_in_array(g_SNN_layer_sizes)-1) of std_logic_vector(f_log2(g_num_timesteps+1)-1 downto 0);  
signal output_spike_counters : output_array;

signal output_spike_count_index : std_logic_vector(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);

signal output_spike_count_to_decoder : std_logic_vector(f_log2(g_num_timesteps+1)-1 downto 0);  

signal output_spike_counters_en  : std_logic;
signal output_spike_counters_rst : std_logic;

signal reset_layers : std_logic;

signal SNN_trigger : std_logic;

signal SNN_input_data_reg : std_logic_vector(g_SNN_layer_sizes(0)-1 downto 0);

signal input_data_reg_en : std_logic;

signal output_decoder_trigger : std_logic;

signal output_decoder_done : std_logic;

signal classes: std_logic_vector(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);

begin

--- assigning SNN inputs/outputs to internal signals ----------------------------------------------------------
SNN_trigger <= trigger_i;

classes_o <= classes;
ready_o <= SNN_ready;
done_o  <= SNN_done;
---------------------------------------------------------------------------------------------------------------

--- casting generic integers to unsigned/signed data types ----------------------------------------------------
num_timesteps <= to_unsigned(g_num_timesteps, num_timesteps'length);
---------------------------------------------------------------------------------------------------------------

--- logical AND'ing the main reset with the membrane reset -----------------------------------------------------
reset_layers <= rstn_i and (not reset_membranes);
---------------------------------------------------------------------------------------------------------------

--- registering the input data before triggering SNN ----------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then
        SNN_input_data_reg <= (others => '0');
    elsif (input_data_reg_en = '1') then
        SNN_input_data_reg <= data_sample_i;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- SNN input layer instantiation -----------------------------------------------------------------------------
SNN_input_layer : input_layer
  Generic map(g_num_inputs    => g_SNN_layer_sizes(0),
              g_num_timesteps => g_num_timesteps)
  Port map (clk_i    => clk_i,
            rstn_i   => rstn_i,
            data_sample_i => SNN_input_data_reg,
            timestep_counter_i => timestep_counter,
            spikes_o => input_layer_spikes
           );

layer_trigger_connections(0) <= trigger_network;           
layer_spike_connections(0)(g_SNN_layer_sizes(0)-1 downto 0) <= input_layer_spikes;
---------------------------------------------------------------------------------------------------------------

--- SNN lif layers generation ---------------------------------------------------------------------------------
layer : for i in 1 to g_SNN_layer_sizes'length-1 generate
    lif_layers : lif_layer 
    generic map (g_num_layer_inputs  => g_SNN_layer_sizes(i-1),  
                 g_num_layer_neurons => g_SNN_layer_sizes(i),  
                 g_num_beta_shifts   => g_num_beta_shifts,
                 g_layer_index       => i,
                 g_file_path         => g_setup_file_path
                )
    port map (clk_i         => clk_i,
              rstn_i        => reset_layers,
              reset_spike_ffs_i => reset_spike_ffs,
              trigger_i     => layer_trigger_connections(i-1),
              spikes_i      => layer_spike_connections(i-1)(g_SNN_layer_sizes(i-1)-1 downto 0),
              spikes_o      => layer_spike_connections(i)(g_SNN_layer_sizes(i)-1 downto 0),
              layer_done_o  => layer_trigger_connections(i)
             );
end generate;

rightmost_array_int <= g_SNN_layer_sizes'length-1;
output_layer_spikes <= layer_spike_connections(rightmost_array_int)(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);
output_layer_done <= layer_trigger_connections(rightmost_array_int);
---------------------------------------------------------------------------------------------------------------

--- SNN output layer spike counters ---------------------------------------------------------------------------
Process (clk_i, rstn_i, output_spike_counters_rst)

begin         

for i in 0 to f_last_val_in_array(g_SNN_layer_sizes)-1 loop
    if (rstn_i = '0' or output_spike_counters_rst = '1') then
        output_spike_counters <= (others => (others => '0'));
    elsif (rising_edge(clk_i)) then
        if (output_spike_counters_en = '1' and output_layer_spikes(i) = '1') then
            output_spike_counters(i) <= std_logic_vector(unsigned(output_spike_counters(i)) + 1);
        end if;
    end if;
end loop;
    
end Process;
---------------------------------------------------------------------------------------------------------------

--- SNN output spike counter array mux to output decoder input ------------------------------------------------
output_spike_count_to_decoder <= output_spike_counters(to_integer(unsigned(output_spike_count_index)));
---------------------------------------------------------------------------------------------------------------

--- SNN output layer decoder ----------------------------------------------------------------------------------
SNN_output_decoder : output_decoder     
generic map (g_num_outputs   => f_last_val_in_array(g_SNN_layer_sizes),
             g_num_timesteps => g_num_timesteps)
Port map (clk_i  => clk_i,
          rstn_i => rstn_i,
          trigger_i  => output_decoder_trigger,
          output_spike_count_i  => output_spike_count_to_decoder,
          output_spike_count_index_o  => output_spike_count_index,
          class_regs_o  => classes,
          done_o  => output_decoder_done
         );
---------------------------------------------------------------------------------------------------------------

--- fsm timestep counter --------------------------------------------------------------------------------------
Process(clk_i, rstn_i, timestep_counter_en, timestep_counter_rst)

begin

if (rstn_i = '0') then
    timestep_counter <= (others => '0');
elsif (rising_edge(clk_i)) then
    if (timestep_counter_rst = '1') then
        timestep_counter <= (others => '0');
    elsif (timestep_counter_en = '1') then
        timestep_counter <= timestep_counter + 1;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm current state logic -----------------------------------------------------------------------------------
fsm_current : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    S_SNN_Current_State <= S_SNN_idle;

elsif (rising_edge(clk_i)) then
    S_SNN_Current_State <= S_SNN_Next_State;
    
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm next state logic --------------------------------------------------------------------------------------
fsm_next : Process (S_SNN_Current_State, SNN_trigger, output_layer_done, timestep_counter, num_timesteps, output_decoder_done)

begin

case S_SNN_Current_State is

    when S_SNN_idle =>
        if (SNN_trigger = '1') then
            S_SNN_Next_State <= S_SNN_reset_spike_counters;
        else
            S_SNN_Next_State <= S_SNN_idle;
        end if;
    
    when S_SNN_reset_spike_counters =>
        S_SNN_Next_State <= S_SNN_trigger_network;
            
    when S_SNN_trigger_network =>
        S_SNN_Next_State <= S_SNN_wait_for_network_done;
    
    when S_SNN_wait_for_network_done =>
        if (output_layer_done = '1') then
            S_SNN_Next_State <= S_SNN_timestep_count_inc_and_update_spikecounts;
        else
            S_SNN_Next_State <= S_SNN_wait_for_network_done;
        end if;
        
    when S_SNN_timestep_count_inc_and_update_spikecounts => 
        S_SNN_Next_State <= S_SNN_reset_spike_ffs;
        
    when S_SNN_reset_spike_ffs => 
        S_SNN_Next_State <= S_SNN_timestep_counter_check;
                    
    when S_SNN_timestep_counter_check => 
        if (timestep_counter = num_timesteps) then
            S_SNN_Next_State <= S_SNN_update_output_decoder;
        else
            S_SNN_Next_State <= S_SNN_trigger_network;
        end if;
    
    when S_SNN_update_output_decoder =>
        if (output_decoder_done = '1') then
            S_SNN_Next_State <= S_SNN_done;
        else
            S_SNN_Next_State <= S_SNN_update_output_decoder;
        end if;
                                                                                                                                         
    when S_SNN_done =>
        S_SNN_Next_State <= S_SNN_idle;    

end case;

end Process;
----------------------------------------------------------------------------------------------------------------

--- fsm SNN output decoding logic ------------------------------------------------------------------------------
fsm_outputs : Process (S_SNN_Current_State) 

begin

case S_SNN_Current_State is

when S_SNN_idle =>
    SNN_ready            <= '1';
    SNN_done             <= '0';
    input_data_reg_en    <= '1';
    trigger_network      <= '0';
    reset_membranes      <= '0';
    reset_spike_ffs      <= '0';
    timestep_counter_rst <= '0';
    timestep_counter_en  <= '0';
    output_decoder_trigger <= '0';
    output_spike_counters_en  <= '0';
    output_spike_counters_rst <= '0';
    
when S_SNN_reset_spike_counters =>
    SNN_ready            <= '0';
    SNN_done             <= '0';
    input_data_reg_en    <= '0';
    trigger_network      <= '0';
    reset_membranes      <= '0';
    reset_spike_ffs      <= '0';
    timestep_counter_rst <= '0';
    timestep_counter_en  <= '0';
    output_decoder_trigger <= '0';  
    output_spike_counters_en  <= '0';
    output_spike_counters_rst <= '1';
    
when S_SNN_trigger_network =>
    SNN_ready            <= '0';
    SNN_done             <= '0';
    input_data_reg_en    <= '0';
    trigger_network      <= '1';
    reset_membranes      <= '0';
    reset_spike_ffs      <= '0';
    timestep_counter_rst <= '0';
    timestep_counter_en  <= '0';
    output_decoder_trigger <= '0';
    output_spike_counters_en  <= '0';
    output_spike_counters_rst <= '0';

when S_SNN_wait_for_network_done =>
    SNN_ready            <= '0';
    SNN_done             <= '0';
    input_data_reg_en    <= '0';
    trigger_network      <= '0';
    reset_membranes      <= '0';
    reset_spike_ffs      <= '0';
    timestep_counter_rst <= '0';
    timestep_counter_en  <= '0';
    output_decoder_trigger <= '0';
    output_spike_counters_en  <= '0';
    output_spike_counters_rst <= '0';
    
when S_SNN_timestep_count_inc_and_update_spikecounts =>
    SNN_ready            <= '0';
    SNN_done             <= '0';
    input_data_reg_en    <= '0';
    trigger_network      <= '0';
    reset_membranes      <= '0';
    reset_spike_ffs      <= '0';
    timestep_counter_rst <= '0';
    timestep_counter_en  <= '1';
    output_decoder_trigger <= '0'; 
    output_spike_counters_en  <= '1';
    output_spike_counters_rst <= '0';
    
when S_SNN_reset_spike_ffs => 
    SNN_ready            <= '0';
    SNN_done             <= '0';
    input_data_reg_en    <= '0';
    trigger_network      <= '0';
    reset_membranes      <= '0';
    reset_spike_ffs      <= '1';
    timestep_counter_rst <= '0';
    timestep_counter_en  <= '0';
    output_decoder_trigger <= '0';
    output_spike_counters_en  <= '0';
    output_spike_counters_rst <= '0';
          
when S_SNN_timestep_counter_check =>
    SNN_ready            <= '0';
    SNN_done             <= '0';
    input_data_reg_en    <= '0';
    trigger_network      <= '0';
    reset_membranes      <= '0';
    reset_spike_ffs      <= '0';
    timestep_counter_rst <= '0';
    timestep_counter_en  <= '0';
    output_decoder_trigger <= '0';
    output_spike_counters_en  <= '0';
    output_spike_counters_rst <= '0';

when S_SNN_update_output_decoder => 
    SNN_ready            <= '0';
    SNN_done             <= '0';
    input_data_reg_en    <= '0';
    trigger_network      <= '0';
    reset_membranes      <= '0';
    reset_spike_ffs      <= '0';
    timestep_counter_rst <= '0'; 
    timestep_counter_en  <= '0';
    output_decoder_trigger <= '1';
    output_spike_counters_en  <= '0';
    output_spike_counters_rst <= '0';
                  
when S_SNN_done =>
    SNN_ready            <= '0';
    SNN_done             <= '1';
    input_data_reg_en    <= '0';
    trigger_network      <= '0';
    reset_membranes      <= '1';
    reset_spike_ffs      <= '1';
    timestep_counter_rst <= '1'; 
    timestep_counter_en  <= '0';
    output_decoder_trigger <= '0';
    output_spike_counters_en  <= '0';
    output_spike_counters_rst <= '0';
      
end case;

end Process;
-----------------------------------------------------------------------------------------------------------------

end Behavioral;