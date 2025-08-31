
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity fast_SNN is
Generic (g_SNN_layer_sizes : natural_array;   --number of layers / layer sizes in network
         g_num_timesteps   : natural;         --number of timesteps to stimulate network
         g_num_beta_shifts : natural;         --number of right shifts for beta decay
         g_setup_file_path : string           --base file path to access the network parameters
        );
Port (clk_i : in std_logic;
      rstn_i : in std_logic;
      trigger_i : in std_logic;
      data_sample_i : in std_logic_vector(g_SNN_layer_sizes(0)-1 downto 0);
      classes_o : out std_logic_vector(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);    
      ready_o : out std_logic;
      done_o  : out std_logic
     );
end fast_SNN;

architecture Behavioral of fast_SNN is

attribute keep: boolean;

type State_type is (S_SNN_idle, S_SNN_encode_delay_cycle_1, S_SNN_encode_delay_cycle_2, S_SNN_trigger_hidden_layer,
                    S_SNN_wait_for_hidden_layer_spikes_ready, S_SNN_check_timestep_counter, S_SNN_wait_for_output_layer_spikes_ready, 
                    S_SNN_decode_output_spikes, S_SNN_done);
                                                            
signal S_SNN_Current_State, S_SNN_Next_State : State_type;

signal data_sample_reg : std_logic_vector(15 downto 0);
signal data_sample_reg_en : std_logic;

signal SNN_rst_n : std_logic;

signal SNN_layer_rst_n : std_logic;

signal input_layer_spikes : std_logic_vector(g_SNN_layer_sizes(0)-1 downto 0);
attribute keep of input_layer_spikes: signal is true;

signal timestep_counter : unsigned(f_log2(g_num_timesteps)-1 downto 0);

signal hidden_layer_ready : std_logic;

signal hidden_layer_trigger : std_logic;

signal hidden_layer_spikes_ready : std_logic;

signal hidden_layer_spikes : std_logic_vector(g_SNN_layer_sizes(1)-1 downto 0);
attribute keep of hidden_layer_spikes: signal is true;

signal output_layer_ready : std_logic;

signal output_layer_trigger : std_logic;

signal output_layer_spikes_ready : std_logic;

signal output_layer_spikes : std_logic_vector(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);
attribute keep of output_layer_spikes: signal is true;

signal output_neuron_0_spike_counter : unsigned(f_log2(g_num_timesteps)-1 downto 0);

signal output_neuron_1_spike_counter : unsigned(f_log2(g_num_timesteps)-1 downto 0);

signal class_regs_en : std_logic;

signal class_0_winner : std_logic;
signal class_1_winner : std_logic;

signal class_0_reg : std_logic;
signal class_1_reg : std_logic;

begin

SNN_layer_rst_n <= rstn_i and SNN_rst_n;

--- input data register ---------------------------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then
        data_sample_reg <= (others => '0');
    elsif (data_sample_reg_en = '1') then
        data_sample_reg <= data_sample_i;
    
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- input layer -----------------------------------------------------------------------------------------------
input_layer_inst : input_layer
  Generic map(g_num_inputs => g_SNN_layer_sizes(0),
              g_num_timesteps => g_num_timesteps)
  Port map (clk_i    => clk_i,
            rstn_i   => rstn_i,
            data_sample_i => data_sample_reg,
            timestep_counter_i => timestep_counter,
            spikes_o => input_layer_spikes
           );
---------------------------------------------------------------------------------------------------------------

--- hidden layer ----------------------------------------------------------------------------------------------
hidden_layer_inst : hidden_layer
Generic map(g_num_inputs => g_SNN_layer_sizes(0),
            g_num_neurons => g_SNN_layer_sizes(1),
            g_num_beta_shifts => g_num_beta_shifts,
            g_file_path => g_setup_file_path)
Port map (clk_i     => clk_i,
          rstn_i    => SNN_layer_rst_n,
          trigger_i => hidden_layer_trigger,
          output_layer_ready_i => output_layer_ready,
          spikes_i => input_layer_spikes,
          spikes_o => hidden_layer_spikes,
          output_layer_trigger_o => output_layer_trigger,
          layer_ready_o => hidden_layer_ready,
          spikes_ready_o => hidden_layer_spikes_ready
         );
