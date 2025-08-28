# Data Collection Overview 🔍

This repository contains the source code for the collection framework developed during the PhD project to collect RISC-V instruction data train the SNN of the smart watchdog, which is also submitted to the [AMD Open Hardware Design Competition 2025].

It features:
- Design bitstream generated from Vivado.
- FPGA backend built using Vitis, running on an AMD VC709 evaluation board (Virtex-7 FPGA).
- Stream RISC-V instruction data to a serial terminal over UART.

---

## Data Collection Contents 📦

- MicroBlaze
     - ***main.c*** : Main C code that runs on the MicroBlaze
     - ***platform.c***  : Platform-specific functions
     - ***platform.h***  : Platform-specific header file
     - ***platform_config.h*** : Platform config header file

- ***design_1_wrapper.xsa*** : Generated bitstream from Vivado for use in Vitis

- ***constraints_file.xdc*** : AMD VC709 board contraints (not required for build)

- ***HDL***: Contains all VHDL source code for the data collection FPGA design (not required for build)

- neorv32-main
     - ***rtl/*** : Contains all VHDL source code for the RISC-V CPU - Neorv32 (not required for build)
     - ***sim/*** : Contains all simulation resources for the RISC-V CPU - Neorv32 (not required for build)
     - ***sw/*** : Contains software framework for the RISC-V CPU - Neorv32 (not required for build)

**Note:** The heap sort C source code can be found: `neorv32-main/sw/examples/my_code_heap_sort`

---

## Demonstrator Dependencies 📝

- Vitis: **2023.1**
- FPGA platform: **AMD VC709**
- A serial terminal: E.g. **CoolTerm** (or equivalent)

⚠️ **Note:** This design is hardware-dependent and can only be ran on the AMD VC709 board!  

---

 ## Build Steps to Run the Demonstrator 🔨

These stages for building the data collection design must be performed in the following order:

 ## 1. Serial Terminal Setup 📺

**Step 1** - Power up the VC709 FOGA board and plug both Micro-USB port (JTAG) and Mini USB (UART) into the board and two USB ports on a PC.
com port driver check?
**Step 2** - Open a serial terminal. This design has been veriried and used successfuly with CoolTerm (but others equivalent terminals should work). Setup the serial port to the following: 

- Baud rate: ***230,400***
- data bits: ***8***
- Parity bits: ***None***
- Stop bits: ***1***
- DTR: ***On***
- RTS: ***On***

 Ensure the following terminal settings:

 - Terminal mode: ***Raw mode***

  Ensure the following file capture settings:

 - Capture format: ***Plain Text***
 
**Step 3** - Finally make the serial connection (connect).  

---

 ## 2. FPGA Build (Vitis IDE) 🖥️

**Step 1** - Open Vitis IDE, create a clean workpace and start a new application project.

**Step 2** - Select the tab **"create a new platform from hardware (XSA)"**. Browse for the **"design_1_wrapper.xsa"**, found in:

`/AMD-AOHW25_620/Data_Collection/design_1_wrapper.xsa`.

**Step 3** - **Name the application project** data_collection (or anything), **click Next>** and **click Next>** again to skip domain.

**Step 4** - In template, select **Empty C Application (C)** and **Click Finish>**.

**Step 5** - **Right-click the `/src` folder** → **Import Sources**. Browse and select the `MicroBlaze` folder found in: 

`/AMD-AOHW25_620/Data_Collection/MicroBlaze`, and check the boxes to include the 4 source files:

`main.c`
`platform.c`
`platform.h`
`platform_config.h`

**Step 6** - Build the project.

**Step 7** - Set up a **single debug application** as the run configuration, and **Click Run>**.

✅ Once the FPGA is programmed, the following information should be printed on the terminal, completing the demonstrator build.

<p align="center">
  <img src="../assets/data_collection_startup_print.PNG" alt="Data Collection Startup Print" width="300"/>
</p>

---

 ## 1. To Collect Data 🗂️

 

