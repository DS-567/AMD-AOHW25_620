
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity top_level is
  Generic(g_num_timesteps   : natural := 10;                 --number of timesteps to stimulate network
          g_num_beta_shifts : natural := 2;                  --number of right shifts for beta decay
          g_SNN_layer_sizes : natural_array := (16, 20, 2);  --number of layers / layer sizes in network
          g_setup_file_path : string := "C:/ip_repo_2/setup text files/Design 2 With Bias 20 Hidden Neurons/";
          g_fifo_delay_write_cycles : natural := 16);
          
  Port(clk_i : in std_logic;  --100MHz on-board clock
       rst_i : in std_logic;  --active high on-board push button (middle button on board)
       
       JB1_o : out std_logic;  -- 74HC165_CP clock output
       JB2_o : out std_logic;  -- 74HC165_PL parallel load output
       JB3_i : in std_logic;   -- 74HC165_DS input
       
       JB4_o : out std_logic;  -- 74AHCT595_SHCP clock output
       JB7_o : out std_logic;  -- 74AHCT595_STCP store output
       JB8_o : out std_logic;  -- 74AHCT595_DS data output
       
       seg_a_o, seg_b_o, seg_c_o, seg_d_o, seg_e_o, seg_f_o, seg_g_o : out std_logic;
       anode_0_o, anode_1_o, anode_2_o, anode_3_o : out std_logic; 
       anode_4_o, anode_5_o, anode_6_o, anode_7_o : out std_logic;
       
       JA1_o  : out std_logic; -- motor PWM signal
       JA2_o  : out std_logic; -- motor direction signal
               
       JC1_i  : in std_logic;  -- motor encoder ch A        
       JC2_i  : in std_logic;  -- motor encoder ch B        
               
       JD1_o  : out std_logic; -- motor reverse LED
       JD2_o  : out std_logic; -- motor forward LED
       JD3_o  : out std_logic; -- motor running LED 
       JD4_i  : in std_logic;  -- hand encoder ch B
       JD7_i  : in std_logic;  -- hand encoder ch A
       JD8_i  : in std_logic;  -- motor stop button
       JD9_i  : in std_logic;  -- motor start button
       JD10_i : in std_logic;  -- motor direction switch
       
       led0_o : out std_logic; -- system error led
       
       neorv32_buttons_from_uB_i : in std_logic_vector(5 downto 0);              -- neorv32 control buttons from uB (on Python GUI) to neorv32
       motor_setpoint_from_uB_i  : in std_logic_vector(15 downto 0);             -- motor setpoint RPM from uB (on Python GUI) to neorv32
       python_gui_control_from_uB_i : in std_logic_vector(14 downto 0);          -- python gui control buttons and led from uB (on Python GUI)
       
       motor_speeds_to_uB_o : out std_logic_vector(31 downto 0);                 -- motor setpoint and actual RPM to uB (for Python GUI)
       pc_bit_fault_type_counters_to_uB_o : out std_logic_vector(20 downto 1);   -- PC bit fault type counters to uB (for Python GUI)
       other_data_to_uB_o   : out std_logic_vector(9 downto 0);                  -- other data to uB (for Python GUI)      
       
       watchdog_data_from_uB_i : in std_logic_vector(1 downto 0);
       watchdog_data_to_uB_o : out std_logic_vector(5 downto 0);
       
       ir_data_o                   : out std_logic_vector(31 downto 0);
       pc_data_o                   : out std_logic_vector(31 downto 0);
       execute_states_data_o       : out std_logic_vector(3 downto 0);
       rs1_reg_data_o              : out std_logic_vector(31 downto 0);
       mtvec_data_o                : out std_logic_vector(31 downto 0);
       mepc_data_o                 : out std_logic_vector(31 downto 0);
       
       features_data_o             : out std_logic_vector(15 downto 0);
       
       mcause_data_o               : out std_logic_vector(5 downto 0);
       
       fifo_write_cycles_from_uB_i : in std_logic_vector(11 downto 0);
       fifo_write_cycles_to_uB_o   : out std_logic_vector(11 downto 0);
       
       input_neurons_2_to_0_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       input_neurons_5_to_3_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       input_neurons_8_to_6_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       input_neurons_11_to_9_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       input_neurons_14_to_12_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       input_neurons_15_spikes_to_uB_o : out std_logic_vector(10 downto 1);
       
       hidden_neurons_2_to_0_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       hidden_neurons_5_to_3_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       hidden_neurons_8_to_6_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       hidden_neurons_11_to_9_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       hidden_neurons_14_to_12_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       hidden_neurons_17_to_15_spikes_to_uB_o : out std_logic_vector(30 downto 1);
       hidden_neurons_19_to_18_spikes_to_uB_o : out std_logic_vector(20 downto 1);

       output_neurons_1_to_0_spikes_to_uB_o : out std_logic_vector(20 downto 1)
      );  
       
end top_level;

architecture Behavioral of top_level is

attribute keep: boolean;

signal rst_debounced : std_logic;
signal rst_n : std_logic;

signal PC_data_temp : std_ulogic_vector(31 downto 0);
signal PC_data_out  : std_logic_vector(31 downto 0);
attribute keep of PC_data_out: signal is true;

signal IR_data_temp : std_ulogic_vector(31 downto 0);
signal IR_data_out  : std_logic_vector(31 downto 0);
attribute keep of IR_data_out: signal is true;

signal neorv32_execute_states : std_logic_vector(3 downto 0);
attribute keep of neorv32_execute_states: signal is true;

signal rs1_reg_data_temp : std_ulogic_vector(31 downto 0);
signal rs1_reg_data_out  : std_logic_vector(31 downto 0);
attribute keep of rs1_reg_data_out: signal is true;

signal mtvec_data_temp : std_ulogic_vector(31 downto 0);
signal mtvec_data_out  : std_logic_vector(31 downto 0);
attribute keep of mtvec_data_out: signal is true;

