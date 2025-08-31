
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.SNN_package.all;

entity eight_to_one_mux_setup_regs is
  Port (data_zero_i   : in std_logic_vector(15 downto 0);
        data_one_i    : in std_logic_vector(15 downto 0);
        data_two_i    : in std_logic_vector(15 downto 0);
        data_three_i  : in std_logic_vector(15 downto 0);
        data_four_i   : in std_logic_vector(15 downto 0);
        data_five_i   : in std_logic_vector(15 downto 0);
        data_six_i    : in std_logic_vector(15 downto 0);
        data_seven_i  : in std_logic_vector(15 downto 0);
        sel_i         : in std_logic_vector(2 downto 0);
        data_o        : out std_logic_vector(15 downto 0)
       );
end eight_to_one_mux_setup_regs;

architecture Behavioral of eight_to_one_mux_setup_regs is

begin

with sel_i select
data_o <= data_zero_i  when "000",
          data_one_i   when "001",
          data_two_i   when "010",
          data_three_i when "011",
          data_four_i  when "100",
          data_five_i  when "101",
          data_six_i   when "110",
          data_seven_i when others;
  
end Behavioral;