
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity input_debouncer is
  Generic (g_debounce_threshold : natural);
  Port (clk_i  : in std_logic;
        bit_i  : in std_logic;
        bit_o  : out std_logic
       );
end input_debouncer;

architecture Behavioral of input_debouncer is

signal ff_1 : std_logic;
signal ff_2 : std_logic;
signal ff_3 : std_logic;

signal counter : unsigned(31 downto 0);

begin

--- 3 flip flops and a counter for switch debouncer logic -----------------------------------------------------
Process (clk_i)

begin
    
if (rising_edge(clk_i)) then
    ff_1 <= bit_i;
    ff_2 <= ff_1;
    ff_3 <= ff_2;
    
    if (ff_3 = '1') then
        counter <= counter + 1;
    else
        counter <= (others => '0');
    
    end if;
end if;
        
end Process;

bit_o <= '1' when (counter >= g_debounce_threshold and ff_1 = '1' and ff_2 = '1' and ff_3 = '1') else '0';
---------------------------------------------------------------------------------------------------------------

end Behavioral;
