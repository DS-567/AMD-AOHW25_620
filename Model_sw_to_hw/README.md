
Step 1 - Download the repo zip file (if not already done so).

Step 2 - Open the Windows terminal:

cmd

and navigate to folder:

/AMD-AOHW25_620/Demonstrator/sw/Python_GUI

Step 3 - Create and activate a virtual environment (windows):

[PATH_TO_PYTHON39] -m venv venv

venv\Scripts\activate

Step 4 - Install dependencies:

pip install -r requirements.txt

Step 5 - Plug in the Nexys A7-100T FPGA board. Find the COM port in Device Manager and update uart_config.json, e.g.

"COM1".

Step 6 - Run the script:

python ISCAS_demo_gui.py

A blank GUI should pop-up.
