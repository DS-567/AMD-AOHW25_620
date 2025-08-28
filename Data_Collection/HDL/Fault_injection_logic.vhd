library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Fault_Injection_Logic is
Port (bit_i                 : in std_logic;     
      four_to_one_mux_sel_i : in std_logic_vector(1 downto 0);
      bit_o                 : out std_logic
     );
end Fault_Injection_Logic;

architecture Behavioral of Fault_Injection_Logic is

begin

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 4 to 1 multiplexor to select which data to use for mux output ---

with four_to_one_mux_sel_i select bit_o <= bit_i when "00", 
                                  '0'   when "01", 
                                  '1'   when "10",
                                  not bit_i when others;
                                  
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

end Behavioral;
