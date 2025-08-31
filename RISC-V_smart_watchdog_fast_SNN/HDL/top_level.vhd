
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity top_level is
  Generic(g_num_timesteps   : natural := 10;                 --number of timesteps to stimulate network
          g_num_beta_shifts : natural := 2;                  --number of right shifts for beta decay
          g_SNN_layer_sizes : natural_array := (16, 20, 2);  --number of layers / layer sizes in network
          g_setup_file_path : string := "C:/riscv_watchdog_fast_design_2/setup text files/Design 2 With Bias 20 Hidden Neurons/");
  Port (clk_in1_p : in std_logic;  --200MHz on-board clock
        clk_in1_n : in std_logic;    
        rst_i     : in std_logic;  --active high on-board push button
        start_i   : in std_logic;  --active high on-board push button
        sw7_i     : in std_logic;  --on-board dip switch 7
        led0_o    : out std_logic  --active high on-board led
       ); 
end top_level;

architecture Behavioral of top_level is

attribute keep: boolean;

signal clk_100MHz : std_logic;

signal rst_debounced : std_logic;
signal rst_n : std_logic;
attribute keep of rst_n : signal is true;

type State_type is (S_top_idle, S_top_fifo_and_counters_rst, S_top_delay_cycle, S_top_neorv32_run, S_top_check_fifo_wr_ack, S_top_check_fifo_last_wr_ack,
                    S_top_wait_for_watchdog_ready, S_top_done, S_top_error);
                                                         
signal S_top_Current_State, S_top_Next_State : State_type;
attribute keep of S_top_Current_State: signal is true;
attribute keep of S_top_Next_State: signal is true;

signal start_debounced : std_logic;
signal start_pulse : std_logic;
attribute keep of start_pulse: signal is true;

signal fifo_data_in : std_logic_vector(163 downto 0);
attribute keep of fifo_data_in: signal is true;

signal fifo_data_out : std_logic_vector(163 downto 0);
attribute keep of fifo_data_out: signal is true;

signal fifo_rst : std_logic; 
attribute keep of fifo_rst: signal is true;

signal fifo_wr_en : std_logic; 
attribute keep of fifo_wr_en: signal is true;

signal fifo_rd_en : std_logic; 
attribute keep of fifo_rd_en: signal is true;

signal fifo_empty : std_logic; 
attribute keep of fifo_empty: signal is true;

signal fifo_full : std_logic; 
attribute keep of fifo_full: signal is true;

signal fifo_wr_ack : std_logic; 
attribute keep of fifo_wr_ack: signal is true;

signal fifo_rd_valid : std_logic; 
attribute keep of fifo_rd_valid: signal is true;

signal metric_counters_rst : std_logic;
attribute keep of metric_counters_rst: signal is true;

signal top_ready : std_logic;
attribute keep of top_ready: signal is true;

signal top_done : std_logic;
attribute keep of top_done: signal is true;

signal top_error : std_logic;
attribute keep of top_error: signal is true;

signal fifo_error : std_logic;
attribute keep of fifo_error: signal is true;

signal watchdog_ready : std_logic;
attribute keep of watchdog_ready: signal is true;

signal watchdog_error : std_logic;
attribute keep of watchdog_error: signal is true;

signal SNN_done : std_logic;
attribute keep of SNN_done: signal is true;

signal SNN_class_zero : std_logic;
signal SNN_class_zero_pulse : std_logic;
attribute keep of SNN_class_zero: signal is true;
attribute keep of SNN_class_zero_pulse: signal is true;

signal SNN_class_one : std_logic;
signal SNN_class_one_pulse : std_logic;
attribute keep of SNN_class_one: signal is true;
attribute keep of SNN_class_one_pulse: signal is true;

--- accurcy performance metric counters ---
signal total_classes_counter : unsigned(15 downto 0);
attribute keep of total_classes_counter: signal is true;

signal total_label_0_classes_counter : unsigned(15 downto 0);
attribute keep of total_label_0_classes_counter: signal is true;

signal total_label_1_classes_counter : unsigned(15 downto 0);
attribute keep of total_label_1_classes_counter: signal is true;

signal neorv32_run_counter_rst : std_logic;
attribute keep of neorv32_run_counter_rst: signal is true;

signal neorv32_run_counter_en : std_logic;
attribute keep of neorv32_run_counter_en: signal is true;

signal neorv32_run_counter : std_logic_vector(31 downto 0);
attribute keep of neorv32_run_counter: signal is true;

signal neorv32_reset : std_logic;
attribute keep of neorv32_reset: signal is true;

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

