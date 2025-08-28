library IEEE;  
use IEEE.STD_LOGIC_1164.ALL; 

entity Top_level is 
Port (clk_i                       : in std_logic;  --100MHz
      rst_i                       : in std_logic;  --active high
      uBlaze_data_i               : in std_logic_vector(22 downto 0);
      setup_regs_data_o           : out std_logic_vector(15 downto 0);
      uB_to_hardware_signals_i    : in std_logic_vector(3 downto 0);
      hardware_to_uB_signals_o    : out std_logic_vector(3 downto 0);
      result_data_mem_o           : out std_logic_vector(31 downto 0);
      pc_data_o                   : out std_logic_vector(31 downto 0);
      ir_data_o                   : out std_logic_vector(31 downto 0);
      execute_states_data_o       : out std_logic_vector(3 downto 0);
      execute_branch_taken_data_o : out std_logic;
      mcause_data_o               : out std_logic_vector(5 downto 0);
      mepc_data_o                 : out std_logic_vector(31 downto 0);
      rs1_reg_data_o              : out std_logic_vector(31 downto 0);
      alu_comp_status_data_o      : out std_logic_vector(1 downto 0);
      ctrl_bus_1_data_o           : out std_logic_vector(31 downto 0);
      ctrl_bus_2_data_o           : out std_logic_vector(28 downto 0);
      mtvec_data_o                : out std_logic_vector(31 downto 0);
      hardware_ready_led_o        : out std_logic;
      hardware_error_led_o        : out std_logic 
     );
end Top_level;

architecture Behavioral of Top_level is

signal rst         : std_logic;
signal rst_n       : std_logic;

signal count_value : std_logic_vector(31 downto 0);

signal fsm_1_ready   : std_logic; 
signal fsm_2_ready   : std_logic; 

signal fsm_1_error   : std_logic; 
signal fsm_2_error   : std_logic;

signal hardware_ready : std_logic;
signal hardware_error : std_logic;

signal fsm_1_read_result_ready : std_logic;

signal fsm_2_new_data_in_reg_to_read : std_logic;

signal uB_has_read_result_data      : std_logic;
signal uB_start_application_run     : std_logic;
signal uB_has_read_current_reg_data : std_logic;
signal uB_reset_RAM_result_data     : std_logic;

signal fifo_wr_ack    : std_logic;
signal fifo_rd_valid  : std_logic;
signal fifo_wr_en     : std_logic;
signal fifo_rd_en     : std_logic;
signal fifo_full      : std_logic;
signal fifo_empty     : std_logic;
signal fifo_data_out  : std_logic_vector(233 downto 0); 
signal fifo_reg_en    : std_logic;
signal fifo_reg       : std_logic_vector(233 downto 0);   
signal fifo_rst       : std_logic;
signal fsm_1_rst_fifo_and_reg : std_logic;

signal DUT_reset_command : std_logic;

signal PC_data_temp : std_ulogic_vector(31 downto 0);
signal PC_data_out  : std_logic_vector(31 downto 0);

signal IR_data_temp : std_ulogic_vector(31 downto 0);
signal IR_data_out  : std_logic_vector(31 downto 0);

signal neorv32_execute_states : std_logic_vector(3 downto 0);

signal neorv32_branch_taken : std_logic;

signal mcause_data_temp : std_ulogic_vector(5 downto 0);
signal mcause_data_out  : std_logic_vector(5 downto 0);

signal mepc_data_temp : std_ulogic_vector(31 downto 0);
signal mepc_data_out  : std_logic_vector(31 downto 0);

signal mtvec_data_temp : std_ulogic_vector(31 downto 0);
signal mtvec_data_out  : std_logic_vector(31 downto 0);

signal rs1_reg_data_temp : std_ulogic_vector(31 downto 0);
signal rs1_reg_data_out  : std_logic_vector(31 downto 0);

signal alu_comp_status_data_temp : std_ulogic_vector(1 downto 0);
signal alu_comp_status_data_out  : std_logic_vector(1 downto 0);

signal ctrl_bus_data_temp : std_ulogic_vector(60 downto 0);
signal ctrl_bus_data_out  : std_logic_vector(60 downto 0);

signal Neorv32_fifo_data_in : std_logic_vector(233 downto 0);

