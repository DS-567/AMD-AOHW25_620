
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

library work;
use work.SNN_package.all;

entity synapse_weights is
Generic(g_num_layer_inputs : integer;         
        g_file_path : string);
Port (clk_i  : in std_logic;
      we_i   : in std_logic;
      addr_i : in unsigned(f_log2(g_num_layer_inputs)-1 downto 0);
      di_i   : in std_logic_vector(neuron_bit_width downto 0);
      do_o   : out std_logic_vector(neuron_bit_width downto 0)
     );
end synapse_weights;

architecture Behavioral of synapse_weights is

impure function InitWeightsFromFile(RamFileName : in string) return WeightsType is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable RAM : WeightsType(0 to g_num_layer_inputs-1);
begin
for i in 0 to g_num_layer_inputs-1 loop
readline(RamFile, RamFileLine);
read(RamFileLine, RAM(i));
end loop;
return RAM;
end function;

signal RAM : WeightsType(0 to g_num_layer_inputs-1) := InitWeightsFromFile(g_file_path);
                                   
begin

Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (we_i = '1') then
        RAM(to_integer(unsigned(addr_i))) <= to_bitvector(di_i);
    end if;

do_o <= to_stdlogicvector(RAM(to_integer(unsigned(addr_i))));

end if;

end Process;

end Behavioral;
