# Model Software to Hardware Framework Overview 🔍 

This repository contains the SNN software model of the smart watchdog, including the Python script to to load the torch model, extract the parameters and create setup text files required by Vivado for generating the SNN. This is also part of the submission to the AMD Open Hardware Design Competition 2025.

It features:
- A physical hardare setup (left) i.e motor, encoder, custom PCBs.
- Python GUI frontend for user interaction (right).
- Design bitstream generated from Vivado.
- FPGA backend built using Vitis, running on the Nexys A7-100T board.

<p align="center">
  <img src="../assets/software_model_to_hardware_framework.PNG" alt="Software Model to Hardware Framework" width="800"/>
</p>

### Short Decription

- PI-speed control C algorithmn is compiled and executed on Neorv32, resembling a safety-critical motor control task.
- Motor speed and direction is controlled while faults are injected into the program counter of Neorv32 where control flow errors might manifest.
- The smart watchdog monitors each instruction executed by Neorv32 and classifies accordingly, i.e. normal execution or control flow error detected.
- Smart watchdog class decisions and other information is extracted off FPGA over UART to a Python GUI for displaying to the user.

---

## Model_sw_to_hw Contents 📦

- ***smart_watchdog_snn_model.pth*** : Path of SNNTorch software model
- ***model_sw_to_hw.py*** : Main Python script
- ***requirements.txt***  : Python dependencies
- ***SNN_config.json***  : UART configuration

**Note:** More information on the custom PCBs can be found: [`AMD-AOHW25_620/Demonstrator/hw/PCBs/`](/Demonstrator/hw/PCBs/).

---

## Demonstrator Dependencies 📝

- Python: **3.9.10**

---

 ## Build Steps to Run the Python Script 🔨

The following stages must be performed in order.

 ## 1. Python GUI Build 📺

**Step 1** - Download the repo zip file (if not already done so).

**Step 2** - Open the Windows terminal:

`cmd`

and navigate to folder:

`/AMD-AOHW25_620/Demonstrator/sw/Python_GUI`

**Step 3** - Create and activate a virtual environment (windows):
         
`[PATH_TO_PYTHON39] -m venv venv`

`venv\Scripts\activate`


**Step 4** - Install dependencies:

`pip install -r requirements.txt`

**Step 5** - Plug in the Nexys A7-100T FPGA board. Find the COM port in Device Manager and update `uart_config.json,` e.g.

`"COM1"`.

**Step 6** - Run the script:

`python ISCAS_demo_gui.py`

A blank GUI should pop-up.

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







Step 1 - Download the repo zip file (if not already done so).

Step 2 - Open the Windows terminal:

cmd

and navigate to folder:

/AMD-AOHW25_620/Demonstrator/Model_sw_to_hw/model_sw_to_hw

Step 3 - Create and activate a virtual environment (windows):

[PATH_TO_PYTHON39] -m venv venv

venv\Scripts\activate

Step 4 - Install dependencies:

pip install -r requirements.txt

Step 6 - Run the script:

python model_sw_to_hw.py

print message and files created ?
