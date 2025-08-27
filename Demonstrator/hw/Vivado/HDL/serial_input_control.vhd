
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity serial_input_control is
Generic (g_delay_count_threshold : natural;
         g_num_read_bytes : natural;
         g_delay_counter_width : natural);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      trigger_i : in std_logic;
      serial_input_bit_i : in std_logic;
      serial_input_shift_clk_o : out std_logic;
      serial_input_parallel_load_o : out std_logic;
      debounced_inputs_o : out std_logic_vector(15 downto 0);
      serial_output_control_trigger_o : out std_logic
     );
end serial_input_control;

architecture Behavioral of serial_input_control is

--- signal declarations ---------------------------------------------------------------------------------------
type State_type is (S_idle, S_load_parallel_inputs, S_register_serial_bit, S_shift_serial_data, S_shift_clock_high, S_shift_clock_low, S_register_stage, 
                    S_debounce_stage, S_done);

signal S_State : State_type;

signal serial_input_bit_reg : std_logic;

signal serial_data : std_logic_vector(15 downto 0);

signal delay_counter : unsigned(g_delay_counter_width-1 downto 0);
signal index_counter : unsigned(4 downto 0);

signal serial_input_shift_clk : std_logic;
signal serial_input_parallel_load : std_logic;

signal serial_data_reg_current : std_logic_vector(15 downto 0);
signal serial_data_reg_last : std_logic_vector(15 downto 0);
signal debounced_inputs : std_logic_vector(15 downto 0);

signal done : std_logic;
---------------------------------------------------------------------------------------------------------------

begin

--- fsm logic -------------------------------------------------------------------------------------------------
fsm : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    serial_data <= (others => '0');
    delay_counter <= (others => '0'); 
    index_counter <= (others => '0');
    serial_input_parallel_load <= '1';
    serial_input_shift_clk <= '0';
    S_State <= S_idle;
    done <= '0';
    
elsif (rising_edge(clk_i)) then
          
    case S_State is

        when S_idle =>
            done <= '0';
            
            if (trigger_i = '1') then
                S_State <= S_load_parallel_inputs;
                
            else
                S_State <= S_idle;
            end if;
            
        when S_load_parallel_inputs =>
            serial_input_parallel_load <= '0';          
           
            if (delay_counter < g_delay_count_threshold) then
                delay_counter <= delay_counter + 1;
                S_State <= S_load_parallel_inputs;
            else
                serial_input_parallel_load <= '1';
                delay_counter <= (others => '0'); 
                S_State <= S_register_serial_bit;
            end if;
        
        when S_register_serial_bit =>
            serial_input_bit_reg <= serial_input_bit_i;
            S_State <= S_shift_serial_data;
        
        when S_shift_serial_data =>
            serial_data <= serial_data(14 downto 0) & serial_input_bit_reg;
            S_State <= S_shift_clock_high;
 
        when S_shift_clock_high =>
            serial_input_shift_clk <= '1';
            
            if (delay_counter < g_delay_count_threshold) then
                delay_counter <= delay_counter + 1;
                S_State <= S_shift_clock_high;
            else
                index_counter <= index_counter + 1;
                delay_counter <= (others => '0'); 
                S_State <= S_shift_clock_low;
            end if;
                    
        when S_shift_clock_low =>
            serial_input_shift_clk <= '0';
                        
            if (delay_counter < g_delay_count_threshold) then
                delay_counter <= delay_counter + 1;
                S_State <= S_shift_clock_low;
            else
                delay_counter <= (others => '0');
                
                if (index_counter > g_num_read_bytes*8-1) then
                    index_counter <= (others => '0');
                    S_State <= S_register_stage;                  
                else
                    S_State <= S_register_serial_bit;
                end if;
            end if;
                            
        when S_register_stage =>
            serial_data_reg_current <= serial_data;
            serial_data_reg_last <= serial_data_reg_current;
            S_State <= S_debounce_stage;
        
        when S_debounce_stage =>
            debounced_inputs <= serial_data_reg_last and serial_data_reg_current;
            S_State <= S_done;
            
        when S_done =>
            debounced_inputs_o <= debounced_inputs; 
            serial_data <= (others => '0'); 
            done <= '1';            
            S_State <= S_idle;

    end case;
    
end if;

end Process;

serial_input_shift_clk_o <= serial_input_shift_clk;
serial_input_parallel_load_o <= serial_input_parallel_load;

serial_output_control_trigger_o <= done;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
