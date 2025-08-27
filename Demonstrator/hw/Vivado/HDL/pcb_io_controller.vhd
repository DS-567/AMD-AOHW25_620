
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity pcb_io_controller is
Port (clk_i : in std_logic;
      rstn_i : in std_logic;
      serial_input_data_i : in std_logic;                   -- 74HC165_DS input
      serial_input_shift_clk_o : out std_logic;             -- 74HC165_CP clock output
      serial_input_parallel_load_o : out std_logic;         -- 74HC165_PL parallel load output
      debounced_inputs_o : out std_logic_vector(15 downto 0);
      output_write_data_i : in std_logic_vector(47 downto 0);      
      serial_output_data_o : out std_logic;                 -- 74AHCT595_DS output
      serial_output_shift_clk_o : out std_logic;            -- 74AHCT595_SHCP clock output
      serial_output_storage_clk_o : out std_logic           -- 74AHCT595_STCP store output
     );
end pcb_io_controller;

 architecture Behavioral of pcb_io_controller is

--- signal declarations ---------------------------------------------------------------------------------------
signal serial_input_trigger : std_logic;

signal serial_output_trigger : std_logic;

signal serial_input_shift_clk : std_logic;
signal serial_input_parallel_load : std_logic;

signal debounced_inputs : std_logic_vector(15 downto 0);

signal serial_output_data : std_logic;
signal serial_output_shift_clk : std_logic;
signal serial_output_storage_clk : std_logic;
---------------------------------------------------------------------------------------------------------------

begin

--- Instantiating debounce delay counter ----------------------------------------------------------------------
debounce_delay_counter_inst : debounce_delay_counter
generic map (g_delay_count_threshold => 2_500_000)
port map (clk_i => clk_i,
          rstn_i => rstn_i,
          trigger_o => serial_input_trigger
         );
---------------------------------------------------------------------------------------------------------------
         
--- Instantiating serial input control ------------------------------------------------------------------------
serial_input_control_inst : serial_input_control        
generic map (g_delay_count_threshold => 350,    -- CHANGE THIS TO INCLUDE THE DEBOUNCE TIME IN US LIKE THE INPUT DEBOUNCER COMPONENT DOES IN MS!!!!!!
             g_num_read_bytes => 2,
             g_delay_counter_width => 12)
port map (clk_i => clk_i,
          rstn_i => rstn_i,
          trigger_i => serial_input_trigger,
          serial_input_bit_i => serial_input_data_i, 
          serial_input_shift_clk_o => serial_input_shift_clk,
          serial_input_parallel_load_o => serial_input_parallel_load,
          debounced_inputs_o => debounced_inputs,
          serial_output_control_trigger_o => serial_output_trigger
         );
             
serial_input_shift_clk_o <= serial_input_shift_clk; 
serial_input_parallel_load_o <= serial_input_parallel_load;

debounced_inputs_o <= debounced_inputs;
---------------------------------------------------------------------------------------------------------------

--- Instantiating serial output control -----------------------------------------------------------------------
serial_output_control_inst : serial_output_control
generic map (g_delay_count_threshold => 350,    -- 10us
             g_num_write_bytes => 6,
             g_delay_counter_width => 12)
port map (clk_i => clk_i,
          rstn_i => rstn_i,
          data_i => output_write_data_i, 
          trigger_i => serial_output_trigger,
          serial_output_data_o => serial_output_data,
          serial_output_shift_clk_o => serial_output_shift_clk,
          serial_output_storage_clk_o => serial_output_storage_clk
         );

serial_output_data_o <= serial_output_data;
serial_output_shift_clk_o <= serial_output_shift_clk;
serial_output_storage_clk_o <= serial_output_storage_clk;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
