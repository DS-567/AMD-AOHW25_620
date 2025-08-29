
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity serial_output_control is
  Generic (g_delay_count_threshold : natural;
           g_num_write_bytes : natural;
           g_delay_counter_width : natural);
  Port (clk_i  : in std_logic;
        rstn_i : in std_logic;
        trigger_i : in std_logic;
        data_i : in std_logic_vector(47 downto 0);
        serial_output_data_o : out std_logic;
        serial_output_shift_clk_o : out std_logic;
        serial_output_storage_clk_o : out std_logic
       );
end serial_output_control;

architecture Behavioral of serial_output_control is

--- signal declarations ---------------------------------------------------------------------------------------
type State_type is (S_idle, S_register_data, S_register_serial_bit, S_shift_clock_high, S_storage_clock_high, S_storage_clock_low, S_done);
signal S_State : State_type;

signal data_reg : std_logic_vector(47 downto 0);

signal serial_data_bit_reg : std_logic;

signal delay_counter : unsigned(g_delay_counter_width-1 downto 0);
signal bit_counter : unsigned(15 downto 0);

signal shift_reg_clk : std_logic;
signal storage_reg_clk : std_logic;
---------------------------------------------------------------------------------------------------------------

--- component declarations ------------------------------------------------------------------------------------
component pulse_generator is
  Port (clk_i   : in std_logic;
        rstn_i  : in std_logic;
        bit_i   : in std_logic;
        pulse_o : out std_logic             
       );
end component;
---------------------------------------------------------------------------------------------------------------

begin

--- fsm logic -------------------------------------------------------------------------------------------------
fsm : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    data_reg <= (others => '0');
    delay_counter <= (others => '0'); 
    bit_counter <= (others => '0');
    serial_data_bit_reg <= '0';
    shift_reg_clk <= '0';
    storage_reg_clk <= '0';
    S_State <= S_idle;
    
elsif (rising_edge(clk_i)) then
          
    case S_State is

        when S_idle =>
        
            if (trigger_i = '1') then
                S_State <= S_register_data;
            else
                S_State <= S_idle;
            end if;
            
        when S_register_data =>
            data_reg <= data_i;
            S_State <= S_register_serial_bit;
            
        when S_register_serial_bit =>
            serial_data_bit_reg <= data_reg(to_integer(bit_counter));
            
            if (delay_counter < g_delay_count_threshold) then
                delay_counter <= delay_counter + 1;
                S_State <= S_register_serial_bit;
            else
                delay_counter <= (others => '0'); 
                S_State <= S_shift_clock_high;
            end if;
            
        when S_shift_clock_high =>
            shift_reg_clk <= '1';
            
            if (delay_counter < g_delay_count_threshold) then
                delay_counter <= delay_counter + 1;
                S_State <= S_shift_clock_high;
            else
                shift_reg_clk <= '0';
                delay_counter <= (others => '0'); 
                
                if (bit_counter <= g_num_write_bytes*8-2) then
                    bit_counter <= bit_counter + 1;
                    S_State <= S_register_serial_bit;
                else
                    bit_counter <= (others => '0');
                    S_State <= S_storage_clock_high;
                end if;
            end if;
            
        when S_storage_clock_high =>
            storage_reg_clk <= '1';
            
            if (delay_counter < g_delay_count_threshold) then
                delay_counter <= delay_counter + 1;
                S_State <= S_storage_clock_high;
            else
                delay_counter <= (others => '0'); 
                S_State <= S_storage_clock_low;
            end if;
            
        when S_storage_clock_low =>
            storage_reg_clk <= '0';
                        
            if (delay_counter < g_delay_count_threshold) then
                delay_counter <= delay_counter + 1;
                S_State <= S_storage_clock_low;
            else
                delay_counter <= (others => '0'); 
                S_State <= S_done;
            end if;
            
        when S_done =>
            serial_data_bit_reg <= '0';
            shift_reg_clk <= '0';
            storage_reg_clk <= '0';
            S_State <= S_idle;

    end case;
    
end if;

end Process;

serial_output_data_o <= serial_data_bit_reg;
serial_output_shift_clk_o <= shift_reg_clk;
serial_output_storage_clk_o <= storage_reg_clk;
----------------------------------------------------------------------------------------------------------------

end Behavioral;