signal application_run_time_reg_data : std_logic_vector(15 downto 0); 
attribute keep of application_run_time_reg_data: signal is true;

signal enable_fault_inj_reg_data : std_logic;
signal enable_fault_inj_reg_data_vector  : std_logic_vector(0 downto 0);
attribute keep of enable_fault_inj_reg_data: signal is true;

signal fault_injection_en : std_logic;
attribute keep of fault_injection_en: signal is true;

signal bit_one_reg_data       : std_logic_vector(53 downto 0);
signal bit_two_reg_data       : std_logic_vector(53 downto 0);
signal bit_three_reg_data     : std_logic_vector(53 downto 0);
signal bit_four_reg_data      : std_logic_vector(53 downto 0);
signal bit_five_reg_data      : std_logic_vector(53 downto 0);
signal bit_six_reg_data       : std_logic_vector(53 downto 0);
signal bit_seven_reg_data     : std_logic_vector(53 downto 0);
signal bit_eight_reg_data     : std_logic_vector(53 downto 0);
signal bit_nine_reg_data      : std_logic_vector(53 downto 0);
signal bit_ten_reg_data       : std_logic_vector(53 downto 0); 

signal stuck_at_hold_time_reg_data : std_logic_vector(15 downto 0);

signal bit_fault_inj_en : std_logic;
attribute keep of bit_fault_inj_en: signal is true;

signal FIL_four_to_one_mux_selects : std_logic_vector(20 downto 1);
attribute keep of FIL_four_to_one_mux_selects: signal is true;

signal neorv32_pc_we : std_logic;
attribute keep of neorv32_pc_we: signal is true;

signal watchdog_rst : std_logic;
attribute keep of watchdog_rst: signal is true;

signal watchdog_rst_n : std_logic;
attribute keep of watchdog_rst_n: signal is true;

begin

--- Assigning clock -------------------------------------------------------------------------------------------
clk_wiz_100mhz : clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => clk_100Mhz,
   -- Clock in ports
   clk_in1_p => clk_in1_p,
   clk_in1_n => clk_in1_n
 );
---------------------------------------------------------------------------------------------------------------

--- Assigning led ---------------------------------------------------------------------------------------------
led0_o <= '1';
---------------------------------------------------------------------------------------------------------------

--- reset button debouncing and synchronising -----------------------------------------------------------------
reset_button_debouncer : input_debouncer
generic map (g_debounce_threshold => 1_000_000)  -- should be 10ms debounce time     
port map (clk_i  => clk_100MHz,
          bit_i => rst_i,
          bit_o => rst_debounced
         );

--- Reset button synchronising and inverting ------------------------------------------------------------------
rst_n <= not rst_debounced when rising_edge(clk_100MHz);   
---------------------------------------------------------------------------------------------------------------

--- watchdog reset --------------------------------------------------------------------------------------------
watchdog_rst_n <= rst_n and watchdog_rst;    
---------------------------------------------------------------------------------------------------------------

--- start button debouncing and synchronising -----------------------------------------------------------------
start_button_debouncer : input_debouncer
generic map (g_debounce_threshold => 1_000_000)  -- should be 10ms debounce time     
port map (clk_i  => clk_100MHz,
          bit_i => start_i,
          bit_o => start_debounced
         );
---------------------------------------------------------------------------------------------------------------

