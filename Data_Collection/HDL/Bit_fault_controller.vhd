
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bit_fault_controller is
  Port (clk_i                 : in std_logic;
        rstn_i                : in std_logic; 
        bit_fault_inj_en_i    : in std_logic;   
        count_value_i         : in std_logic_vector(31 downto 0); 
        stuck_at_hold_time_i  : in std_logic_vector(15 downto 0); 
        bit_setup_reg_i       : in std_logic_vector(53 downto 0); 
        neorv32_pc_we_i       : in std_logic;
        four_to_one_mux_sel_o : out std_logic_vector(1 downto 0)
       );
end Bit_fault_controller;

architecture Behavioral of Bit_fault_controller is

attribute keep: boolean;

signal fault_one_type    : std_logic_vector(1 downto 0);
signal fault_two_type    : std_logic_vector(1 downto 0);
signal fault_three_type  : std_logic_vector(1 downto 0);

signal fault_one_time_int    : integer range 0 to 65535;
signal fault_two_time_int    : integer range 0 to 65535;
signal fault_three_time_int  : integer range 0 to 65535;

attribute keep of fault_one_time_int: signal is true;
attribute keep of fault_two_time_int: signal is true;
attribute keep of fault_three_time_int: signal is true;

signal stuck_at_zero_trigger : std_logic;
signal stuck_at_one_trigger  : std_logic;
signal bit_flip_trigger      : std_logic;
attribute keep of stuck_at_zero_trigger: signal is true;
attribute keep of stuck_at_one_trigger: signal is true;
attribute keep of bit_flip_trigger: signal is true;

type State_type is (no_fault, sa0, sa1, bit_flip);
signal Current_State , Next_State : State_type;
attribute keep of Current_State: signal is true;
attribute keep of Next_State: signal is true;

signal count_value_int : integer;
attribute keep of count_value_int: signal is true;

signal stuck_at_hold_time_int : integer range 0 to 65535;
attribute keep of stuck_at_hold_time_int: signal is true;

signal Q0_out : std_logic; 
signal Q1_out : std_logic;

begin

------------------------------------------------------------------------------------------------------------------------------------------------
--- assigning fault types and times to internal logic signals for fsm below ---

fault_one_type    <= bit_setup_reg_i(1 downto 0);
fault_two_type    <= bit_setup_reg_i(3 downto 2);
fault_three_type  <= bit_setup_reg_i(5 downto 4);

fault_one_time_int   <= to_integer(unsigned(bit_setup_reg_i(21 downto 6)));        
fault_two_time_int   <= to_integer(unsigned(bit_setup_reg_i(37 downto 22)));
fault_three_time_int <= to_integer(unsigned(bit_setup_reg_i(53 downto 38)));

count_value_int <= to_integer(unsigned(count_value_i));

stuck_at_hold_time_int <= to_integer(unsigned(stuck_at_hold_time_i));

stuck_at_zero_trigger <= '1' when ( 
    (bit_fault_inj_en_i = '1' and fault_one_type = "01" and count_value_int >= fault_one_time_int-1 and count_value_int < fault_one_time_int + stuck_at_hold_time_int-1) or
    (bit_fault_inj_en_i = '1' and fault_two_type = "01" and count_value_int >= fault_two_time_int-1 and count_value_int < fault_two_time_int + stuck_at_hold_time_int-1) or
    (bit_fault_inj_en_i = '1' and fault_three_type = "01" and count_value_int >= fault_three_time_int-1 and count_value_int < fault_three_time_int + stuck_at_hold_time_int-1))
        
    else '0';
                                    
stuck_at_one_trigger  <= '1' when ( 
    (bit_fault_inj_en_i = '1' and fault_one_type = "10" and count_value_int >= fault_one_time_int-1 and count_value_int < fault_one_time_int + stuck_at_hold_time_int-1) or
    (bit_fault_inj_en_i = '1' and fault_two_type = "10" and count_value_int >= fault_two_time_int-1 and count_value_int < fault_two_time_int + stuck_at_hold_time_int-1) or
    (bit_fault_inj_en_i = '1' and fault_three_type = "10" and count_value_int >= fault_three_time_int-1 and count_value_int < fault_three_time_int + stuck_at_hold_time_int-1))    
    
    else '0';

bit_flip_trigger <= '1' when (
    (bit_fault_inj_en_i = '1' and fault_one_type = "11" and count_value_int = fault_one_time_int-1) or
    (bit_fault_inj_en_i = '1' and fault_two_type = "11" and count_value_int = fault_two_time_int-1) or
    (bit_fault_inj_en_i = '1' and fault_three_type = "11" and count_value_int = fault_three_time_int-1) ) 
    
    else '0'; 
                         
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- bit fsm next state logic ---
 
process (clk_i, rstn_i, Current_State, stuck_at_zero_trigger, stuck_at_one_trigger, bit_flip_trigger, neorv32_pc_we_i)

begin

if (rstn_i = '0') then     
    current_state <= no_fault;

elsif (rising_edge(clk_i)) then
        current_state <= next_state;

end if;

case current_state is

when no_fault =>
    if (stuck_at_zero_trigger = '1') then
        next_state <= sa0;
        
    elsif (stuck_at_one_trigger = '1') then
        next_state <= sa1;
    
    elsif (bit_flip_trigger = '1') then
        next_state <= bit_flip;
    
    else
        next_state <= no_fault;   
    
    end if;

when sa0 =>
    if (stuck_at_zero_trigger = '0') then
        next_state <= no_fault;
    
    else
        next_state <= sa0;    
    
    end if;

when sa1 =>
    if (stuck_at_one_trigger = '0') then
        next_state <= no_fault;
    
    else
        next_state <= sa1;    
    
    end if;
    
when bit_flip =>
    if (neorv32_pc_we_i = '1') then
        next_state <= no_fault;
        
    elsif (stuck_at_zero_trigger = '1') then
        next_state <= sa0;
        
    elsif (stuck_at_one_trigger = '1') then
        next_state <= sa1;
    
    else
        next_state <= bit_flip;   
         
    end if;  
            
end case;

end Process;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- bit fsm output logic decoding ---

process (current_state)

begin

case current_state is

    when no_fault =>
        four_to_one_mux_sel_o <= "00";
        
    when sa0 =>
        four_to_one_mux_sel_o <= "01";
        
    when sa1 =>
        four_to_one_mux_sel_o <= "10";
                  
    when bit_flip =>
        four_to_one_mux_sel_o <= "11";
        
 end case;
 
 end process;

------------------------------------------------------------------------------------------------------------------------------------------------

end Behavioral;
