
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity bit_fault_type_select_counters is
  Port (clk_i  : in std_logic;
        rstn_i : in std_logic;
        pcb_button_i : in std_logic;
        gui_axi_button_i : in std_logic;
        fault_type_count_o : out std_logic_vector(1 downto 0)
       );
end bit_fault_type_select_counters;

architecture Behavioral of bit_fault_type_select_counters is

--- signal declarations ---------------------------------------------------------------------------------------
signal fault_type_count_inc_or_gate : std_logic;

signal fault_type_count_inc_pulse : std_logic;

signal fault_type_count : unsigned(1 downto 0);
---------------------------------------------------------------------------------------------------------------

begin

--- counter increment OR gate logic ---------------------------------------------------------------------------
fault_type_count_inc_or_gate <= pcb_button_i or gui_axi_button_i;
---------------------------------------------------------------------------------------------------------------

--- counter increment rising edge pulse generator -------------------------------------------------------------
counter_inc_rising_edge_pulse : pulse_generator
Port map (clk_i => clk_i,
          rstn_i => rstn_i,
          bit_i => fault_type_count_inc_or_gate,
          pulse_o => fault_type_count_inc_pulse
         );
         
---------------------------------------------------------------------------------------------------------------

--- bit fault type counter logic ------------------------------------------------------------------------------
Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    fault_type_count <= "00";
elsif (rising_edge(clk_i)) then
    if (fault_type_count_inc_pulse = '1') then
        fault_type_count <= fault_type_count + 1;
    end if;
end if;
        
end Process;

fault_type_count_o <= std_logic_vector(unsigned(fault_type_count));
---------------------------------------------------------------------------------------------------------------

end Behavioral;
