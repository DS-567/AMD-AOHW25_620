
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

package SNN_package is

constant neuron_bit_width : natural := 24; --number of total fixed point bits for neuron computation (10 integer + 14 fractional)

type natural_array is array (natural range <>) of natural; --array of naturals for defining layer(s) dimensions

type bv_array is array (0 to 0) of bit_vector(neuron_bit_width-1 downto 0); -- array (size of 1) of an integer for defining neuron bias / threshold

type hidden_weights_array is array (0 to 15) of bit_vector(neuron_bit_width-1 downto 0);

type output_weights_array is array (0 to 19) of bit_vector(neuron_bit_width-1 downto 0);

function f_log2 (x : positive) return natural;

function f_max_val_in_array (input : natural_array) return natural;

function f_swap_bits (input : std_logic_vector) return std_logic_vector;

function f_or_logic(input : std_logic_vector) return std_logic;

function f_last_val_in_array (input : natural_array) return natural;

impure function InitBVArrayFromFile(RamFileName : in string) return bv_array;

impure function InitHiddenWeightsArrayFromFile(RamFileName : in string) return hidden_weights_array;

impure function InitOutputWeightsArrayFromFile(RamFileName : in string) return output_weights_array;


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
Generic(g_SNN_layer_sizes : natural_array; --number of layers / layer sizes in network
        g_num_timesteps   : natural;       --number of timesteps to stimulate network
        g_num_beta_shifts : natural;       --number of right shifts for beta decay
        g_setup_file_path : string);       --base file path to access the network parameters
