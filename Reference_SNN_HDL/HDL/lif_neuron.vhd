library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

library work;
use work.SNN_package.all;

entity lif_neuron is
Generic (g_num_layer_inputs : integer;          --number of inputs connected to neuron   
         g_num_beta_shifts  : integer;          --number of right shifts for beta decay
         g_neuron_index     : integer;          --neuron index number in layer 
         g_neuron_weights_file_path : string;   --file path to initialise neuron weights
         g_neuron_bias_file_path    : string;   --file path to initialise neuron biases
         g_neuron_threshold_file_path : string  --file path to initialise neuron threshold
);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      membrane_reg_wr_i : in std_logic;
      spike_ff_rst_i    : in std_logic;
      spike_ff_wr_i : in std_logic;
      mux_sels_i    : in std_logic_vector(1 downto 0);
      weight_addr_i : in unsigned(f_log2(g_num_layer_inputs)-1 downto 0);
      spike_i       : in std_logic;
      spike_o       : out std_logic      
);
end lif_neuron;

architecture Behavioral of lif_neuron is

signal bias_data : std_logic_vector(neuron_bit_width downto 0);    
signal bias      : std_logic_vector(neuron_bit_width-1 downto 0);              
signal bias_MSB  : std_logic;

signal weight_mem_data_out : std_logic_vector(neuron_bit_width downto 0);    
signal weight : std_logic_vector(neuron_bit_width-1 downto 0);          
signal weight_MSB  : std_logic;
signal weight_mux  : std_logic_vector(neuron_bit_width-1 downto 0);

signal membrane_reg : std_logic_vector(neuron_bit_width-1 downto 0);
signal membrane_shifted : std_logic_vector(neuron_bit_width-1 downto 0);            
signal membrane_reg_wr_en : std_logic;            

signal adder_opA, adder_opB : std_logic_vector(neuron_bit_width-1 downto 0);        

signal opB_mux_sel : std_logic_vector(1 downto 0);

signal add_sub_mux_sel : std_logic_vector(1 downto 0);

signal threshold_mux : std_logic_vector(neuron_bit_width-1 downto 0); 
signal threshold : std_logic_vector(neuron_bit_width-1 downto 0);

signal comparator_output : std_logic;

signal adder_result : std_logic_vector(neuron_bit_width-1 downto 0);             

signal add_sub : std_logic;

signal spike_ff_rst   : std_logic;
signal spike_ff_wr_en : std_logic;
signal spike_ff    : std_logic;

constant bias_value : bv_array := InitBVArrayFromFile(g_neuron_bias_file_path);

constant threshold_value : bv_array := InitBVArrayFromFile(g_neuron_threshold_file_path);

begin

--- entity inputs to internal signal assignments --------------------------------------------------------------
membrane_reg_wr_en <= membrane_reg_wr_i;

spike_ff_rst <= spike_ff_rst_i;
spike_ff_wr_en <= spike_ff_wr_i;

opB_mux_sel <= mux_sels_i;
add_sub_mux_sel <= mux_sels_i;
---------------------------------------------------------------------------------------------------------------

--- weights memory --------------------------------------------------------------------------------------------
synapse_weight_mem : synapse_weights
generic map (g_num_layer_inputs => g_num_layer_inputs,
             g_file_path => g_neuron_weights_file_path)
port map (clk_i  => clk_i,
          we_i   => '0',
          addr_i => weight_addr_i,
          di_i   => (others => '0'),
          do_o   => weight_mem_data_out
        );

weight <= weight_mem_data_out(neuron_bit_width-1 downto 0);
weight_MSB <= weight_mem_data_out(neuron_bit_width);
---------------------------------------------------------------------------------------------------------------

--- bias assignment -------------------------------------------------------------------------------------------
bias_data <= to_stdlogicvector(bias_value(0)(neuron_bit_width downto 0));

bias <= bias_data(neuron_bit_width-1 downto 0);
bias_MSB <= bias_data(neuron_bit_width);
---------------------------------------------------------------------------------------------------------------

--- synapse weight input spike mux ----------------------------------------------------------------------------
weight_mux <= weight when (spike_i = '1') else (others => '0');     
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

--- threshold assignment --------------------------------------------------------------------------------------
threshold <= to_stdlogicvector(threshold_value(0)(neuron_bit_width-1 downto 0));
---------------------------------------------------------------------------------------------------------------

--- threshold mux ---------------------------------------------------------------------------------------------
threshold_mux <= threshold when (spike_ff = '1') else (others => '0');     
---------------------------------------------------------------------------------------------------------------

--- adder operands muxes --------------------------------------------------------------------------------------
adder_opA <= membrane_reg;

adder_opB <= membrane_shifted when opB_mux_sel = "00" else 
             weight_mux       when opB_mux_sel = "01" else 
             bias             when opB_mux_sel = "10" else             
             threshold_mux;
----------------------------------------------------------------------------------------------------------------

--- adder add or subtract mux ----------------------------------------------------------------------------------
add_sub <= '1'        when add_sub_mux_sel = "00" else 
           weight_MSB when add_sub_mux_sel = "01" else 
           bias_MSB   when add_sub_mux_sel = "10" else             
           '1';                                            
----------------------------------------------------------------------------------------------------------------
 
--- adder ------------------------------------------------------------------------------------------------------
adder_result <= std_logic_vector(unsigned(adder_opA) + unsigned(adder_opB)) when add_sub = '0' else
                std_logic_vector(unsigned(adder_opA) - unsigned(adder_opB)); 
----------------------------------------------------------------------------------------------------------------
 
--- membrane register ------------------------------------------------------------------------------------------
Process(clk_i, rstn_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then
        membrane_reg <= (others => '0');
    elsif (membrane_reg_wr_en = '1') then
            membrane_reg <= adder_result;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- 32-bit signed comparator ----------------------------------------------------------------------------------
Process(membrane_reg, threshold)

begin
if (signed(membrane_reg) > signed(threshold)) then                                                                              
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
    if (rstn_i = '0' or spike_ff_rst = '1') then
        spike_ff <= '0';
    elsif (spike_ff_wr_en = '1') then
        spike_ff <= comparator_output;
    end if;
end if;

end Process;

spike_o <= spike_ff;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
