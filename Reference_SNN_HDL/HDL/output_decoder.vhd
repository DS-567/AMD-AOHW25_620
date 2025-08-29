
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity output_decoder is 
Generic (g_num_outputs   : natural;
         g_num_timesteps : natural
        );
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      trigger_i : in std_logic;
      output_spike_count_i : in std_logic_vector(f_log2(g_num_timesteps+1)-1 downto 0);  
      output_spike_count_index_o : out std_logic_vector(g_num_outputs-1 downto 0);
      class_regs_o : out std_logic_vector(g_num_outputs-1 downto 0);
      done_o : out std_logic
     );
end output_decoder;

architecture Behavioral of output_decoder is

type State_type is (S_decoder_idle, S_decoder_compare, S_decoder_check_index_count, S_decoder_index_count_inc,
                    S_decoder_update_class_reg, S_decoder_decode_class_reg, S_decoder_done);

signal S_decoder_State : State_type;
                                         
signal output_spike_count_index : std_logic_vector(g_num_outputs-1 downto 0);

signal max_index : std_logic_vector(g_num_outputs-1 downto 0);

signal max_value : std_logic_vector(f_log2(g_num_timesteps+1)-1 downto 0);  

signal trigger_pulse : std_logic;

signal valid : std_logic;

signal decoder_out : std_logic_vector(g_num_outputs-1 downto 0);

signal class_temp : std_logic_vector(g_num_outputs-1 downto 0);

signal class_regs : std_logic_vector(g_num_outputs-1 downto 0);

begin

output_spike_count_index_o <= output_spike_count_index;

--- trigger rising pulse generator ----------------------------------------------------------------------------
output_classifier_trigger_pulse : pulse_generator
port map (clk_i   => clk_i,
          rstn_i  => rstn_i,
          bit_i   => trigger_i,
          pulse_o => trigger_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- decoder fsm logic -----------------------------------------------------------------------------------------
decoder_fsm : Process(clk_i, rstn_i) is

begin

if (rstn_i = '0') then
    S_decoder_State <= S_decoder_idle;
    
elsif (rising_edge(clk_i)) then

    case S_decoder_State is
 
        when S_decoder_idle =>
            output_spike_count_index <= (others => '0');
            max_index  <= (others => '0');
            max_value  <= (others => '0');
            valid      <= '0';
            class_temp <= (others => '0');
            class_regs <= (others => '0');
            done_o     <= '0';
            
            if (trigger_pulse = '1') then
                S_decoder_State <= S_decoder_compare;
            else
                S_decoder_State <= S_decoder_idle;
            end if;
                        
        when S_decoder_compare =>
            if (output_spike_count_i > max_value) then
                max_value <= output_spike_count_i;
                max_index <= output_spike_count_index;
                valid     <= '1';
            elsif (output_spike_count_i = max_value) then
                valid     <= '0';                
            end if;
            
            S_decoder_State <= S_decoder_check_index_count;
            
        when S_decoder_check_index_count =>
            if (to_integer(unsigned(output_spike_count_index)) >= g_num_outputs-1) then
                S_decoder_State <= S_decoder_update_class_reg;
            else
                S_decoder_State <= S_decoder_index_count_inc;
            end if;
                            
        when S_decoder_index_count_inc =>
            output_spike_count_index <= std_logic_vector(unsigned(output_spike_count_index) + 1);
                    
            S_decoder_State <= S_decoder_compare;
                
        when S_decoder_update_class_reg =>
            if (valid = '1') then
                class_temp <= max_index;
            end if;
        
            S_decoder_State <= S_decoder_decode_class_reg;
            
        when S_decoder_decode_class_reg =>
            class_regs <= decoder_out;
        
            S_decoder_State <= S_decoder_done;
        
        when S_decoder_done => 
            done_o <= '1';
        
            S_decoder_State <= S_decoder_idle;
        
    end case;
    
end if;

end process;

class_regs_o <= class_regs;
---------------------------------------------------------------------------------------------------------------

--- class decoder ---------------------------------------------------------------------------------------------
Process (class_temp, valid)

begin

if (valid = '1') then
    decoder_out <= (others => '0'); 
    decoder_out(to_integer(unsigned(class_temp))) <= '1';  
else
    decoder_out <= (others => '0');

end if;

end process;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
