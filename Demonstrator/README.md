# Demonstrator Repo 🔍 

ADD INTRO....

---

## Demonstrator Dependencies 📝

- Python: **3.9.10**
- Vitis: **2023.1**
- FPGA platform: **Nexys A7-100T**

⚠️ **Note:** This design is hardware-dependent and requires custom PCBs.  
The build instructions can still be followed, but the system will not function without them. 

---

 ## Build Steps to Run the Demonstrator 🔨

There are two stages for building the demonstrator, which must be performed in order.

 ## 1. Python GUI Build 📺

**Step 1** - Download the repo zip file (if not already done so).

**Step 2** - Open terminal (cmd) and navigate to folder:

`(\Demonstrator\sw\Python_GUI)`

**Step 3** - Create and activate a virtual environment (windows):
         
           <python39.exe path> -m venv venv
           venv\Scripts\activate
    
**Step 4** - Install dependencies:

           pip install -r requirements.txt

**Step 5** - Plug in the Nexys A7-100T FPGA board. Find the COM port in Device Manager and update `uart_config.json,` e.g. `"COM1"`.

**Step 6** - Run the script:

            python ISCAS_demo_gui.py

---

 ## 2. FPGA Build (Vitis IDE) 🖥️

**Step 1** - Open Vitis IDE with a clean workpace and start a new application project.

**Step 2** - Select the tab **"create a new platform from hardware (XSA)"**. Browse and select the design_1_wrapper.xsa, and press Next>.

**Step 3** - Enter the application project name as demo, and press Next>.

**Step 4** - **Click Next>** again on the domain page.

**Step 5** - Select Empty Application (C) and press Next>.

**Step 6** - Right-click the src folder → Add Sources → select all 4 provided source files from ....... (nicer code directory..)

**Step 7** - Set up a **single debug application** and run the configuration.

---

✅ Once the FPGA is programmed, the Python GUI will initialize, completing the demonstrator build.

