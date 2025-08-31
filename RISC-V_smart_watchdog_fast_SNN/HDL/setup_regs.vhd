
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.SNN_package.all;

entity setup_regs is
  Port (clk_i                  : in std_logic;
        rstn_i                 : in std_logic;
        uBlaze_data_i          : in std_logic_vector(22 downto 0);
        setup_regs_data_o      : out std_logic_vector(15 downto 0);
        application_run_time_o : out std_logic_vector(15 downto 0);
        stuck_at_hold_time_o   : out std_logic_vector(15 downto 0);
        spare_reg_o            : out std_logic_vector(15 downto 0);
        fault_injection_en_o   : out std_logic_vector(0 downto 0);
        bit_1_data_o           : out std_logic_vector(53 downto 0);
        bit_2_data_o           : out std_logic_vector(53 downto 0);
        bit_3_data_o           : out std_logic_vector(53 downto 0);
        bit_4_data_o           : out std_logic_vector(53 downto 0);
        bit_5_data_o           : out std_logic_vector(53 downto 0);
        bit_6_data_o           : out std_logic_vector(53 downto 0);
        bit_7_data_o           : out std_logic_vector(53 downto 0);
        bit_8_data_o           : out std_logic_vector(53 downto 0);
        bit_9_data_o           : out std_logic_vector(53 downto 0);
        bit_10_data_o          : out std_logic_vector(53 downto 0)
       );
end setup_regs;

architecture Behavioral of setup_regs is

signal uBlaze_data_lines         : std_logic_vector(15 downto 0);
signal uBlaze_addr_lines         : std_logic_vector(5 downto 0);
signal uBlaze_wr_en_line         : std_logic;
signal reg_addr_decoded_wr_lines : std_logic_vector(63 downto 0);

type fault_times_reg_data is array (0 to 29) of std_logic_vector(15 downto 0);
signal fault_times_data : fault_times_reg_data;

type fault_types_reg_data is array (30 to 59) of std_logic_vector(1 downto 0);
signal fault_types_data : fault_types_reg_data;

type fault_types_mux is array (30 to 59) of std_logic_vector(15 downto 0);
signal fault_types_mux_data : fault_types_mux;

signal stuck_at_hold_time_reg_data : std_logic_vector(15 downto 0);
 
signal spare_reg_data : std_logic_vector(15 downto 0); 
signal spare_reg_mux  : std_logic_vector(15 downto 0);

signal fault_injection_en_reg_data : std_logic_vector(0 downto 0);  
signal fault_injection_en_reg_mux  : std_logic_vector(15 downto 0);  

signal application_run_time_reg_data  : std_logic_vector(15 downto 0);  

signal mux_zero_out  : std_logic_vector(15 downto 0);
signal mux_one_out   : std_logic_vector(15 downto 0);
signal mux_two_out   : std_logic_vector(15 downto 0);
signal mux_three_out : std_logic_vector(15 downto 0);
signal mux_four_out  : std_logic_vector(15 downto 0);
signal mux_five_out  : std_logic_vector(15 downto 0);
signal mux_six_out   : std_logic_vector(15 downto 0);
signal mux_seven_out : std_logic_vector(15 downto 0);
signal read_mux_out  : std_logic_vector(15 downto 0);

signal mux_switch_addr : std_logic_vector(4 downto 0);
signal mux_switch_addr_int : integer;

begin 

------------------------------------------------------------------------------------------------------------------------
--- input and output mapping of setup regs output data ---

spare_reg_o <= (others => '0');

application_run_time_o <= "0000101110111000"; --3,000
                                                              
stuck_at_hold_time_o   <= "0000000000000000"; 
                                   
fault_injection_en_o   <= "1";

bit_1_data_o(1 downto 0)    <= "00"; 
bit_1_data_o(3 downto 2)    <= "00";
bit_1_data_o(5 downto 4)    <= "00";
bit_1_data_o(21 downto 6)   <= "0000000000000000"; 
bit_1_data_o(37 downto 22)  <= "0000000000000000"; 
bit_1_data_o(53 downto 38)  <= "0000000000000000"; 

