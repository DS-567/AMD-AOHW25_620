
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_1 is 
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
end FSM_1;

architecture Behavioral of FSM_1 is

type State_type is (fsm1_S_idle, fsm1_S_DUT_run, fsm1_S_check_fifo_wr_ack, fsm1_S_check_fifo_last_wr_ack, fsm1_S_dmem_transfer_trigger,
                    fsm1_S_dmem_transfer_wait, fsm1_S_one_cycle_delay, fsm1_S_wait_for_uB_result_data_read, fsm1_S_done, fsm1_S_rst_fifo_and_reg, 
                    fsm1_S_rst_DMEM, fsm1_S_error);
                    
signal fsm1_Current_State, fsm1_Next_State : State_type;

signal fsm_1_counter_en   : std_logic;
signal fsm_1_count        : std_logic_vector(31 downto 0);
signal fsm_1_counter_rst : std_logic;

signal dmem_transfer_triger_delay_count_en  : std_logic;
signal dmem_transfer_triger_delay_count_rst : std_logic;
signal dmem_transfer_triger_delay_count     : std_logic_vector(2 downto 0);
signal dmem_transfer_triger_delay_threshold : std_logic_vector(2 downto 0) := "010";

signal fsm_1_Q0_out : std_logic;
signal fsm_1_Q1_out : std_logic;
signal fsm_1_start_application_run_pulse : std_logic;

begin

------------------------------------------------------------------------------------------------------------------------------------------------
--- pulse generator for starting application run ---

fsm_1_clocked : Process (clock_i, resetn_i, start_application_run_i)

begin

if (resetn_i = '0') then
    fsm_1_Q0_out <= '0';
    fsm_1_Q1_out <= '0';
    
elsif (rising_edge(clock_i)) then
    fsm_1_Q0_out <= start_application_run_i;
    fsm_1_Q1_out <= fsm_1_Q0_out;

end if;

end Process;

fsm_1_start_application_run_pulse <= fsm_1_Q0_out and (not fsm_1_Q1_out);

------------------------------------------------------------------------------------------------------------------------------------------------
--- counter for timing how long the application runs for ---

fsm_1_counter : Process (clock_i, resetn_i)

begin

if (resetn_i = '0') then
    fsm_1_count <= (others => '0');

elsif (rising_edge(clock_i)) then

    if (fsm_1_counter_rst = '1') then
        fsm_1_count <= (others => '0');
        
    elsif (fsm_1_counter_en = '1') then
        fsm_1_count <= std_logic_vector(unsigned(fsm_1_count) + 1);
 
    end if;
end if;

end Process;

count_value_o <= fsm_1_count;

------------------------------------------------------------------------------------------------------------------------------------------------
--- counter for creating a delay to assert the DMA trigger interupt for more than one cycle ---

dma_trigger_interupt_counter : Process (clock_i, resetn_i)

begin

if (resetn_i = '0') then
    dmem_transfer_triger_delay_count <= (others => '0');

elsif (rising_edge(clock_i)) then

    if (dmem_transfer_triger_delay_count_rst = '1') then
        dmem_transfer_triger_delay_count <= (others => '0');
        
    elsif (dmem_transfer_triger_delay_count_en = '1') then
        dmem_transfer_triger_delay_count <= std_logic_vector(unsigned(dmem_transfer_triger_delay_count) + 1);
 
    end if;
end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm 1 state logic ---

fsm_1 : Process (clock_i, resetn_i, fsm_2_error_i)

begin

if (resetn_i = '0') then
    fsm1_Current_State <= fsm1_S_idle;

elsif (rising_edge(clock_i)) then
    
    if (fsm_2_error_i = '1' or fifo_full_i = '1') then
        fsm1_Current_State <= fsm1_S_error;
    
    else
        fsm1_Current_State <= fsm1_Next_State;

    end if;
end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm1 next state logic ---

fsm_1_next_state_logic : Process (fsm1_Current_State, fsm_1_start_application_run_pulse, fsm_2_ready_i, fifo_wr_ack_i, application_run_time_i, 
                                  fsm_1_count, dmem_transfer_done_i, uB_has_read_result_data_i, DMEM_reset_done_i,
                                  dmem_transfer_triger_delay_count, dmem_transfer_triger_delay_threshold)

begin