signal mepc_data_temp : std_ulogic_vector(31 downto 0);
signal mepc_data_out  : std_logic_vector(31 downto 0);
attribute keep of mepc_data_out: signal is true;

signal mcause_data_temp : std_ulogic_vector(5 downto 0);
signal mcause_data_out  : std_logic_vector(5 downto 0);
attribute keep of mcause_data_out: signal is true;

signal features_data : std_logic_vector(15 downto 0);
attribute keep of features_data: signal is true;

signal neorv32_pc_we : std_logic;
attribute keep of neorv32_pc_we: signal is true;

signal neorv32_rst_n : std_logic;
attribute keep of neorv32_rst_n: signal is true;

signal fifo_data_in : std_logic_vector(169 downto 0);
attribute keep of fifo_data_in: signal is true;

signal fifo_data_out : std_logic_vector(169 downto 0);
attribute keep of fifo_data_out: signal is true;

signal fifo_rst : std_logic;
signal fifo_wr_en : std_logic; 
signal fifo_rd_en : std_logic; 
signal fifo_empty : std_logic; 
signal fifo_full : std_logic; 
signal fifo_wr_ack : std_logic; 
signal fifo_rd_valid : std_logic; 
attribute keep of fifo_rst: signal is true;
attribute keep of fifo_wr_en: signal is true;
attribute keep of fifo_rd_en: signal is true;
attribute keep of fifo_empty: signal is true;
attribute keep of fifo_full: signal is true;
attribute keep of fifo_wr_ack: signal is true;
attribute keep of fifo_rd_valid: signal is true;

signal fault_control_fifo_rst : std_logic; 
attribute keep of fault_control_fifo_rst: signal is true;

signal FIL_four_to_one_mux_selects : std_logic_vector(20 downto 1);
attribute keep of FIL_four_to_one_mux_selects: signal is true;

signal gpio_i_top : std_ulogic_vector(63 downto 0);

signal gpio_o_top_ulv : std_ulogic_vector(63 downto 0);
signal gpio_o_top : std_logic_vector(63 downto 0);

signal pwm_o_top_ulv : std_ulogic_vector(11 downto 0);

signal xirq_lines : std_ulogic_vector(31 downto 0); 

signal watchdog_rst : std_logic;
attribute keep of watchdog_rst: signal is true;

signal watchdog_rst_n : std_logic;
attribute keep of watchdog_rst_n: signal is true;

signal watchdog_ready : std_logic;
signal watchdog_busy  : std_logic;
signal watchdog_done : std_logic;
signal watchdog_error : std_logic;
attribute keep of watchdog_ready: signal is true;
attribute keep of watchdog_busy: signal is true;
attribute keep of watchdog_done: signal is true;
attribute keep of watchdog_error: signal is true;

signal SNN_done : std_logic;
attribute keep of SNN_done: signal is true;

signal SNN_class_zero : std_logic;
signal SNN_class_one : std_logic;
attribute keep of SNN_class_zero: signal is true;
attribute keep of SNN_class_one: signal is true;

signal neorv32_data_ready_to_read : std_logic;
attribute keep of neorv32_data_ready_to_read: signal is true;

signal uB_has_read_neorv32_data : std_logic;
attribute keep of uB_has_read_neorv32_data: signal is true;

signal SNN_class_ready_to_read : std_logic;
attribute keep of SNN_class_ready_to_read: signal is true;

signal uB_has_read_SNN_class_data : std_logic;
attribute keep of uB_has_read_SNN_class_data: signal is true;

signal fault_control_error : std_logic;
attribute keep of fault_control_error: signal is true;

signal system_error : std_logic;
attribute keep of system_error: signal is true;

signal serial_input_shift_clk_top : std_logic;
signal serial_input_parallel_load_top : std_logic;
signal serial_input_data_top : std_logic;

signal debounced_inputs_top : std_logic_vector(15 downto 0);
attribute keep of debounced_inputs_top: signal is true;

signal output_write_data_top : std_logic_vector(47 downto 0);
 attribute keep of output_write_data_top: signal is true;

signal serial_output_data_top : std_logic;
signal serial_output_shift_clk_top : std_logic;
signal serial_output_storage_clk_top : std_logic;

signal bit_fault_type_sel_buttons : std_logic_vector(10 downto 1);
signal inject_faults_button : std_logic;
signal clear_faults_button : std_logic;
signal clear_all_faults_button : std_logic;
signal watchdog_enable_switch : std_logic;
signal neorv32_reset_switch : std_logic;
attribute keep of bit_fault_type_sel_buttons: signal is true;
attribute keep of inject_faults_button: signal is true;
attribute keep of clear_faults_button: signal is true;
attribute keep of clear_all_faults_button: signal is true;
attribute keep of watchdog_enable_switch: signal is true;
attribute keep of neorv32_reset_switch: signal is true;

signal bit_fault_type_selects : std_logic_vector(20 downto 1);
attribute keep of bit_fault_type_selects: signal is true;

signal bit_fault_type_selects_rstn : std_logic;
attribute keep of bit_fault_type_selects_rstn: signal is true;

signal bit_no_fault_leds : std_logic_vector(10 downto 1);
signal bit_stuck_at_zero_leds : std_logic_vector(10 downto 1);
signal bit_stuck_at_one_leds : std_logic_vector(10 downto 1);
signal bit_bit_flip_leds : std_logic_vector(10 downto 1);
attribute keep of bit_no_fault_leds: signal is true;
attribute keep of bit_stuck_at_zero_leds: signal is true;
attribute keep of bit_stuck_at_one_leds: signal is true;
attribute keep of bit_bit_flip_leds: signal is true;

signal neorv32_trap_triggered : std_logic;
signal watchdog_fault_detected : std_logic;
signal watchdog_no_faults_detected : std_logic;
signal faults_active : std_logic;
attribute keep of neorv32_trap_triggered: signal is true;
attribute keep of watchdog_fault_detected: signal is true;
attribute keep of watchdog_no_faults_detected: signal is true;
attribute keep of faults_active: signal is true;

