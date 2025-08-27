-- #################################################################################################
-- # << NEORV32 - Processor-internal data memory (DMEM) >>                                         #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2023, Stephan Nolting. All rights reserved.                                     #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 Processor - https://github.com/stnolting/neorv32              (c) Stephan Nolting #
-- #################################################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

architecture neorv32_dmem_rtl of neorv32_dmem is

signal result_data_transfer_threshold : std_ulogic_vector(11 downto 0);

-- local signals --
signal dmem_rdata : std_ulogic_vector(31 downto 0);
signal rden  : std_ulogic;
signal addr  : std_ulogic_vector(index_size_f(DMEM_SIZE/4)-1 downto 0);

-- The memory (RAM) is built from 4 individual byte-wide memories because some synthesis
-- tools have issues inferring 32-bit memories that provide dedicated byte-enable signals
-- and/or with multi-dimensional arrays. [NOTE] Read-during-write behavior is irrelevant
-- as read and write accesses are mutually exclusive.
signal mem_ram_b0, mem_ram_b1, mem_ram_b2, mem_ram_b3 : mem8_t(0 to DMEM_SIZE/4-1);

 -- RISNG EDGE PULSE GENERATOR SIGNALS --
signal dmem_Q0_out, dmem_Q1_out : std_logic;
signal dmem_transfer_trigger_pulse : std_logic;

signal dmem_Q2_out, dmem_Q3_out : std_logic;
signal dmem_reset_trigger_pulse : std_logic;

 -- TRIGGER FLIP FLOP SIGNALS --
signal dmem_transfer_trigger_ff : std_logic;
signal dmem_transfer_trigger_ff_rst : std_logic;

signal dmem_reset_trigger_ff : std_logic;
signal dmem_reset_trigger_ff_rst : std_logic;

 -- COUNTER SIGNALS --
signal dmem_addr_counter  : std_ulogic_vector(index_size_f(DMEM_SIZE/4)-1 downto 0); -- "index_size_f" function should make this 12-bits like addr (4096)
signal dmem_counter_en    : std_logic;
signal dmem_counter_rst   : std_logic;

 -- STATE MACHINE SIGNALS --
type State_type is (dmem_fsm_S_idle, dmem_fsm_S_data_read_delay, dmem_fsm_S_data_wr_pulse, dmem_fsm_S_data_transfer_counter_inc, dmem_fsm_S_write_zero, 
                    dmem_fsm_S_one_cycle_delay, dmem_fsm_S_check_zero, dmem_fsm_S_reset_dmem_counter_inc, dmem_fsm_S_rst_data_transfer_ff, 
                    dmem_fsm_S_rst_dmem_reset_ff, dmem_fsm_S_rst_counter, dmem_fsm_S_transfer_done, dmem_fsm_S_dmem_reset_done);

signal dmem_fsm_Current_State , dmem_fsm_Next_State : State_type;

 -- MULTIPLEXOR SIGNALS --
signal dmem_mux_sel   : std_logic;
signal dmem_mux_out_b0_en : std_logic;
signal dmem_mux_out_b1_en : std_logic;
signal dmem_mux_out_b2_en : std_logic;
signal dmem_mux_out_b3_en : std_logic;

signal dmem_mux_addr_out : std_ulogic_vector(index_size_f(DMEM_SIZE/4)-1 downto 0);
signal dmem_mux_data_out : std_ulogic_vector(31 downto 0);

 -- MEMORY ACCESS MODIFICATION SIGNALS --
signal dmem_reset_wr_en : std_logic;

 -- RDATA CHECK FOR ZERO SIGNALS --
signal dmem_rdata_compare_en : std_logic;
signal dmem_rdata_is_zero : std_logic;

begin

