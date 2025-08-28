
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM_2 is 
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
end FSM_2;

architecture Behavioral of FSM_2 is

type State_type is (fsm2_S_idle, fsm2_S_read_fifo, fsm2_S_check_for_valid_read, fsm2_S_fifo_to_reg, fsm2_S_check_reg_data, 
                    fsm2_S_new_data_to_read, fsm2_S_error);

signal fsm2_Current_State , fsm2_Next_State : State_type;

signal fsm_2_Q0_out : std_logic;
signal fsm_2_Q1_out : std_logic;

signal uB_has_read_data_pulse : std_logic;

begin

------------------------------------------------------------------------------------------------------------------------------------------------
--- pulse generator for uB having read the current data in reg ---

fsm_1_clocked : Process (clock_i, resetn_i, uB_has_read_data_i)

begin

if (resetn_i = '0') then
    fsm_2_Q0_out <= '0';
    fsm_2_Q1_out <= '0';
    
elsif (rising_edge(clock_i)) then
    fsm_2_Q0_out <= uB_has_read_data_i;
    fsm_2_Q1_out <= fsm_2_Q0_out;

end if;

end Process;

uB_has_read_data_pulse <= fsm_2_Q0_out and (not fsm_2_Q1_out);

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm 2 state logic ---

fsm_2 : Process (clock_i, resetn_i, fsm_1_error_i)

begin

if (resetn_i = '0') then
    fsm2_Current_State <= fsm2_S_idle;

elsif (rising_edge(clock_i)) then
    
    if (fsm_1_error_i = '1') then
        fsm2_Current_State <= fsm2_S_error;
    
    else
        fsm2_Current_State <= fsm2_Next_State;

    end if;
end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm 2 next logic ---

fsm_2_next_state_logic : Process (fsm2_Current_State, fifo_empty_i, fsm_1_ready_i, fifo_rd_valid_i, reg_fifo_data_equal, uB_has_read_data_pulse)

begin

case fsm2_Current_State is

    when fsm2_S_idle =>
        if (fifo_empty_i = '0' and fsm_1_ready_i = '0') then
            fsm2_Next_State <= fsm2_S_read_fifo;        
        else
            fsm2_Next_State <= fsm2_S_idle;
        end if;

    when fsm2_S_read_fifo =>
        fsm2_Next_State <= fsm2_S_check_for_valid_read;
    
    when fsm2_S_check_for_valid_read =>
        if (fifo_rd_valid_i = '0') then
            fsm2_Next_State <= fsm2_S_error;
        else
            fsm2_Next_State <= fsm2_S_fifo_to_reg;
        end if;
        
    when fsm2_S_fifo_to_reg =>
            fsm2_Next_State <= fsm2_S_check_reg_data;

    when fsm2_S_check_reg_data =>
        if (reg_fifo_data_equal = '1') then
            fsm2_Next_State <= fsm2_S_new_data_to_read;
        else
            fsm2_Next_State <= fsm2_S_error;
        end if;
                    
    when fsm2_S_new_data_to_read =>
        if (uB_has_read_data_pulse = '1' and fifo_empty_i = '0') then
            fsm2_Next_State <= fsm2_S_read_fifo;
        elsif (uB_has_read_data_pulse = '1' and fifo_empty_i = '1') then
            fsm2_Next_State <= fsm2_S_idle;
        else
            fsm2_Next_State <= fsm2_S_new_data_to_read;            
        end if;

    when fsm2_S_error =>
            fsm2_Next_State <= fsm2_S_error;
                 
    end case;
        
end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm 2 output decoding logic ---

fsm2_outputs : Process (fsm2_Current_State)

begin

case fsm2_Current_State is

when fsm2_S_idle =>
    fsm_2_ready_o    <= '1';
    fsm_2_error_o    <= '0';
    fsm_2_new_data_o <= '0';
    fifo_rd_en_o     <= '0';
    fifo_reg_en_o    <= '0';

when fsm2_S_read_fifo =>
    fsm_2_ready_o    <= '0';
    fsm_2_error_o    <= '0';
    fsm_2_new_data_o <= '0';
    fifo_rd_en_o     <= '1';
    fifo_reg_en_o    <= '0';

when fsm2_S_check_for_valid_read =>
    fsm_2_ready_o    <= '0';
    fsm_2_error_o    <= '0';
    fsm_2_new_data_o <= '0';
    fifo_rd_en_o     <= '0';
    fifo_reg_en_o    <= '0';
       
when fsm2_S_fifo_to_reg =>
    fsm_2_ready_o    <= '0';
    fsm_2_error_o    <= '0';
    fsm_2_new_data_o <= '0';
    fifo_rd_en_o     <= '0';
    fifo_reg_en_o    <= '1';

when fsm2_S_check_reg_data =>
    fsm_2_ready_o    <= '0';
    fsm_2_error_o    <= '0';
    fsm_2_new_data_o <= '0';
    fifo_rd_en_o     <= '0';
    fifo_reg_en_o    <= '0';
       
when fsm2_S_new_data_to_read =>
    fsm_2_ready_o    <= '0';
    fsm_2_error_o    <= '0';
    fsm_2_new_data_o <= '1';
    fifo_rd_en_o     <= '0';
    fifo_reg_en_o    <= '0';

when fsm2_S_error =>
    fsm_2_ready_o    <= '0';
    fsm_2_error_o    <= '1';
    fsm_2_new_data_o <= '0';
    fifo_rd_en_o     <= '0';
    fifo_reg_en_o    <= '0';
      
end case;

end Process;

end Behavioral;
