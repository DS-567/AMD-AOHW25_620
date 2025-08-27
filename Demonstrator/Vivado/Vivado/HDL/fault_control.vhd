
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;   

entity fault_control is
Generic (fifo_delay_cycles : natural);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      inject_faults_button_i : in std_logic;
      clear_faults_button_i  : in std_logic;
      fifo_write_cycles_i : in std_logic_vector(11 downto 0);
      bit_fault_sels_i : in std_logic_vector(20 downto 1);
      neorv32_pc_we_i  : in std_logic;
      watchdog_en_i    : in std_logic;
      watchdog_ready_i : in std_logic;
      fifo_empty_i : in std_logic;
      fifo_full_i  : in std_logic;
      fifo_wr_en_o : out std_logic;
      fifo_rst_o : out std_logic;
      watchdog_rst_o  : out std_logic;
      faults_active_o : out std_logic;
      neorv32_fault_sels_o  : out std_logic_vector(20 downto 1);
      fault_control_error_o : out std_logic     
    );
end fault_control;

architecture Behavioral of fault_control is

attribute keep: boolean;

type State_type is (S_idle, S_reset_watchdog, S_watchdog_ready_wait, S_clear_button_wait, S_fault_inject_delay, S_fifo_wr_counter_wait,
                    S_reset_fifo_and_counter, S_error);
                                                           
signal S_Current_State, S_Next_State : State_type;
attribute keep of S_Current_State: signal is true;
attribute keep of S_Next_State: signal is true; 

signal inject_fault_pulse : std_logic;
attribute keep of inject_fault_pulse: signal is true; 

signal clear_fault_pulse : std_logic;
attribute keep of clear_fault_pulse: signal is true; 

signal fifo_write_counter : unsigned(15 downto 0);
signal fifo_write_counter_en : std_logic;
signal fifo_write_counter_rst : std_logic;
attribute keep of fifo_write_counter: signal is true; 
attribute keep of fifo_write_counter_en: signal is true; 
attribute keep of fifo_write_counter_rst: signal is true; 

signal inject_faults_en : std_logic;
attribute keep of inject_faults_en: signal is true; 

signal mux_selects : std_logic_vector(20 downto 1);
attribute keep of mux_selects: signal is true; 

begin