signal motor_encoder_counter_top_ulv : std_ulogic_vector(31 downto 0);

signal setpoint_motor_speeds_reg : std_logic_vector(31 downto 0);
signal actual_motor_speeds_reg : std_logic_vector(31 downto 0);

signal bcd_motor_speeds_reg : std_logic_vector(31 downto 0);

signal segments : std_logic_vector(6 downto 0);
signal anodes   : std_logic_vector(7 downto 0);

signal motor_stop_button : std_logic;
signal motor_start_button : std_logic;
signal motor_direction_button : std_logic;
signal motor_stop_button_debounced : std_logic;
signal motor_start_button_debounced : std_logic;
signal motor_direction_button_debounced : std_logic;

signal motor_encoder_ch_A : std_logic;
signal motor_encoder_ch_B : std_logic;

signal hand_encoder_ch_A : std_logic;
signal hand_encoder_ch_B : std_logic;
signal hand_encoder_ch_A_debounced : std_logic;
signal hand_encoder_ch_B_debounced : std_logic;  

signal motor_direction_reg : std_logic;
signal motor_forward_led_reg : std_logic;
signal motor_reverse_led_reg : std_logic;
signal motor_running_led_reg : std_logic;

signal python_motor_stop_button : std_logic;
signal python_motor_start_button : std_logic;
signal python_motor_direction_button : std_logic;

signal python_increase_speed_button : std_logic;
signal python_decrease_speed_button : std_logic;
signal python_confirm_speed_setpoint_button : std_logic;

signal python_speed_setpoint_value : std_logic_vector(15 downto 0);
signal python_speed_setpoint_value_ulv : std_ulogic_vector(15 downto 0);

signal python_bit_fault_type_sel_buttons : std_logic_vector(10 downto 1);
signal python_inject_faults_button : std_logic;
signal python_clear_faults_button : std_logic;
signal python_clear_all_faults_button : std_logic;
signal python_neorv32_reset_button : std_logic;
signal python_neorv32_trap_triggered : std_logic;

signal inject_faults_cmd : std_logic;
signal clear_faults_cmd : std_logic;
signal clear_all_faults_button_cmd : std_logic;

signal input_neurons_spikes_top : std_logic_vector(160 downto 1);
signal hidden_neurons_spikes_top : std_logic_vector(200 downto 1);
signal output_neurons_spikes_top : std_logic_vector(20 downto 1);

begin

--- reset button debouncing -----------------------------------------------------------------------------------
reset_button_debouncer : input_debouncer
generic map (g_clk_freq => 100_000_000,
             g_debounce_time_ms => 50,
             g_counter_bit_width => 24)
port map (clk_i => clk_i,
          bit_i => rst_i,
          bit_o => rst_debounced
         );
---------------------------------------------------------------------------------------------------------------

--- reset button inverting and synchronising ------------------------------------------------------------------
rst_n <= not rst_debounced when rising_edge(clk_i);
---------------------------------------------------------------------------------------------------------------

--- registering all PMOD inputs -------------------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
    motor_encoder_ch_A <= not JC1_i;
    motor_encoder_ch_B <= not JC2_i;
    hand_encoder_ch_A <= not JD7_i;
    hand_encoder_ch_B <= not JD4_i;
    motor_stop_button <= JD8_i;
    motor_start_button <= JD9_i;
    motor_direction_button <= JD10_i;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- motor stop button debouncing ------------------------------------------------------------------------------
stop_button_button_debouncer : input_debouncer
generic map (g_clk_freq => 100_000_000,
             g_debounce_time_ms => 50,
             g_counter_bit_width => 24)
port map (clk_i => clk_i,
          bit_i => motor_stop_button,
          bit_o => motor_stop_button_debounced
         );
---------------------------------------------------------------------------------------------------------------

--- motor start button debouncing -----------------------------------------------------------------------------
start_button_debouncer : input_debouncer
generic map (g_clk_freq => 100_000_000,
             g_debounce_time_ms => 50,
             g_counter_bit_width => 24)
port map (clk_i => clk_i,
          bit_i => motor_start_button,
          bit_o => motor_start_button_debounced
         );
---------------------------------------------------------------------------------------------------------------

--- motor direction switch debouncing -------------------------------------------------------------------------
motor_direction_debouncer : input_debouncer
generic map (g_clk_freq => 100_000_000,
             g_debounce_time_ms => 50,
             g_counter_bit_width => 24)
port map (clk_i => clk_i,
          bit_i => motor_direction_button,
          bit_o => motor_direction_button_debounced
         );
---------------------------------------------------------------------------------------------------------------

--- registering all inputs from Python GUI (through uB and AXI interface) -------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
    python_motor_stop_button <= neorv32_buttons_from_uB_i(0);
    python_motor_start_button <= neorv32_buttons_from_uB_i(1);
    python_motor_direction_button <= neorv32_buttons_from_uB_i(2);
    python_increase_speed_button <= neorv32_buttons_from_uB_i(3);
    python_decrease_speed_button <= neorv32_buttons_from_uB_i(4);
    python_confirm_speed_setpoint_button <= neorv32_buttons_from_uB_i(5);
    python_speed_setpoint_value <= motor_setpoint_from_uB_i;
    
    python_bit_fault_type_sel_buttons <= python_gui_control_from_uB_i(9 downto 0);
    python_inject_faults_button <= python_gui_control_from_uB_i(10);
    python_clear_faults_button <= python_gui_control_from_uB_i(11);
    python_clear_all_faults_button <= python_gui_control_from_uB_i(12);
    python_neorv32_reset_button <= python_gui_control_from_uB_i(13);
    python_neorv32_trap_triggered <= python_gui_control_from_uB_i(14);
    
    uB_has_read_SNN_class_data <= watchdog_data_from_uB_i(0);
    uB_has_read_neorv32_data <= watchdog_data_from_uB_i(1);

