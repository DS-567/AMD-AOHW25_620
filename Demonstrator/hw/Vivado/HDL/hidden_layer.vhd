
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity hidden_layer is
Generic (g_num_inputs : natural;       --number of inputs in layer
         g_num_neurons : natural;      --number of neurons in layer
         g_num_beta_shifts : natural;  --number of right shifts for beta decay
         g_file_path : string          --layer file path
);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      trigger_i : in std_logic;
      output_layer_ready_i : in std_logic;
      spikes_i : in std_logic_vector(g_num_inputs-1 downto 0);
      spikes_o : out std_logic_vector(g_num_neurons-1 downto 0);
      output_layer_trigger_o : out std_logic;
      layer_ready_o : out std_logic;
      spikes_ready_o : out std_logic
);
end hidden_layer;

architecture Behavioral of hidden_layer is

type State_type is (S_layer_idle, S_add_weights_muxes_cycle_0, S_add_weights_cycle_1, S_add_weights_cycle_2, S_add_weights_cycle_3, S_add_weights_cycle_4,
                    S_add_bias_cycle_5, S_add_membrane_decay_cycle_6, S_layer_membrane_reg_wr, S_layer_spike_update, S_layer_spike_regs_en, 
                    S_layer_check_output_layer_ready, S_layer_subtract_threshold);
             
signal S_layer_Current_State, S_layer_Next_State : State_type;

signal neuron_membrane_reg_wr : std_logic;

signal neuron_spike_ffs_wr : std_logic;

signal sub_threshold_mux_sel : std_logic;

signal layer_spikes : std_logic_vector(g_num_neurons-1 downto 0);

signal layer_spikes_reg : std_logic_vector(g_num_neurons-1 downto 0);

signal layer_spikes_reg_en : std_logic;

signal trigger_output_layer : std_logic;

begin

--- hidden synapse/ neuron instantiation --------------------------------------------------------------------
neuron : for i in 0 to g_num_neurons-1 generate
hidden_layer_neurons : hidden_neuron
  Generic map(g_num_inputs => g_num_inputs,
              g_num_beta_shifts => g_num_beta_shifts,
              g_neuron_index => i,
              g_neuron_weights_file_path => g_file_path & "layer " & integer'image(1) & " weights/" & "neuron " & integer'image(i) & ".txt",
              g_neuron_bias_file_path => g_file_path & "layer " & integer'image(1) & " biases/" & "neuron " & integer'image(i) & ".txt",
              g_neuron_threshold_file_path => g_file_path & "threshold" & ".txt")
  Port map (clk_i    => clk_i,
            rstn_i   => rstn_i,
            spikes_i => spikes_i,
            sub_threshold_mux_sel_i => sub_threshold_mux_sel,
            membrane_reg_wr_i => neuron_membrane_reg_wr,
            spike_ff_wr_i => neuron_spike_ffs_wr,
            spike_o => layer_spikes(i)
           );
end generate neuron;
---------------------------------------------------------------------------------------------------------------

--- hidden layer output spikes register -----------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then 
        layer_spikes_reg <= (others => '0');
        
    elsif (layer_spikes_reg_en = '1') then
        layer_spikes_reg <= layer_spikes;

    end if;
end if;

end Process;

spikes_o <= layer_spikes_reg;
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
fsm_next : Process (S_layer_Current_State, trigger_i, output_layer_ready_i)

begin

case S_layer_Current_State is

    when S_layer_idle =>
        if (trigger_i = '1') then
            S_layer_Next_State <= S_add_weights_muxes_cycle_0;
        else
            S_layer_Next_State <= S_layer_idle;
        end if;
    
    when S_add_weights_muxes_cycle_0 =>
        S_layer_Next_State <= S_add_weights_cycle_1;
    
    when S_add_weights_cycle_1 =>
        S_layer_Next_State <= S_add_weights_cycle_2;
            
    when S_add_weights_cycle_2 =>
        S_layer_Next_State <= S_add_weights_cycle_3;
        
    when S_add_weights_cycle_3 =>
        S_layer_Next_State <= S_add_weights_cycle_4;

    when S_add_weights_cycle_4 =>
        S_layer_Next_State <= S_add_bias_cycle_5;
      
    when S_add_bias_cycle_5 =>
        S_layer_Next_State <= S_add_membrane_decay_cycle_6;

    when S_add_membrane_decay_cycle_6 =>
        S_layer_Next_State <= S_layer_membrane_reg_wr;    
    
    when S_layer_membrane_reg_wr =>
        S_layer_Next_State <= S_layer_spike_update; 
    
    when S_layer_spike_update =>
        S_layer_Next_State <= S_layer_spike_regs_en; 
    
    when S_layer_spike_regs_en =>
        S_Layer_Next_State <= S_layer_check_output_layer_ready;
    
    when S_layer_check_output_layer_ready =>
        if (output_layer_ready_i = '1') then
            S_layer_Next_State <= S_layer_subtract_threshold; 
        else
            S_layer_Next_State <= S_layer_check_output_layer_ready; 
        end if;

    when S_layer_subtract_threshold =>
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
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '1';
    spikes_ready_o         <= '0';

when S_add_weights_muxes_cycle_0 =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';

when S_add_weights_cycle_1 =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';

when S_add_weights_cycle_2 =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';

when S_add_weights_cycle_3 =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';

when S_add_weights_cycle_4 =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';
                         
when S_add_bias_cycle_5 =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';

when S_add_membrane_decay_cycle_6 =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';

when S_layer_membrane_reg_wr =>
    neuron_membrane_reg_wr <= '1';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';
   
when S_layer_spike_update =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '1';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';

when S_layer_spike_regs_en =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '1';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '1';

when S_layer_check_output_layer_ready =>
    neuron_membrane_reg_wr <= '0';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '0';
    sub_threshold_mux_sel  <= '0';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';
            
when S_layer_subtract_threshold =>
    neuron_membrane_reg_wr <= '1';
    neuron_spike_ffs_wr    <= '0';
    layer_spikes_reg_en    <= '0';
    trigger_output_layer   <= '1';
    sub_threshold_mux_sel  <= '1';
    layer_ready_o          <= '0';
    spikes_ready_o         <= '0';
           
end case;

end Process;

output_layer_trigger_o <= trigger_output_layer;
-----------------------------------------------------------------------------------------------------------------

end Behavioral;