---------------------------------------------------------------------------------------------------------------

--- output layer ----------------------------------------------------------------------------------------------
output_layer_inst : output_layer
Generic map(g_num_inputs => g_SNN_layer_sizes(1),
            g_num_neurons => g_SNN_layer_sizes(2),
            g_num_beta_shifts => g_num_beta_shifts,
            g_file_path => g_setup_file_path)
Port map (clk_i     => clk_i,
          rstn_i    => SNN_layer_rst_n,
          trigger_i => output_layer_trigger,
          spikes_i => hidden_layer_spikes,
          spikes_o => output_layer_spikes,
          layer_ready_o => output_layer_ready,
          spikes_ready_o => output_layer_spikes_ready
         );
---------------------------------------------------------------------------------------------------------------

--- output neuron 0 spike counter -----------------------------------------------------------------------------
Process (clk_i)

begin        

if (rising_edge(clk_i)) then
    if (rstn_i = '0' or SNN_rst_n = '0') then
        output_neuron_0_spike_counter <= (others => '0');
        
    elsif (output_layer_spikes_ready = '1' and output_layer_spikes(0) = '1') then
        output_neuron_0_spike_counter <= output_neuron_0_spike_counter + 1;
    
    end if;
end if;
    
end Process;
---------------------------------------------------------------------------------------------------------------

--- output neuron 1 spike counter -----------------------------------------------------------------------------
Process (clk_i)

begin        

if (rising_edge(clk_i)) then
    if (rstn_i = '0' or SNN_rst_n = '0') then
        output_neuron_1_spike_counter <= (others => '0');
        
    elsif (output_layer_spikes_ready = '1' and output_layer_spikes(1) = '1') then
        output_neuron_1_spike_counter <= output_neuron_1_spike_counter + 1;
    
    end if;
end if;
    
end Process;
---------------------------------------------------------------------------------------------------------------

--- output layer spike count decoder --------------------------------------------------------------------------
class_0_winner <= '1' when output_neuron_0_spike_counter > output_neuron_1_spike_counter else '0';
class_1_winner <= '1' when output_neuron_1_spike_counter > output_neuron_0_spike_counter else '0';

Process (clk_i)

begin         

if (rising_edge(clk_i)) then
    if (rstn_i = '0' or SNN_rst_n = '0') then
        class_0_reg <= '0';
        class_1_reg <= '0';
    elsif (class_regs_en = '1') then
        class_0_reg <= class_0_winner;
        class_1_reg <= class_1_winner;
    end if;
end if;

end Process;

classes_o(0) <= class_0_reg;
classes_o(1) <= class_1_reg;
---------------------------------------------------------------------------------------------------------------

--- timestep counter ------------------------------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0' or SNN_rst_n = '0') then
        timestep_counter <= (others => '0');
    elsif (hidden_layer_spikes_ready = '1') then
        timestep_counter <= timestep_counter + 1;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm snn current state logic -------------------------------------------------------------------------------
fsm_snn_current : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    S_SNN_Current_State <= S_SNN_idle;

elsif (rising_edge(clk_i)) then
    S_SNN_Current_State <= S_SNN_Next_State;
    
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm snn next state logic ----------------------------------------------------------------------------------
fsm_snn_next : Process (S_SNN_Current_State, hidden_layer_ready, output_layer_ready, trigger_i, hidden_layer_spikes_ready,
                        timestep_counter, output_layer_spikes_ready)

begin

