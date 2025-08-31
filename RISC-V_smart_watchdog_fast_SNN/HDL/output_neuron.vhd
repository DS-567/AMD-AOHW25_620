library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

library work;
use work.SNN_package.all;

entity output_neuron is
Generic (g_num_inputs : natural;                --number of inputs connected to the neuron
         g_num_beta_shifts : natural;           --number of right shifts for beta decay
         g_neuron_index : natural;              --neuron index number in layer 
         g_neuron_weights_file_path : string;   --file path to initialise neuron weights
         g_neuron_bias_file_path : string;      --file path to initialise neuron biases
         g_neuron_threshold_file_path : string  --file path to initialise neuron threshold
);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      spikes_i : in std_logic_vector(g_num_inputs-1 downto 0);
      sub_threshold_mux_sel_i : in std_logic;
      membrane_reg_wr_i : in std_logic;
      spike_ff_wr_i : in std_logic;
      spike_o : out std_logic      
);
end output_neuron;

architecture Behavioral of output_neuron is

constant weights : output_weights_array := InitOutputWeightsArrayFromFile(g_neuron_weights_file_path);

constant bias_value : bv_array := InitBVArrayFromFile(g_neuron_bias_file_path);

constant threshold_value : bv_array := InitBVArrayFromFile(g_neuron_threshold_file_path);

signal bias_slv : std_logic_vector(neuron_bit_width-1 downto 0);

signal threshold_slv : std_logic_vector(neuron_bit_width-1 downto 0);


signal weight_mux_0  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_1  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_2  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_3  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_4  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_5  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_6  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_7  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_8  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_9  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_10 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_11 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_12 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_13 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_14 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_15 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_16 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_17 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_18 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_19 : std_logic_vector(neuron_bit_width-1 downto 0);

signal weight_mux_reg_0  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_1  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_2  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_3  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_4  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_5  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_6  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_7  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_8  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_9  : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_10 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_11 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_12 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_13 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_14 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_15 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_16 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_17 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_18 : std_logic_vector(neuron_bit_width-1 downto 0);
signal weight_mux_reg_19 : std_logic_vector(neuron_bit_width-1 downto 0);

signal adder_weights_cycle_1_reg_0 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_1 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_2 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_3 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_4 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_5 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_6 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_7 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_8 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_1_reg_9 : std_logic_vector(neuron_bit_width-1 downto 0);

signal adder_weights_cycle_2_reg_0 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_2_reg_1 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_2_reg_2 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_2_reg_3 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_2_reg_4 : std_logic_vector(neuron_bit_width-1 downto 0);

signal adder_weights_cycle_3_reg_0 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_3_reg_1 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_3_reg_2 : std_logic_vector(neuron_bit_width-1 downto 0);

signal adder_weights_cycle_4_reg_0 : std_logic_vector(neuron_bit_width-1 downto 0);
signal adder_weights_cycle_4_reg_1 : std_logic_vector(neuron_bit_width-1 downto 0);

signal adder_cycle_5_reg : std_logic_vector(neuron_bit_width-1 downto 0);

signal synapse_current : std_logic_vector(neuron_bit_width-1 downto 0);

signal membrane_reg_data_mux : std_logic_vector(neuron_bit_width-1 downto 0);           

signal membrane_reg : std_logic_vector(neuron_bit_width-1 downto 0);           
signal membrane_reg_wr_en : std_logic;            

signal membrane_shifted : std_logic_vector(neuron_bit_width-1 downto 0); 

signal membrane_decay_sub_res_reg : std_logic_vector(neuron_bit_width-1 downto 0); 

signal threshold_mux : std_logic_vector(neuron_bit_width-1 downto 0); 

signal threshold_sub_res_reg : std_logic_vector(neuron_bit_width-1 downto 0);

signal sub_threshold_mux_sel : std_logic;

signal comparator_output : std_logic;

signal spike_ff_wr_en : std_logic;
signal spike_ff : std_logic;

begin

--- entity inputs to internal signal assignments --------------------------------------------------------------
membrane_reg_wr_en <= membrane_reg_wr_i;

spike_ff_wr_en <= spike_ff_wr_i;

