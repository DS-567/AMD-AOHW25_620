
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.SNN_package.all;

entity two_to_four_decoder is
  Port (bit_fault_select_counter : in std_logic_vector(1 downto 0);
        no_fault : out std_logic;
        stuck_at_zero : out std_logic;
        stuck_at_one : out std_logic;
        bit_flip : out std_logic
       );
end two_to_four_decoder;

architecture Behavioral of two_to_four_decoder is

begin

Process(bit_fault_select_counter)

begin

if (bit_fault_select_counter = "00") then
    no_fault <= '1';
    stuck_at_zero <= '0';
    stuck_at_one <= '0';
    bit_flip <= '0';
    
elsif (bit_fault_select_counter = "01") then
    no_fault <= '0';
    stuck_at_zero <= '1';
    stuck_at_one <= '0';
    bit_flip <= '0';

elsif (bit_fault_select_counter = "10") then
    no_fault <= '0';
    stuck_at_zero <= '0';
    stuck_at_one <= '1';
    bit_flip <= '0';

else
    no_fault <= '0';
    stuck_at_zero <= '0';
    stuck_at_one <= '0';
    bit_flip <= '1';
    
end if;

end Process;

end Behavioral;