end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- motor encoder counter -------------------------------------------------------------------------------------
motor_encoder_counter : encoder_pulses_counter
port map (clk_i  => clk_i,
          rstn_i => rst_n,
          encoder_A_i => motor_encoder_ch_A,
          encoder_B_i => motor_encoder_ch_B,
          encoder_count_o => motor_encoder_counter_top_ulv
         );
---------------------------------------------------------------------------------------------------------------

--- hand encoder input debouncers -----------------------------------------------------------------------------
hand_encoder_ch_A_debouncer : input_debouncer
generic map (g_clk_freq => 100_000_000,            
             g_debounce_time_ms => 1,
             g_counter_bit_width => 25)
port map (clk_i => clk_i,
          bit_i => hand_encoder_ch_A,
          bit_o => hand_encoder_ch_A_debounced
         );
                                     
hand_encoder_ch_B_debouncer : input_debouncer
generic map (g_clk_freq => 100_000_000,            
             g_debounce_time_ms => 1,
             g_counter_bit_width => 25)
port map (clk_i => clk_i,
          bit_i => hand_encoder_ch_B,
          bit_o => hand_encoder_ch_B_debounced
         );
---------------------------------------------------------------------------------------------------------------

--- neorv32 reset logic (active low) --------------------------------------------------------------------------
neorv32_rst_n <= rst_n and neorv32_reset_switch and (not python_neorv32_reset_button) when rising_edge(clk_i);

other_data_to_uB_o(4) <= neorv32_rst_n;
---------------------------------------------------------------------------------------------------------------

--- NEORV32 RISCV core to generate data -----------------------------------------------------------------------
Neorv32 : neorv32_ProcessorTop_Minimal 
  port map(
    -- Global control --
    clk_i  => clk_i,
    rstn_i => neorv32_rst_n,
    FIL_four_to_one_mux_selects_i => FIL_four_to_one_mux_selects,
    program_counter_o        => PC_data_temp,
    dmem_transfer_trigger_i  => '0',
    dmem_reset_trigger_i     => '0',
    result_data_wr_address_o => open,
    dmem_to_result_data_o    => open,
    result_data_mem_wr_pulse_o => open,
    dmem_transfer_done_o     => open,
    dmem_reset_done_o        => open,
    neorv32_pc_we_o          => neorv32_pc_we, 
    instruction_register_o   => IR_data_temp,
    neorv32_execute_states_o => neorv32_execute_states,
    neorv32_branch_taken_o   => open,
    mcause_reg_o             => mcause_data_temp,
    mepc_reg_o               => mepc_data_temp,
    mtvec_reg_o              => mtvec_data_temp,
    rs1_reg_o                => rs1_reg_data_temp,
    alu_comp_status_o        => open,
    ctrl_bus_o               => open,
    gpio_i                   => gpio_i_top,
    gpio_o                   => gpio_o_top_ulv,
    pwm_o                    => pwm_o_top_ulv,
    xirq_i                   => xirq_lines                     
  );

IR_data_out <= to_stdlogicvector(IR_data_temp);
PC_data_out <= to_stdlogicvector(PC_data_temp);
rs1_reg_data_out <= to_stdlogicvector(rs1_reg_data_temp);
mtvec_data_out  <= to_stdlogicvector(mtvec_data_temp);
mepc_data_out   <= to_stdlogicvector(mepc_data_temp);
mcause_data_out <= to_stdlogicvector(mcause_data_temp);

fifo_data_in(31 downto 0)  <= IR_data_out;
fifo_data_in(63 downto 32) <= PC_data_out;
fifo_data_in(67 downto 64) <= neorv32_execute_states;
fifo_data_in(99 downto 68) <= rs1_reg_data_out;
fifo_data_in(131 downto 100) <= mtvec_data_out;
fifo_data_in(163 downto 132) <= mepc_data_out;
fifo_data_in(169 downto 164) <= mcause_data_out;

gpio_o_top <= to_stdlogicvector(gpio_o_top_ulv);

JA1_o <= pwm_o_top_ulv(0);  
---------------------------------------------------------------------------------------------------------------

--- assigning signals to Neorv32 interrupts -------------------------------------------------------------------
xirq_lines(0) <= hand_encoder_ch_A_debounced;

xirq_lines(31 downto 1) <= (others => '0');
---------------------------------------------------------------------------------------------------------------

--- neorv32 GPIO input signal registering ---------------------------------------------------------------------

python_speed_setpoint_value_ulv <= to_stdulogicvector(python_speed_setpoint_value);

Process(clk_i)

begin

if (rising_edge(clk_i)) then
    gpio_i_top(31 downto 0) <= motor_encoder_counter_top_ulv(31 downto 0);
       
    gpio_i_top(32) <= motor_stop_button_debounced;
    gpio_i_top(33) <= motor_start_button_debounced;
    gpio_i_top(34) <= motor_direction_button_debounced;
    gpio_i_top(35) <= hand_encoder_ch_B_debounced;
    
    gpio_i_top(36) <= python_motor_stop_button;
    gpio_i_top(37) <= python_motor_start_button;
    gpio_i_top(38) <= python_motor_direction_button;
    gpio_i_top(39) <= python_increase_speed_button;
    gpio_i_top(40) <= python_decrease_speed_button;
    gpio_i_top(41) <= python_confirm_speed_setpoint_button;
    
    gpio_i_top(57 downto 42) <= python_speed_setpoint_value_ulv;
        
    gpio_i_top(63 downto 58) <= (others => '0');
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- motor registers -------------------------------------------------------------------------------------------
Process (clk_i, rst_n)

begin

if (rst_n = '0') then
    motor_direction_reg <= '0';
    motor_running_led_reg <= '0';