sub_threshold_mux_sel <= sub_threshold_mux_sel_i;
---------------------------------------------------------------------------------------------------------------

--- threshold assignment --------------------------------------------------------------------------------------
threshold_slv <= to_stdlogicvector(threshold_value(0));
---------------------------------------------------------------------------------------------------------------

bias_slv <= to_stdlogicvector(bias_value(0));

--- weight spike muxes registers ------------------------------------------------------------------------------
weight_mux_0  <= to_stdlogicvector(weights(0))  when (spikes_i(0) = '1')  else (others => '0');
weight_mux_1  <= to_stdlogicvector(weights(1))  when (spikes_i(1) = '1')  else (others => '0');
weight_mux_2  <= to_stdlogicvector(weights(2))  when (spikes_i(2) = '1')  else (others => '0');
weight_mux_3  <= to_stdlogicvector(weights(3))  when (spikes_i(3) = '1')  else (others => '0');
weight_mux_4  <= to_stdlogicvector(weights(4))  when (spikes_i(4) = '1')  else (others => '0');
weight_mux_5  <= to_stdlogicvector(weights(5))  when (spikes_i(5) = '1')  else (others => '0');
weight_mux_6  <= to_stdlogicvector(weights(6))  when (spikes_i(6) = '1')  else (others => '0');
weight_mux_7  <= to_stdlogicvector(weights(7))  when (spikes_i(7) = '1')  else (others => '0');
weight_mux_8  <= to_stdlogicvector(weights(8))  when (spikes_i(8) = '1')  else (others => '0');
weight_mux_9  <= to_stdlogicvector(weights(9))  when (spikes_i(9) = '1')  else (others => '0');
weight_mux_10 <= to_stdlogicvector(weights(10)) when (spikes_i(10) = '1') else (others => '0');
weight_mux_11 <= to_stdlogicvector(weights(11)) when (spikes_i(11) = '1') else (others => '0');
weight_mux_12 <= to_stdlogicvector(weights(12)) when (spikes_i(12) = '1') else (others => '0');
weight_mux_13 <= to_stdlogicvector(weights(13)) when (spikes_i(13) = '1') else (others => '0');
weight_mux_14 <= to_stdlogicvector(weights(14)) when (spikes_i(14) = '1') else (others => '0');
weight_mux_15 <= to_stdlogicvector(weights(15)) when (spikes_i(15) = '1') else (others => '0');
weight_mux_16 <= to_stdlogicvector(weights(16)) when (spikes_i(16) = '1') else (others => '0');
weight_mux_17 <= to_stdlogicvector(weights(17)) when (spikes_i(17) = '1') else (others => '0');
weight_mux_18 <= to_stdlogicvector(weights(18)) when (spikes_i(18) = '1') else (others => '0');
weight_mux_19 <= to_stdlogicvector(weights(19)) when (spikes_i(19) = '1') else (others => '0');
---------------------------------------------------------------------------------------------------------------

