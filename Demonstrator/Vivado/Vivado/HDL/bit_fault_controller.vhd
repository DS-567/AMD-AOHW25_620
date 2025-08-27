
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bit_fault_controller is
  Port (clk_i  : in std_logic;
        rstn_i : in std_logic; 
        bit_fault_type_i  : in std_logic_vector(1 downto 0);
        inject_fault_en_i : in std_logic;   
        neorv32_pc_we_i   : in std_logic;
        four_to_one_mux_sel_o : out std_logic_vector(1 downto 0)        
       );
end bit_fault_controller;

architecture Behavioral of bit_fault_controller is

attribute keep: boolean;

signal fault_type : std_logic_vector(1 downto 0);

signal stuck_at_zero_trigger : std_logic;
signal stuck_at_one_trigger  : std_logic;
signal bit_flip_trigger      : std_logic;

type State_type is (no_fault, sa0, sa1, bit_flip_inject, bit_flip_removed);
signal Current_State , Next_State : State_type;

signal Q0_out : std_logic; 
signal Q1_out : std_logic;

begin

--- assigning fault types and times to internal logic signals for fsm below --------------------------------------
fault_type  <= bit_fault_type_i;
------------------------------------------------------------------------------------------------------------------

--- fault type trigger logic -------------------------------------------------------------------------------------
stuck_at_zero_trigger <= '1' when inject_fault_en_i = '1' and fault_type = "01" and neorv32_pc_we_i = '1' else '0';
                                    
stuck_at_one_trigger <= '1' when inject_fault_en_i = '1' and fault_type = "10" and neorv32_pc_we_i = '1' else '0';

bit_flip_trigger <= '1' when inject_fault_en_i = '1' and fault_type = "11" and neorv32_pc_we_i = '1' else '0';
------------------------------------------------------------------------------------------------------------------
                       
--- bit fsm next state logic -------------------------------------------------------------------------------------
process (clk_i, rstn_i, Current_State, stuck_at_zero_trigger, stuck_at_one_trigger, bit_flip_trigger, neorv32_pc_we_i, inject_fault_en_i)

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
        next_state <= bit_flip_inject;
    
    else
        next_state <= no_fault;   
    
    end if;

when sa0 =>
    if (inject_fault_en_i = '0') then
        next_state <= no_fault;
    
    else
        next_state <= sa0;    
    
    end if;

when sa1 =>
    if (inject_fault_en_i = '0') then
        next_state <= no_fault;
    
    else
        next_state <= sa1;    
    
    end if;
    
when bit_flip_inject =>
    if (neorv32_pc_we_i = '1' or inject_fault_en_i = '0') then
        next_state <= bit_flip_removed;
            
    else
        next_state <= bit_flip_inject;   
         
    end if;  

when bit_flip_removed =>
    if (inject_fault_en_i = '0') then
        next_state <= no_fault;
        
    else
        next_state <= bit_flip_removed;   
     
    end if;  
                
end case;

end Process;
------------------------------------------------------------------------------------------------------------------

--- bit fsm output logic decoding --------------------------------------------------------------------------------
process (current_state)

begin

case current_state is

    when no_fault =>
        four_to_one_mux_sel_o <= "00";
        
    when sa0 =>
        four_to_one_mux_sel_o <= "01";
        
    when sa1 =>
        four_to_one_mux_sel_o <= "10";
                  
    when bit_flip_inject =>
        four_to_one_mux_sel_o <= "11";
        
    when bit_flip_removed =>
        four_to_one_mux_sel_o <= "00";
        
 end case;
 
 end process;
------------------------------------------------------------------------------------------------------------------

end Behavioral;
