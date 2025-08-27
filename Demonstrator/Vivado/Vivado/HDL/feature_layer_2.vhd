
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity feature_layer_2 is
Generic (g_num_features : natural);
Port (clk_i  : in std_logic;
      rstn_i : in std_logic;
      fifo_new_data_i : in std_logic;
      fifo_data_i : in std_logic_vector(163 downto 0);
      layer_features_reg_wr_i : in std_logic;
      layer_reset_i : in std_logic;
      instruction_executed_o : out std_logic;
      features_o : out std_logic_vector(g_num_features-1 downto 0)         
     );
end feature_layer_2;

architecture Behavioral of feature_layer_2 is

attribute keep: boolean;

constant dispatch_state : std_logic_vector(3 downto 0) := "0000";  
constant execute_state : std_logic_vector(3 downto 0) := "0110";  
constant branched_state  : std_logic_vector(3 downto 0) := "1001";
constant trap_enter_state  : std_logic_vector(3 downto 0) := "0001";
constant trap_exit_state  : std_logic_vector(3 downto 0)  := "0010";

signal ir_data : std_logic_vector(31 downto 0);
signal pc_data : std_logic_vector(31 downto 0);
signal execute_states_data : std_logic_vector(3 downto 0);
signal rs1_data : std_logic_vector(31 downto 0);
signal mtvec_data : std_logic_vector(31 downto 0);
signal mepc_data : std_logic_vector(31 downto 0);
attribute keep of ir_data : signal is true;
attribute keep of pc_data : signal is true;
attribute keep of execute_states_data : signal is true;
attribute keep of rs1_data : signal is true;
attribute keep of mtvec_data : signal is true;
attribute keep of mepc_data : signal is true;

signal dispatch_state_found : std_logic;
attribute keep of dispatch_state_found : signal is true;

signal instruction_started : std_logic;
signal instruction_executed : std_logic;
attribute keep of instruction_started : signal is true;
attribute keep of instruction_executed : signal is true;

signal current_ir : std_logic_vector(31 downto 0);
signal last_ir : std_logic_vector(31 downto 0);
attribute keep of current_ir : signal is true;
attribute keep of last_ir : signal is true;

signal last_ir_opcode : std_logic_vector(6 downto 0);
attribute keep of last_ir_opcode : signal is true;

signal current_pc : std_logic_vector(31 downto 0);
signal last_pc : std_logic_vector(31 downto 0);
attribute keep of last_pc : signal is true;
attribute keep of current_pc : signal is true;

signal cpu_branched_state : std_logic;
signal cpu_trap_enter_state : std_logic;
signal cpu_trap_exit_state : std_logic;
attribute keep of cpu_branched_state : signal is true;
attribute keep of cpu_trap_enter_state : signal is true;
attribute keep of cpu_trap_exit_state : signal is true;

signal branch_address : std_logic_vector(31 downto 0);
attribute keep of branch_address : signal is true;

signal jal_address : std_logic_vector(31 downto 0);
attribute keep of jal_address : signal is true;

signal jalr_address : std_logic_vector(31 downto 0);
attribute keep of jalr_address : signal is true;

signal pc_sub_result : std_logic_vector(31 downto 0);
attribute keep of pc_sub_result : signal is true;

signal pc_increment : std_logic;
attribute keep of pc_increment : signal is true;

signal pc_rs1_sub_result : std_logic_vector(31 downto 0);
attribute keep of pc_rs1_sub_result : signal is true;

signal branch_valid : std_logic;
attribute keep of branch_valid : signal is true;

signal jal_valid : std_logic;
attribute keep of jal_valid : signal is true;

signal jalr_valid : std_logic;
attribute keep of jalr_valid : signal is true;

signal trap_enter_valid : std_logic;
attribute keep of trap_enter_valid : signal is true;

signal trap_exit_valid : std_logic;
attribute keep of trap_exit_valid : signal is true;

signal last_ir_opcode_out : std_logic_vector(6 downto 0);
signal cpu_branched_state_out : std_logic;
signal cpu_trap_enter_state_out : std_logic;
signal cpu_trap_exit_state_out : std_logic;
signal pc_increment_out : std_logic;
signal branch_valid_out : std_logic;
signal jal_valid_out : std_logic;
signal jalr_valid_out : std_logic;
signal trap_enter_valid_out : std_logic;
signal trap_exit_valid_out : std_logic;
attribute keep of last_ir_opcode_out : signal is true;
attribute keep of cpu_branched_state_out : signal is true;
attribute keep of cpu_trap_enter_state_out : signal is true;
attribute keep of cpu_trap_exit_state_out : signal is true;
attribute keep of pc_increment_out : signal is true;
attribute keep of branch_valid_out : signal is true;
attribute keep of jal_valid_out : signal is true;
attribute keep of jalr_valid_out : signal is true;
attribute keep of trap_enter_valid_out : signal is true;
attribute keep of trap_exit_valid_out : signal is true;