--- start button rising pulse generator -----------------------------------------------------------------------
start_button_pulse : pulse_generator
port map (clk_i   => clk_100MHz,
          rstn_i  => rst_n,
          bit_i   => start_debounced,
          pulse_o => start_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- counter for timing how long neorv32 runs for --------------------------------------------------------------

Process (clk_100Mhz, rst_n)

begin

if (rst_n = '0') then
    neorv32_run_counter <= (others => '0');

elsif (rising_edge(clk_100Mhz)) then

    if (neorv32_run_counter_rst = '1') then
        neorv32_run_counter <= (others => '0');
        
    elsif (neorv32_run_counter_en = '1') then
        neorv32_run_counter <= std_logic_vector(unsigned(neorv32_run_counter) + 1);
 
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- NEORV32 RISCV core to generate data to FIFO ---------------------------------------------------------------
DUT_neorv32_inst : neorv32_ProcessorTop_Minimal 
  port map(
    -- Global control --
    clk_i       => clk_100Mhz,
    rstn_i      => neorv32_reset,
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
    mcause_reg_o             => open,
    mepc_reg_o               => mepc_data_temp,
    mtvec_reg_o              => mtvec_data_temp,
    rs1_reg_o                => rs1_reg_data_temp,
    alu_comp_status_o        => open,
    ctrl_bus_o               => open       
  );

PC_data_out        <= to_stdlogicvector(PC_data_temp);
IR_data_out        <= to_stdlogicvector(IR_data_temp);
rs1_reg_data_out   <= to_stdlogicvector(rs1_reg_data_temp);
mtvec_data_out     <= to_stdlogicvector(mtvec_data_temp);
mepc_data_out      <= to_stdlogicvector(mepc_data_temp);

fifo_data_in(31 downto 0)  <= IR_data_out;
fifo_data_in(63 downto 32) <= PC_data_out;
fifo_data_in(67 downto 64) <= neorv32_execute_states;
fifo_data_in(99 downto 68) <= rs1_reg_data_out;
fifo_data_in(131 downto 100) <= mtvec_data_out;
fifo_data_in(163 downto 132) <= mepc_data_out;
---------------------------------------------------------------------------------------------------------------

--- Instantiating fifo to buffer Neorv32 data -----------------------------------------------------------------
fifo_inst : fifo_generator_0
port map (clk => clk_100Mhz,
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
---------------------------------------------------------------------------------------------------------------

--- setup register component instantiation --------------------------------------------------------------------
setup_regs_inst : setup_regs 
  Port map (clk_i                  => clk_100Mhz,  
            rstn_i                 => rst_n,  
            uBlaze_data_i          => (others => '0'),
            setup_regs_data_o      => open,  
            application_run_time_o => application_run_time_reg_data,  
            stuck_at_hold_time_o   => stuck_at_hold_time_reg_data,  
            spare_reg_o            => open,    
            fault_injection_en_o   => enable_fault_inj_reg_data_vector,
            bit_1_data_o           => bit_one_reg_data,    
            bit_2_data_o           => bit_two_reg_data,  
            bit_3_data_o           => bit_three_reg_data,  
            bit_4_data_o           => bit_four_reg_data,  
            bit_5_data_o           => bit_five_reg_data,   
            bit_6_data_o           => bit_six_reg_data,  
            bit_7_data_o           => bit_seven_reg_data,   
            bit_8_data_o           => bit_eight_reg_data,   
            bit_9_data_o           => bit_nine_reg_data,    
            bit_10_data_o          => bit_ten_reg_data
           );

enable_fault_inj_reg_data <= enable_fault_inj_reg_data_vector(0);
---------------------------------------------------------------------------------------------------------------

--- fault injection fsm enable bit logic ----------------------------------------------------------------------
bit_fault_inj_en <= enable_fault_inj_reg_data and sw7_i; --fault_injection_en (from fsm1 I think!);
---------------------------------------------------------------------------------------------------------------

--- bit 1 fault injection controller --------------------------------------------------------------------------
Bit_1_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_one_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(2 downto 1)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 2 fault injection controller --------------------------------------------------------------------------
Bit_2_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_two_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(4 downto 3)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 3 fault injection controller --------------------------------------------------------------------------
Bit_3_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_three_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(6 downto 5)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 4 fault injection controller --------------------------------------------------------------------------
Bit_4_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_four_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(8 downto 7)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 5 fault injection controller --------------------------------------------------------------------------
Bit_5_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_five_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(10 downto 9)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 6 fault injection controller --------------------------------------------------------------------------
Bit_6_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_six_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(12 downto 11)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 7 fault injection controller --------------------------------------------------------------------------
Bit_7_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_seven_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(14 downto 13)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 8 fault injection controller --------------------------------------------------------------------------
Bit_8_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_eight_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(16 downto 15)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 9 fault injection controller --------------------------------------------------------------------------
Bit_9_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_nine_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(18 downto 17)
         );
---------------------------------------------------------------------------------------------------------------

--- bit 10 fault injection controller --------------------------------------------------------------------------
Bit_10_Fault_Controller_inst : bit_fault_controller
port map (clk_i => clk_100Mhz,
          rstn_i => rst_n,
          bit_fault_inj_en_i => bit_fault_inj_en, 
          count_value_i => neorv32_run_counter,
          stuck_at_hold_time_i => stuck_at_hold_time_reg_data,
          bit_setup_reg_i => bit_ten_reg_data,
          neorv32_pc_we_i => neorv32_pc_we,
          four_to_one_mux_sel_o => FIL_four_to_one_mux_selects(20 downto 19)
         );
---------------------------------------------------------------------------------------------------------------

--- watchdog reset --------------------------------------------------------------------------------------------
watchdog_rst_n <= rst_n and watchdog_rst;    
---------------------------------------------------------------------------------------------------------------

--- Instantiating watchdog component --------------------------------------------------------------------------
watchdog_2_inst : watchdog_2
generic map (g_SNN_layer_sizes => g_SNN_layer_sizes,
             g_num_timesteps   => g_num_timesteps, 
             g_num_beta_shifts => g_num_beta_shifts,
             g_setup_file_path => g_setup_file_path)
port map (clk_i  => clk_100Mhz,
          rstn_i => watchdog_rst,
          fifo_empty_i    => fifo_empty,
          fifo_rd_valid_i => fifo_rd_valid,
          fifo_data_i  => fifo_data_out,
          fifo_rd_en_o => fifo_rd_en,
          SNN_done_o   => SNN_done,
          SNN_class_zero_o => SNN_class_zero,
          SNN_class_one_o  => SNN_class_one,
          watchdog_ready_o => watchdog_ready,
          watchdog_error_o => watchdog_error
         );
---------------------------------------------------------------------------------------------------------------

--- SNN class zero rising pulse generator ---------------------------------------------------------------------
snn_class_0_pulse : pulse_generator
port map (clk_i   => clk_100Mhz,
          rstn_i  => rst_n,
          bit_i   => SNN_class_zero,
          pulse_o => SNN_class_zero_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- SNN class one rising pulse generator ----------------------------------------------------------------------
snn_class_1_pulse : pulse_generator
port map (clk_i   => clk_100Mhz,
          rstn_i  => rst_n,
          bit_i   => SNN_class_one,
          pulse_o => SNN_class_one_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- Assigning top error ---------------------------------------------------------------------------------------
top_error <= fifo_error or watchdog_error;
---------------------------------------------------------------------------------------------------------------

--- total samples classifications counter ---------------------------------------------------------------------
Process(clk_100MHz)

begin

if (rising_edge(clk_100MHz)) then
    if (rst_n = '0' or metric_counters_rst = '1') then
        total_classes_counter <= (others => '0');
    elsif (SNN_done = '1') then
        total_classes_counter <= total_classes_counter + 1;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- total label 0 samples classifications counter -------------------------------------------------------------
Process(clk_100MHz)

begin

if (rising_edge(clk_100MHz)) then
    if (rst_n = '0' or metric_counters_rst = '1') then
        total_label_0_classes_counter <= (others => '0');
    elsif (SNN_class_zero_pulse = '1') then
        total_label_0_classes_counter <= total_label_0_classes_counter + 1;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- total label 1 samples classifications counter -------------------------------------------------------------
Process(clk_100MHz)

begin

if (rising_edge(clk_100MHz)) then
    if (rst_n = '0' or metric_counters_rst = '1') then
        total_label_1_classes_counter <= (others => '0');
    elsif (SNN_class_one_pulse = '1') then
        total_label_1_classes_counter <= total_label_1_classes_counter + 1;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm top current state logic -------------------------------------------------------------------------------
fsm_top_current : Process (clk_100MHz, rst_n)

begin

if (rst_n = '0') then
    S_top_Current_State <= S_top_idle;

elsif (rising_edge(clk_100MHz)) then
    S_top_Current_State <= S_top_Next_State;
    
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- top fsm next state logic ----------------------------------------------------------------------------------
top_fsm_next_state_logic : Process (S_top_Current_State, start_pulse, watchdog_ready, fifo_empty, fifo_full, fifo_wr_ack, neorv32_run_counter,
                                    application_run_time_reg_data)

begin

case S_top_Current_State is

    when S_top_idle =>
        if (start_pulse = '1' and watchdog_ready = '1' and fifo_empty = '1') then
            S_top_Next_State <= S_top_fifo_and_counters_rst;
        else
            S_top_Next_State <= S_top_idle;
        end if;
    
    when S_top_fifo_and_counters_rst =>
        S_top_Next_State <= S_top_delay_cycle;
        
    when S_top_delay_cycle =>
        S_top_Next_State <= S_top_neorv32_run;
    
    when S_top_neorv32_run =>
        S_top_Next_State <= S_top_check_fifo_wr_ack;
        
    when S_top_check_fifo_wr_ack =>
        if (fifo_wr_ack = '0' or fifo_full = '1') then
            S_top_Next_State <= S_top_error;
        elsif (to_integer(unsigned(neorv32_run_counter)) < to_integer(unsigned(application_run_time_reg_data) - 1)) then
            S_top_Next_State <= S_top_check_fifo_wr_ack;
        else
            S_top_Next_State <= S_top_check_fifo_last_wr_ack;
        end if;
    
    when S_top_check_fifo_last_wr_ack =>
        if (fifo_wr_ack = '0' or fifo_full = '1') then
            S_top_Next_State <= S_top_error;
        else
            S_top_Next_State <= S_top_wait_for_watchdog_ready;
        end if;
    
    when S_top_wait_for_watchdog_ready =>
        if (watchdog_ready = '0') then
            S_top_Next_State <= S_top_wait_for_watchdog_ready;
        else
            S_top_Next_State <= S_top_done;
        end if;
    
    when S_top_done =>
        S_top_Next_State <= S_top_idle;
    
    when S_top_error =>
        S_top_Next_State <= S_top_error;
        
    end case;
        
end Process;
----------------------------------------------------------------------------------------------------------------

--- fsm top output decoding logic ------------------------------------------------------------------------------
top_fsm_outputs : Process (S_top_Current_State) 

begin

case S_top_Current_State is

when S_top_idle =>
    neorv32_run_counter_rst <= '0';
    neorv32_run_counter_en  <= '0';
    metric_counters_rst <= '0';
    neorv32_reset <= '0';
    watchdog_rst  <= '1';
    fifo_rst   <= '0';
    fifo_wr_en <= '0';
    top_ready  <= '1';
    top_done   <= '0';
    fifo_error <= '0';    

when S_top_fifo_and_counters_rst =>
    neorv32_run_counter_rst <= '1';
    neorv32_run_counter_en  <= '0';
    metric_counters_rst <= '1';
    neorv32_reset <= '0';
    watchdog_rst  <= '1';
    fifo_rst   <= '1';
    fifo_wr_en <= '0';
    top_ready  <= '0';
    top_done   <= '0';
    fifo_error <= '0'; 
        
when S_top_delay_cycle =>
    neorv32_run_counter_rst <= '0';
    neorv32_run_counter_en  <= '0';
    metric_counters_rst <= '0';
    neorv32_reset <= '0';
    watchdog_rst  <= '1';
    fifo_rst   <= '0';
    fifo_wr_en <= '0';
    top_ready  <= '0';
    top_done   <= '0';
    fifo_error <= '0';  
        
when S_top_neorv32_run =>
    neorv32_run_counter_rst <= '0';
    neorv32_run_counter_en  <= '1';
    metric_counters_rst <= '0';
    neorv32_reset <= '1';
    watchdog_rst  <= '1';
    fifo_rst   <= '0';
    fifo_wr_en <= '1';
    top_ready  <= '0';
    top_done   <= '0';
    fifo_error <= '0';    
        
when S_top_check_fifo_wr_ack =>
    neorv32_run_counter_rst <= '0';
    neorv32_run_counter_en  <= '1';
    metric_counters_rst <= '0';
    neorv32_reset <= '1';
    watchdog_rst  <= '1';
    fifo_rst   <= '0';
    fifo_wr_en <= '1';
    top_ready  <= '0';
    top_done   <= '0';
    fifo_error <= '0';    
        
when S_top_check_fifo_last_wr_ack =>
    neorv32_run_counter_rst <= '0';
    neorv32_run_counter_en  <= '0';
    metric_counters_rst <= '0';
    neorv32_reset <= '1';
    watchdog_rst  <= '1';
    fifo_rst   <= '0';
    fifo_wr_en <= '0';
    top_ready  <= '0';
    top_done   <= '0';
    fifo_error <= '0';    

when S_top_wait_for_watchdog_ready =>
    neorv32_run_counter_rst <= '0';
    neorv32_run_counter_en  <= '0';
    metric_counters_rst <= '0';
    neorv32_reset <= '0';
    watchdog_rst  <= '1';
    fifo_rst   <= '0';
    fifo_wr_en <= '0';
    top_ready  <= '0';
    top_done   <= '0';
    fifo_error <= '0'; 
       
when S_top_done =>
    neorv32_run_counter_rst <= '0';
    neorv32_run_counter_en  <= '0';
    metric_counters_rst <= '0';
    neorv32_reset <= '0';
    watchdog_rst  <= '0';
    fifo_rst   <= '0';
    fifo_wr_en <= '0';
    top_ready  <= '0';
    top_done   <= '1';                       
    fifo_error <= '0';    
        
when S_top_error =>
    neorv32_run_counter_rst <= '0';
    neorv32_run_counter_en  <= '0';
    metric_counters_rst <= '0';
    neorv32_reset <= '0';
    watchdog_rst  <= '0';
    fifo_rst   <= '0';
    fifo_wr_en <= '0';
    top_ready  <= '0';
    top_done   <= '0';  
    fifo_error <= '1';  
              
end case;

end Process;
-----------------------------------------------------------------------------------------------------------------

end Behavioral;
