
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity beta_shifter is
Generic (g_num_beta_shifts : integer);         
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      membrane_i : in std_logic_vector(neuron_bit_width-1 downto 0);
      membrane_o : out std_logic_vector(neuron_bit_width-1 downto 0)
      );
end beta_shifter;

architecture Behavioral of beta_shifter is

signal result  : std_logic_vector(neuron_bit_width-1 downto 0);

begin

--- Test signed shift process ---------------------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then
        result <= (others => '0');        
    else 
        result <= membrane_i(neuron_bit_width-1 downto neuron_bit_width-1-(g_num_beta_shifts-1)) & membrane_i(neuron_bit_width-1 downto 0+g_num_beta_shifts);
    end if;
end if;

end Process;

membrane_o <= result;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