Port (clk_i   : in std_logic;
      rstn_i  : in std_logic;
      fifo_empty_i : in std_logic;
      fifo_rd_valid_i : in std_logic;
      fifo_data_i : in std_logic_vector(163 downto 0);
      fifo_rd_en_o : out std_logic;
      SNN_done_o   : out std_logic;
      SNN_class_zero_o : out std_logic;
      SNN_class_one_o : out std_logic;
      watchdog_ready_o : out std_logic;
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
      

component neorv32_ProcessorTop_Minimal is
  generic (
    -- Fault Injection Setup Modifications --
    NUM_RESULT_DATA_VALUES : natural := 45; -- bubble sort = 25, fibonacci series = 45, matrix multiplication = 16 (compile code too!)
    -- General --
    CLOCK_FREQUENCY   : natural := 100_000_000; -- clock frequency of clk_i in Hz
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN   : boolean := true;    -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE : natural := 8*1024;  -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN   : boolean := true;    -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE : natural := 16*1024; -- size of processor-internal data memory in bytes
    REGFILE_HW_RST    : boolean := true 
    -- Processor peripherals --
  );
  port (
    -- Global control --
    clk_i  : in  std_logic;
    rstn_i : in  std_logic; 
    FIL_four_to_one_mux_selects_i : in std_logic_vector(20 downto 1);
    program_counter_o          : out std_ulogic_vector(31 downto 0);
    dmem_transfer_trigger_i    : in std_logic;
    dmem_reset_trigger_i       : in std_logic;
    result_data_wr_address_o   : out std_ulogic_vector(5 downto 0);
    dmem_to_result_data_o      : out std_ulogic_vector(31 downto 0);
    result_data_mem_wr_pulse_o : out std_logic;
    dmem_transfer_done_o       : out std_logic;
    dmem_reset_done_o          : out std_logic;
    neorv32_pc_we_o            : out std_logic;
    instruction_register_o     : out std_ulogic_vector(31 downto 0);
    neorv32_execute_states_o   : out std_logic_vector(3 downto 0);
    neorv32_branch_taken_o     : out std_logic;
    mcause_reg_o               : out std_ulogic_vector(5 downto 0);
    mepc_reg_o                 : out std_ulogic_vector(31 downto 0);
    mtvec_reg_o                : out std_ulogic_vector(31 downto 0);
    rs1_reg_o                  : out std_ulogic_vector(31 downto 0);
    alu_comp_status_o          : out std_ulogic_vector(1 downto 0);
    ctrl_bus_o                 : out std_ulogic_vector(60 downto 0)
  );
end component;


component setup_regs is
  Port (clk_i                  : in std_logic;
        rstn_i                 : in std_logic;
        uBlaze_data_i          : in std_logic_vector(22 downto 0);
        setup_regs_data_o      : out std_logic_vector(15 downto 0);
        application_run_time_o : out std_logic_vector(15 downto 0);
        stuck_at_hold_time_o   : out std_logic_vector(15 downto 0);
        spare_reg_o            : out std_logic_vector(15 downto 0);
        fault_injection_en_o   : out std_logic_vector(0 downto 0);
        bit_1_data_o           : out std_logic_vector(53 downto 0);
        bit_2_data_o           : out std_logic_vector(53 downto 0);
        bit_3_data_o           : out std_logic_vector(53 downto 0);
        bit_4_data_o           : out std_logic_vector(53 downto 0);
        bit_5_data_o           : out std_logic_vector(53 downto 0);
        bit_6_data_o           : out std_logic_vector(53 downto 0);
        bit_7_data_o           : out std_logic_vector(53 downto 0);
        bit_8_data_o           : out std_logic_vector(53 downto 0);
        bit_9_data_o           : out std_logic_vector(53 downto 0);
        bit_10_data_o          : out std_logic_vector(53 downto 0)
       );
end component;


component eight_to_one_mux_setup_regs is
  Port (data_zero_i   : in std_logic_vector(15 downto 0);
        data_one_i    : in std_logic_vector(15 downto 0);
        data_two_i    : in std_logic_vector(15 downto 0);
        data_three_i  : in std_logic_vector(15 downto 0);
        data_four_i   : in std_logic_vector(15 downto 0);
        data_five_i   : in std_logic_vector(15 downto 0);
        data_six_i    : in std_logic_vector(15 downto 0);
        data_seven_i  : in std_logic_vector(15 downto 0);
        sel_i         : in std_logic_vector(2 downto 0);
        data_o        : out std_logic_vector(15 downto 0)
       );
end component;


component address_wr_decoder is
  Port (clk_100MHz_i     : in std_logic;
        rstn_i           : in std_logic;
        wr_en_i          : in std_logic;
        addr_i           : in std_logic_vector(5 downto 0);    
        decoded_reg_en_o : out std_logic_vector(63 downto 0)   
       );
end component;


component D_type_ff_reg is 
generic(bit_width    : integer := 1);
  Port (clk_100MHz_i : in std_logic;
        rstn_i       : in std_logic;
        wr_en_i      : in std_logic;
        data_i       : in std_logic_vector(bit_width-1 downto 0);
        data_o       : out std_logic_vector(bit_width-1 downto 0)
       );
end component;


component bit_fault_controller is
  Port (clk_i                 : in std_logic;
        rstn_i                : in std_logic; 
        bit_fault_inj_en_i    : in std_logic;   
        count_value_i         : in std_logic_vector(31 downto 0); 
        stuck_at_hold_time_i  : in std_logic_vector(15 downto 0); 
        bit_setup_reg_i       : in std_logic_vector(53 downto 0); 
        neorv32_pc_we_i       : in std_logic;
        four_to_one_mux_sel_o : out std_logic_vector(1 downto 0)
       );
end component;


component fast_SNN is
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
end component;


component input_layer is
Generic (g_num_inputs : natural;    --number of inputs in layer
         g_num_timesteps : natural  --number of timesteps to stimulate network
        );
Port (clk_i    : in std_logic;
      rstn_i   : in std_logic;
      data_sample_i : in std_logic_vector(g_num_inputs-1 downto 0);
      timestep_counter_i : in unsigned(f_log2(g_num_timesteps)-1 downto 0);
      spikes_o : out std_logic_vector(g_num_inputs-1 downto 0)
     );
end component;


component two_to_one_mux is
Generic (g_mux_width : natural);
Port (freq_low_i   : std_logic_vector(g_mux_width-1 downto 0);
      freq_high_i  : std_logic_vector(g_mux_width-1 downto 0);
      sel_i        : in std_logic;
      freq_o       : out std_logic_vector(g_mux_width-1 downto 0)
     );
end component;


component hidden_layer is
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
end component;


component hidden_neuron is
Generic (g_num_inputs : natural;                --number of inputs connected to the neuron
         g_num_beta_shifts : natural;           --number of right shifts for beta decay
         g_neuron_index : natural;              --neuron index number in layer 
         g_neuron_weights_file_path : string;   --file path to initialise neuron weights
         g_neuron_bias_file_path : string;      --file path to initialise neuron biases
         g_neuron_threshold_file_path : string  --file path to initialise neuron threshold
        );
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      spikes_i : in std_logic_vector(15 downto 0);
      sub_threshold_mux_sel_i : in std_logic;
      membrane_reg_wr_i : in std_logic;
      spike_ff_wr_i : in std_logic;
      spike_o : out std_logic      
     );
