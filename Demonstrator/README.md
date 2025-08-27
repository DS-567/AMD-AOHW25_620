# Steps to Run the Demonstrator

ADD INTRO....

⚠️ **Note:** This design is hardware-dependent and requires custom PCBs. The build instructions can still be followed, but the system will not be functional!

⚠️ **Note:** This design is specifically designed for the Nexys A7-100T development board (Artix-7 FPGA) only!

There are two stages for building the demonstrator and must be performed in order.

## 1. Python GUI Build

**Step 1** - Download the repo zip file (if not already done so).

**Step 2** - Open terminal (cmd) and navigate to folder (\Demonstrator).

**Step 3** - Create and activate a virtual environment (windows):
         
           <python39.exe path> -m venv venv
           venv\Scripts\activate
    
**Step 4** - Install dependencies:

           pip install -r requirements.txt

**Step 5** - Plug in Nexys A7-100T FPGA board. Open device manager, find the COM port and manually overwrite the uart_config.json file

**Step 6** - Run the script:

            python ISCAS_demo_gui.py

## 2. FPGA Build (Vitis IDE)

**Step 1** - Open Vitis IDE with a clean workpace and start a new application project.

**Step 2** - Select the tab "create a new platform from hardware (XSA). Browse and select the design_1_wrapper.xsa, and press Next>.

**Step 3** - Enter the application project name as demo, and press Next>.

**Step 4** - Press Next> again on the domain page.

**Step 5** - Select Empty Application (C) and press Next>.

**Step 6** - Right click ......... and add src files, make sure all 4 are selected.

**Step 7** - Set up a single debug application and run the configuration.

The Python GUI should get initialised once the FPGA is programmed and the demonstrator has been successfully built.