case fsm1_Current_State is

    when fsm1_S_idle =>
        if (fsm_1_start_application_run_pulse = '1' and fsm_2_ready_i = '1') then
            fsm1_Next_State <= fsm1_S_DUT_run;
        else
            fsm1_Next_State <= fsm1_S_idle;
        end if;

    when fsm1_S_DUT_run =>
            fsm1_Next_State <= fsm1_S_check_fifo_wr_ack;
        
    when fsm1_S_check_fifo_wr_ack =>
        if (fifo_wr_ack_i = '0') then
            fsm1_Next_State <= fsm1_S_error;
        elsif (to_integer(unsigned(fsm_1_count)) < to_integer(unsigned(application_run_time_i) - 1)) then
            fsm1_Next_State <= fsm1_S_check_fifo_wr_ack;
        else
            fsm1_Next_State <= fsm1_S_check_fifo_last_wr_ack;
        end if;
    
    when fsm1_S_check_fifo_last_wr_ack =>
        if (fifo_wr_ack_i = '0') then
            fsm1_Next_State <= fsm1_S_error;
        else
            fsm1_Next_State <= fsm1_S_dmem_transfer_trigger;
        end if;
    
    when fsm1_S_dmem_transfer_trigger =>
        if (to_integer(unsigned(dmem_transfer_triger_delay_count)) >= to_integer(unsigned(dmem_transfer_triger_delay_threshold))) then
            fsm1_Next_State <= fsm1_S_dmem_transfer_wait;
        else
            fsm1_Next_State <= fsm1_S_dmem_transfer_trigger;
        end if;
    
    when fsm1_S_dmem_transfer_wait =>
        if (dmem_transfer_done_i = '1') then
            fsm1_Next_State <= fsm1_S_one_cycle_delay;
        else
            fsm1_Next_State <= fsm1_S_dmem_transfer_wait;
        end if;
    
    when fsm1_S_one_cycle_delay =>
        fsm1_Next_State <= fsm1_S_wait_for_uB_result_data_read;
    
    when fsm1_S_wait_for_uB_result_data_read =>
        if (uB_has_read_result_data_i = '1') then
            fsm1_Next_State <= fsm1_S_done;
        else
            fsm1_Next_State <= fsm1_S_wait_for_uB_result_data_read;
        end if;
    
    when fsm1_S_done =>
        if (fsm_2_ready_i = '1') then  
            fsm1_Next_State <= fsm1_S_rst_fifo_and_reg;
        else
            fsm1_Next_State <= fsm1_S_done;
        end if;
    
    when fsm1_S_rst_fifo_and_reg=>
        fsm1_Next_State <= fsm1_S_rst_DMEM;
        
    when fsm1_S_rst_DMEM =>
        if (DMEM_reset_done_i = '1') then
            fsm1_Next_State <= fsm1_S_idle;
        else
            fsm1_Next_State <= fsm1_S_rst_DMEM;
        end if;
        
    when fsm1_S_error =>
        fsm1_Next_State <= fsm1_S_error;
        
    end case;
        
end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm1 output decoding logic ---

fsm1_outputs : Process (fsm1_Current_State) 

begin

case fsm1_Current_State is

when fsm1_S_idle =>
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '1';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '0';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '0';
    
when fsm1_S_DUT_run =>
    fsm_1_counter_en     <= '1';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '1';
    fsm_1_fifo_wr_o               <= '1';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '1';
    
when fsm1_S_check_fifo_wr_ack =>
    fsm_1_counter_en     <= '1';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '1';
    fsm_1_fifo_wr_o               <= '1';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '1';
    
when fsm1_S_check_fifo_last_wr_ack =>
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '1';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '1';

when fsm1_S_dmem_transfer_trigger =>
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '1';
    fsm_1_DUT_reset_command_o     <= '0';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '1';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '1';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '0';

when fsm1_S_dmem_transfer_wait =>
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '0';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '0';

when fsm1_S_one_cycle_delay =>
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '0';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '0';
    
when fsm1_S_wait_for_uB_result_data_read =>
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0'; 
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '0';     
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '1';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '0';
        
when fsm1_S_rst_fifo_and_reg => 
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '0';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '1';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '1';
    fsm_1_fault_injection_en_o <= '0';

when fsm1_S_rst_DMEM => 
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '0';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '1';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '0';
    
when fsm1_S_done =>
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '0';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '0';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '0';
    
when fsm1_S_error =>
    fsm_1_counter_en     <= '0';
    fsm_1_ready_o       <= '0';
    fsm_1_error_o       <= '1';
    fsm_1_counter_rst   <= '0';
    fsm_1_DUT_reset_command_o     <= '0';
    fsm_1_fifo_wr_o               <= '0';
    fsm_1_rst_fifo_and_reg_o      <= '0';
    fsm_1_dmem_transfer_trigger_o <= '0';
    fsm_1_read_result_ready_o     <= '0';
    fsm_1_dmem_reset_trigger_o    <= '0';
    dmem_transfer_triger_delay_count_en  <= '0';
    dmem_transfer_triger_delay_count_rst <= '0';
    fsm_1_fault_injection_en_o <= '0';
    
end case;

end Process;

end Behavioral;