begin

--- assigning fifo data to the feature values -----------------------------------------------------------------
ir_data <= fifo_data_i(31 downto 0);
pc_data <= fifo_data_i(63 downto 32);
execute_states_data <= fifo_data_i(67 downto 64);
rs1_data <= fifo_data_i(99 downto 68);
mtvec_data <= fifo_data_i(131 downto 100);
mepc_data <= fifo_data_i(163 downto 132);
---------------------------------------------------------------------------------------------------------------

--- flip flip to store the first dispatch state found (feature layer can begin processing neorv32 data) -------
Process (clk_i)

begin

if (rising_edge(clk_i)) then   
    if (rstn_i = '0') then
        dispatch_state_found <= '0';
            
    elsif (fifo_new_data_i = '1' and execute_states_data = dispatch_state) then 
        dispatch_state_found <= '1';
    
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- an instruction has been executed logic --------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then   
    if (rstn_i = '0') then
        instruction_started <= '0';
        instruction_executed <= '0';
    
    elsif (layer_reset_i = '1') then
        instruction_executed  <= '0';
        
    elsif (dispatch_state_found = '1' and fifo_new_data_i = '1' and execute_states_data = execute_state) then 
        instruction_started <= '1';
        instruction_executed <= instruction_started;
    
    end if;
end if;

end Process;

instruction_executed_o <= instruction_executed;
---------------------------------------------------------------------------------------------------------------

--- IR and PC registers pipeline ------------------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then   
    if (rstn_i = '0') then
        current_ir <= (others => '0');
        last_ir  <= (others => '0');
        
        current_pc <= (others => '0');
        last_pc    <= (others => '0');
    
    elsif (dispatch_state_found = '1' and fifo_new_data_i = '1' and execute_states_data = execute_state) then 
        current_ir <= ir_data;
        last_ir <= current_ir;
        
        current_pc <= pc_data;
        last_pc    <= current_pc;
    
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- ir opcode -------------------------------------------------------------------------------------------------
last_ir_opcode <= last_ir(6 downto 0);
---------------------------------------------------------------------------------------------------------------

--- cpu branched state active flip flop -----------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0' or layer_reset_i = '1') then
        cpu_branched_state <= '0';
        
    elsif (dispatch_state_found = '1' and fifo_new_data_i = '1' and execute_states_data = branched_state) then
        cpu_branched_state <= '1';
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- cpu trap enter state active flip flop ---------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0' or layer_reset_i = '1') then
        cpu_trap_enter_state <= '0';
        
    elsif (dispatch_state_found = '1' and fifo_new_data_i = '1' and execute_states_data = trap_enter_state) then
        cpu_trap_enter_state <= '1';
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- cpu trap exit state active flip flop ----------------------------------------------------------------------
Process(clk_i)

begin

if (rising_edge(clk_i)) then
    if (rstn_i = '0' or layer_reset_i = '1') then
        cpu_trap_exit_state <= '0';
        
    elsif (dispatch_state_found = '1' and fifo_new_data_i = '1' and execute_states_data = trap_exit_state) then
        cpu_trap_exit_state <= '1';
    end if;
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- last ir branch address offset -----------------------------------------------------------------------------
Process (last_ir)

begin

if (last_ir(6 downto 0) = "1100011") then    --branch opcode
    if (last_ir(31) = '1') then              --check MSB for sign
        branch_address <= "1111111111111111111" & last_ir(31) & last_ir(7) & last_ir(30 downto 25) & last_ir(11 downto 8) & '0';
    else
        branch_address <= "0000000000000000000" & last_ir(31) & last_ir(7) & last_ir(30 downto 25) & last_ir(11 downto 8) & '0';
    end if;
else
    branch_address <= x"00000000";           --zero if not branch  
end if;

end Process;
---------------------------------------------------------------------------------------------------------------

--- last ir jal address offset --------------------------------------------------------------------------------
Process (last_ir)

begin

