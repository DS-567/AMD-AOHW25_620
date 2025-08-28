
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Address_wr_Decoder is
  Port (clk_100MHz_i     : in std_logic;
        rstn_i           : in std_logic;
        wr_en_i          : in std_logic;
        addr_i           : in std_logic_vector(5 downto 0);     --6 bits of address input
        decoded_reg_en_o : out std_logic_vector(63 downto 0)    --64 bits of decoded register enable lines output
       );
end Address_wr_Decoder;

architecture Behavioral of Address_wr_Decoder is

begin

Decoder_Process : Process (clk_100MHz_i, rstn_i)

begin

if (rstn_i = '0') then
    decoded_reg_en_o <= (others => '0');
    
elsif (rising_edge(clk_100MHz_i)) then
    if (wr_en_i = '1') then
        decoded_reg_en_o <= (others => '0'); 
        decoded_reg_en_o(to_integer(unsigned(addr_i))) <= '1';
    
    else
        decoded_reg_en_o <= (others => '0');
        
    end if;
end if;

end Process;

end Behavioral;
