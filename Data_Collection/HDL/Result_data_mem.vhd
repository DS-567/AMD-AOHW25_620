library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity Result_data_mem is
  port (clk_i   : in  std_logic;
        rstn_i  : in std_logic;
        result_data_DMEM_reset_trigger_i : in std_logic;
        wr_en_i    : in std_logic;
        wr_address_i : in std_logic_vector(5 downto 0);
        wr_data_i    : in  std_logic_vector(31 downto 0);
        rd_address_i : in std_logic_vector(5 downto 0);
        result_data_rd_data_o    : out std_logic_vector(31 downto 0);
        result_data_reset_done_o : out std_logic
       );
end entity Result_data_mem;

architecture Behavioral of Result_data_mem is

signal result_data_Q0_out : std_logic;
signal result_data_Q1_out : std_logic;
signal result_data_reset_DMEM_pulse : std_logic;

type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
signal result_data_mem : ram_type;

signal result_data_wr_data_mux_out : std_logic_vector(31 downto 0);
signal result_data_wr_address_mux_out : std_logic_vector(5 downto 0);
signal result_data_mux_sel : std_logic;

signal result_data_reset_wr_en : std_logic;

signal result_data_addr_counter  : std_logic_vector(5 downto 0); 
signal result_data_counter_en    : std_logic;
signal result_data_counter_rst   : std_logic;

type State_type is (result_data_fsm_S_idle, result_data_fsm_S_write_zero, result_data_fsm_S_counter_inc, result_data_fsm_S_rst_counter, 
                    result_data_fsm_S_done);
                    
signal result_data_fsm_Current_State , result_data_fsm_Next_State : State_type;

begin
 
------------------------------------------------------------------------------------------------------------------------------------------------
--- pulse generator for triggering the writing of all zeros to the DMEM (BRAM) ---

trigger_DMEM_reset_pulse_generator : Process (clk_i, rstn_i, result_data_DMEM_reset_trigger_i)

begin

if (rstn_i = '0') then  
    result_data_Q0_out <= '0';
    result_data_Q1_out <= '0';
    
elsif (rising_edge(clk_i)) then
    result_data_Q0_out <= result_data_DMEM_reset_trigger_i;
    result_data_Q1_out <= result_data_Q0_out;

end if;

end Process;

result_data_reset_DMEM_pulse <= result_data_Q0_out and (not result_data_Q1_out);

------------------------------------------------------------------------------------------------------------------------------------------------
--- counter for generating RAM addresses to write zeros to ---

reset_write_addr_counter : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    result_data_addr_counter <= (others => '0');

elsif (rising_edge(clk_i)) then
    
    if (result_data_counter_rst = '1') then
        result_data_addr_counter <= (others => '0');
        
    elsif (result_data_counter_en = '1') then
        result_data_addr_counter <= std_logic_vector(unsigned(result_data_addr_counter) + 1);
    
    end if;
end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm state logic ---

fsm_state : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    result_data_fsm_Current_State <= result_data_fsm_S_idle;

elsif (rising_edge(clk_i)) then
    result_data_fsm_Current_State <= result_data_fsm_Next_State;

end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm next state logic ---

fsm_next_state_logic : Process (result_data_fsm_Current_State, result_data_reset_DMEM_pulse, rstn_i, result_data_addr_counter)

begin

case result_data_fsm_Current_State is

    when result_data_fsm_S_idle =>
        if (result_data_reset_DMEM_pulse = '1') then
            result_data_fsm_Next_State <= result_data_fsm_S_write_zero;
        else
            result_data_fsm_Next_State <= result_data_fsm_S_idle;
        end if;

    when result_data_fsm_S_write_zero =>
        result_data_fsm_Next_State <= result_data_fsm_S_counter_inc;    
        
    when result_data_fsm_S_counter_inc =>
        if (result_data_addr_counter = "111111") then      -- 63 (last RAM location)  
            result_data_fsm_Next_State <= result_data_fsm_S_rst_counter;
        else
            result_data_fsm_Next_State <= result_data_fsm_S_write_zero;
        end if;
        
     when result_data_fsm_S_rst_counter =>
        result_data_fsm_Next_State <= result_data_fsm_S_done;
        
     when result_data_fsm_S_done =>
        result_data_fsm_Next_State <= result_data_fsm_S_idle;

end case;
        
end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm output decoding logic ---

fsm_outputs : Process (result_data_fsm_Current_State)

begin

case result_data_fsm_Current_State is

    when result_data_fsm_S_idle =>
        result_data_reset_done_o <= '0';
        result_data_counter_en   <= '0';
        result_data_counter_rst  <= '0';
        result_data_mux_sel      <= '0';
        result_data_reset_wr_en  <= '0';

    when result_data_fsm_S_write_zero =>
        result_data_reset_done_o <= '0';
        result_data_counter_en   <= '0';
        result_data_counter_rst  <= '0';
        result_data_mux_sel      <= '1';  
        result_data_reset_wr_en  <= '1';
        
    when result_data_fsm_S_counter_inc =>
        result_data_reset_done_o <= '0';
        result_data_counter_en   <= '1';
        result_data_counter_rst  <= '0';
        result_data_mux_sel      <= '1';  
        result_data_reset_wr_en  <= '0';
                  
    when result_data_fsm_S_rst_counter =>
        result_data_reset_done_o <= '0';
        result_data_counter_en   <= '0';
        result_data_counter_rst  <= '1';
        result_data_mux_sel      <= '0';  
        result_data_reset_wr_en  <= '0';

    when result_data_fsm_S_done =>
        result_data_reset_done_o <= '1';
        result_data_counter_en   <= '0';
        result_data_counter_rst  <= '0';        
        result_data_mux_sel      <= '0'; 
        result_data_reset_wr_en  <= '0';
                    
end case;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- result data BRAM mux outputs ---

result_data_wr_data_mux_out <= wr_data_i when (result_data_mux_sel = '0') else x"00000000";

result_data_wr_address_mux_out <= wr_address_i when (result_data_mux_sel = '0') else result_data_addr_counter;

------------------------------------------------------------------------------------------------------------------------------------------------
--- result data BRAM ---

Process(clk_i) is
 
 begin
   
 if rising_edge(clk_i) then
     if (wr_en_i = '1' or result_data_reset_wr_en = '1') then
         result_data_mem(to_integer(unsigned(result_data_wr_address_mux_out))) <= result_data_wr_data_mux_out;
     end if;
     
     result_data_rd_data_o <= result_data_mem(to_integer(unsigned(rd_address_i)));
 
 end if;
 
 end Process;
 
 ------------------------------------------------------------------------------------------------------------------------------------------------

end Behavioral;