signal reg_data_check : std_logic;

signal application_run_time_reg_data : std_logic_vector(15 downto 0); 

signal enable_fault_inj_reg_data : std_logic;
signal enable_fault_inj_reg_data_vector  : std_logic_vector(0 downto 0);

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

signal FIL_four_to_one_mux_selects : std_logic_vector(20 downto 1);

signal RAM_read_addr_in   : std_logic_vector(5 downto 0);
signal ram_data_out_temp  : std_ulogic_vector(31 downto 0);

signal result_data_mem_wr_pulse  : std_logic;
signal result_data_wr_address_temp : std_ulogic_vector(5 downto 0);
signal result_data_wr_address    : std_logic_vector(5 downto 0);
signal result_data_rd_address    : std_logic_vector(5 downto 0);
signal result_data_rd_data       : std_logic_vector(31 downto 0);
signal result_data_reset_done    : std_logic;

signal dmem_transfer_trigger : std_logic;
signal dmem_transfer_done : std_logic;
signal dmem_reset_trigger : std_logic;
signal dmem_reset_done    : std_logic;

signal dmem_to_result_data_temp : std_ulogic_vector(31 downto 0);
signal dmem_to_result_data : std_logic_vector(31 downto 0);

signal fault_injection_en : std_logic;

signal neorv32_pc_we : std_logic;

---------------------------------------------------------------------------------------------        

component FSM_1 is
  Port (clock_i                    : in std_logic;
        resetn_i                   : in std_logic;
        application_run_time_i     : in std_logic_vector(15 downto 0);
        start_application_run_i    : in std_logic;    
        fsm_2_ready_i              : in std_logic;
        fsm_2_error_i              : in std_logic;
        fsm_1_fifo_wr_o            : out std_logic;
        fifo_full_i                : in std_logic;
        fifo_wr_ack_i              : in std_logic;
        fsm_1_DUT_reset_command_o  : out std_logic;
        fsm_1_ready_o              : out std_logic;
        fsm_1_rst_fifo_and_reg_o   : out std_logic;
        fsm_1_error_o              : out std_logic;
        count_value_o              : out std_logic_vector(31 downto 0);
        fsm_1_dmem_transfer_trigger_o : out std_logic;
        dmem_transfer_done_i       : in std_logic;
        fsm_1_read_result_ready_o  : out std_logic;
        uB_has_read_result_data_i  : in std_logic;
        fsm_1_dmem_reset_trigger_o : out std_logic;
        dmem_reset_done_i          : in std_logic;
        fsm_1_fault_injection_en_o : out std_logic   
       );
end component;

component FSM_2 is 
  Port (clock_i             : in std_logic;
        resetn_i            : in std_logic;
        fifo_empty_i        : in std_logic;  
        fifo_rd_valid_i     : in std_logic;  
        uB_has_read_data_i  : in std_logic;
        fsm_1_ready_i       : in std_logic;
        fsm_1_error_i       : in std_logic;
        reg_fifo_data_equal : in std_logic;
        fifo_rd_en_o        : out std_logic;
        fifo_reg_en_o       : out std_logic;
        fsm_2_new_data_o    : out std_logic;
        fsm_2_ready_o       : out std_logic;
        fsm_2_error_o       : out std_logic
        );
end component;

component Bit_fault_controller is
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

component Setup_regs is
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

component Fault_Injection_Logic is
Port (bit_i                 : in std_logic;     
      four_to_one_mux_sel_i : in std_logic_vector(1 downto 0);
      bit_o                 : out std_logic
     );
end component;

COMPONENT fifo_generator_0
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(233 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(233 DOWNTO 0);
    full : OUT STD_LOGIC;
    wr_ack : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC 
  );
END COMPONENT;

