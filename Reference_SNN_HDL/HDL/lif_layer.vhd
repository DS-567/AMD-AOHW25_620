
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity lif_layer is
Generic (g_num_layer_inputs  : integer;  --number of inputs connected to layer   
         g_num_layer_neurons : integer;  --number of LIF neurons in the layer
         g_num_beta_shifts   : integer;  --number of right shifts for beta decay
         g_layer_index       : integer;  --layer index in network
         g_file_path         : string    --layer file path
);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      reset_spike_ffs_i : in std_logic;
      trigger_i    : in std_logic;
      spikes_i     : in std_logic_vector(g_num_layer_inputs-1 downto 0);
      spikes_o     : out std_logic_vector(g_num_layer_neurons-1 downto 0);
      layer_done_o : out std_logic
);
end lif_layer;

architecture Behavioral of lif_layer is

type State_type is (S_layer_idle, S_layer_neuron_decay, S_layer_spike_accumulate, S_layer_synapse_counter_check, S_layer_synapse_counter_inc,
                    S_layer_mem_addr_delay_cycle, S_layer_add_bias, S_layer_spike_update, S_layer_subtract_threshold, S_layer_done);
             
signal S_layer_Current_State, S_layer_Next_State : State_type;

signal synapse_counter_en  : std_logic;
signal synapse_counter_rst : std_logic;
signal synapse_counter     : unsigned(f_log2(g_num_layer_inputs)-1 downto 0);

signal neuron_spike_ffs_wr : std_logic;

signal num_layer_inputs : unsigned(f_log2(g_num_layer_inputs)-1 downto 0);

signal input_spike_mux : std_logic;

signal spike_present : std_logic;

signal neuron_mux_sel : std_logic_vector(1 downto 0);

signal neuron_membrane_reg_wr : std_logic;

begin