elsif (rising_edge(clk_i)) then
    if (gpio_o_top(33) = '1') then
        motor_direction_reg <= gpio_o_top(0);
        motor_running_led_reg <= gpio_o_top(1);
        motor_forward_led_reg <= gpio_o_top(2);
        motor_reverse_led_reg <= gpio_o_top(3);
    end if;
end if;
  
end process;

JA2_o <= motor_direction_reg;  -- motor direction : 1 - forward | 0 = reverse

JD1_o <= motor_reverse_led_reg;   -- reverse led
JD2_o <= motor_forward_led_reg;   -- forward led
JD3_o <= motor_running_led_reg;   -- running led

other_data_to_uB_o(0) <= motor_running_led_reg;
other_data_to_uB_o(1) <= motor_forward_led_reg;
other_data_to_uB_o(2) <= motor_reverse_led_reg;
---------------------------------------------------------------------------------------------------------------

---seven segment displays controller component instantiation --------------------------------------------------
seven_seg_display_controller_inst : seven_seg_display_controller
port map (clk_i  => clk_i,
          rstn_i => rst_n,
          data_i => bcd_motor_speeds_reg,
          segments_o   => segments,
          anodes_sel_o => anodes  
         );

seg_a_o <= segments(0);
seg_b_o <= segments(1);
seg_c_o <= segments(2);
seg_d_o <= segments(3); 
seg_e_o <= segments(4);
seg_f_o <= segments(5);
seg_g_o <= segments(6);

anode_0_o <= anodes(0);
anode_1_o <= anodes(1);
anode_2_o <= anodes(2);
anode_3_o <= anodes(3);
anode_4_o <= anodes(4);
anode_5_o <= anodes(5);
anode_6_o <= anodes(6);
anode_7_o <= anodes(7);
---------------------------------------------------------------------------------------------------------------

--- setpoint motor speeds register ----------------------------------------------------------------------------
Process (clk_i, rst_n)

begin

if (rst_n = '0') then
    setpoint_motor_speeds_reg <= (others => '0');
elsif (rising_edge(clk_i)) then
    if (gpio_o_top(32) = '1') then
        setpoint_motor_speeds_reg <= gpio_o_top(31 downto 0);
    end if;  
end if;
  
end process;

motor_speeds_to_uB_o(31 downto 16) <= setpoint_motor_speeds_reg(15 downto 0) when rising_edge(clk_i);
bcd_motor_speeds_reg(31 downto 16) <= setpoint_motor_speeds_reg(31 downto 16) when rising_edge(clk_i);
---------------------------------------------------------------------------------------------------------------

--- actual motor speeds register ------------------------------------------------------------------------------
Process (clk_i, rst_n)

begin

if (rst_n = '0') then
    actual_motor_speeds_reg <= (others => '0');
elsif (rising_edge(clk_i)) then
    if (gpio_o_top(34) = '1') then
        actual_motor_speeds_reg <= gpio_o_top(31 downto 0);
    end if;
end if;
  
end process;

motor_speeds_to_uB_o(15 downto 0) <= actual_motor_speeds_reg(15 downto 0) when rising_edge(clk_i);
bcd_motor_speeds_reg(15 downto 0) <= actual_motor_speeds_reg(31 downto 16) when rising_edge(clk_i);
---------------------------------------------------------------------------------------------------------------

--- fifo reset logic (active high) ----------------------------------------------------------------------------
fifo_rst <= rst_debounced or fault_control_fifo_rst;
---------------------------------------------------------------------------------------------------------------

--- Instantiating fifo buffer for Neorv32 data signal ---------------------------------------------------------
fifo_inst : fifo_generator_0
port map (clk => clk_i,
          srst => fifo_rst,
          din => fifo_data_in,
          wr_en => fifo_wr_en, 
          rd_en => fifo_rd_en,
          dout => fifo_data_out,
          full => fifo_full,
          wr_ack => fifo_wr_ack,
          empty => fifo_empty,
          valid => fifo_rd_valid
         );
         
-- data for python script
ir_data_o             <= fifo_data_out(31 downto 0);
pc_data_o             <= fifo_data_out(63 downto 32);
execute_states_data_o <= fifo_data_out(67 downto 64);
rs1_reg_data_o        <= fifo_data_out(99 downto 68);
mtvec_data_o          <= fifo_data_out(131 downto 100);
mepc_data_o           <= fifo_data_out(163 downto 132);
mcause_data_o         <= fifo_data_out(169 downto 164);
---------------------------------------------------------------------------------------------------------------

--- watchdog reset (active low) -------------------------------------------------------------------------------
watchdog_rst_n <= rst_n and (not watchdog_rst) when rising_edge(clk_i);    
---------------------------------------------------------------------------------------------------------------

--- Instantiating watchdog component --------------------------------------------------------------------------
watchdog_2_inst : watchdog_2
generic map (g_SNN_layer_sizes => g_SNN_layer_sizes,
             g_num_timesteps   => g_num_timesteps, 
             g_num_beta_shifts => g_num_beta_shifts,
             g_setup_file_path => g_setup_file_path)
port map (clk_i  => clk_i,
          rstn_i => watchdog_rst_n,
          watchdog_en_i   => watchdog_enable_switch,
          clear_faults_button_i => clear_faults_cmd,
          fifo_empty_i    => fifo_empty,
          fifo_rd_valid_i => fifo_rd_valid,
          fifo_data_i  => fifo_data_out(163 downto 0),
          fifo_rd_en_o => fifo_rd_en,
          neorv32_data_ready_to_read_o => neorv32_data_ready_to_read,
          uB_has_read_neorv32_data_i => uB_has_read_neorv32_data,
          features_o => features_data,
          SNN_done_o => SNN_done,
          SNN_class_zero_o => SNN_class_zero,
          SNN_class_one_o  => SNN_class_one,
          SNN_class_ready_to_read_o => SNN_class_ready_to_read,
          uB_has_read_SNN_class_data_i => uB_has_read_SNN_class_data,
          watchdog_ready_o => watchdog_ready,
          watchdog_busy_o  => watchdog_busy,
          watchdog_done_o  => watchdog_done,
          watchdog_error_o => watchdog_error,
          watchdog_no_faults_detected_o => watchdog_no_faults_detected,
          watchdog_fault_detected_o => watchdog_fault_detected,
          
          input_neurons_spike_shift_reg_o  => input_neurons_spikes_top,
          hidden_neurons_spike_shift_reg_o => hidden_neurons_spikes_top,
          output_neurons_spike_shift_reg_o => output_neurons_spikes_top
         );

