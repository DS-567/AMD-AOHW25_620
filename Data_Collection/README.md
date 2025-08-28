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

Firstly download the repo ZIP file (if not already done so).

 ## 1. Serial Terminal Setup 📺

**Step 1** - Power up the VC709 FOGA board and plug both Micro-USB port (JTAG) and Mini USB (UART) into the board and two USB ports on a PC.

com port driver check?
**Step 2** - Open the Windows device manager and check if drivers for the virtual COM port need to be installed.

⚠️ **Note:** If the drivers are out of date, the drivers can be found here https://www.silabs.com/software-and-tools/usb-to-uart-bridge-vcp-drivers?tab=downloads. Simply download the drivers and search manually for the drivers in your downloads folder.

Once the COM port appears as shown in the image below, move to step 3.

ADD IMAGE OF COM PORT

**Step 3** - Open a serial terminal. This design has been used successfuly with CoolTerm (however other equivalent terminals should work). Setup the serial port to the following: 

- Baud rate: ***230,400***
- data bits: ***8***
- Parity bits: ***None***
- Stop bits: ***1***
- DTR: ***On***
- RTS: ***On***

  Also ensure the following file capture settings:

 - Capture format: ***Plain Text***
 
**Step 4** - Finally make the serial connection (connect).  

---

 ## 2. FPGA Build (Vitis IDE) 🖥️

**Step 1** - Open Vitis IDE, create a clean workpace and start a new application project. Skip the welcome page by pressing ***Next>***.

**Step 2** - Select the tab **"create a new platform from hardware (XSA)"**. Browse for the **"design_1_wrapper.xsa"**, found in:

`/AMD-AOHW25_620/Data_Collection/design_1_wrapper.xsa`.

**Step 3** - **Name the application project** data_collection (or anything), ***click Next>*** and ***click Next>*** again to skip domain.

**Step 4** - In template, select ***Empty Application (C)*** and ***Click Finish>***.

**Step 5** - ***Right-click the `/src` folder*** → ***Import Sources***. Browse and select the `MicroBlaze` folder found in: 

`/AMD-AOHW25_620/Data_Collection/MicroBlaze`, and check the boxes to include all 4 source files:

`main.c`
`platform.c`
`platform.h`
`platform_config.h`

and **Click Finish**.

**Step 6** - Build the project.

**Step 7** - Set up a ***single debug application*** as the run configuration using the run dropdown icon, and ***Click Run>***.

✅ Once the FPGA is programmed, the following information should be printed on the terminal, completing the build.

<p align="center">
  <img src="../assets/data_collection_startup_print.PNG" alt="Data Collection Startup Print" width="300"/>
</p>

---

 ## 1. To Collect Data 🗂️

 There are two modes of operation: ***Manual*** and ***Auto***.

- ***Auto*** is the main mode of collecting data and requires configuring fault injection runs in software using the MicroBlaze, i.e. `main.c`.

- ***Manual*** is for running a single C application on the RISC-V just once and was useful for de-bugging in the early stages. For a simple demo, we will use ***Manual*** operation

**Step 1** - Enter the following commands to setup the time to run the RISC-V application for (the bare minimum command necessary):

- 1. Enter `1` followed by the `Enter` key.
- 2. Enter `14` followed by the `Enter` key.
- 3. Enter `10,000` followed by the `Enter` key.
- 4. And return home by pressing the `m` key followed by the `Enter` key.
- 5. Then enter `7` followed by the `Enter` key.
 
**Step 2** - The design is now ready to run the RISC-V C application for 10,000 clock cycles. The data that is about to be streamed needs to be saved:

- 1. On CoolTerm, press the ***clear data*** icon - clearing the terminal window.
- 2. Press `ctrl` + `r` and save the text file locally.
- 3. Enter `1` followed by the `Enter' key - and the RISC-V instruction data should begin streaming off-FPGA to the text file.
 
UART is a slow protocol and this will take a few minutes. Grab a coffee ;)

**Step 3** - After 10,000 clock cycles of RISC-V instruction data is streamed, close the text file:

- 1. Press `ctrl` + `shift` + `r` to save the text file locally.
- 2. And return home by pressing the `m` key followed by `Enter'.

---

Open the text file that was just created. This is the RISC-V instruction data from Neorv32 executed!

- The `RAM_result_data_00` -> `RAM_result_data_19` shows the sorted 20 numbers from the C heap sort application on Neorv32.

- Each subsequent line shows the instruction data for each of the 10,000 clock cycles.

- The `CPU_state= SLEEP` is the `main()` returning 0 after the heap sort completed, and this takes almost 10,000 cycles.

Faults can be injected to capture data to see how the core behaves. This was the data collection framework that collected data to train the SNN model in this PhD! In Auto mode, lots of data can be gathered in a single text file by repeating the C application on the RISC-V repeately with differnet faults setup, as opposed to what we demonstrated here in manual mode with just a single application execution.