bit_2_data_o(1 downto 0)    <= "00";    
bit_2_data_o(3 downto 2)    <= "00";
bit_2_data_o(5 downto 4)    <= "00";
bit_2_data_o(21 downto 6)   <= "0000000000000000"; 
bit_2_data_o(37 downto 22)  <= "0000000000000000"; 
bit_2_data_o(53 downto 38)  <= "0000000000000000";
                                    
bit_3_data_o(1 downto 0)    <= "00"; 
bit_3_data_o(3 downto 2)    <= "00";
bit_3_data_o(5 downto 4)    <= "00";
bit_3_data_o(21 downto 6)   <= "0000000000000000"; 
bit_3_data_o(37 downto 22)  <= "0000000000000000"; 
bit_3_data_o(53 downto 38)  <= "0000000000000000"; 

bit_4_data_o(1 downto 0)    <= "11"; 
bit_4_data_o(3 downto 2)    <= "00";
bit_4_data_o(5 downto 4)    <= "00";
bit_4_data_o(21 downto 6)   <= "0000000000001010"; -- 10
bit_4_data_o(37 downto 22)  <= "0000000000000000";
bit_4_data_o(53 downto 38)  <= "0000000000000000";

bit_5_data_o(1 downto 0)    <= "00"; 
bit_5_data_o(3 downto 2)    <= "00";
bit_5_data_o(5 downto 4)    <= "00";
bit_5_data_o(21 downto 6)   <= "0000000000000000"; 
bit_5_data_o(37 downto 22)  <= "0000000000000000";
bit_5_data_o(53 downto 38)  <= "0000000000000000";

bit_6_data_o(1 downto 0)    <= "00"; 
bit_6_data_o(3 downto 2)    <= "00";
bit_6_data_o(5 downto 4)    <= "00";
bit_6_data_o(21 downto 6)   <= "0000000000000000";
bit_6_data_o(37 downto 22)  <= "0000000000000000"; 
bit_6_data_o(53 downto 38)  <= "0000000000000000";

bit_7_data_o(1 downto 0)    <= "00"; 
bit_7_data_o(3 downto 2)    <= "00";
bit_7_data_o(5 downto 4)    <= "00";
bit_7_data_o(21 downto 6)   <= "0000000000000000"; 
bit_7_data_o(37 downto 22)  <= "0000000000000000";
bit_7_data_o(53 downto 38)  <= "0000000000000000";

bit_8_data_o(1 downto 0)    <= "00"; 
bit_8_data_o(3 downto 2)    <= "00";
bit_8_data_o(5 downto 4)    <= "00";
bit_8_data_o(21 downto 6)   <= "0000000000000000"; 
bit_8_data_o(37 downto 22)  <= "0000000000000000";
bit_8_data_o(53 downto 38)  <= "0000000000000000";

bit_9_data_o(1 downto 0)    <= "00"; 
bit_9_data_o(3 downto 2)    <= "00";
bit_9_data_o(5 downto 4)    <= "00";
bit_9_data_o(21 downto 6)   <= "0000000000000000"; 
bit_9_data_o(37 downto 22)  <= "0000000000000000";
bit_9_data_o(53 downto 38)  <= "0000000000000000";

bit_10_data_o(1 downto 0)    <= "00"; 
bit_10_data_o(3 downto 2)    <= "00";
bit_10_data_o(5 downto 4)    <= "00";
bit_10_data_o(21 downto 6)   <= "0000000000000000"; 
bit_10_data_o(37 downto 22)  <= "0000000000000000";
bit_10_data_o(53 downto 38)  <= "0000000000000000";

------------------------------------------------------------------------------------------------------------------------
--- input and output mapping of microblaze input data to internal module signals ---

uBlaze_data_lines <= uBlaze_data_i(15 downto 0);
uBlaze_addr_lines <= uBlaze_data_i(21 downto 16);
uBlaze_wr_en_line <= uBlaze_data_i(22);

setup_regs_data_o <= read_mux_out;

------------------------------------------------------------------------------------------------------------------------
--- 6 to 64 bit address decoder component instantiation ---