other_data_to_uB_o(6) <= watchdog_no_faults_detected;
other_data_to_uB_o(7) <= watchdog_fault_detected;

watchdog_data_to_uB_o(0) <= watchdog_ready;
watchdog_data_to_uB_o(1) <= watchdog_done;
watchdog_data_to_uB_o(2) <= SNN_class_ready_to_read;
watchdog_data_to_uB_o(3) <= SNN_class_zero;
watchdog_data_to_uB_o(4) <= SNN_class_one;
watchdog_data_to_uB_o(5) <= neorv32_data_ready_to_read;

features_data_o <= features_data;

input_neurons_15_spikes_to_uB_o <= input_neurons_spikes_top(160 downto 151);
input_neurons_14_to_12_spikes_to_uB_o <= input_neurons_spikes_top(150 downto 121);
input_neurons_11_to_9_spikes_to_uB_o <= input_neurons_spikes_top(120 downto 91);
input_neurons_8_to_6_spikes_to_uB_o <= input_neurons_spikes_top(90 downto 61);
input_neurons_5_to_3_spikes_to_uB_o <= input_neurons_spikes_top(60 downto 31);
input_neurons_2_to_0_spikes_to_uB_o <= input_neurons_spikes_top(30 downto 1);

hidden_neurons_19_to_18_spikes_to_uB_o <= hidden_neurons_spikes_top(200 downto 181);
hidden_neurons_17_to_15_spikes_to_uB_o <= hidden_neurons_spikes_top(180 downto 151);
hidden_neurons_14_to_12_spikes_to_uB_o <= hidden_neurons_spikes_top(150 downto 121);
hidden_neurons_11_to_9_spikes_to_uB_o <= hidden_neurons_spikes_top(120 downto 91);
hidden_neurons_8_to_6_spikes_to_uB_o <= hidden_neurons_spikes_top(90 downto 61);
hidden_neurons_5_to_3_spikes_to_uB_o <= hidden_neurons_spikes_top(60 downto 31);
hidden_neurons_2_to_0_spikes_to_uB_o <= hidden_neurons_spikes_top(30 downto 1);

output_neurons_1_to_0_spikes_to_uB_o <= output_neurons_spikes_top;
---------------------------------------------------------------------------------------------------------------

--- neorv32 trap triggered led logic --------------------------------------------------------------------------
neorv32_trap_triggered <= python_neorv32_trap_triggered and watchdog_done;

other_data_to_uB_o(9) <= neorv32_trap_triggered;
---------------------------------------------------------------------------------------------------------------

--- Instantiating fault control component ---------------------------------------------------------------------
fault_control_logic : fault_control 
Generic map (fifo_delay_cycles => g_fifo_delay_write_cycles)
Port map (clk_i => clk_i,
          rstn_i => rst_n,
          inject_faults_button_i => inject_faults_cmd,
          clear_faults_button_i  => clear_faults_cmd,
          fifo_write_cycles_i => fifo_write_cycles_from_uB_i,
          bit_fault_sels_i => bit_fault_type_selects,
          neorv32_pc_we_i  => neorv32_pc_we,
          watchdog_en_i    => watchdog_enable_switch,
          watchdog_ready_i => watchdog_ready,
          fifo_empty_i => fifo_empty,
          fifo_full_i  => fifo_full,
          fifo_wr_en_o => fifo_wr_en,
          fifo_rst_o => fault_control_fifo_rst,
          watchdog_rst_o => watchdog_rst,
          faults_active_o => faults_active,
          neorv32_fault_sels_o => FIL_four_to_one_mux_selects,
          fault_control_error_o => fault_control_error
         );
         
other_data_to_uB_o(3) <= faults_active;

fifo_write_cycles_to_uB_o <= fifo_write_cycles_from_uB_i;
---------------------------------------------------------------------------------------------------------------

--- assigning top level error logic ---------------------------------------------------------------------------
system_error <= watchdog_error or fault_control_error when rising_edge(clk_i);

led0_o <= system_error;

other_data_to_uB_o(8) <= system_error;
---------------------------------------------------------------------------------------------------------------

--- Instantiating PCB I/O controller --------------------------------------------------------------------------
pcb_io_controller_inst : pcb_io_controller
port map (clk_i => clk_i,
          rstn_i => rst_n,
          serial_input_data_i => serial_input_data_top, 
          serial_input_shift_clk_o => serial_input_shift_clk_top,
          serial_input_parallel_load_o => serial_input_parallel_load_top,
          debounced_inputs_o => debounced_inputs_top,
          output_write_data_i => output_write_data_top,
          serial_output_data_o => serial_output_data_top,
          serial_output_shift_clk_o => serial_output_shift_clk_top,
          serial_output_storage_clk_o => serial_output_storage_clk_top
         );
         
JB1_o <= serial_input_shift_clk_top;
JB2_o <= serial_input_parallel_load_top;
serial_input_data_top <= JB3_i;

JB4_o <= serial_output_shift_clk_top;
JB7_o <= serial_output_storage_clk_top;
JB8_o <= serial_output_data_top;
---------------------------------------------------------------------------------------------------------------

