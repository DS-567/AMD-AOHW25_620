
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
      watchdog_en_i : in std_logic;
      clear_faults_button_i  : in std_logic;
      fifo_empty_i  : in std_logic;
      fifo_rd_valid_i : in std_logic;
      fifo_data_i : in std_logic_vector(163 downto 0);
      fifo_rd_en_o : out std_logic;
      neorv32_data_ready_to_read_o : out std_logic;
      uB_has_read_neorv32_data_i : in std_logic;
      features_o : out std_logic_vector(g_SNN_layer_sizes(0)-1 downto 0);
      SNN_done_o : out std_logic;
      SNN_class_zero_o : out std_logic;
      SNN_class_one_o  : out std_logic;
      SNN_class_ready_to_read_o : out std_logic;
      uB_has_read_SNN_class_data_i : in std_logic;
      watchdog_ready_o : out std_logic;
      watchdog_busy_o  : out std_logic;
      watchdog_done_o  : out std_logic;
      watchdog_error_o : out std_logic;
      watchdog_no_faults_detected_o : out std_logic;
      watchdog_fault_detected_o : out std_logic;
      
      input_neurons_spike_shift_reg_o : out std_logic_vector(160 downto 1);
      hidden_neurons_spike_shift_reg_o : out std_logic_vector(200 downto 1);
      output_neurons_spike_shift_reg_o : out std_logic_vector(20 downto 1)
    );
end watchdog_2;

architecture Behavioral of watchdog_2 is
   
attribute keep: boolean;

type State_type is (S_reset, S_idle, S_fifo_read, S_check_fifo_read, S_neorv32_data_to_read, S_check_for_instruction_executed,
                    S_FL_output_ffs_wr, S_SNN_trigger, S_wait_for_SNN_done, S_SNN_class_data_ready_to_read, S_SNN_class_check,
                    S_FL_ffs_rst, S_fault_detected, S_done, S_error);
                                                           
signal S_Current_State, S_Next_State : State_type;
attribute keep of S_Current_State: signal is true;
attribute keep of S_Next_State: signal is true; 

signal ready : std_logic;
signal done  : std_logic;
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

signal watchdog_fault_detected_ff : std_logic; 
signal watchdog_fault_detected_ff_en : std_logic;
attribute keep of watchdog_fault_detected_ff : signal is true;
attribute keep of watchdog_fault_detected_ff_en : signal is true;

signal watchdog_output_led_ffs_en : std_logic;
attribute keep of watchdog_output_led_ffs_en : signal is true;

signal clear_fault_pulse : std_logic;
attribute keep of clear_fault_pulse : signal is true;

signal uB_has_read_neorv32_data_pulse : std_logic;
attribute keep of uB_has_read_neorv32_data_pulse : signal is true;

signal uB_has_read_class_data_pulse : std_logic;
attribute keep of uB_has_read_class_data_pulse : signal is true;

signal neorv32_data_ready_to_read : std_logic;
attribute keep of neorv32_data_ready_to_read : signal is true;

signal SNN_class_ready_to_read : std_logic;
attribute keep of SNN_class_ready_to_read : signal is true;

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
         
features_o <= features;
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
          done_o    => SNN_done,
          
          input_neurons_spike_shift_reg_o => input_neurons_spike_shift_reg_o,
          hidden_neurons_spike_shift_reg_o => hidden_neurons_spike_shift_reg_o,
          output_neurons_spike_shift_reg_o => output_neurons_spike_shift_reg_o
         );
         
SNN_done_o <= SNN_done;
SNN_class_zero_o <= SNN_classes(0);
SNN_class_one_o <= SNN_classes(1);
---------------------------------------------------------------------------------------------------------------