component neorv32_ProcessorTop_Minimal is
  generic (
    -- Fault Injection Setup Modifications --
    NUM_RESULT_DATA_VALUES : natural := 20; -- bubble sort = 25, fibonacci series = 45, matrix multiplication = 16, heap sort = 20 (compile code too!)
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

component Result_data_mem is
  port (clk_i   : in  std_logic;
        rstn_i  : in std_logic;
        result_data_DMEM_reset_trigger_i : in std_logic;
        wr_en_i      : in std_logic;
        wr_address_i : in std_logic_vector(5 downto 0);
        wr_data_i    : in  std_logic_vector(31 downto 0);
        rd_address_i : in std_logic_vector(5 downto 0);
        result_data_rd_data_o    : out std_logic_vector(31 downto 0);
        result_data_reset_done_o : out std_logic
       );
end component;
       
begin
 
------------------------------------------------------------------------------------------------------------------------------------------------
--- IO signal mapping ---

hardware_ready <= fsm_1_ready and fsm_2_ready;
hardware_error <= fsm_1_error or fsm_2_error;

uB_start_application_run     <= uB_to_hardware_signals_i(0);
uB_has_read_current_reg_data <= uB_to_hardware_signals_i(1);
uB_has_read_result_data      <= uB_to_hardware_signals_i(2);
uB_reset_RAM_result_data     <= uB_to_hardware_signals_i(3);

hardware_to_uB_signals_o(0) <= fsm_2_new_data_in_reg_to_read;         
hardware_to_uB_signals_o(1) <= hardware_ready;  
hardware_to_uB_signals_o(2) <= hardware_error;
hardware_to_uB_signals_o(3) <= fsm_1_read_result_ready;

hardware_ready_led_o <= hardware_ready;
hardware_error_led_o <= hardware_error;

result_data_rd_address <= uBlaze_data_i(21 downto 16);

------------------------------------------------------------------------------------------------------------------------------------------------
--- Synchronising reset button with clock and inverting ---

rst      <= rst_i when rising_edge(clk_i);
rst_n    <= not rst_i when rising_edge(clk_i);

fifo_rst <= fsm_1_rst_fifo_and_reg or rst;

------------------------------------------------------------------------------------------------------------------------------------------------
--- NEORV32 RISCV core to generate program counter data to FIFO ---

DUT_neorv32_inst : neorv32_ProcessorTop_Minimal 
  port map(
    -- Global control --
    clk_i       => clk_i,
    rstn_i      => DUT_reset_command,
    FIL_four_to_one_mux_selects_i => FIL_four_to_one_mux_selects,
    program_counter_o             => PC_data_temp,
    dmem_transfer_trigger_i  => dmem_transfer_trigger,
    dmem_reset_trigger_i     => dmem_reset_trigger,
    result_data_wr_address_o => result_data_wr_address_temp,
    dmem_to_result_data_o    => dmem_to_result_data_temp,
    result_data_mem_wr_pulse_o => result_data_mem_wr_pulse,
    dmem_transfer_done_o     => dmem_transfer_done,
    dmem_reset_done_o        => dmem_reset_done,
    neorv32_pc_we_o          => neorv32_pc_we,
    instruction_register_o   => IR_data_temp,
    neorv32_execute_states_o => neorv32_execute_states,
    neorv32_branch_taken_o   => neorv32_branch_taken,
    mcause_reg_o             => mcause_data_temp,
    mepc_reg_o               => mepc_data_temp,
    mtvec_reg_o              => mtvec_data_temp,
    rs1_reg_o                => rs1_reg_data_temp,
    alu_comp_status_o        => alu_comp_status_data_temp,
    ctrl_bus_o               => ctrl_bus_data_temp       
  );

PC_data_out        <= to_stdlogicvector(PC_data_temp);
IR_data_out        <= to_stdlogicvector(IR_data_temp);
mcause_data_out    <= to_stdlogicvector(mcause_data_temp);
mepc_data_out      <= to_stdlogicvector(mepc_data_temp);
rs1_reg_data_out   <= to_stdlogicvector(rs1_reg_data_temp);
alu_comp_status_data_out <= to_stdlogicvector(alu_comp_status_data_temp);
ctrl_bus_data_out        <= to_stdlogicvector(ctrl_bus_data_temp);
mtvec_data_out           <= to_stdlogicvector(mtvec_data_temp);

Neorv32_fifo_data_in(31 downto 0)    <= PC_data_out;
Neorv32_fifo_data_in(63 downto 32)   <= IR_data_out;
Neorv32_fifo_data_in(67 downto 64)   <= neorv32_execute_states;
Neorv32_fifo_data_in(68)             <= neorv32_branch_taken;
Neorv32_fifo_data_in(74 downto 69)   <= mcause_data_out;
Neorv32_fifo_data_in(106 downto 75)  <= mepc_data_out;
Neorv32_fifo_data_in(138 downto 107) <= rs1_reg_data_out;
Neorv32_fifo_data_in(140 downto 139) <= alu_comp_status_data_out;
Neorv32_fifo_data_in(201 downto 141) <= ctrl_bus_data_out;
Neorv32_fifo_data_in(233 downto 202) <= mtvec_data_out;

result_data_wr_address <= to_stdlogicvector(result_data_wr_address_temp);
dmem_to_result_data    <= to_stdlogicvector(dmem_to_result_data_temp);

---------------------------------------------------------------------------------------------        
--- FIFO generator wizard component instantiation ---

FIFO_generator_0_inst : fifo_generator_0
  PORT MAP (
    clk    => clk_i,
    srst   => fifo_rst,
    din    => Neorv32_fifo_data_in,
    wr_en  => fifo_wr_en,
    rd_en  => fifo_rd_en,
    dout   => fifo_data_out,
    full   => fifo_full,
    wr_ack => fifo_wr_ack,
    empty  => fifo_empty,
    valid  => fifo_rd_valid
  );

------------------------------------------------------------------------------------------------------------------------------------------------
--- FIFO out register ---

fifo_reg_ff : Process (clk_i, rst_n)

begin

if (rst_n = '0') then
    fifo_reg <= (others => '0');
    
    elsif (rising_edge(clk_i)) then
        if (fsm_1_rst_fifo_and_reg = '1') then
            fifo_reg <= (others => '0');
            
        elsif (fifo_reg_en = '1') then
            fifo_reg <= fifo_data_out;
 
        end if;
end if;

end Process;
 
pc_data_o                   <= fifo_reg(31 downto 0);
ir_data_o                   <= fifo_reg(63 downto 32);
execute_states_data_o       <= fifo_reg(67 downto 64);
execute_branch_taken_data_o <= fifo_reg(68);
mcause_data_o               <= fifo_reg(74 downto 69);
mepc_data_o                 <= fifo_reg(106 downto 75);
rs1_reg_data_o              <= fifo_reg(138 downto 107);
alu_comp_status_data_o      <= fifo_reg(140 downto 139);
ctrl_bus_1_data_o           <= fifo_reg(172 downto 141);
ctrl_bus_2_data_o           <= fifo_reg(201 downto 173);
mtvec_data_o                <= fifo_reg(233 downto 202);

---------------------------------------------------------------------------------------------        
--- FIFO data out and reg data out comparator for fsm 2 check reg data state ---

fifo_and_reg_data_check : Process (fifo_data_out, fifo_reg)

begin

if (fifo_data_out = fifo_reg) then
    reg_data_check <= '1';
else
    reg_data_check <= '0';
end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- FSM 1 component instantiation ---

FSM_1_inst : FSM_1
  Port map (clock_i                    => clk_i,
            resetn_i                   => rst_n,
            application_run_time_i     => application_run_time_reg_data,
            start_application_run_i    => uB_start_application_run,
            fsm_2_ready_i              => fsm_2_ready,
            fsm_2_error_i              => fsm_2_error,
            fsm_1_fifo_wr_o            => fifo_wr_en,
            fifo_full_i                => fifo_full,
            fifo_wr_ack_i              => fifo_wr_ack,
            fsm_1_DUT_reset_command_o  => DUT_reset_command,
            fsm_1_ready_o              => fsm_1_ready,
            fsm_1_rst_fifo_and_reg_o   => fsm_1_rst_fifo_and_reg,
            fsm_1_error_o              => fsm_1_error,
            count_value_o              => count_value,
            fsm_1_dmem_transfer_trigger_o => dmem_transfer_trigger,
            dmem_transfer_done_i       => dmem_transfer_done,
            fsm_1_read_result_ready_o  => fsm_1_read_result_ready,
            uB_has_read_result_data_i  => uB_has_read_result_data,
            fsm_1_dmem_reset_trigger_o => dmem_reset_trigger,
            dmem_reset_done_i          => dmem_reset_done,
            fsm_1_fault_injection_en_o => fault_injection_en
           );

------------------------------------------------------------------------------------------------------------------------------------------------
--- FSM 2 component instantiation ---

FSM_2_inst : FSM_2
  Port map (clock_i             => clk_i,
            resetn_i            => rst_n,
            fifo_empty_i        => fifo_empty,
            fifo_rd_valid_i     => fifo_rd_valid,
            uB_has_read_data_i  => uB_has_read_current_reg_data,
            fsm_1_ready_i       => fsm_1_ready,
            fsm_1_error_i       => fsm_1_error,
            reg_fifo_data_equal => reg_data_check,
            fifo_rd_en_o        => fifo_rd_en,
            fifo_reg_en_o       => fifo_reg_en,
            fsm_2_new_data_o    => fsm_2_new_data_in_reg_to_read,
            fsm_2_ready_o       => fsm_2_ready,
            fsm_2_error_o       => fsm_2_error
           );
        
------------------------------------------------------------------------------------------------------------------------------------------------
--- result data ram for storing the dmem result data after each Neorv32 application run that the uB reads ---

Result_data_mem_inst : Result_data_mem port map (
        clk_i   => clk_i,
        rstn_i  => rst_n,
        result_data_DMEM_reset_trigger_i => uB_reset_RAM_result_data,
        wr_en_i => result_data_mem_wr_pulse,
        wr_address_i => result_data_wr_address,
        wr_data_i    => dmem_to_result_data,
        rd_address_i => result_data_rd_address,
        result_data_rd_data_o    => result_data_mem_o,
        result_data_reset_done_o => result_data_reset_done
       );
       
------------------------------------------------------------------------------------------------------------------------------------------------
--- setup register component instantiation ---

Setup_regs_inst : Setup_Regs 
  Port map (clk_i                  => clk_i,  
            rstn_i                 => rst_n,  
            uBlaze_data_i          => uBlaze_data_i,
            setup_regs_data_o      => setup_regs_data_o,  
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

------------------------------------------------------------------------------------------------------------------------------------------------
--- fault injection fsm enable bit logic (to only allow bit fault controllers to assert faults during DUT run) ---

bit_fault_inj_en <= enable_fault_inj_reg_data and fault_injection_en;

------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 1 fault injection controller ---

Bit_1_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en, 
          count_value_i               => count_value,
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_one_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(2 downto 1)
         );

------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 2 fault injection controller ---

Bit_2_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en,
          count_value_i               => count_value, 
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_two_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(4 downto 3)
         );