--- weight spike muxes cycle 0 registers ----------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then 
        weight_mux_reg_0  <= (others => '0');
        weight_mux_reg_1  <= (others => '0');
        weight_mux_reg_2  <= (others => '0');
        weight_mux_reg_3  <= (others => '0');
        weight_mux_reg_4  <= (others => '0');
        weight_mux_reg_5  <= (others => '0');
        weight_mux_reg_6  <= (others => '0');
        weight_mux_reg_7  <= (others => '0');
        weight_mux_reg_8  <= (others => '0');
        weight_mux_reg_9  <= (others => '0');
        weight_mux_reg_10 <= (others => '0');
        weight_mux_reg_11 <= (others => '0');
        weight_mux_reg_12 <= (others => '0');
        weight_mux_reg_13 <= (others => '0');
        weight_mux_reg_14 <= (others => '0');
        weight_mux_reg_15 <= (others => '0');
        weight_mux_reg_16 <= (others => '0');
        weight_mux_reg_17 <= (others => '0');
        weight_mux_reg_18 <= (others => '0');
        weight_mux_reg_19 <= (others => '0');
        
    else
        weight_mux_reg_0  <= weight_mux_0; 
        weight_mux_reg_1  <= weight_mux_1; 
        weight_mux_reg_2  <= weight_mux_2; 
        weight_mux_reg_3  <= weight_mux_3; 
        weight_mux_reg_4  <= weight_mux_4; 
        weight_mux_reg_5  <= weight_mux_5; 
        weight_mux_reg_6  <= weight_mux_6; 
        weight_mux_reg_7  <= weight_mux_7; 
        weight_mux_reg_8  <= weight_mux_8; 
        weight_mux_reg_9  <= weight_mux_9; 
        weight_mux_reg_10 <= weight_mux_10; 
        weight_mux_reg_11 <= weight_mux_11; 
        weight_mux_reg_12 <= weight_mux_12; 
        weight_mux_reg_13 <= weight_mux_13; 
        weight_mux_reg_14 <= weight_mux_14; 
        weight_mux_reg_15 <= weight_mux_15; 
        weight_mux_reg_16 <= weight_mux_16; 
        weight_mux_reg_17 <= weight_mux_17; 
        weight_mux_reg_18 <= weight_mux_18; 
        weight_mux_reg_19 <= weight_mux_19; 
                
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- weight adders cycle 1 registers ---------------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then 
        adder_weights_cycle_1_reg_0 <= (others => '0');
        adder_weights_cycle_1_reg_1 <= (others => '0');
        adder_weights_cycle_1_reg_2 <= (others => '0');
        adder_weights_cycle_1_reg_3 <= (others => '0');
        adder_weights_cycle_1_reg_4 <= (others => '0');
        adder_weights_cycle_1_reg_5 <= (others => '0');
        adder_weights_cycle_1_reg_6 <= (others => '0');
        adder_weights_cycle_1_reg_7 <= (others => '0');
        adder_weights_cycle_1_reg_8 <= (others => '0');        
        adder_weights_cycle_1_reg_9 <= (others => '0');   
    else
        adder_weights_cycle_1_reg_0 <= std_logic_vector(signed(weight_mux_reg_0) + signed(weight_mux_reg_1));
        adder_weights_cycle_1_reg_1 <= std_logic_vector(signed(weight_mux_reg_2) + signed(weight_mux_reg_3));
        adder_weights_cycle_1_reg_2 <= std_logic_vector(signed(weight_mux_reg_4) + signed(weight_mux_reg_5));
        adder_weights_cycle_1_reg_3 <= std_logic_vector(signed(weight_mux_reg_6) + signed(weight_mux_reg_7));
        adder_weights_cycle_1_reg_4 <= std_logic_vector(signed(weight_mux_reg_8) + signed(weight_mux_reg_9));
        adder_weights_cycle_1_reg_5 <= std_logic_vector(signed(weight_mux_reg_10) + signed(weight_mux_reg_11));
        adder_weights_cycle_1_reg_6 <= std_logic_vector(signed(weight_mux_reg_12) + signed(weight_mux_reg_13));
        adder_weights_cycle_1_reg_7 <= std_logic_vector(signed(weight_mux_reg_14) + signed(weight_mux_reg_15));
        adder_weights_cycle_1_reg_8 <= std_logic_vector(signed(weight_mux_reg_16) + signed(weight_mux_reg_17));
        adder_weights_cycle_1_reg_9 <= std_logic_vector(signed(weight_mux_reg_18) + signed(weight_mux_reg_19));
    
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- weight adders cycle 2 registers ---------------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then 
        adder_weights_cycle_2_reg_0 <= (others => '0');
        adder_weights_cycle_2_reg_1 <= (others => '0');
        adder_weights_cycle_2_reg_2 <= (others => '0');
        adder_weights_cycle_2_reg_3 <= (others => '0');
        adder_weights_cycle_2_reg_4 <= (others => '0');
        
    else
        adder_weights_cycle_2_reg_0 <= std_logic_vector(signed(adder_weights_cycle_1_reg_0) + signed(adder_weights_cycle_1_reg_1));
        adder_weights_cycle_2_reg_1 <= std_logic_vector(signed(adder_weights_cycle_1_reg_2) + signed(adder_weights_cycle_1_reg_3));
        adder_weights_cycle_2_reg_2 <= std_logic_vector(signed(adder_weights_cycle_1_reg_4) + signed(adder_weights_cycle_1_reg_5));
        adder_weights_cycle_2_reg_3 <= std_logic_vector(signed(adder_weights_cycle_1_reg_6) + signed(adder_weights_cycle_1_reg_7));
        adder_weights_cycle_2_reg_4 <= std_logic_vector(signed(adder_weights_cycle_1_reg_8) + signed(adder_weights_cycle_1_reg_9));
    
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- weight adders and bias cycle 3 registers ------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then 
        adder_weights_cycle_3_reg_0 <= (others => '0');
        adder_weights_cycle_3_reg_1 <= (others => '0');
        adder_weights_cycle_3_reg_2 <= (others => '0');
        
    else
        adder_weights_cycle_3_reg_0 <= std_logic_vector(signed(adder_weights_cycle_2_reg_0) + signed(adder_weights_cycle_2_reg_1));
        adder_weights_cycle_3_reg_1 <= std_logic_vector(signed(adder_weights_cycle_2_reg_2) + signed(adder_weights_cycle_2_reg_3));
        adder_weights_cycle_3_reg_2 <= std_logic_vector(signed(adder_weights_cycle_2_reg_4) + signed(bias_slv));
         
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- weight adders, bias and membrane decay cycle 4 register ---------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then 
        adder_weights_cycle_4_reg_0 <= (others => '0');
        adder_weights_cycle_4_reg_1 <= (others => '0');
        
    else
        adder_weights_cycle_4_reg_0 <= std_logic_vector(signed(adder_weights_cycle_3_reg_0) + signed(adder_weights_cycle_3_reg_1));
        adder_weights_cycle_4_reg_1 <= std_logic_vector(signed(adder_weights_cycle_3_reg_2) + signed(membrane_decay_sub_res_reg));
        
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- membrane decay cycle 5 register ---------------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then 
        adder_cycle_5_reg <= (others => '0');
        
    else
        adder_cycle_5_reg <= std_logic_vector(signed(adder_weights_cycle_4_reg_0) + signed(adder_weights_cycle_4_reg_1));

    end if;