result_data_transfer_threshold <= std_ulogic_vector(to_unsigned(NUM_RESULT_DATA_VALUES-1, result_data_transfer_threshold'length));

------------------------------------------------------------------------------------------------------------------------------------------------
--- pulse generator for triggering the DMEM result data transfer ---

trigger_DMEM_transfer_pulse_generator : Process (clk_i, rstn_i, dmem_transfer_trigger_i)

begin

if (rstn_i = '1') then  
    dmem_Q0_out <= '0';
    dmem_Q1_out <= '0';
    
elsif (rising_edge(clk_i)) then
    dmem_Q0_out <= dmem_transfer_trigger_i;
    dmem_Q1_out <= dmem_Q0_out;

end if;

end Process;

dmem_transfer_trigger_pulse <= dmem_Q0_out and (not dmem_Q1_out);

--------------------------------------------------------------------------------------------------------------------------------------------------
----- flip flop for triggering the data transfer to result data RAM ---

Process (clk_i, rstn_i, dmem_transfer_trigger_pulse, dmem_transfer_trigger_ff, dmem_transfer_trigger_ff_rst)

begin

if (rstn_i = '1' or dmem_transfer_trigger_ff_rst = '1') then
    dmem_transfer_trigger_ff <= '0';

elsif (rising_edge(clk_i)) then
    dmem_transfer_trigger_ff <= dmem_transfer_trigger_pulse or dmem_transfer_trigger_ff;

end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- pulse generator for triggering the DMEM reset ---

trigger_DMEM_reset_pulse_generator : Process (clk_i, rstn_i, dmem_reset_trigger_i)

begin

if (rstn_i = '1') then  
    dmem_Q2_out <= '0';
    dmem_Q3_out <= '0';
    
elsif (rising_edge(clk_i)) then
    dmem_Q2_out <= dmem_reset_trigger_i;
    dmem_Q3_out <= dmem_Q2_out;

end if;

end Process;

dmem_reset_trigger_pulse <= dmem_Q2_out and (not dmem_Q3_out);

--------------------------------------------------------------------------------------------------------------------------------------------------
----- flip flop for triggering the dmem reset ---

Process (clk_i, rstn_i, dmem_reset_trigger_pulse, dmem_reset_trigger_ff_rst, dmem_reset_trigger_ff)

begin

if (rstn_i = '1' or dmem_reset_trigger_ff_rst = '1') then
    dmem_reset_trigger_ff <= '0';

elsif (rising_edge(clk_i)) then
    dmem_reset_trigger_ff <= dmem_reset_trigger_pulse or dmem_reset_trigger_ff;

end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- counter for generating RAM addresses ---

addr_counter_logic : Process (clk_i, rstn_i)

begin

if (rstn_i = '1') then
    dmem_addr_counter <= (others => '0');

elsif (rising_edge(clk_i)) then
    
    if (dmem_counter_rst = '1') then
        dmem_addr_counter <= (others => '0');
        
    elsif (dmem_counter_en = '1') then
        dmem_addr_counter <= std_ulogic_vector(unsigned(dmem_addr_counter) + 1);
    
    end if;
end if;

end Process;

result_data_wr_address_o <= dmem_addr_counter(5 downto 0);

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm state logic ---

fsm_state : Process (clk_i, rstn_i)

begin

if (rstn_i = '1') then
    dmem_fsm_Current_State <= dmem_fsm_S_idle;

elsif (rising_edge(clk_i)) then
    dmem_fsm_Current_State <= dmem_fsm_Next_State;

end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm next state logic ---

fsm_next_state_logic : Process (rstn_i, dmem_fsm_Current_State, dmem_transfer_trigger_ff, dmem_reset_trigger_ff, dmem_addr_counter, dmem_rdata_is_zero,
                                result_data_transfer_threshold)

begin

case dmem_fsm_Current_State is

    when dmem_fsm_S_idle =>
        if (rstn_i = '0' and dmem_transfer_trigger_ff = '1' and dmem_reset_trigger_ff = '0') then
            dmem_fsm_Next_State <= dmem_fsm_S_data_read_delay;
            
        elsif (rstn_i = '0' and dmem_reset_trigger_ff = '1' and dmem_transfer_trigger_ff = '0') then
            dmem_fsm_Next_State <= dmem_fsm_S_write_zero;
            
        else
            dmem_fsm_Next_State <= dmem_fsm_S_idle;
        end if;

     when dmem_fsm_S_data_read_delay =>
        dmem_fsm_Next_State <= dmem_fsm_S_data_wr_pulse;
          
     when dmem_fsm_S_data_wr_pulse =>
        dmem_fsm_Next_State <= dmem_fsm_S_data_transfer_counter_inc;
                               
     when dmem_fsm_S_data_transfer_counter_inc =>
        if ((dmem_addr_counter = result_data_transfer_threshold) and dmem_transfer_trigger_ff = '1') then     
            dmem_fsm_Next_State <= dmem_fsm_S_rst_data_transfer_ff;
        else
            dmem_fsm_Next_State <= dmem_fsm_S_data_read_delay;
        end if;         
                
    when dmem_fsm_S_rst_data_transfer_ff =>
        dmem_fsm_Next_State <= dmem_fsm_S_transfer_done;    

    when dmem_fsm_S_transfer_done =>
        dmem_fsm_Next_State <= dmem_fsm_S_rst_counter;
        
    when dmem_fsm_S_rst_counter =>
        dmem_fsm_Next_State <= dmem_fsm_S_idle;
    
    when dmem_fsm_S_write_zero =>              
        dmem_fsm_Next_State <= dmem_fsm_S_one_cycle_delay;
        
    when dmem_fsm_S_one_cycle_delay =>              
        dmem_fsm_Next_State <= dmem_fsm_S_check_zero;
    
    when dmem_fsm_S_check_zero =>
        if (dmem_rdata_is_zero = '1') then   
            dmem_fsm_Next_State <= dmem_fsm_S_reset_dmem_counter_inc;
        else
            dmem_fsm_Next_State <= dmem_fsm_S_write_zero;
        end if;
    
    when dmem_fsm_S_reset_dmem_counter_inc =>
        if (dmem_addr_counter = "111111111111" and dmem_reset_trigger_ff = '1') then --"111111111111" = 4095 (size of DMEM : 4,096 * 4 = 16,384)
            dmem_fsm_Next_State <= dmem_fsm_S_rst_dmem_reset_ff;
        else
            dmem_fsm_Next_State <= dmem_fsm_S_write_zero;
         end if; 

    when dmem_fsm_S_rst_dmem_reset_ff =>
        dmem_fsm_Next_State <= dmem_fsm_S_dmem_reset_done; 
        
    when dmem_fsm_S_dmem_reset_done =>
        dmem_fsm_Next_State <= dmem_fsm_S_rst_counter; 
   
end case;
        
end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- fsm output decoding logic ---

fsm_outputs : Process (dmem_fsm_Current_State)

begin

case dmem_fsm_Current_State is

    when dmem_fsm_S_idle =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '0';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';
        
    when dmem_fsm_S_data_read_delay =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '1';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';

    when dmem_fsm_S_data_wr_pulse =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '1';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '1';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';

    when dmem_fsm_S_data_transfer_counter_inc =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '1';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '1';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';
        
    when dmem_fsm_S_write_zero =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '1';
        dmem_rdata_compare_en <= '1';
        dmem_reset_wr_en      <= '1';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';
                  
    when dmem_fsm_S_one_cycle_delay =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '1';
        dmem_rdata_compare_en <= '1';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';
    
    when dmem_fsm_S_check_zero =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '1';
        dmem_rdata_compare_en <= '1';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';
    
    when dmem_fsm_S_reset_dmem_counter_inc =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '1';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '1';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';
    
    when dmem_fsm_S_rst_data_transfer_ff =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '0';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '1';
        dmem_reset_trigger_ff_rst    <= '0';
        
    when dmem_fsm_S_rst_dmem_reset_ff =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '0';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '1';
        
    when dmem_fsm_S_rst_counter =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '1';
        dmem_mux_sel          <= '0';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';

    when dmem_fsm_S_transfer_done =>
        dmem_transfer_done_o  <= '1';
        dmem_reset_done_o     <= '0';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';
        dmem_mux_sel          <= '0';  
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0';      
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';

    when dmem_fsm_S_dmem_reset_done =>
        dmem_transfer_done_o  <= '0';
        dmem_reset_done_o     <= '1';
        dmem_counter_en       <= '0';
        dmem_counter_rst      <= '0';  
        dmem_mux_sel          <= '0';
        dmem_rdata_compare_en <= '0';
        dmem_reset_wr_en      <= '0';
        result_data_mem_wr_pulse_o   <= '0'; 
        dmem_transfer_trigger_ff_rst <= '0';
        dmem_reset_trigger_ff_rst    <= '0';
            
end case;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- logic to compare BRAM data out (rdata) with zero ---

rdata_zero_check : Process(dmem_rdata_compare_en, dmem_rdata)

begin

if (dmem_rdata_compare_en = '1') then
    if (dmem_rdata = x"00000000") then	
        dmem_rdata_is_zero <= '1';
    else
        dmem_rdata_is_zero <= '0';
    end if;
else
    dmem_rdata_is_zero <= '0';
    
end if;

end Process;

------------------------------------------------------------------------------------------------------------------------------------------------
--- DMEM reset to zero address/data/byte enable multiplexors ---

dmem_mux_addr_out <= addr when (dmem_mux_sel = '0') else dmem_addr_counter;

dmem_mux_data_out <= bus_req_i.data when (dmem_mux_sel = '0') else x"00000000";

dmem_mux_out_b0_en <= bus_req_i.ben(0) when (dmem_mux_sel = '0') else '1';
dmem_mux_out_b1_en <= bus_req_i.ben(1) when (dmem_mux_sel = '0') else '1';
dmem_mux_out_b2_en <= bus_req_i.ben(2) when (dmem_mux_sel = '0') else '1';
dmem_mux_out_b3_en <= bus_req_i.ben(3) when (dmem_mux_sel = '0') else '1';

------------------------------------------------------------------------------------------------------------------------------------------------
--- Memory Access (Modified) ---
  
mem_access: process(clk_i)
begin
  if rising_edge(clk_i) then -- no reset to infer block RAM
    if ( (bus_req_i.stb = '1' and bus_req_i.rw = '1') or (dmem_reset_wr_en = '1') ) then    
      if (dmem_mux_out_b0_en = '1') then -- byte 0
        mem_ram_b0(to_integer(unsigned(dmem_mux_addr_out))) <= dmem_mux_data_out(07 downto 00);
      end if;
      if (dmem_mux_out_b1_en = '1') then -- byte 1
        mem_ram_b1(to_integer(unsigned(dmem_mux_addr_out))) <= dmem_mux_data_out(15 downto 08);
      end if;
      if (dmem_mux_out_b2_en = '1') then -- byte 2
        mem_ram_b2(to_integer(unsigned(dmem_mux_addr_out))) <= dmem_mux_data_out(23 downto 16);
      end if;
      if (dmem_mux_out_b3_en = '1') then -- byte 3
        mem_ram_b3(to_integer(unsigned(dmem_mux_addr_out))) <= dmem_mux_data_out(31 downto 24);
      end if;
    end if;
    dmem_rdata(07 downto 00) <= mem_ram_b0(to_integer(unsigned(dmem_mux_addr_out)));
    dmem_rdata(15 downto 08) <= mem_ram_b1(to_integer(unsigned(dmem_mux_addr_out)));
    dmem_rdata(23 downto 16) <= mem_ram_b2(to_integer(unsigned(dmem_mux_addr_out)));
    dmem_rdata(31 downto 24) <= mem_ram_b3(to_integer(unsigned(dmem_mux_addr_out)));
  
  end if;
end process mem_access;

-- word aligned access --
addr <= bus_req_i.addr(index_size_f(DMEM_SIZE/4)+1 downto 2);

dmem_to_result_data_o <= dmem_rdata;

------------------------------------------------------------------------------------------------------------------------------------------------
--- Bus Feedback ---  

bus_feedback: process(rstn_i, clk_i)
begin
  if (rstn_i = '0') then
    rden          <= '0';
    bus_rsp_o.ack <= '0';
  elsif rising_edge(clk_i) then
    rden          <= bus_req_i.stb and (not bus_req_i.rw);
    bus_rsp_o.ack <= bus_req_i.stb;
  end if;
end process bus_feedback;

bus_rsp_o.data <= dmem_rdata when (rden = '1') else (others => '0'); -- output gate
bus_rsp_o.err  <= '0'; -- no access error possible

------------------------------------------------------------------------------------------------------------------------------------------------

end neorv32_dmem_rtl;