--- assigning the debounced inputs to internal signals --------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rst_n = '0') then
        bit_fault_type_sel_buttons <= (others => '0');
        inject_faults_button <= '0';
        clear_faults_button <= '0';
        clear_all_faults_button <= '0';
        watchdog_enable_switch <= '0';
        neorv32_reset_switch <= '0';
    else
        bit_fault_type_sel_buttons(10) <= debounced_inputs_top(15);
        bit_fault_type_sel_buttons(9)  <= debounced_inputs_top(14);
        bit_fault_type_sel_buttons(8)  <= debounced_inputs_top(13);
        bit_fault_type_sel_buttons(7)  <= debounced_inputs_top(12);
        bit_fault_type_sel_buttons(6)  <= debounced_inputs_top(11);
        bit_fault_type_sel_buttons(5)  <= debounced_inputs_top(10);
        bit_fault_type_sel_buttons(4)  <= debounced_inputs_top(9);
        bit_fault_type_sel_buttons(3)  <= debounced_inputs_top(8);
        bit_fault_type_sel_buttons(2)  <= debounced_inputs_top(7);
        bit_fault_type_sel_buttons(1)  <= debounced_inputs_top(6);
        inject_faults_button <= debounced_inputs_top(5);
        clear_faults_button  <= debounced_inputs_top(4);
        clear_all_faults_button <= debounced_inputs_top(3);
        watchdog_enable_switch  <= not debounced_inputs_top(2);
        neorv32_reset_switch    <= debounced_inputs_top(1);
    end if;
end if;

end Process;

other_data_to_uB_o(5) <= watchdog_enable_switch;
---------------------------------------------------------------------------------------------------------------

--- registering all inputs from Python GUI (through uB and AXI interface) -------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
    inject_faults_cmd <= inject_faults_button or python_inject_faults_button;
    clear_faults_cmd <= clear_faults_button or python_clear_faults_button;
    clear_all_faults_button_cmd <= clear_all_faults_button or python_clear_all_faults_button;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- registering pcb output data -------------------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rst_n = '0') then
        output_write_data_top <= (others => '0');
    else       
        output_write_data_top(0) <= faults_active;
        output_write_data_top(1) <= watchdog_enable_switch;
        output_write_data_top(2) <= not neorv32_rst_n;
        output_write_data_top(3) <= watchdog_no_faults_detected;
        output_write_data_top(4) <= watchdog_fault_detected;
        output_write_data_top(5) <= neorv32_trap_triggered;
        output_write_data_top(6) <= '0';
        output_write_data_top(7) <= '0';
        
        output_write_data_top(8) <= bit_no_fault_leds(2);
        output_write_data_top(9) <= bit_stuck_at_zero_leds(2);
        output_write_data_top(10) <= bit_stuck_at_one_leds(2);
        output_write_data_top(11) <= bit_bit_flip_leds(2);
        output_write_data_top(12) <= bit_no_fault_leds(1);
        output_write_data_top(13) <= bit_stuck_at_zero_leds(1);
        output_write_data_top(14) <= bit_stuck_at_one_leds(1);
        output_write_data_top(15) <= bit_bit_flip_leds(1);
        
        output_write_data_top(16) <= bit_no_fault_leds(4);
        output_write_data_top(17) <= bit_stuck_at_zero_leds(4);
        output_write_data_top(18) <= bit_stuck_at_one_leds(4);
        output_write_data_top(19) <= bit_bit_flip_leds(4);
        output_write_data_top(20) <= bit_no_fault_leds(3);
        output_write_data_top(21) <= bit_stuck_at_zero_leds(3);
        output_write_data_top(22) <= bit_stuck_at_one_leds(3);
        output_write_data_top(23) <= bit_bit_flip_leds(3);
        
        output_write_data_top(24) <= bit_no_fault_leds(6);
        output_write_data_top(25) <= bit_stuck_at_zero_leds(6);
        output_write_data_top(26) <= bit_stuck_at_one_leds(6);
        output_write_data_top(27) <= bit_bit_flip_leds(6);
        output_write_data_top(28) <= bit_no_fault_leds(5);
        output_write_data_top(29) <= bit_stuck_at_zero_leds(5);
        output_write_data_top(30) <= bit_stuck_at_one_leds(5);
        output_write_data_top(31) <= bit_bit_flip_leds(5);
        
        output_write_data_top(32) <= bit_no_fault_leds(8);
        output_write_data_top(33) <= bit_stuck_at_zero_leds(8);
        output_write_data_top(34) <= bit_stuck_at_one_leds(8);
        output_write_data_top(35) <= bit_bit_flip_leds(8);
        output_write_data_top(36) <= bit_no_fault_leds(7);
        output_write_data_top(37) <= bit_stuck_at_zero_leds(7);
        output_write_data_top(38) <= bit_stuck_at_one_leds(7);
        output_write_data_top(39) <= bit_bit_flip_leds(7); 
        
        output_write_data_top(40) <= bit_no_fault_leds(10);
        output_write_data_top(41) <= bit_stuck_at_zero_leds(10);
        output_write_data_top(42) <= bit_stuck_at_one_leds(10);
        output_write_data_top(43) <= bit_bit_flip_leds(10);
        output_write_data_top(44) <= bit_no_fault_leds(9);
        output_write_data_top(45) <= bit_stuck_at_zero_leds(9);
        output_write_data_top(46) <= bit_stuck_at_one_leds(9);
        output_write_data_top(47) <= bit_bit_flip_leds(9);
        
    end if;
end if;
        
end Process;
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters reset logic ---------------------------------------------------------------------
bit_fault_type_selects_rstn <= rst_n and (not clear_all_faults_button_cmd) when rising_edge(clk_i);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 1) --------------------------------------------------
bit_1_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(1),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(1),
          fault_type_count_o => bit_fault_type_selects(2 downto 1)
         );

