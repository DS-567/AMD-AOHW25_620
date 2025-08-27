
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity seven_seg_display_controller is
  Port (clk_i  : in std_logic;
        rstn_i : in std_logic;
        data_i : in std_logic_vector(31 downto 0);
        segments_o   : out std_logic_vector(6 downto 0);
        anodes_sel_o : out std_logic_vector(7 downto 0) 
       );
end seven_seg_display_controller;

architecture Behavioral of seven_seg_display_controller is

type State_type is (S_reset, S_digit_0, S_digit_1, S_digit_2, S_digit_3, S_digit_4, S_digit_5, S_digit_6, S_digit_7);
                    
signal Current_State , Next_State : State_type;

signal input_mux_sel  : std_logic_vector(2 downto 0);
signal input_mux_data : std_logic_vector(3 downto 0);

signal tick : std_logic;
signal tick_counter : unsigned(19 downto 0);
signal tick_counter_en : std_logic;
constant DIVISOR: unsigned(19 downto 0) := X"186A0"; --100000  

begin

--- seven segment tick counter used to refersh the display ----------------------------------------------------
Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    tick_counter <= (others => '0');
elsif (rising_edge(clk_i)) then
        if (tick_counter = DIVISOR) then
            tick_counter <= (others => '0');
            tick <= '1';
        else
            tick_counter <= tick_counter + 1;
            tick <= '0';
        end if;
end if;

end process;
---------------------------------------------------------------------------------------------------------------

--- 4-bit 4 to 1 mux to select the data for each display digit ------------------------------------------------
with input_mux_sel select
    input_mux_data <= data_i(03 downto 00) when "000",
                      data_i(07 downto 04) when "001",
                      data_i(11 downto 08) when "010",
                      data_i(15 downto 12) when "011",
                      data_i(19 downto 16) when "100",
                      data_i(23 downto 20) when "101",
                      data_i(27 downto 24) when "110",
                      data_i(31 downto 28) when others;
---------------------------------------------------------------------------------------------------------------

--- bcd decoder component instantiation -----------------------------------------------------------------------
bcd_decoder_inst : bcd_decoder
port map (bcd_i => input_mux_data,
          seven_segs_o => segments_o
         );
---------------------------------------------------------------------------------------------------------------

--- seven segment fsm for controlling display control signals and the digit data select -----------------------
Process (clk_i, rstn_i, Current_State)
 
begin
 
if (rstn_i = '0') then
    Current_State <= S_reset;
    
elsif (rising_edge(clk_i)) then
    if (tick = '1') then
        Current_State <= Next_State;
        
    end if;
end if; 
 
case Current_State is

when S_reset =>
    Next_State <= S_digit_0;
 
when S_digit_0 =>
    Next_State <= S_digit_1;   
  
when S_digit_1 =>
    Next_State <= S_digit_2;   
    
when S_digit_2 =>
    Next_State <= S_digit_3;   
                 
when S_digit_3 =>
    Next_State <= S_digit_4;  

when S_digit_4 =>
    Next_State <= S_digit_5;   
      
when S_digit_5 =>
    Next_State <= S_digit_6;   
        
when S_digit_6 =>
    Next_State <= S_digit_7;   
                     
when S_digit_7 =>
    Next_State <= S_digit_0;  
                      
end case;
  
end process;
---------------------------------------------------------------------------------------------------------------

--- seven segment fsm output decoding -------------------------------------------------------------------------
Process (Current_State)
 
begin
 
case Current_State is

when S_reset =>
    input_mux_sel <= "000";
    anodes_sel_o <= "11111111";
  
when S_digit_0 =>
    input_mux_sel <= "000";
    anodes_sel_o <= "11111110";
      
when S_digit_1 =>
    input_mux_sel <= "001";
    anodes_sel_o <= "11111101";
      
when S_digit_2 =>
    input_mux_sel <= "010";
    anodes_sel_o <= "11111011";
              
when S_digit_3 =>
    input_mux_sel <= "011";
    anodes_sel_o <= "11110111";

when S_digit_4 =>
    input_mux_sel <= "100";
    anodes_sel_o <= "11101111";
          
when S_digit_5 =>
    input_mux_sel <= "101";
    anodes_sel_o <= "11011111";
          
when S_digit_6 =>
    input_mux_sel <= "110";
    anodes_sel_o <= "10111111";
                  
when S_digit_7 =>
    input_mux_sel <= "111";
    anodes_sel_o <= "01111111";
        
end case;
 
end Process;
---------------------------------------------------------------------------------------------------------------

end Behavioral;