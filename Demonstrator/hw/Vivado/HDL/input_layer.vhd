
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.SNN_package.all;

entity input_layer is
Generic (g_num_inputs : natural;    --number of inputs in layer
         g_num_timesteps : natural  --number of timesteps to stimulate network
        );
Port (clk_i    : in std_logic;
      rstn_i   : in std_logic;
      data_sample_i : in std_logic_vector(g_num_inputs-1 downto 0);
      timestep_counter_i : in unsigned(f_log2(g_num_timesteps)-1 downto 0);
      spikes_o : out std_logic_vector(g_num_inputs-1 downto 0)
     );
end input_layer;

architecture Behavioral of input_layer is

type spike_data_type is array (0 to g_num_inputs-1) of std_logic_vector(g_num_timesteps-1 downto 0);

signal spiketrain_regs : spike_data_type;
signal freq_mux : spike_data_type;

signal freq_low : std_logic_vector(g_num_timesteps-1 downto 0);
signal freq_high : std_logic_vector(g_num_timesteps-1 downto 0);

signal spikes_out_reg : std_logic_vector(g_num_inputs-1 downto 0);

begin

--- spiketrain frequency low & high definitions ---------------------------------------------------------------
freq_low  <= "0000100001";
freq_high <= "1101110111";
---------------------------------------------------------------------------------------------------------------

--- input spiketrain frequency encoder muxes ------------------------------------------------------------------
f_mux : for i in 0 to g_num_inputs-1 generate
    mux : two_to_one_mux 
    generic map (g_mux_width => g_num_timesteps)
    port map (freq_low_i   => freq_low,
              freq_high_i  => freq_high,
              sel_i  => data_sample_i(i),
              freq_o => freq_mux(i));
end generate;
---------------------------------------------------------------------------------------------------------------

--- encoded input spiketrain registers ------------------------------------------------------------------------
Process(clk_i, rstn_i)

begin

for i in 0 to g_num_inputs-1 loop
    if (rstn_i = '0') then
        spiketrain_regs <= (others => (others => '0'));
    elsif (rising_edge(clk_i)) then
        spiketrain_regs(i) <= freq_mux(i);
    end if;

end loop;

end Process;
---------------------------------------------------------------------------------------------------------------

--- spike output muxes ----------------------------------------------------------------------------------------
Process(clk_i, rstn_i)

begin

for i in 0 to g_num_inputs-1 loop
    if (rstn_i = '0') then
        spikes_out_reg <= (others => '0');
    elsif (rising_edge(clk_i)) then
        spikes_out_reg(i) <= spiketrain_regs(i)(to_integer(unsigned(timestep_counter_i)));
    end if;

end loop;

end Process;

spikes_o <= spikes_out_reg;
---------------------------------------------------------------------------------------------------------------

end Behavioral;