end component;


component output_layer is
Generic (g_num_inputs : natural;       --number of inputs in layer
         g_num_neurons : natural;      --number of neurons in layer
         g_num_beta_shifts : natural;  --number of right shifts for beta decay
         g_file_path : string          --layer file path
        );
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      trigger_i : in std_logic;
      spikes_i : in std_logic_vector(g_num_inputs-1 downto 0);
      spikes_o : out std_logic_vector(g_num_neurons-1 downto 0);
      layer_ready_o : out std_logic;
      spikes_ready_o : out std_logic
     );
end component;


component output_neuron is
Generic (g_num_inputs : natural;                --number of inputs connected to the neuron
         g_num_beta_shifts : natural;           --number of right shifts for beta decay
         g_neuron_index : natural;              --neuron index number in layer 
         g_neuron_weights_file_path : string;   --file path to initialise neuron weights
         g_neuron_bias_file_path : string;      --file path to initialise neuron biases
         g_neuron_threshold_file_path : string  --file path to initialise neuron threshold
        );
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      spikes_i : in std_logic_vector(19 downto 0);
      sub_threshold_mux_sel_i : in std_logic;
      membrane_reg_wr_i : in std_logic;
      spike_ff_wr_i : in std_logic;
      spike_o : out std_logic      
     );
end component;


component beta_shifter is
Generic (g_num_beta_shifts : natural);         
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      membrane_i : in std_logic_vector(neuron_bit_width-1 downto 0);
      membrane_o : out std_logic_vector(neuron_bit_width-1 downto 0)
      );
end component;


component pulse_generator is
Port (clk_i   : in std_logic;
      rstn_i  : in std_logic;
      bit_i   : in std_logic;
      pulse_o : out std_logic             
     );
end component;


component input_debouncer is
  Generic (g_debounce_threshold : natural);
Port (clk_i  : in std_logic;
      bit_i  : in std_logic;
      bit_o  : out std_logic
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


function f_max_val_in_array (input : natural_array) return natural is
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


function f_last_val_in_array (input : natural_array) return natural is
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


impure function InitHiddenWeightsArrayFromFile(RamFileName : in string) return hidden_weights_array is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable text_data : hidden_weights_array;
begin
for i in hidden_weights_array'range loop
readline(RamFile, RamFileLine);
read(RamFileLine, text_data(i));
end loop;
return text_data;
end function;


impure function InitOutputWeightsArrayFromFile(RamFileName : in string) return output_weights_array is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable text_data : output_weights_array;
begin
for i in output_weights_array'range loop
readline(RamFile, RamFileLine);
read(RamFileLine, text_data(i));
end loop;
return text_data;
end function;


end package body;
