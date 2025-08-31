
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity watchdog_2 is
Generic(g_SNN_layer_sizes : natural_array; --number of layers / layer sizes in network
        g_num_timesteps   : natural;       --number of timesteps to stimulate network
        g_num_beta_shifts : natural;       --number of right shifts for beta decay
        g_setup_file_path : string);       --base file path to access the network parameters
Port (clk_i   : in std_logic;
      rstn_i  : in std_logic;
      fifo_empty_i : in std_logic;
      fifo_rd_valid_i : in std_logic;
      fifo_data_i : in std_logic_vector(163 downto 0);
      fifo_rd_en_o : out std_logic;
      SNN_done_o   : out std_logic;
      SNN_class_zero_o : out std_logic;
      SNN_class_one_o : out std_logic;
      watchdog_ready_o : out std_logic;
      watchdog_error_o : out std_logic
    );
end watchdog_2;

architecture Behavioral of watchdog_2 is

attribute keep: boolean;

type State_type is (S_idle, S_fifo_read, S_check_fifo_read, S_check_for_instruction_executed, S_FL_output_ffs_wr, S_SNN_trigger,
                    S_FL_ffs_rst, S_done, S_error);
                                                           
signal S_Current_State, S_Next_State : State_type;
attribute keep of S_Current_State: signal is true;
attribute keep of S_Next_State: signal is true;

signal ready : std_logic;
signal done : std_logic;
signal error : std_logic;
attribute keep of ready : signal is true;
attribute keep of done : signal is true;
attribute keep of error : signal is true;

signal fifo_rd_en : std_logic;
attribute keep of fifo_rd_en : signal is true;

signal FL_output_ffs_wr : std_logic;
signal FL_ffs_rst : std_logic;
attribute keep of FL_output_ffs_wr : signal is true;
attribute keep of FL_ffs_rst : signal is true;

signal instruction_executed : std_logic;
attribute keep of instruction_executed : signal is true;

signal features : std_logic_vector(g_SNN_layer_sizes(0)-1 downto 0);
attribute keep of features : signal is true;

signal SNN_ready : std_logic;
attribute keep of SNN_ready : signal is true;

signal SNN_done : std_logic;
attribute keep of SNN_done : signal is true;

signal SNN_trigger : std_logic;
attribute keep of SNN_trigger : signal is true;

signal SNN_classes : std_logic_vector(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);
attribute keep of SNN_classes: signal is true;

begin

--- Instantiating feature layer component ---------------------------------------------------------------------
feature_layer_2_inst : feature_layer_2
generic map (g_num_features => g_SNN_layer_sizes(0))
port map (clk_i  => clk_i,
          rstn_i => rstn_i,
          fifo_new_data_i => fifo_rd_valid_i,
          fifo_data_i => fifo_data_i,
          layer_features_reg_wr_i => FL_output_ffs_wr,
          layer_reset_i => FL_ffs_rst,
          instruction_executed_o => instruction_executed,
          features_o => features
         );
---------------------------------------------------------------------------------------------------------------

--- fast SNN instantiation ------------------------------------------------------------------------------------
fast_SNN_inst : fast_SNN 
generic map (g_SNN_layer_sizes => g_SNN_layer_sizes,       
             g_num_beta_shifts => g_num_beta_shifts,
             g_num_timesteps   => g_num_timesteps,
             g_setup_file_path => g_setup_file_path)
port map (clk_i     => clk_i,
          rstn_i    => rstn_i,
          trigger_i => SNN_trigger,
          data_sample_i => features,
          classes_o => SNN_classes,
          ready_o   => SNN_ready,
          done_o    => SNN_done
         );
         
SNN_done_o <= SNN_done;
SNN_class_zero_o <= SNN_classes(0);
SNN_class_one_o <= SNN_classes(1);
---------------------------------------------------------------------------------------------------------------

--- fsm current state logic -----------------------------------------------------------------------------------
fsm_current : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    S_Current_State <= S_idle;

elsif (rising_edge(clk_i)) then
    S_Current_State <= S_Next_State;
    
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm next state logic --------------------------------------------------------------------------------------
fsm_next : Process (S_Current_State, fifo_empty_i, fifo_rd_valid_i, instruction_executed, SNN_ready)

begin

case S_Current_State is

    when S_idle =>
        if (fifo_empty_i = '0') then
            S_Next_State <= S_fifo_read;
        else
            S_Next_State <= S_idle;
        end if;
    
    when S_fifo_read =>
        S_Next_State <= S_check_fifo_read;
       
    when S_check_fifo_read =>
        if (fifo_rd_valid_i = '1') then
            S_Next_State <= S_check_for_instruction_executed;
        else
            S_Next_State <= S_error;
        end if;
        
    when S_check_for_instruction_executed =>
        if (instruction_executed = '1' and SNN_ready = '1') then
            S_Next_State <= S_FL_output_ffs_wr;
        elsif (instruction_executed = '1' and SNN_ready = '0') then
            S_Next_State <= S_check_for_instruction_executed;
        elsif (fifo_empty_i = '0') then
            S_Next_State <= S_fifo_read;
        else
            S_Next_State <= S_FL_ffs_rst;
        end if;
            
    when S_FL_output_ffs_wr =>
        S_Next_State <= S_SNN_trigger;
                    
    when S_SNN_trigger =>
        S_Next_State <= S_FL_ffs_rst;
                
    when S_FL_ffs_rst =>
        if (fifo_empty_i = '1') then
            S_Next_State <= S_done;
        else
            S_Next_State <= S_fifo_read;
        end if;
         
    when S_done =>
        S_Next_State <= S_idle;  
    
    when S_error =>
        S_Next_State <= S_error;
        
end case;

end Process;
----------------------------------------------------------------------------------------------------------------

--- fsm output decoding logic ----------------------------------------------------------------------------------
fsm_outputs : Process (S_Current_State) 

begin

case S_Current_State is

when S_idle =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '1';
    done  <= '0';
    error <= '0'; 

when S_fifo_read =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '1';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0'; 

when S_check_fifo_read =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0'; 

when S_check_for_instruction_executed =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0';
    
when S_FL_output_ffs_wr =>
    FL_output_ffs_wr <= '1';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0'; 
                
when S_SNN_trigger =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '1';
    ready <= '0';
    done  <= '0';   
    error <= '0';      
        
when S_FL_ffs_rst =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '1';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';        
    error <= '0';   
        
when S_done =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '1';   
    error <= '0';        
              
when S_error =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';   
    error <= '1';         
           
end case;

end Process;

fifo_rd_en_o <= fifo_rd_en;

watchdog_ready_o <= ready;
watchdog_error_o <= error;
----------------------------------------------------------------------------------------------------------------

end Behavioral;