address_wr_decoder_inst : address_wr_decoder
Port map (clk_100MHz_i     => clk_i,
          rstn_i           => rstn_i,
          wr_en_i   => uBlaze_wr_en_line,
          addr_i    => uBlaze_addr_lines,
          decoded_reg_en_o => reg_addr_decoded_wr_lines
         );
  
------------------------------------------------------------------------------------------------------------------------
--- 16-bit register component instantiations for fault times on 10 bits (30 off these) ---

Fault_Times_Regs_generate : for i in 0 to 29 generate

Fault_Times_Regs : D_Type_FF_Reg
 generic map (bit_width    => 16)
 Port map    (clk_100MHz_i => clk_i,
              rstn_i       => rstn_i,
              wr_en_i      => reg_addr_decoded_wr_lines(i),
              data_i       => uBlaze_data_lines,
              data_o       => fault_times_data(i)
             );

end generate Fault_Times_Regs_generate;

------------------------------------------------------------------------------------------------------------------------
--- 2-bit register component instantiations for fault types on 10 bits (30 off these) ---

Fault_Types_Regs_generate : for i in 30 to 59 generate

Fault_Types_Regs : D_Type_FF_Reg
 generic map (bit_width    => 2)
 Port map    (clk_100MHz_i => clk_i,
              rstn_i       => rstn_i,
              wr_en_i      => reg_addr_decoded_wr_lines(i),
              data_i       => uBlaze_data_lines(1 downto 0),
              data_o       => fault_types_data(i)
             );

end generate Fault_Types_Regs_generate;

fault_types_mux_data(30) <= "00000000000000" & fault_types_data(30);
fault_types_mux_data(31) <= "00000000000000" & fault_types_data(31);
fault_types_mux_data(32) <= "00000000000000" & fault_types_data(32);
fault_types_mux_data(33) <= "00000000000000" & fault_types_data(33);
fault_types_mux_data(34) <= "00000000000000" & fault_types_data(34);
fault_types_mux_data(35) <= "00000000000000" & fault_types_data(35);
fault_types_mux_data(36) <= "00000000000000" & fault_types_data(36);
fault_types_mux_data(37) <= "00000000000000" & fault_types_data(37);
fault_types_mux_data(38) <= "00000000000000" & fault_types_data(38);
fault_types_mux_data(39) <= "00000000000000" & fault_types_data(39);
fault_types_mux_data(40) <= "00000000000000" & fault_types_data(40);
fault_types_mux_data(41) <= "00000000000000" & fault_types_data(41);
fault_types_mux_data(42) <= "00000000000000" & fault_types_data(42);
fault_types_mux_data(43) <= "00000000000000" & fault_types_data(43);
fault_types_mux_data(44) <= "00000000000000" & fault_types_data(44);
fault_types_mux_data(45) <= "00000000000000" & fault_types_data(45);
fault_types_mux_data(46) <= "00000000000000" & fault_types_data(46);
fault_types_mux_data(47) <= "00000000000000" & fault_types_data(47);
fault_types_mux_data(48) <= "00000000000000" & fault_types_data(48);
fault_types_mux_data(49) <= "00000000000000" & fault_types_data(49);
fault_types_mux_data(50) <= "00000000000000" & fault_types_data(50);
fault_types_mux_data(51) <= "00000000000000" & fault_types_data(51);
fault_types_mux_data(52) <= "00000000000000" & fault_types_data(52);
fault_types_mux_data(53) <= "00000000000000" & fault_types_data(53);
fault_types_mux_data(54) <= "00000000000000" & fault_types_data(54);
fault_types_mux_data(55) <= "00000000000000" & fault_types_data(55);
fault_types_mux_data(56) <= "00000000000000" & fault_types_data(56);
fault_types_mux_data(57) <= "00000000000000" & fault_types_data(57);
fault_types_mux_data(58) <= "00000000000000" & fault_types_data(58);
fault_types_mux_data(59) <= "00000000000000" & fault_types_data(59);