end if;

end Process;

synapse_current <= adder_cycle_5_reg;
---------------------------------------------------------------------------------------------------------------

 --- membrane potential register data in mux ------------------------------------------------------------------
membrane_reg_data_mux <= synapse_current when sub_threshold_mux_sel = '0' else threshold_sub_res_reg;
---------------------------------------------------------------------------------------------------------------

--- membrane potential register -------------------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
   if (rstn_i = '0') then
       membrane_reg <= (others => '0');
   elsif (membrane_reg_wr_en = '1') then
           membrane_reg <= membrane_reg_data_mux;
   end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- membrane data shifter -------------------------------------------------------------------------------------
membrane_decay : beta_shifter generic map
(g_num_beta_shifts => g_num_beta_shifts)        
port map 
(clk_i      => clk_i,
 rstn_i     => rstn_i,
 membrane_i => membrane_reg,
 membrane_o => membrane_shifted
);
---------------------------------------------------------------------------------------------------------------

--- membrane decay sub result register ------------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
   if (rstn_i = '0') then
       membrane_decay_sub_res_reg <= (others => '0');
   else
       membrane_decay_sub_res_reg <= std_logic_vector(signed(membrane_reg) - signed(membrane_shifted));   
   end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- threshold mux ---------------------------------------------------------------------------------------------
threshold_mux <= threshold_slv when (spike_ff = '1') else (others => '0');     
---------------------------------------------------------------------------------------------------------------

--- threshold sub result register -----------------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
   if (rstn_i = '0') then
       threshold_sub_res_reg <= (others => '0');
   else
       threshold_sub_res_reg <= std_logic_vector(signed(membrane_reg) - signed(threshold_mux));   
   end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- signed comparator -----------------------------------------------------------------------------------------
Process(membrane_reg, threshold_slv)

begin
if (signed(membrane_reg) > signed(threshold_slv)) then                                                                              
    comparator_output <= '1';
else
    comparator_output <= '0';
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- neuron spike output register ------------------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then
        spike_ff <= '0';
    elsif (spike_ff_wr_en = '1') then
        spike_ff <= comparator_output;
    end if;
end if;

end Process;

spike_o <= spike_ff;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