--- fifo write counter (counts cycles of neorv32 data that is written to FIFO) --------------------------------
Process (clk_i, rstn_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0' or fifo_write_counter_rst = '1') then
        fifo_write_counter <= (others => '0');
    elsif (fifo_write_counter_en = '1') then
        fifo_write_counter <= fifo_write_counter + 1;
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- inject faults button rising pulse generator ---------------------------------------------------------------
inject_fault_pulse_gen : pulse_generator
port map (clk_i   => clk_i,
          rstn_i  => rstn_i,
          bit_i   => inject_faults_button_i,
          pulse_o => inject_fault_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- clear faults button rising pulse generator ----------------------------------------------------------------
clear_fault_pulse_gen : pulse_generator
port map (clk_i   => clk_i,
          rstn_i  => rstn_i,
          bit_i   => clear_faults_button_i,
          pulse_o => clear_fault_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- fsm current state logic -----------------------------------------------------------------------------------
fsm_current : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    S_Current_State <= S_idle;

elsif (rising_edge(clk_i)) then
    S_Current_State <= S_Next_State;
    
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm next state logic --------------------------------------------------------------------------------------
fsm_next : Process (S_Current_State, watchdog_ready_i, inject_fault_pulse, watchdog_en_i, fifo_empty_i, fifo_full_i, fifo_write_counter,
                    fifo_write_cycles_i, clear_fault_pulse)

begin
                   
case S_Current_State is

when S_idle =>
    if (inject_fault_pulse = '1' and watchdog_en_i = '1' and fifo_empty_i = '1' and watchdog_ready_i = '1') then
        S_Next_State <= S_reset_watchdog;
    elsif (inject_fault_pulse = '1' and watchdog_en_i = '0' and fifo_empty_i = '1' and watchdog_ready_i = '1') then
        S_Next_State <= S_clear_button_wait;
    elsif (fifo_empty_i = '0') then
        S_Next_State <= S_error;
    else
        S_Next_State <= S_idle;
    end if;

when S_reset_watchdog =>
    S_Next_State <= S_watchdog_ready_wait;
    
when S_watchdog_ready_wait =>
    if (watchdog_ready_i = '1') then
        S_Next_State <= S_fault_inject_delay;
    else
        S_Next_State <= S_watchdog_ready_wait;
    end if;
                
when S_fault_inject_delay =>
    if (fifo_full_i = '1') then
        S_Next_State <= S_error;
    elsif (fifo_write_counter >= fifo_delay_cycles) then
        S_Next_State <= S_fifo_wr_counter_wait;
    else
        S_Next_State <= S_fault_inject_delay;
    end if;
    
when S_fifo_wr_counter_wait =>
    if (fifo_full_i = '1') then
        S_Next_State <= S_error;
    elsif (fifo_write_counter >= unsigned(fifo_write_cycles_i)) then
        S_Next_State <= S_clear_button_wait;
    else
        S_Next_State <= S_fifo_wr_counter_wait;
    end if;

when S_clear_button_wait =>
    if (clear_fault_pulse = '1') then
        S_Next_State <= S_reset_fifo_and_counter;
    else
        S_Next_State <= S_clear_button_wait;
    end if; 
        
when S_reset_fifo_and_counter =>
    S_Next_State <= S_idle;

when S_error =>
    S_Next_State <= S_error;    
    
end case;

end Process;
------------------------------------------------------------------------------------------------------------------

----- fsm output decoding logic ----------------------------------------------------------------------------------
fsm_outputs : Process (S_Current_State) 

begin

case S_Current_State is
     
when S_idle =>
    fifo_write_counter_en  <= '0';
    fifo_write_counter_rst <= '0';
    inject_faults_en <= '0';
    fifo_wr_en_o <= '0';
    fifo_rst_o   <= '0'; 
    watchdog_rst_o  <= '0';
    faults_active_o <= '0';
    fault_control_error_o <= '0';

when S_reset_watchdog =>
    fifo_write_counter_en  <= '0';
    fifo_write_counter_rst <= '0';
    inject_faults_en <= '0';
    fifo_wr_en_o <= '0';
    fifo_rst_o   <= '0'; 
    watchdog_rst_o  <= '1';
    faults_active_o <= '0';
    fault_control_error_o <= '0';

when S_watchdog_ready_wait =>
    fifo_write_counter_en  <= '0';
    fifo_write_counter_rst <= '0';
    inject_faults_en <= '0';
    fifo_wr_en_o <= '0';
    fifo_rst_o   <= '0'; 
    watchdog_rst_o  <= '0';
    faults_active_o <= '0';
    fault_control_error_o <= '0';
    
when S_fault_inject_delay =>
    fifo_write_counter_en  <= '1';
    fifo_write_counter_rst <= '0';
    inject_faults_en <= '0';
    fifo_wr_en_o <= '1';
    fifo_rst_o   <= '0'; 
    watchdog_rst_o  <= '0';
    faults_active_o <= '1';
    fault_control_error_o <= '0';

when S_fifo_wr_counter_wait =>
    fifo_write_counter_en  <= '1';
    fifo_write_counter_rst <= '0';
    inject_faults_en <= '1';
    fifo_wr_en_o <= '1';
    fifo_rst_o   <= '0'; 
    watchdog_rst_o  <= '0';
    faults_active_o <= '1';
    fault_control_error_o <= '0';

when S_clear_button_wait =>
    fifo_write_counter_en  <= '0';
    fifo_write_counter_rst <= '0';
    inject_faults_en <= '1';
    fifo_wr_en_o <= '0';
    fifo_rst_o   <= '0'; 
    watchdog_rst_o  <= '0';
    faults_active_o <= '1';
    fault_control_error_o <= '0';  

when S_reset_fifo_and_counter =>
    fifo_write_counter_en  <= '0';
    fifo_write_counter_rst <= '1';
    inject_faults_en <= '0';
    fifo_wr_en_o <= '0';
    fifo_rst_o   <= '1'; 
    watchdog_rst_o  <= '0';
    faults_active_o <= '1';
    fault_control_error_o <= '0';  

when S_error =>
    fifo_write_counter_en  <= '0';
    fifo_write_counter_rst <= '0';
    inject_faults_en <= '0';
    fifo_wr_en_o <= '0';
    fifo_rst_o   <= '0'; 
    watchdog_rst_o  <= '0';
    faults_active_o <= '0';
    fault_control_error_o <= '1'; 
                                           
end case;

end Process;
----------------------------------------------------------------------------------------------------------------

--- PC bit 1 fault controller ---------------------------------------------------------------------------------
PC_bit_1 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(2 downto 1),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(2 downto 1)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 2 fault controller ---------------------------------------------------------------------------------
PC_bit_2 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(4 downto 3),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(4 downto 3)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 3 fault controller ---------------------------------------------------------------------------------
PC_bit_3 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(6 downto 5),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(6 downto 5)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 4 fault controller ---------------------------------------------------------------------------------
PC_bit_4 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(8 downto 7),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(8 downto 7)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 5 fault controller ---------------------------------------------------------------------------------
PC_bit_5 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(10 downto 9),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(10 downto 9)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 6 fault controller ---------------------------------------------------------------------------------
PC_bit_6 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(12 downto 11),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(12 downto 11)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 7 fault controller ---------------------------------------------------------------------------------
PC_bit_7 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(14 downto 13),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(14 downto 13)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 8 fault controller ---------------------------------------------------------------------------------
PC_bit_8 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(16 downto 15),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(16 downto 15)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 9 fault controller ---------------------------------------------------------------------------------
PC_bit_9 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(18 downto 17),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(18 downto 17)   
    );
---------------------------------------------------------------------------------------------------------------

--- PC bit 10 fault controller --------------------------------------------------------------------------------
PC_bit_10 : bit_fault_controller Port map
    (clk_i  => clk_i,
     rstn_i => rstn_i,
     bit_fault_type_i => bit_fault_sels_i(20 downto 19),
     inject_fault_en_i => inject_faults_en,  
     neorv32_pc_we_i => neorv32_pc_we_i,
     four_to_one_mux_sel_o => mux_selects(20 downto 19)   
    );
---------------------------------------------------------------------------------------------------------------

--- neorv32 fault injection select lines ----------------------------------------------------------------------
neorv32_fault_sels_o <= mux_selects;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
