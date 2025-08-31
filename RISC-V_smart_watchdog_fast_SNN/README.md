# Smart Watchdog Vivado ILA Overview 🔍 

This repository contains the source code and implemtation files for a Vivado project with a ILA debug core synthesized, also submitted to the AMD Open Hardware Design Competition 2025. The smart watchdog operation when monitoring the RISC-V processor can be observed in detail by looking at the waveforms.

It features:
- A compressed design bitstream generated from Vivado.
- A debug probe file generated from Vivado.

### Short Decription

- The FPGA can be easily programmed using the Vivado design files through the hardware manager.
- The feature extraction process can be seen along with the SNN spiking activity.
- Smart watchdog class decisions can be observed after each instruction of a Fibonacci Series C application.
- Running hardware performance counters track the number of monitored instructions.

---

## Demonstrator Contents 📦

- Vivado
     - ***riscv_watchdog_fast_design_2_compressed.bit*** : Compressed bitstream generated from Vivado.
     - ***debug_nets.ltx*** : Debug probe netlist generated from Vivado.
     - ***constraints_file.xdc*** : AMD VC709 (Virtex-7) board contraints (not required for build)
     - ***HDL/*** : Contains all VHDL source code of the Vivado project (not required for build).
     - ***setup_text_files/*** : Text files of SNN parameters used during Vivado synthesis (not required for build).

- neorv32-main
     - ***rtl/*** : Contains all VHDL source code for the RISC-V CPU - Neorv32 (not required for build).
     - ***sim/*** : Contains all simulation resources for the RISC-V CPU - Neorv32 (not required for build).
     - ***sw/*** : Contains software framework for the RISC-V CPU - Neorv32 (not required for build).

**Note:** The Fibonacci Series C and disassembled source code can be found: `neorv32-main/sw/examples/my_code_fibonacci_series`

---

## Demonstrator Dependencies 📝

- Vivafo: **2023.1 was used to generate bitstream**
- FPGA platform: **AMD VC709 (Virtex-7)**

⚠️ **Note:** This design is hardware-dependent and will only run on the AMD VC709 FPGA board.

---

 ## Build Steps to Run the Vivado bitstream 🔨

Steps must be performed in order.

**Step 1** - Download the repo zip file (if not already done so) and unzip.

**Step 2** - Open Vivado and then open the hardware manager.

**Step 3** - Power up the AMD VC709 FPGA board and plug in the JTAG USB cable to board and PC.

**Step 4** - Click *Open target* and *auto-connect* to the FPGA.

**Step 5** - Click *Program Device*:





---

 ## 2. FPGA Build (Vitis IDE) 🖥️

**Step 1** - Open Vitis IDE, create a clean workpace and start a new application project.

**Step 2** - Select the tab **"create a new platform from hardware (XSA)"**. Browse for the **"design_1_wrapper.xsa"**, found in:

`/AMD-AOHW25_620/Demonstrator/hw/vivado/design_1_wrapper.xsa`.

**Step 3** - **Name the application project** demo (or anything), **click Next>** and **click Next>** again to skip domain.

**Step 4** - In template, select **Empty C Application (C)** and **Click Finish>**.

**Step 5** - **Right-click the `/src` folder** → **Import Sources**. Browse and select the `MicroBlaze` folder found in: 

`/AMD-AOHW25_620/Demonstrator/sw/MicroBlaze`, and check the boxes to include the 4 source files:

`main.c`
`platform.c`
`platform.h`
`platform_config.h`

**Step 6** - Build the project.

**Step 7** - Set up a **single debug application** as the run configuration, and **Click Run>**.

---

✅ Once the FPGA is programmed, the Python GUI will initialize, completing the demonstrator build.


