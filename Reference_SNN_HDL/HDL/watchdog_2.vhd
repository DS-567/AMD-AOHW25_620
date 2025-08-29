
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity watchdog_2 is
  Generic(g_num_features : natural;
          g_SNN_layer_sizes : integer_array; --number of layers / layer sizes in network
          g_num_timesteps   : integer;       --number of timesteps to stimulate network
          g_num_beta_shifts : integer;       --number of right shifts for beta decay
          g_setup_file_path : string         --base file path to access the network parameters
          );
  Port (clk_i   : in std_logic;
        rstn_i  : in std_logic;
        trigger_pulse_i : in std_logic;
        fifo_empty_i : in std_logic;
        fifo_rd_valid_i : in std_logic;
        fifo_data_i : in std_logic_vector(163 downto 0);
        fifo_rd_en_o : out std_logic;
        SNN_done_o   : out std_logic;
        SNN_class_zero_o : out std_logic;
        SNN_class_one_o : out std_logic;
        watchdog_error_o : out std_logic
      ); 
end watchdog_2;

architecture Behavioral of watchdog_2 is

attribute keep: boolean;

type State_type is (S_idle, S_fifo_read, S_check_fifo_read, S_delay_cycle, S_feature_layer_regs_en, S_SNN_reset, S_SNN_trigger, S_reset_feature_layer, S_done, S_error);
                                                           
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

signal feature_layer_regs_wr : std_logic;
signal feature_layer_rst : std_logic;
attribute keep of feature_layer_regs_wr : signal is true;
attribute keep of feature_layer_rst : signal is true;

signal instruction_executed : std_logic;
attribute keep of instruction_executed : signal is true;

signal features : std_logic_vector(g_num_features-1 downto 0);
attribute keep of features : signal is true;

signal SNN_ready : std_logic;
attribute keep of SNN_ready : signal is true;

signal SNN_done : std_logic;
attribute keep of SNN_done : signal is true;

signal SNN_trigger : std_logic;
attribute keep of SNN_trigger : signal is true;

signal SNN_classes : std_logic_vector(f_last_val_in_array(g_SNN_layer_sizes)-1 downto 0);
attribute keep of SNN_classes: signal is true;

signal SNN_reset : std_logic;      
attribute keep of SNN_reset: signal is true;

signal SNN_rst_n : std_logic;  
attribute keep of SNN_rst_n: signal is true;

begin

--- Instantiating feature layer component ---------------------------------------------------------------------
feature_layer_2_inst : feature_layer_2
generic map (g_num_features => g_num_features)
port map (clk_i  => clk_i,
          rstn_i => rstn_i,
          fifo_new_data_i => fifo_rd_valid_i,
          fifo_data_i => fifo_data_i,
          layer_features_reg_wr_i => feature_layer_regs_wr,
          layer_reset_i => feature_layer_rst,
          instruction_executed_o => instruction_executed,
          features_o => features
         );
---------------------------------------------------------------------------------------------------------------

--- SNN reset logic -------------------------------------------------------------------------------------------
SNN_rst_n <= rstn_i and (not SNN_reset);
---------------------------------------------------------------------------------------------------------------

--- SNN instantiation -----------------------------------------------------------------------------------------
SNN_inst : SNN 
generic map (g_SNN_layer_sizes => g_SNN_layer_sizes,       
             g_num_beta_shifts => g_num_beta_shifts,
             g_num_timesteps   => g_num_timesteps,
             g_setup_file_path => g_setup_file_path)
port map (clk_i     => clk_i,
          rstn_i    => SNN_rst_n,
          trigger_i => SNN_trigger,
          data_sample_i => features,
          classes_o => SNN_classes,
          ready_o   => SNN_ready,
          done_o    => SNN_done
         );
         
SNN_done_o <= SNN_done;

--- Needs fixed for full generic-ness!
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
fsm_next : Process (S_Current_State, trigger_pulse_i, fifo_empty_i, fifo_rd_valid_i, instruction_executed, SNN_ready)

begin

case S_Current_State is

    when S_idle =>
        if (trigger_pulse_i = '1' and fifo_empty_i = '0') then
            S_Next_State <= S_fifo_read;
        else
            S_Next_State <= S_idle;
        end if;
    
    when S_fifo_read =>
        S_Next_State <= S_check_fifo_read;
       
    when S_check_fifo_read =>
        if (fifo_rd_valid_i = '1') then
            S_Next_State <= S_delay_cycle;
        else
            S_Next_State <= S_error;
        end if;
        
    when S_delay_cycle =>
        if (instruction_executed = '1' and SNN_ready = '1') then
            S_Next_State <= S_feature_layer_regs_en;
        elsif (instruction_executed = '1' and SNN_ready = '0') then
            S_Next_State <= S_delay_cycle;
        else
            S_Next_State <= S_fifo_read;
        end if;
            
    when S_feature_layer_regs_en =>
        S_Next_State <= S_SNN_reset;
    
    when S_SNN_reset =>
        S_Next_State <= S_SNN_trigger;
                
    when S_SNN_trigger =>
        S_Next_State <= S_reset_feature_layer;
                
    when S_reset_feature_layer =>
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
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    SNN_reset   <= '0';
    ready <= '1';
    done  <= '0';
    error <= '0'; 

when S_fifo_read =>
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '0';
    fifo_rd_en <= '1';
    SNN_trigger <= '0';
    SNN_reset   <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0'; 

when S_check_fifo_read =>
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    SNN_reset   <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0'; 

when S_delay_cycle =>
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    SNN_reset   <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0';
    
when S_feature_layer_regs_en =>
    feature_layer_regs_wr <= '1';
    feature_layer_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    SNN_reset   <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0'; 
        
when S_SNN_reset =>
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    SNN_reset   <= '1';
    ready <= '0';
    done  <= '0';   
    error <= '0'; 
        
when S_SNN_trigger =>
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '1';
    SNN_reset   <= '0';
    ready <= '0';
    done  <= '0';   
    error <= '0';      
        
when S_reset_feature_layer =>
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '1';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    SNN_reset   <= '0';
    ready <= '0';
    done  <= '0';        
    error <= '0';   
        
when S_done =>
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    SNN_reset   <= '0';
    ready <= '0';
    done  <= '1';   
    error <= '0';        
              
when S_error =>
    feature_layer_regs_wr <= '0';
    feature_layer_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    SNN_reset   <= '0';
    ready <= '0';
    done  <= '0';   
    error <= '1';         
           
end case;

end Process;

fifo_rd_en_o <= fifo_rd_en;
watchdog_error_o <= error;
----------------------------------------------------------------------------------------------------------------

end Behavioral;