------------------------------------------------------------------------------------------------------------------------
--- 16-bit register component instantiation for stuck at hold time (1 off these) ---

Stuck_at_Hold_Time_Reg : D_Type_FF_Reg
 generic map (bit_width    => 16)
 Port map    (clk_100MHz_i => clk_i,
              rstn_i       => rstn_i,
              wr_en_i      => reg_addr_decoded_wr_lines(60),
              data_i       => uBlaze_data_lines,
              data_o       => stuck_at_hold_time_reg_data
             );

------------------------------------------------------------------------------------------------------------------------
--- 16-bit register component instantiation now spare (was used for bit flip hold time (1 off these) ---

Spare_Reg : D_Type_FF_Reg
 generic map (bit_width    => 16)
 Port map    (clk_100MHz_i => clk_i,
              rstn_i       => rstn_i,
              wr_en_i      => reg_addr_decoded_wr_lines(61),
              data_i       => uBlaze_data_lines(15 downto 0),
              data_o       => spare_reg_data
             );
             
spare_reg_mux <= spare_reg_data;

------------------------------------------------------------------------------------------------------------------------
--- 1-bit register component instantiation for fault injection enable (1 off these) ---

Fault_Injection_Enable_Reg : D_Type_FF_Reg
 generic map (bit_width    => 1)
 Port map    (clk_100MHz_i => clk_i,
              rstn_i       => rstn_i,
              wr_en_i      => reg_addr_decoded_wr_lines(62),
              data_i       => uBlaze_data_lines(0 downto 0),
              data_o       => fault_injection_en_reg_data
             );
 
fault_injection_en_reg_mux(0 downto 0) <= fault_injection_en_reg_data;
fault_injection_en_reg_mux(15 downto 1) <= (others => '0');

------------------------------------------------------------------------------------------------------------------------
--- 16-bit register component instantiation for application run time (1 off these) ---

Application_Run_time_Reg : D_Type_FF_Reg
 generic map (bit_width    => 16)
 Port map    (clk_100MHz_i => clk_i,
              rstn_i       => rstn_i,
              wr_en_i      => reg_addr_decoded_wr_lines(63),
              data_i       => uBlaze_data_lines,
              data_o       => application_run_time_reg_data
             );
            
-------------------------------------------------------------------------------
--- 8 to 1 mux 0 component instantiation ---

eight_to_one_mux_inst_0 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => fault_times_data(0), 
          data_one_i    => fault_times_data(1), 
          data_two_i    => fault_times_data(2), 
          data_three_i  => fault_times_data(3), 
          data_four_i   => fault_times_data(4), 
          data_five_i   => fault_times_data(5), 
          data_six_i    => fault_times_data(6), 
          data_seven_i  => fault_times_data(7), 
          sel_i         => uBlaze_addr_lines(2 downto 0), 
          data_o        => mux_zero_out 
       );

-------------------------------------------------------------------------------
--- 8 to 1 mux 1 component instantiation ---

eight_to_one_mux_inst_1 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => fault_times_data(8), 
          data_one_i    => fault_times_data(9), 
          data_two_i    => fault_times_data(10), 
          data_three_i  => fault_times_data(11), 
          data_four_i   => fault_times_data(12), 
          data_five_i   => fault_times_data(13), 
          data_six_i    => fault_times_data(14), 
          data_seven_i  => fault_times_data(15), 
          sel_i         => uBlaze_addr_lines(2 downto 0), 
          data_o        => mux_one_out 
       );

-------------------------------------------------------------------------------
--- 8 to 1 mux 2 component instantiation ---

eight_to_one_mux_inst_2 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => fault_times_data(16), 
          data_one_i    => fault_times_data(17), 
          data_two_i    => fault_times_data(18), 
          data_three_i  => fault_times_data(19), 
          data_four_i   => fault_times_data(20), 
          data_five_i   => fault_times_data(21), 
          data_six_i    => fault_times_data(22), 
          data_seven_i  => fault_times_data(23), 
          sel_i         => uBlaze_addr_lines(2 downto 0), 
          data_o        => mux_two_out 
       );
       
