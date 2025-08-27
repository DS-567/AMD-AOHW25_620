-- ================================================================================ --
-- NEORV32 - Minimal setup without a bootloader                                     --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2024 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;

entity neorv32_ProcessorTop_Minimal is
  generic (
    -- Fault Injection Setup Modifications --
    NUM_RESULT_DATA_VALUES : natural := 25; -- Number of result data values to be produced by Neorv32 that are captured to result data mem
    -- General --
    CLOCK_FREQUENCY   : natural := 100_000_000;       -- clock frequency of clk_i in Hz
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN   : boolean := true;    -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE : natural := 16*1024; -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN   : boolean := true;    -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE : natural := 16*1024; -- size of processor-internal data memory in bytes
    REGFILE_HW_RST    : boolean := true;
    IO_GPTMR_EN       : boolean := true;
    IO_PWM_NUM_CH     : natural := 1;
    IO_GPIO_NUM       : natural := 64;
    XIRQ_NUM_CH       : natural := 1; -- number of external IRQ channels (0..32)
    XIRQ_TRIGGER_TYPE     : std_ulogic_vector(31 downto 0) := x"00000001"; -- trigger type: 0=level, 1=edge
    XIRQ_TRIGGER_POLARITY : std_ulogic_vector(31 downto 0) := x"00000001"  -- trigger polarity: 0=low-level/falling-edge, 1=high-level/rising-edge  
    -- Processor peripherals --
  );
  port (
    -- Global control --
    clk_i  : in  std_logic;
    rstn_i : in  std_logic; 
    
    FIL_four_to_one_mux_selects_i : in std_logic_vector(20 downto 1);
    program_counter_o     : out std_ulogic_vector(31 downto 0);
    
    dmem_transfer_trigger_i  : in std_logic;
    dmem_reset_trigger_i     : in std_logic;
    result_data_wr_address_o : out std_ulogic_vector(5 downto 0);
    dmem_to_result_data_o    : out std_ulogic_vector(31 downto 0);
    result_data_mem_wr_pulse_o : out std_logic;
    dmem_transfer_done_o     : out std_logic;
    dmem_reset_done_o : out std_logic;
    neorv32_pc_we_o   : out std_logic;
    instruction_register_o : out std_ulogic_vector(31 downto 0);
    neorv32_execute_states_o : out std_logic_vector(3 downto 0);
    neorv32_branch_taken_o : out std_logic;
    mcause_reg_o     : out std_ulogic_vector(5 downto 0);
    mepc_reg_o       : out std_ulogic_vector(31 downto 0);
    mtvec_reg_o      : out std_ulogic_vector(31 downto 0);
    rs1_reg_o        : out std_ulogic_vector(31 downto 0);
    alu_comp_status_o : out std_ulogic_vector(1 downto 0);
    ctrl_bus_o        : out std_ulogic_vector(60 downto 0);
    gpio_i            : in  std_ulogic_vector(63 downto 0) := (others => 'L'); -- parallel input
    gpio_o            : out std_ulogic_vector(63 downto 0);                    -- parallel output
    pwm_o             : out std_ulogic_vector(11 downto 0);  -- pwm channels
    xirq_i            : in  std_ulogic_vector(31 downto 0) -- IRQ channels
  );
end entity;

architecture neorv32_ProcessorTop_Minimal_rtl of neorv32_ProcessorTop_Minimal is

begin

  -- The core of the problem ----------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  neorv32_inst: entity neorv32.neorv32_top
  generic map (
    -- Fault Injection Setup Modifications --
    NUM_RESULT_DATA_VALUES => NUM_RESULT_DATA_VALUES,
    -- General --
    CLOCK_FREQUENCY              => CLOCK_FREQUENCY,   -- clock frequency of clk_i in Hz
    INT_BOOTLOADER_EN            => false,             -- boot configuration: true = boot explicit bootloader; false = boot from int/ext (I)MEM
    -- Internal Instruction memory --
    MEM_INT_IMEM_EN              => MEM_INT_IMEM_EN,   -- implement processor-internal instruction memory
    MEM_INT_IMEM_SIZE            => MEM_INT_IMEM_SIZE, -- size of processor-internal instruction memory in bytes
    -- Internal Data memory --
    MEM_INT_DMEM_EN              => MEM_INT_DMEM_EN,   -- implement processor-internal data memory
    MEM_INT_DMEM_SIZE            => MEM_INT_DMEM_SIZE, -- size of processor-internal data memory in bytes
    -- Processor peripherals --
    IO_MTIME_EN                  => true,              -- implement machine system timer (MTIME)?
    REGFILE_HW_RST               => REGFILE_HW_RST,
    IO_GPIO_NUM                  => IO_GPIO_NUM,
    IO_PWM_NUM_CH                => IO_PWM_NUM_CH,
    IO_GPTMR_EN                  => IO_GPTMR_EN,
    XIRQ_NUM_CH                  => XIRQ_NUM_CH,
    XIRQ_TRIGGER_TYPE            => XIRQ_TRIGGER_TYPE,
    XIRQ_TRIGGER_POLARITY        => XIRQ_TRIGGER_POLARITY
  )
  port map (
    -- Global control --
    clk_i  => clk_i,    -- global clock, rising edge
    rstn_i => rstn_i,   -- global reset, low-active, async
    FIL_four_to_one_mux_selects_i => FIL_four_to_one_mux_selects_i,
    program_counter_o       => program_counter_o,
    dmem_transfer_trigger_i => dmem_transfer_trigger_i,
    dmem_reset_trigger_i    => dmem_reset_trigger_i,
    result_data_wr_address_o => result_data_wr_address_o,
    dmem_to_result_data_o    => dmem_to_result_data_o,
    result_data_mem_wr_pulse_o  => result_data_mem_wr_pulse_o,
    dmem_transfer_done_o  => dmem_transfer_done_o,
    dmem_reset_done_o     => dmem_reset_done_o,
    neorv32_pc_we_o       => neorv32_pc_we_o,
    instruction_register_o => instruction_register_o,
    neorv32_execute_states_o => neorv32_execute_states_o,
    neorv32_branch_taken_o   => neorv32_branch_taken_o,
    mcause_reg_o => mcause_reg_o,
    mepc_reg_o   => mepc_reg_o,
    rs1_reg_o    => rs1_reg_o,
    alu_comp_status_o => alu_comp_status_o,
    ctrl_bus_o   => ctrl_bus_o,
    mtvec_reg_o  => mtvec_reg_o,
    gpio_i       => gpio_i,
    gpio_o       => gpio_o,
    pwm_o        => pwm_o,
    xirq_i       => xirq_i
  );

end architecture;
