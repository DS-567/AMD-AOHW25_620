
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity encoder_pulses_counter is
  Port (clk_i  : in std_logic;
        rstn_i : in std_logic;
        encoder_A_i : in std_logic;
        encoder_B_i : in std_logic;
        encoder_count_o : out std_ulogic_vector(31 downto 0)
       );
end encoder_pulses_counter;

architecture Behavioral of encoder_pulses_counter is

--- encoder inputs flip flops for clock synchronising ---
signal ff_A0 : std_logic;
signal ff_A1 : std_logic;
signal ff_A2 : std_logic;
signal ff_B0 : std_logic;
signal ff_B1 : std_logic;
signal ff_B2 : std_logic;

signal rising_edge_A  : std_logic;
signal falling_edge_A : std_logic;
signal rising_edge_B  : std_logic;
signal falling_edge_B : std_logic;

signal encoder_counter_en : std_logic;

signal encoder_count : std_ulogic_vector(31 downto 0);

begin

--- encoder input channel synchronisation and rising / falling edge detectors ---------------------------------
Process (clk_i)

begin
-- NEED DEBOUNCING ON THESE EDGES I THINK ??? AND USE FSM SEQUENCE DETECTION AND UP DOWN COUNTER ???
if (rising_edge(clk_i)) then
    if (rstn_i = '0') then
        ff_A0 <= '0';
        ff_A1 <= '0';
        ff_A2 <= '0';
        
        ff_B0 <= '0';
        ff_B1 <= '0';
        ff_B2 <= '0';

    else
       ff_A0 <= encoder_A_i;
       ff_A1 <= ff_A0;
       ff_A2 <= ff_A1;

       ff_B0 <= encoder_B_i;
       ff_B1 <= ff_B0;
       ff_B2 <= ff_B1;
          
    end if;
end if;
   
end Process;

rising_edge_A  <= ff_A1 and (not ff_A2);
falling_edge_A <= ff_A2 and (not ff_A1);

rising_edge_B  <= ff_B1 and (not ff_B2);
falling_edge_B <= ff_B2 and (not ff_B1);
---------------------------------------------------------------------------------------------------------------

--- encoder counter enable OR gate logic ----------------------------------------------------------------------
encoder_counter_en <= rising_edge_A or falling_edge_A or rising_edge_B or falling_edge_B;
---------------------------------------------------------------------------------------------------------------

--- encoder rising / falling edge pulse counter ---------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0') then
        encoder_count <= (others => '0');
        
    elsif (encoder_counter_en = '1') then
        encoder_count <= std_ulogic_vector(unsigned(encoder_count) + 1);
   
    end if;
end if;
   
end Process;

encoder_count_o <= encoder_count;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
