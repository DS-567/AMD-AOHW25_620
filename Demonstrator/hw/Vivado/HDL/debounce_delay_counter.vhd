library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity debounce_delay_counter is
  Generic (g_delay_count_threshold : natural);
  Port (clk_i : in std_logic;
        rstn_i : in std_logic;
        trigger_o : out std_logic       
       );
end debounce_delay_counter;

architecture Behavioral of debounce_delay_counter is

signal trigger : std_logic;
signal debounce_delay_counter : unsigned(31 downto 0);

begin

--- trigger logic ---------------------------------------------------------------------------------------------
Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    debounce_delay_counter <= (others => '0');
elsif (rising_edge(clk_i)) then
    if (debounce_delay_counter >= g_delay_count_threshold) then
        debounce_delay_counter <= (others => '0');
        trigger <= '1';
    else
        trigger <= '0';
        debounce_delay_counter <= debounce_delay_counter + 1;
    end if;
end if;
  
end process;

trigger_o <= trigger;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
