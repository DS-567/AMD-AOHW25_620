
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.SNN_package.all;

entity two_to_one_mux is
Generic (g_mux_width : integer);
Port (freq_low_i   : std_logic_vector(g_mux_width-1 downto 0);
      freq_high_i  : std_logic_vector(g_mux_width-1 downto 0);
      sel_i        : in std_logic;
      freq_o       : out std_logic_vector(g_mux_width-1 downto 0)
     );
end two_to_one_mux;

architecture Behavioral of two_to_one_mux is

begin

freq_o <= freq_low_i when (sel_i = '0') else freq_high_i;

end Behavioral;