------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 3 fault injection controller ---

Bit_3_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en,
          count_value_i               => count_value,
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_three_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(6 downto 5)
         );

------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 4 fault injection controller ---

Bit_4_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en,
          count_value_i               => count_value,
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_four_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(8 downto 7)
         );
        
------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 5 fault injection controller ---

Bit_5_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en,
          count_value_i               => count_value,
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_five_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(10 downto 9)
         );
        
------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 6 fault injection controller ---

Bit_6_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en,
          count_value_i               => count_value,
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_six_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(12 downto 11)
         );
        
------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 7 fault injection controller ---

Bit_7_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en,
          count_value_i               => count_value,
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_seven_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(14 downto 13)
         );
                                   
------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 8 fault injection controller ---

Bit_8_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en,
          count_value_i               => count_value, 
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_eight_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(16 downto 15)
         );

------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 9 fault injection controller ---

Bit_9_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en,
          count_value_i               => count_value,
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_nine_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(18 downto 17)
         );
        
------------------------------------------------------------------------------------------------------------------------------------------------
--- bit 10 fault injection controller ---

Bit_10_Fault_Controller_inst : Bit_fault_controller
port map (clk_i                       => clk_i,
          rstn_i                      => rst_n,
          bit_fault_inj_en_i          => bit_fault_inj_en, 
          count_value_i               => count_value, 
          stuck_at_hold_time_i        => stuck_at_hold_time_reg_data,
          bit_setup_reg_i             => bit_ten_reg_data,
          neorv32_pc_we_i             => neorv32_pc_we,
          four_to_one_mux_sel_o       => FIL_four_to_one_mux_selects(20 downto 19)
         );        
                      
------------------------------------------------------------------------------------------------------------------------------------------------
                              
end Behavioral;