--- uB has read neorv32 data rising pulse generator -----------------------------------------------------------
uB_read_neorv32_data_pulse_gen : pulse_generator
port map (clk_i   => clk_i,
          rstn_i  => rstn_i,
          bit_i   => uB_has_read_neorv32_data_i,
          pulse_o => uB_has_read_neorv32_data_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- uB has read snn class data rising pulse generator ---------------------------------------------------------
uB_read_class_pulse_gen : pulse_generator
port map (clk_i   => clk_i,
          rstn_i  => rstn_i,
          bit_i   => uB_has_read_SNN_class_data_i,
          pulse_o => uB_has_read_class_data_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- clear faults button rising pulse generator ----------------------------------------------------------------
clear_fault_pulse_gen : pulse_generator
port map (clk_i   => clk_i,
          rstn_i  => rstn_i,
          bit_i   => clear_faults_button_i,
          pulse_o => clear_fault_pulse
         );
---------------------------------------------------------------------------------------------------------------

--- watchdog fault detected flip flop -------------------------------------------------------------------------
Process(clk_i, rstn_i)

begin

if (rstn_i = '0') then
    watchdog_fault_detected_ff <= '0';
elsif (rising_edge(clk_i)) then
    if (watchdog_fault_detected_ff_en = '1') then
        watchdog_fault_detected_ff <= '1';
    
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm current state logic -----------------------------------------------------------------------------------
fsm_current : Process (clk_i, rstn_i)

begin

if (rstn_i = '0') then
    S_Current_State <= S_reset;

elsif (rising_edge(clk_i)) then
    S_Current_State <= S_Next_State;
    
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- fsm next state logic --------------------------------------------------------------------------------------
fsm_next : Process (S_Current_State, watchdog_en_i, fifo_empty_i, fifo_rd_valid_i, uB_has_read_neorv32_data_pulse,
                    instruction_executed, SNN_ready, SNN_done, uB_has_read_class_data_pulse, SNN_classes, clear_fault_pulse)

begin

case S_Current_State is
    
    when S_reset =>
        S_Next_State <= S_idle;
        
    when S_idle =>
        if (fifo_empty_i = '0' and watchdog_en_i = '1') then
            S_Next_State <= S_fifo_read;
        else
            S_Next_State <= S_idle;
        end if;
    
    when S_fifo_read =>
        S_Next_State <= S_check_fifo_read;
       
    when S_check_fifo_read =>
        if (fifo_rd_valid_i = '1') then
            S_Next_State <= S_neorv32_data_to_read;
        else
            S_Next_State <= S_error;
        end if;
    
    when S_neorv32_data_to_read =>
        if (uB_has_read_neorv32_data_pulse = '1') then
            S_Next_State <= S_check_for_instruction_executed;
        else
            S_Next_State <= S_neorv32_data_to_read;
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
        S_Next_State <= S_wait_for_SNN_done;
        
    when S_wait_for_SNN_done =>
        if (SNN_done = '1') then
            S_Next_State <= S_SNN_class_data_ready_to_read;
        else
            S_Next_State <= S_wait_for_SNN_done;
        end if;
    
    when S_SNN_class_data_ready_to_read =>
        if (uB_has_read_class_data_pulse = '1') then
            S_Next_State <= S_SNN_class_check;
        else
            S_Next_State <= S_SNN_class_data_ready_to_read;
        end if;
    
    when S_SNN_class_check =>
        if (SNN_classes(0) = '1') then
            S_Next_State <= S_FL_ffs_rst;
        elsif (SNN_classes(1) = '1') then
            S_Next_State <= S_fault_detected;    
        else
            S_Next_State <= S_SNN_class_check;
        end if;
    
    when S_FL_ffs_rst =>
        if (fifo_empty_i = '1') then
            S_Next_State <= S_done;
        else
            S_Next_State <= S_fifo_read;
        end if;
   
    when S_fault_detected =>
        S_Next_State <= S_FL_ffs_rst;
    
    when S_done =>
        if (clear_fault_pulse = '1') then
            S_Next_State <= S_idle;
        else
            S_Next_State <= S_done;
        end if; 
        
    when S_error =>
        S_Next_State <= S_error;
        
end case;

end Process;
----------------------------------------------------------------------------------------------------------------

--- fsm output decoding logic ----------------------------------------------------------------------------------
fsm_outputs : Process (S_Current_State) 

begin

case S_Current_State is

when S_reset =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0';
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';

when S_idle =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '1';
    done  <= '0';
    error <= '0';
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';

when S_fifo_read =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '1';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0';
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';

when S_check_fifo_read =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0';
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';

when S_neorv32_data_to_read =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0';
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '1';
    SNN_class_ready_to_read <= '0';

when S_check_for_instruction_executed =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0';
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';
        
when S_FL_output_ffs_wr =>
    FL_output_ffs_wr <= '1';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';
    error <= '0';
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';
                
when S_SNN_trigger =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '1';
    ready <= '0';
    done  <= '0';   
    error <= '0';      
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';

when S_wait_for_SNN_done =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';   
    error <= '0';  
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';

when S_SNN_class_data_ready_to_read =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';        
    error <= '0';   
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '1';

when S_SNN_class_check =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';        
    error <= '0';   
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';

when S_FL_ffs_rst =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '1';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';        
    error <= '0';   
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';
    
when S_fault_detected => 
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';   
    error <= '0';        
    watchdog_fault_detected_ff_en <= '1';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';
              
when S_done =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '1';   
    error <= '0';        
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '1';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';

when S_error =>
    FL_output_ffs_wr <= '0';
    FL_ffs_rst <= '0';
    fifo_rd_en <= '0';
    SNN_trigger <= '0';
    ready <= '0';
    done  <= '0';   
    error <= '1';         
    watchdog_fault_detected_ff_en <= '0';
    watchdog_output_led_ffs_en <= '0';
    neorv32_data_ready_to_read <= '0';
    SNN_class_ready_to_read <= '0';
           
end case;

end Process;

fifo_rd_en_o <= fifo_rd_en;

watchdog_ready_o <= ready;
watchdog_busy_o  <= not ready;
watchdog_done_o  <= done;
watchdog_error_o <= error;

neorv32_data_ready_to_read_o <= neorv32_data_ready_to_read;
SNN_class_ready_to_read_o <= SNN_class_ready_to_read;
---------------------------------------------------------------------------------------------------------------

--- watchdog fault detected output led flip flops AND gates ---------------------------------------------------
watchdog_no_faults_detected_o <= (not watchdog_fault_detected_ff) and watchdog_output_led_ffs_en;
watchdog_fault_detected_o <= watchdog_fault_detected_ff and watchdog_output_led_ffs_en;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