--- casting generic integers to unsigned/signed data types ----------------------------------------------------
num_layer_inputs  <= to_unsigned(g_num_layer_inputs, num_layer_inputs'length);
---------------------------------------------------------------------------------------------------------------

--- spike input sequencing ------------------------------------------------------------------------------------
input_spike_mux <= spikes_i(to_integer(unsigned(synapse_counter))); 
---------------------------------------------------------------------------------------------------------------

--- synapse counter -------------------------------------------------------------------------------------------
Process(clk_i, rstn_i, synapse_counter_en, synapse_counter_rst)

begin

if (rstn_i = '0') then
    synapse_counter <= (others => '0');
elsif (rising_edge(clk_i)) then
    if (synapse_counter_rst = '1') then
        synapse_counter <= (others => '0');
    elsif (synapse_counter_en = '1') then
        synapse_counter <= synapse_counter + 1;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- lif neuron instantiation ----------------------------------------------------------------------------------
neuron : for i in 0 to g_num_layer_neurons-1 generate
   lif_neurons : lif_neuron generic map
     (g_num_layer_inputs => g_num_layer_inputs,
      g_num_beta_shifts  => g_num_beta_shifts,
      g_neuron_index     => i,
      g_neuron_weights_file_path => g_file_path & "layer " & integer'image(g_layer_index) & " weights/" & "neuron " & integer'image(i) & ".txt",
      g_neuron_bias_file_path    => g_file_path & "layer " & integer'image(g_layer_index) & " biases/" & "neuron " & integer'image(i) & ".txt",
      g_neuron_threshold_file_path => g_file_path & "threshold" & ".txt"
     ) 
   port map (
         clk_i             => clk_i,
         rstn_i            => rstn_i,
         membrane_reg_wr_i => neuron_membrane_reg_wr,
         spike_ff_rst_i    => reset_spike_ffs_i,
         spike_ff_wr_i     => neuron_spike_ffs_wr,
         mux_sels_i        => neuron_mux_sel,
         weight_addr_i     => synapse_counter,
         spike_i           => input_spike_mux,
         spike_o           => spikes_o(i)   
   );
end generate neuron;
---------------------------------------------------------------------------------------------------------------

--- logical OR'ing all input spikes to check if there are spikes active ---------------------------------------
spike_present <= f_or_logic(spikes_i);
---------------------------------------------------------------------------------------------------------------

--- fsm current state logic -----------------------------------------------------------------------------------
fsm_current : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    S_layer_Current_State <= S_layer_idle;

elsif (rising_edge(clk_i)) then
    S_layer_Current_State <= S_layer_Next_State;
    
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm next state logic --------------------------------------------------------------------------------------
fsm_next : Process (S_layer_Current_State, trigger_i, spike_present, synapse_counter, num_layer_inputs)

begin

case S_layer_Current_State is

    when S_layer_idle =>
        if (trigger_i = '1') then
            S_layer_Next_State <= S_layer_neuron_decay;
        else
            S_layer_Next_State <= S_layer_idle;
        end if;
        
    when S_layer_neuron_decay =>
        if (spike_present = '0') then
            S_layer_Next_State <= S_layer_add_bias;
        else
            S_layer_Next_State <= S_layer_spike_accumulate;
        end if;
            
    when S_layer_spike_accumulate =>
        S_layer_Next_State <= S_layer_synapse_counter_check;
        
    when S_layer_synapse_counter_check =>
        if (synapse_counter = num_layer_inputs-1) then
           S_layer_Next_State <= S_layer_add_bias;
        else
            S_layer_Next_State <= S_layer_synapse_counter_inc;
        end if;
    
    when S_layer_synapse_counter_inc =>
        S_layer_Next_State <= S_layer_mem_addr_delay_cycle;
    
    when S_layer_mem_addr_delay_cycle =>
        S_layer_Next_State <= S_layer_spike_accumulate;
                    
    when S_layer_add_bias =>
        S_layer_Next_State <= S_layer_spike_update;
    
    when S_layer_spike_update =>
        S_layer_Next_State <= S_layer_subtract_threshold;
        
    when S_layer_subtract_threshold =>
        S_layer_Next_State <= S_layer_done;
    
    when S_layer_done =>
        S_layer_Next_State <= S_layer_idle;    

end case;

end Process;
----------------------------------------------------------------------------------------------------------------

--- fsm output decoding logic ----------------------------------------------------------------------------------
fsm_outputs : Process (S_layer_Current_State) 

begin

case S_layer_Current_State is

when S_layer_idle =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "00";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '0';
    layer_done_o           <= '0';

when S_layer_neuron_decay =>
    neuron_membrane_reg_wr <= '1';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "00";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '0';
    layer_done_o           <= '0';

when S_layer_spike_accumulate =>
    neuron_membrane_reg_wr <= '1';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "01";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '0';
    layer_done_o           <= '0';

when S_layer_synapse_counter_check =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "01";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '0';
    layer_done_o           <= '0';

when S_layer_synapse_counter_inc =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "01";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '1';
    layer_done_o           <= '0';

when S_layer_mem_addr_delay_cycle =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "01";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '0';
    layer_done_o           <= '0';
                         
when S_layer_add_bias =>
    neuron_membrane_reg_wr <= '1';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "10";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '0';
    layer_done_o           <= '0';

when S_layer_spike_update =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '1';
    neuron_mux_sel         <= "10";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '0';
    layer_done_o           <= '0';

when S_layer_subtract_threshold =>
    neuron_membrane_reg_wr <= '1';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "11";
    synapse_counter_rst    <= '0';
    synapse_counter_en     <= '0';
    layer_done_o           <= '0';
   
when S_layer_done =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    neuron_mux_sel         <= "00";
    synapse_counter_rst    <= '1';
    synapse_counter_en     <= '0';
    layer_done_o           <= '1';
      
end case;

end Process;
-----------------------------------------------------------------------------------------------------------------

end Behavioral;