case S_SNN_Current_State is

    when S_SNN_idle =>
        if (hidden_layer_ready = '1' and output_layer_ready = '1' and trigger_i = '1') then
            S_SNN_Next_State <= S_SNN_encode_delay_cycle_1;
        else
            S_SNN_Next_State <= S_SNN_idle;
        end if;
    
    when S_SNN_encode_delay_cycle_1 =>
        S_SNN_Next_State <= S_SNN_encode_delay_cycle_2;
    
    when S_SNN_encode_delay_cycle_2 =>
        S_SNN_Next_State <= S_SNN_trigger_hidden_layer; 
                                 
    when S_SNN_trigger_hidden_layer =>
        S_SNN_Next_State <= S_SNN_wait_for_hidden_layer_spikes_ready;
    
    when S_SNN_wait_for_hidden_layer_spikes_ready =>
        if (hidden_layer_spikes_ready = '1') then
            S_SNN_Next_State <= S_SNN_check_timestep_counter;
        else
            S_SNN_Next_State <= S_SNN_wait_for_hidden_layer_spikes_ready;
        end if;
    
    when S_SNN_check_timestep_counter =>
        if (timestep_counter >= g_num_timesteps) then
            S_SNN_Next_State <= S_SNN_wait_for_output_layer_spikes_ready;
        elsif (hidden_layer_ready = '1') then
            S_SNN_Next_State <= S_SNN_trigger_hidden_layer;
        else
            S_SNN_Next_State <= S_SNN_check_timestep_counter;
        end if;  
    
    when S_SNN_wait_for_output_layer_spikes_ready =>
        if (output_layer_spikes_ready = '1') then
            S_SNN_Next_State <= S_SNN_decode_output_spikes; 
        else
            S_SNN_Next_State <= S_SNN_wait_for_output_layer_spikes_ready;  
        end if;
        
    when S_SNN_decode_output_spikes =>
        S_SNN_Next_State <= S_SNN_done;
                
    when S_SNN_done =>
        S_SNN_Next_State <= S_SNN_idle;
        
end case;

end Process;
----------------------------------------------------------------------------------------------------------------

--- fsm snn output decoding logic ------------------------------------------------------------------------------
fsm_snn_outputs : Process (S_SNN_Current_State) 

begin

case S_SNN_Current_State is

when S_SNN_idle =>
    SNN_rst_n <= '1';
    class_regs_en <= '0';
    data_sample_reg_en <= '1';
    hidden_layer_trigger <= '0';
    ready_o <= '1';
    done_o  <= '0';

when S_SNN_encode_delay_cycle_1 =>
    SNN_rst_n <= '0';
    class_regs_en <= '0';
    data_sample_reg_en <= '0';
    hidden_layer_trigger <= '0';
    ready_o <= '0';
    done_o  <= '0';

when S_SNN_encode_delay_cycle_2 =>
    SNN_rst_n <= '1';
    class_regs_en <= '0';
    data_sample_reg_en <= '0';
    hidden_layer_trigger <= '0';
    ready_o <= '0';
    done_o  <= '0';
    
when S_SNN_trigger_hidden_layer =>
    SNN_rst_n <= '1';
    class_regs_en <= '0';
    data_sample_reg_en <= '0';
    hidden_layer_trigger <= '1';
    ready_o <= '0';
    done_o  <= '0';
    
when S_SNN_wait_for_hidden_layer_spikes_ready =>
    SNN_rst_n <= '1';
    class_regs_en <= '0';
    data_sample_reg_en <= '0';
    hidden_layer_trigger <= '0';
    ready_o <= '0';
    done_o  <= '0';
    
when S_SNN_check_timestep_counter =>
    SNN_rst_n <= '1';
    class_regs_en <= '0';
    data_sample_reg_en <= '0';
    hidden_layer_trigger <= '0';
    ready_o <= '0';
    done_o  <= '0';
                            
when S_SNN_wait_for_output_layer_spikes_ready =>
    SNN_rst_n <= '1';
    class_regs_en <= '0';
    data_sample_reg_en <= '0';
    hidden_layer_trigger <= '0';
    ready_o <= '0';
    done_o  <= '0';
    
when S_SNN_decode_output_spikes =>
    SNN_rst_n <= '1';
    class_regs_en <= '1';
    data_sample_reg_en <= '0';
    hidden_layer_trigger <= '0';
    ready_o <= '0';
    done_o  <= '0';                       
                
when S_SNN_done =>
    SNN_rst_n <= '1';
    class_regs_en <= '0';
    data_sample_reg_en <= '1';
    hidden_layer_trigger <= '0';
    ready_o <= '0';
    done_o  <= '1';   
           
end case;

end Process;
-----------------------------------------------------------------------------------------------------------------

end Behavioral;