if (last_ir(6 downto 0) = "1101111") then    --jal opcode
    if (last_ir(31) = '1') then              --check MSB for sign
       jal_address <= "11111111111" & last_ir(31) & last_ir(19 downto 12) & last_ir(20) & last_ir(30 downto 21) & '0';
    else
       jal_address <= "00000000000" & last_ir(31) & last_ir(19 downto 12) & last_ir(20) & last_ir(30 downto 21) & '0';
    end if;
else
    jal_address <= x"00000000";              --zero if not jal   
end if;
    
end Process;
---------------------------------------------------------------------------------------------------------------

--- last ir jalr address offset -------------------------------------------------------------------------------
Process (last_ir)

begin

if (last_ir(6 downto 0) = "1100111") then    --jalr opcode
    if (last_ir(31) = '1') then              --check MSB for sign
        jalr_address <= "11111111111111111111" & last_ir(31 downto 20);
    else
        jalr_address <= "00000000000000000000" & last_ir(31 downto 20);
    end if;
else
    jalr_address <= x"00000000";             --zero if not jalr
end if;
    
end Process;
--------------------------------------------------------------------------------------------------------------- 

--- current pc - last pc register assignement -----------------------------------------------------------------
pc_sub_result <= std_logic_vector(unsigned(current_pc) - unsigned(last_pc));
---------------------------------------------------------------------------------------------------------------

--- pc increment (pc sub result and 4 comparator) -------------------------------------------------------------
pc_increment <= '1' when (pc_sub_result = x"00000004") else '0';
---------------------------------------------------------------------------------------------------------------

--- branch valid (pc sub result and branch / jal address comparator) ------------------------------------------
branch_valid <= '1' when (pc_sub_result = branch_address) else '0';  
---------------------------------------------------------------------------------------------------------------

--- jal valid (pc sub result and branch / jal address comparator) ---------------------------------------------
jal_valid <= '1' when (pc_sub_result = jal_address) else '0';  
---------------------------------------------------------------------------------------------------------------

--- current pc - rs1 register assignement ---------------------------------------------------------------------
pc_rs1_sub_result <= std_logic_vector(unsigned(current_pc) - unsigned(rs1_data));
---------------------------------------------------------------------------------------------------------------

--- jalr valid (pc sub result and jalr address comparator) ----------------------------------------------------
jalr_valid <= '1' when (pc_rs1_sub_result = jalr_address) else '0'; 
---------------------------------------------------------------------------------------------------------------

--- trap enter valid logic ------------------------------------------------------------------------------------
trap_enter_valid <= '1' when (current_pc = mtvec_data) else '0';
---------------------------------------------------------------------------------------------------------------

--- trap exit valid logic -------------------------------------------------------------------------------------
trap_exit_valid <= '1' when (current_pc = mepc_data) else '0';
---------------------------------------------------------------------------------------------------------------

--- final feature layer output registers ----------------------------------------------------------------------
Process (clk_i)

begin

if (rising_edge(clk_i)) then   
    if (rstn_i = '0') then
        last_ir_opcode_out <= (others => '0');
        cpu_branched_state_out   <= '0';
        cpu_trap_enter_state_out <= '0';
        cpu_trap_exit_state_out  <= '0';
        pc_increment_out <= '0';
        branch_valid_out <= '0';
        jal_valid_out    <= '0';
        jalr_valid_out   <= '0';
        trap_enter_valid_out <= '0';
        trap_exit_valid_out  <= '0';

    elsif (layer_features_reg_wr_i = '1') then 
        last_ir_opcode_out <= last_ir_opcode;
        cpu_branched_state_out   <= cpu_branched_state;
        cpu_trap_enter_state_out <= cpu_trap_enter_state;
        cpu_trap_exit_state_out  <= cpu_trap_exit_state;
        pc_increment_out <= pc_increment;
        branch_valid_out <= branch_valid;
        jal_valid_out    <= jal_valid;
        jalr_valid_out   <= jalr_valid;
        trap_enter_valid_out <= trap_enter_valid;
        trap_exit_valid_out  <= trap_exit_valid;
    
    end if;
end if;

end Process;

features_o(6 downto 0) <= f_swap_bits(last_ir_opcode_out(6 downto 0));
features_o(7)  <= cpu_branched_state_out;
features_o(8)  <= cpu_trap_enter_state_out;
features_o(9)  <= cpu_trap_exit_state_out;
features_o(10) <= pc_increment_out;
features_o(11) <= branch_valid_out;
features_o(12) <= jal_valid_out;
features_o(13) <= jalr_valid_out;
features_o(14) <= trap_enter_valid_out;
features_o(15) <= trap_exit_valid_out;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
