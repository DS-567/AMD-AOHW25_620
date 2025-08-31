
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.SNN_package.all;

entity D_type_ff_reg is 
generic(bit_width    : integer := 1);
  Port (clk_100MHz_i : in std_logic;
        rstn_i       : in std_logic;
        wr_en_i      : in std_logic;
        data_i       : in std_logic_vector(bit_width-1 downto 0);
        data_o       : out std_logic_vector(bit_width-1 downto 0)
       );
end D_type_ff_reg;

architecture Behavioral of D_type_ff_reg is

signal data_temp : std_logic_vector(bit_width-1 downto 0);

begin

Reg_Process : Process (clk_100MHz_i, rstn_i)

begin

if (rstn_i = '0') then
    data_temp <= (others => '0');
    
elsif (rising_edge(clk_100MHz_i)) then
    
    if (wr_en_i = '1') then
        data_temp <= data_i;
    
    end if;
end if;

end Process;

data_o <= data_temp;

end Behavioral;
