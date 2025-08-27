
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity input_debouncer is
  Generic (g_clk_freq : natural;
           g_debounce_time_ms : natural;
           g_counter_bit_width : natural);
  Port (clk_i  : in std_logic;
        bit_i  : in std_logic;
        bit_o  : out std_logic
       );
end input_debouncer;

architecture Behavioral of input_debouncer is

signal ff_1 : std_logic;
signal ff_2 : std_logic;
signal ff_3 : std_logic;

signal ff_xor : std_logic;

signal counter : unsigned(g_counter_bit_width-1 downto 0);

begin

--- xor gate on flip flops 1 and 2 (checks for unstable button) -----------------------------------------------
ff_xor <= ff_1 xor ff_2;
---------------------------------------------------------------------------------------------------------------

--- 3 flip flops and a counter for contact debouncer logic ----------------------------------------------------
Process (clk_i)

begin
    
if (rising_edge(clk_i)) then
    ff_1 <= bit_i;
    ff_2 <= ff_1;
    
    if (ff_xor = '1') then
        counter <= (others => '0');
        
    elsif (counter < (g_clk_freq*g_debounce_time_ms) / 1000) then
        counter <= counter + 1;
        
    else
        ff_3 <= ff_2;
    
    end if;
end if;
        
end Process;

bit_o <= ff_3;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
