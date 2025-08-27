
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;

entity pulse_generator is
  Port (clk_i   : in std_logic;
        rstn_i  : in std_logic;
        bit_i   : in std_logic;
        pulse_o : out std_logic             
       );
end pulse_generator;

architecture Behavioral of pulse_generator is

signal ff_0_out : std_logic;
signal ff_1_out : std_logic;

begin

--- Rising pulse generator ------------------------------------------------------------------------------------
Process (clk_i)

begin
    
if (rising_edge(clk_i)) then
    if (rstn_i = '0') then
        ff_0_out <= '0';
        ff_1_out <= '0';
    else
        ff_0_out <= bit_i;
        ff_1_out <= ff_0_out;
    end if;
end if;

end Process;

pulse_o <= ff_0_out and (not ff_1_out);
---------------------------------------------------------------------------------------------------------------

end Behavioral;
