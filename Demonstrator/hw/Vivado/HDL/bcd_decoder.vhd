
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.SNN_package.all;

entity bcd_decoder is
  Port (bcd_i : in std_logic_vector(3 downto 0);
        seven_segs_o : out std_logic_vector(6 downto 0)
       );
end bcd_decoder;

architecture Behavioral of bcd_decoder is

begin

--- BCD to seven segment decoding logic -----------------------------------------------------------------------
Process (bcd_i)

begin
    
case bcd_i is
    
when "0000" => seven_segs_o <= "1000000";  -- 0
when "0001" => seven_segs_o <= "1111001";  -- 1
when "0010" => seven_segs_o <= "0100100";  -- 2
when "0011" => seven_segs_o <= "0110000";  -- 3
when "0100" => seven_segs_o <= "0011001";  -- 4
when "0101" => seven_segs_o <= "0010010";  -- 5
when "0110" => seven_segs_o <= "0000010";  -- 6
when "0111" => seven_segs_o <= "1111000";  -- 7
when "1000" => seven_segs_o <= "0000000";  -- 8
when "1001" => seven_segs_o <= "0011000";  -- 9
when others => seven_segs_o <= "1000000";  -- 0 (should never occur)
    
end case;

end process;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
