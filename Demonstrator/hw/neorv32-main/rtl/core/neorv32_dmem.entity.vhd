-- ================================================================================ --
-- NEORV32 SoC - Processor-Internal Data Memory (DMEM) - Entity-Only                --
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
use neorv32.neorv32_package.all;

entity neorv32_dmem is
  generic (
    -- Fault Injection Setup Modifications --
    NUM_RESULT_DATA_VALUES : natural; -- Number of result data values to be produced by Neorv32 that are captured to result data mem
    DMEM_SIZE : natural -- processor-internal instruction memory size in bytes, has to be a power of 2
  );
  port (
    clk_i     : in  std_ulogic; -- global clock line
    rstn_i    : in  std_ulogic; -- async reset, low-active
    bus_req_i : in  bus_req_t;  -- bus request
    bus_rsp_o : out bus_rsp_t;  -- bus response
    
    dmem_transfer_trigger_i  : in std_logic;
    dmem_reset_trigger_i     : in std_logic;
    result_data_wr_address_o : out std_ulogic_vector(5 downto 0);
    dmem_to_result_data_o    : out std_ulogic_vector(31 downto 0);
    result_data_mem_wr_pulse_o : out std_logic;
    dmem_transfer_done_o       : out std_logic;
    dmem_reset_done_o : out std_logic
  );
end neorv32_dmem;