bit_1_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(2 downto 1),
          no_fault => bit_no_fault_leds(1),
          stuck_at_zero => bit_stuck_at_zero_leds(1),
          stuck_at_one => bit_stuck_at_one_leds(1),
          bit_flip => bit_bit_flip_leds(1)
         );

pc_bit_fault_type_counters_to_uB_o(2 downto 1) <= bit_fault_type_selects(2 downto 1);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 2) --------------------------------------------------
bit_2_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(2),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(2),
          fault_type_count_o => bit_fault_type_selects(4 downto 3)
         );

bit_2_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(4 downto 3),
          no_fault => bit_no_fault_leds(2),
          stuck_at_zero => bit_stuck_at_zero_leds(2),
          stuck_at_one => bit_stuck_at_one_leds(2),
          bit_flip => bit_bit_flip_leds(2)
         );
         
pc_bit_fault_type_counters_to_uB_o(4 downto 3) <= bit_fault_type_selects(4 downto 3);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 3) --------------------------------------------------
bit_3_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(3),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(3),
          fault_type_count_o => bit_fault_type_selects(6 downto 5)
         );

bit_3_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(6 downto 5),
          no_fault => bit_no_fault_leds(3),
          stuck_at_zero => bit_stuck_at_zero_leds(3),
          stuck_at_one => bit_stuck_at_one_leds(3),
          bit_flip => bit_bit_flip_leds(3)
         );
                   
pc_bit_fault_type_counters_to_uB_o(6 downto 5) <= bit_fault_type_selects(6 downto 5);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 4) --------------------------------------------------
bit_4_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(4),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(4),
          fault_type_count_o => bit_fault_type_selects(8 downto 7)
         );


bit_4_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(8 downto 7),
          no_fault => bit_no_fault_leds(4),
          stuck_at_zero => bit_stuck_at_zero_leds(4),
          stuck_at_one => bit_stuck_at_one_leds(4),
          bit_flip => bit_bit_flip_leds(4)
        );

pc_bit_fault_type_counters_to_uB_o(8 downto 7) <= bit_fault_type_selects(8 downto 7);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 5) --------------------------------------------------
bit_5_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(5),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(5),
          fault_type_count_o => bit_fault_type_selects(10 downto 9)
         );
         
bit_5_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(10 downto 9),
          no_fault => bit_no_fault_leds(5),
          stuck_at_zero => bit_stuck_at_zero_leds(5),
          stuck_at_one => bit_stuck_at_one_leds(5),
          bit_flip => bit_bit_flip_leds(5)
         );

pc_bit_fault_type_counters_to_uB_o(10 downto 9) <= bit_fault_type_selects(10 downto 9);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 6) --------------------------------------------------
bit_6_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(6),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(6),
          fault_type_count_o => bit_fault_type_selects(12 downto 11)
         );
         
bit_6_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(12 downto 11),
          no_fault => bit_no_fault_leds(6),
          stuck_at_zero => bit_stuck_at_zero_leds(6),
          stuck_at_one => bit_stuck_at_one_leds(6),
          bit_flip => bit_bit_flip_leds(6)
         );

pc_bit_fault_type_counters_to_uB_o(12 downto 11) <= bit_fault_type_selects(12 downto 11);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 7) --------------------------------------------------
bit_7_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(7),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(7),
          fault_type_count_o => bit_fault_type_selects(14 downto 13)
         );
         
bit_7_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(14 downto 13),
          no_fault => bit_no_fault_leds(7),
          stuck_at_zero => bit_stuck_at_zero_leds(7),
          stuck_at_one => bit_stuck_at_one_leds(7),
          bit_flip => bit_bit_flip_leds(7)
         );

pc_bit_fault_type_counters_to_uB_o(14 downto 13) <= bit_fault_type_selects(14 downto 13);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 8) --------------------------------------------------
bit_8_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(8),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(8),
          fault_type_count_o => bit_fault_type_selects(16 downto 15)
         );
         
bit_8_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(16 downto 15),
          no_fault => bit_no_fault_leds(8),
          stuck_at_zero => bit_stuck_at_zero_leds(8),
          stuck_at_one => bit_stuck_at_one_leds(8),
          bit_flip => bit_bit_flip_leds(8)
          );

pc_bit_fault_type_counters_to_uB_o(16 downto 15) <= bit_fault_type_selects(16 downto 15);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 9) --------------------------------------------------
bit_9_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(9),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(9),
          fault_type_count_o => bit_fault_type_selects(18 downto 17)
         );
         
bit_9_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(18 downto 17),
          no_fault => bit_no_fault_leds(9),
          stuck_at_zero => bit_stuck_at_zero_leds(9),
          stuck_at_one => bit_stuck_at_one_leds(9),
          bit_flip => bit_bit_flip_leds(9)
         );

pc_bit_fault_type_counters_to_uB_o(18 downto 17) <= bit_fault_type_selects(18 downto 17);
---------------------------------------------------------------------------------------------------------------

--- 2-bit fault type counters and output led decoder (BIT 10) -------------------------------------------------
bit_10_fault_type_select : bit_fault_type_select_counters
Port map (clk_i  => clk_i,
          rstn_i => bit_fault_type_selects_rstn,
          pcb_button_i => bit_fault_type_sel_buttons(10),
          gui_axi_button_i => python_bit_fault_type_sel_buttons(10),
          fault_type_count_o => bit_fault_type_selects(20 downto 19)
         );
         
bit_10_fault_type_decoder : two_to_four_decoder
Port map (bit_fault_select_counter => bit_fault_type_selects(20 downto 19),
          no_fault => bit_no_fault_leds(10),
          stuck_at_zero => bit_stuck_at_zero_leds(10),
          stuck_at_one => bit_stuck_at_one_leds(10),
          bit_flip => bit_bit_flip_leds(10)
         );

pc_bit_fault_type_counters_to_uB_o(20 downto 19) <= bit_fault_type_selects(20 downto 19);
---------------------------------------------------------------------------------------------------------------

end Behavioral;