-------------------------------------------------------------------------------
--- 8 to 1 mux 3 component instantiation ---

eight_to_one_mux_inst_3 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => fault_times_data(24), 
          data_one_i    => fault_times_data(25), 
          data_two_i    => fault_times_data(26), 
          data_three_i  => fault_times_data(27), 
          data_four_i   => fault_times_data(28), 
          data_five_i   => fault_times_data(29), 
          data_six_i    => fault_types_mux_data(30), 
          data_seven_i  => fault_types_mux_data(31), 
          sel_i         => uBlaze_addr_lines(2 downto 0), 
          data_o        => mux_three_out 
       );
       
-------------------------------------------------------------------------------
--- 8 to 1 mux 4 component instantiation ---

eight_to_one_mux_inst_4 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => fault_types_mux_data(32), 
          data_one_i    => fault_types_mux_data(33), 
          data_two_i    => fault_types_mux_data(34), 
          data_three_i  => fault_types_mux_data(35), 
          data_four_i   => fault_types_mux_data(36), 
          data_five_i   => fault_types_mux_data(37), 
          data_six_i    => fault_types_mux_data(38), 
          data_seven_i  => fault_types_mux_data(39), 
          sel_i         => uBlaze_addr_lines(2 downto 0), 
          data_o        => mux_four_out 
       );
       
-------------------------------------------------------------------------------
--- 8 to 1 mux 5 component instantiation ---

eight_to_one_mux_inst_5 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => fault_types_mux_data(40), 
          data_one_i    => fault_types_mux_data(41), 
          data_two_i    => fault_types_mux_data(42), 
          data_three_i  => fault_types_mux_data(43), 
          data_four_i   => fault_types_mux_data(44), 
          data_five_i   => fault_types_mux_data(45), 
          data_six_i    => fault_types_mux_data(46), 
          data_seven_i  => fault_types_mux_data(47), 
          sel_i         => uBlaze_addr_lines(2 downto 0), 
          data_o        => mux_five_out 
       );          

-------------------------------------------------------------------------------
--- 8 to 1 mux 6 component instantiation ---

eight_to_one_mux_inst_6 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => fault_types_mux_data(48), 
          data_one_i    => fault_types_mux_data(49), 
          data_two_i    => fault_types_mux_data(50), 
          data_three_i  => fault_types_mux_data(51), 
          data_four_i   => fault_types_mux_data(52), 
          data_five_i   => fault_types_mux_data(53), 
          data_six_i    => fault_types_mux_data(54), 
          data_seven_i  => fault_types_mux_data(55), 
          sel_i         => uBlaze_addr_lines(2 downto 0), 
          data_o        => mux_six_out 
       ); 
       
-------------------------------------------------------------------------------
--- 8 to 1 mux 7 component instantiation ---

eight_to_one_mux_inst_7 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => fault_types_mux_data(56), 
          data_one_i    => fault_types_mux_data(57), 
          data_two_i    => fault_types_mux_data(58), 
          data_three_i  => fault_types_mux_data(59), 
          data_four_i   => stuck_at_hold_time_reg_data, 
          data_five_i   => spare_reg_mux, 
          data_six_i    => fault_injection_en_reg_mux, 
          data_seven_i  => application_run_time_reg_data, 
          sel_i         => uBlaze_addr_lines(2 downto 0), 
          data_o        => mux_seven_out 
       );    

-------------------------------------------------------------------------------
--- 8 to 1 mux 8 component instantiation ---

eight_to_one_mux_inst_8 : eight_to_one_mux_setup_regs 
Port map (data_zero_i   => mux_zero_out, 
          data_one_i    => mux_one_out, 
          data_two_i    => mux_two_out, 
          data_three_i  => mux_three_out, 
          data_four_i   => mux_four_out, 
          data_five_i   => mux_five_out, 
          data_six_i    => mux_six_out, 
          data_seven_i  => mux_seven_out, 
          sel_i         => uBlaze_addr_lines(5 downto 3), 
          data_o        => read_mux_out 
       );   
             
-------------------------------------------------------------------------------     
                              
end Behavioral;
