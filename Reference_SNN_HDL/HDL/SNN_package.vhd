
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

package SNN_package is

constant neuron_bit_width : natural := 24; --number of total fixed point bits for neuron computation (10 integer + 14 fractional)

type integer_array is array (natural range <>) of integer; --array of integers for defining layer(s) dimensions

type bv_array is array (0 to 0) of bit_vector(neuron_bit_width downto 0); -- array (size of 1) of an integer for defining neuron bias / threshold

type WeightsType is array (natural range <>) of bit_vector(neuron_bit_width downto 0);

function f_log2 (x : positive) return natural;

function f_max_val_in_array (input : integer_array) return natural;

function f_swap_bits (input : std_logic_vector) return std_logic_vector;

function f_or_logic(input : std_logic_vector) return std_logic;

function f_last_val_in_array (input : integer_array) return natural;

impure function InitBVArrayFromFile(RamFileName : in string) return bv_array;

component clk_wiz_0
port
(-- Clock in ports
-- Clock out ports
clk_out1  : out    std_logic;
clk_in1_p : in     std_logic;
clk_in1_n : in     std_logic
);
end component;

component watchdog_2 is
Generic(g_num_features : natural;
        g_SNN_layer_sizes : integer_array; --number of layers / layer sizes in network
        g_num_timesteps   : integer;       --number of timesteps to stimulate network
        g_num_beta_shifts : integer;       --number of right shifts for beta decay
        g_setup_file_path : string);       --base file path to access the network parameters
Port (clk_i   : in std_logic;
      rstn_i  : in std_logic;
      trigger_pulse_i : in std_logic;
      fifo_empty_i : in std_logic;
      fifo_rd_valid_i : in std_logic;
      fifo_data_i : in std_logic_vector(163 downto 0);
      fifo_rd_en_o : out std_logic;
      SNN_done_o   : out std_logic;
      SNN_class_zero_o : out std_logic;
      SNN_class_one_o : out std_logic;
      watchdog_error_o : out std_logic
    );
end component;

component fifo_generator_0
  PORT (
    clk    : in std_logic;
    srst   : in std_logic;
    din    : in std_logic_vector(163 downto 0);
    wr_en  : in std_logic;
    rd_en  : in std_logic;
    dout   : out std_logic_vector(163 downto 0);
    full   : out std_logic;
    wr_ack : out std_logic;
    empty  : out std_logic;
    valid  : out std_logic 
  );
end component;

component feature_layer_2 is
Generic (g_num_features : natural);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      fifo_new_data_i : in std_logic;
      fifo_data_i : in std_logic_vector(163 downto 0);
      layer_features_reg_wr_i : in std_logic;
      layer_reset_i : in std_logic;
      instruction_executed_o : out std_logic;
      features_o : out std_logic_vector(g_num_features-1 downto 0)              
     );
end component;      
       
component feature_memory is
Generic(g_data_width : natural;
        g_num_data_values : natural;
        g_file_path : string);
port (clk_i  : in std_logic;
      we_i   : in std_logic;
      addr_i : in unsigned(f_log2(g_num_data_values)-1 downto 0);
      di_i   : in std_logic_vector(g_data_width-1 downto 0);
      do_o   : out std_logic_vector(g_data_width-1 downto 0)
     );
end component;

component SNN is
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
end component;

component input_layer is
Generic (g_num_inputs    : integer; --number of timesteps to stimulate network
         g_num_timesteps : integer  --number of inputs in network
        );
Port (clk_i    : in std_logic;
      rstn_i   : in std_logic;
      data_sample_i : in std_logic_vector(g_num_inputs-1 downto 0);
      timestep_counter_i : in unsigned(f_log2(g_num_timesteps)-1 downto 0);
      spikes_o : out std_logic_vector(g_num_inputs-1 downto 0)
     );
end component;

component lif_layer is
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
end component;

component lif_neuron is
Generic (g_num_layer_inputs : integer;          --number of connected to neuron
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
end component;

component synapse_weights is
Generic(g_num_layer_inputs : integer;         
        g_file_path : string);
Port (clk_i  : in std_logic;
      we_i   : in std_logic;
      addr_i : in unsigned(f_log2(g_num_layer_inputs)-1 downto 0);
      di_i   : in std_logic_vector(neuron_bit_width downto 0);
      do_o   : out std_logic_vector(neuron_bit_width downto 0)
     );
end component;          

component beta_shifter is
Generic (g_num_beta_shifts : integer);         
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      membrane_i : in std_logic_vector(neuron_bit_width-1 downto 0);
      membrane_o : out std_logic_vector(neuron_bit_width-1 downto 0)
      );
end component;
       
component two_to_one_mux is
Generic (g_mux_width : integer);
Port (freq_low_i   : std_logic_vector(g_mux_width-1 downto 0);
      freq_high_i  : std_logic_vector(g_mux_width-1 downto 0);
      sel_i        : in std_logic;
      freq_o       : out std_logic_vector(g_mux_width-1 downto 0)
     );
end component;
  
component output_decoder is   
Generic (g_num_outputs   : natural;
         g_num_timesteps : natural);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      trigger_i : in std_logic;
      output_spike_count_i : in std_logic_vector(f_log2(g_num_timesteps+1)-1 downto 0);  
      output_spike_count_index_o : out std_logic_vector(g_num_outputs-1 downto 0);
      class_regs_o : out std_logic_vector(g_num_outputs-1 downto 0);
      done_o : out std_logic
     );
end component;

component pulse_generator is
Port (clk_i   : in std_logic;
      rstn_i  : in std_logic;
      bit_i   : in std_logic;
      pulse_o : out std_logic             
     );
end component;

end package;

package body SNN_package is

function f_log2 (x : positive) return natural is
variable i : natural;
begin
i := 0;  
while (2**i < x) and i < 31 loop
    i := i + 1;
end loop;
return i;
end function;


function f_max_val_in_array (input : integer_array) return natural is
variable max_int_tmp : natural;
begin
max_int_tmp := 0;
for i in input'range loop
    if (input(i) > max_int_tmp) then
        max_int_tmp := input(i);
    end if;
end loop;
return max_int_tmp;
end function f_max_val_in_array;


function f_swap_bits (input : std_logic_vector) return std_logic_vector is
variable input_slv_pointer : natural;
variable slv_tmp : std_logic_vector(input'length-1 downto 0);
begin
input_slv_pointer := input'length;
slv_tmp := (others => '0');
for i in 0 to input'length-1 loop
    input_slv_pointer := input_slv_pointer - 1;
    slv_tmp(i) := input(input_slv_pointer);
end loop;
return slv_tmp;
end function f_swap_bits;


function f_or_logic(input : std_logic_vector) return std_logic is
variable tmp_v : std_logic;
begin
tmp_v := '0';
for i in input'range loop
    tmp_v := tmp_v or input(i);
end loop;
return tmp_v;
end function f_or_logic;


function f_last_val_in_array (input : integer_array) return natural is
variable array_len : natural;
variable last_array_val : natural;
begin
array_len := input'length;
last_array_val := input(array_len-1);
return last_array_val;
end function f_last_val_in_array;


impure function InitBVArrayFromFile(RamFileName : in string) return bv_array is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable text_data : bv_array;
begin
for i in bv_array'range loop
readline(RamFile, RamFileLine);
read(RamFileLine, text_data(i));
end loop;
return text_data;
end function;

end package body;
