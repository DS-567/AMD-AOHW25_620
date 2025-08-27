
# imports
import tkinter as tk
from tkinter import ttk
import threading
import json
import time
import serial
import copy
from copy import deepcopy
import PIL
from PIL import Image, ImageTk
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from pathlib import Path

uart_port = None

listbox_num_selected = 0

watchdog_info_enable = False
spike_plot_enable = False

dropdown_selected = "No Faults"

neorv32_data_buffer_list = []

no_faults_features_list = []
faults_features_list = []

# list to store instruction
no_faults_instruction_list = []
faults_instruction_list = []

progress_bar_count = 0

total_instruction_count = 0
no_faults_instruction_count = 0
faults_instruction_count = 0

# default value
fifo_write_cycles = 4000

snn_class_output = ""
snn_spikes_buffer_list = []
snn_spikes_no_faults_list = []
snn_spikes_faults_list = []

# directory of images for GUI
BASE_DIR = Path(__file__).resolve().parent
IMG_DIR  = BASE_DIR / "images"
UART_DIR  = BASE_DIR / "uart_config.json"

########################################################################################################################################################

# this function directly generates the spiketrain based on the inputted rate and the number of timesteps
# spiketrain spike values are created as float type as that seems to be required for SNNtorch

def send_uart_on_button_press(event, message):
    send_uart_message(f"{message}_p")


def send_uart_on_button_release(event, message):
    send_uart_message(f"{message}_r")

########################################################################################################################################################

def send_setpoint_uart_on_button_press():
    if (motor_setpoint_entry.get().isdigit()):
        setpoint_value = int(motor_setpoint_entry.get())

        if ((setpoint_value >= 2000) and (setpoint_value <= 4000)):
            if ((setpoint_value % 50) == 0):
                message = f"motor_setpoint_{setpoint_value}"
                send_uart_message(message)
                message = f"motor_setpoint_conf_p"
                send_uart_message(message)
                motor_setpoint_warning_label.config(text=f"")
            else:
                motor_setpoint_warning_label.config(text=f"Enter multiples of 50!")
        else:
            motor_setpoint_warning_label.config(text=f"Enter between 2000 & 4000!")
    else:
        motor_setpoint_warning_label.config(text=f"Enter only integers!")

########################################################################################################################################################

def update_led(canvas, led_id, color):
    canvas.itemconfig(led_id, fill=color)

########################################################################################################################################################

def init_uart():
    global uart_port

    # Load config.json
    with open(UART_DIR) as f:
        config = json.load(f)

    uart_port = config["uart_port"]
    baud_rate = config["baud_rate"]
    timeout = config["timeout"]

    uart_port = serial.Serial(uart_port, baudrate=baud_rate, timeout=timeout)

########################################################################################################################################################

def send_uart_message(message):
    if uart_port:
        uart_port.write(f"{message}\n".encode())  # Sends the message ending with a newline

########################################################################################################################################################

def read_uart_messages():
    while True:
        if uart_port and uart_port.in_waiting > 0:
            message = uart_port.readline().decode().strip()
            if message:
                handle_uart_message(message)
                #print(f"UART received from uB: {message}")

########################################################################################################################################################

def handle_uart_message(message):
    global dropdown_selected
    global no_faults_features_list
    global faults_features_list
    global neorv32_data_buffer_list
    global no_faults_instruction_list
    global faults_instruction_list
    global watchdog_info_enable
    global total_instruction_count
    global no_faults_instruction_count
    global faults_instruction_count
    global spike_plot_enable
    global snn_spikes_buffer_list
    global snn_spikes_no_faults_list
    global snn_spikes_faults_list
    global snn_class_output
    global fifo_write_cycles

    if message == "start":

        no_faults_features_list.clear()
        faults_features_list.clear()
        neorv32_data_buffer_list.clear()
        no_faults_instruction_list.clear()
        faults_instruction_list.clear()

        snn_spikes_buffer_list.clear()
        snn_spikes_no_faults_list.clear()
        snn_spikes_faults_list.clear()

        snn_class_output = ""

        total_instruction_count = 0
        no_faults_instruction_count = 0
        faults_instruction_count = 0

        reset_progress_bar()

        clear_listbox()

        clear_treeview()

        selected_instruction_IR_label.config(text="IR: ")
        selected_instruction_IR_decoded_label.config(text="")
        features_label.config(text="Features: ")
        features_15_label.config(text="")
        features_14_label.config(text="")
        features_13_label.config(text="")
        features_12_label.config(text="")
        features_11_label.config(text="")
        features_10_label.config(text="")
        features_9_label.config(text="")
        features_8_label.config(text="")
        features_7_label.config(text="")
        features_opcode_label.config(text="")
        selected_instruction_PC_last_label.config(text="PC (last): ")
        selected_instruction_PC_correct_label.config(text="PC (correct): ")
        selected_instruction_PC_current_label.config(text="PC (current): ")

        watchdog_instructions_faults_monitored_label.config(text=f"With Faults: 0")

        snn_class_output = ""

    elif message.startswith("IR="):
        if (watchdog_info_enable == True):
            neorv32_data_buffer_list.append(message)
            update_progress_bar()

    elif message.startswith("snn_c0_features_"):
        if (watchdog_info_enable == True):
            features = int(message.split("_")[3])
            no_faults_features_list.append(features)

            temp_list = copy.deepcopy(neorv32_data_buffer_list)
            no_faults_instruction_list.append(temp_list)
            neorv32_data_buffer_list.clear()

            progress_bar_count_subtract_one()

            total_instruction_count += 1
            no_faults_instruction_count += 1

            watchdog_instructions_monitored_label.config(text=f"Instructions Monitored: {total_instruction_count}")
            watchdog_instructions_no_faults_monitored_label.config(text=f"With No Faults: {no_faults_instruction_count}")

            snn_class_output = "0"

    elif message.startswith("snn_c1_features_"):
        if (watchdog_info_enable == True):
            features = int(message.split("_")[3])
            faults_features_list.append(features)

            temp_list = copy.deepcopy(neorv32_data_buffer_list)
            faults_instruction_list.append(temp_list)
            neorv32_data_buffer_list.clear()

            progress_bar_count_subtract_one()

            total_instruction_count += 1
            faults_instruction_count += 1

            watchdog_instructions_monitored_label.config(text=f"Instructions Monitored: {total_instruction_count}")
            watchdog_instructions_faults_monitored_label.config(text=f"With Faults: {faults_instruction_count}")

            snn_class_output = "1"

    elif message.startswith("snn_in_2_0_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_in_5_3_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_in_8_6_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_in_11_9_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_in_14_12_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_in_15_spikes_"):
        snn_spikes = int(message.split("_")[4])
        decode_snn_spikes(snn_spikes, "1")

    elif message.startswith("snn_hid_2_0_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_hid_5_3_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_hid_8_6_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_hid_11_9_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_hid_14_12_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_hid_17_15_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "3")

    elif message.startswith("snn_hid_19_18_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "2")

    elif message.startswith("snn_out_1_0_spikes_"):
        snn_spikes = int(message.split("_")[5])
        decode_snn_spikes(snn_spikes, "2")

        temp_spike_list = copy.deepcopy(snn_spikes_buffer_list)

        if (snn_class_output == "0"):
            snn_spikes_no_faults_list.append(temp_spike_list)

        elif (snn_class_output == "1"):
            snn_spikes_faults_list.append(temp_spike_list)

        snn_spikes_buffer_list.clear()

    elif message == "done":

        cpu_trap_enter_found = False
        exception_found = False

        if (dropdown_selected == "No Faults"):
            update_listbox("No Faults")
        elif (dropdown_selected == "Faults"):
            update_listbox("Faults")

        if (len(no_faults_instruction_list) > 0):
            for i in range(len(no_faults_instruction_list)):
                for j in range(len(no_faults_instruction_list[i])):

                    if (cpu_trap_enter_found == True):

                        mcause_hex_str = no_faults_instruction_list[i][j][78] + \
                                         no_faults_instruction_list[i][j][79]

                        mcause_int = int(mcause_hex_str, 16)

                        if ((mcause_int >> 5) == 0):
                            exception_found = True

                    if ("CPU_state= TRAP_ENTER" in no_faults_instruction_list[i][j]):
                        cpu_trap_enter_found = True

        cpu_trap_enter_found = False

        if (len(faults_instruction_list) > 0):
            for i in range(len(faults_instruction_list)):
                for j in range(len(faults_instruction_list[i])):

                    if (cpu_trap_enter_found == True):

                        mcause_hex_str = faults_instruction_list[i][j][78] + \
                                         faults_instruction_list[i][j][79]

                        mcause_int = int(mcause_hex_str, 16)

                        if ((mcause_int >> 5) == 0):
                            exception_found = True

                    if ("CPU_state= TRAP_ENTER" in faults_instruction_list[i][j]):
                        cpu_trap_enter_found = True

        if (watchdog_info_enable == True):
            if (exception_found == True):
                send_uart_message("trap_trig_1")
            else:
                send_uart_message("trap_trig_0")
        else:
            send_uart_message("trap_trig_0")


    elif message == "motor_run_0":
        update_led(motor_running_led_canvas, motor_running_led, "lightgrey")
    elif message == "motor_run_1":
        update_led(motor_running_led_canvas, motor_running_led, "green")

    elif message == "motor_for_1":
        update_led(forward_direction_led_canvas, forward_direction_led, "yellow")
    elif message == "motor_for_0":
        update_led(forward_direction_led_canvas, forward_direction_led, "lightgrey")

    elif message == "motor_rev_1":
        update_led(reverse_direction_led_canvas, reverse_direction_led, "yellow")
    elif message == "motor_rev_0":
        update_led(reverse_direction_led_canvas, reverse_direction_led, "lightgrey")

    elif message == "flts_active_1":
        update_led(faults_active_led_canvas, faults_active_led, "yellow")
    elif message == "flts_active_0":
        update_led(faults_active_led_canvas, faults_active_led, "lightgrey")

    elif message.startswith("motor_setpoint_"):
        setpoint_speed = int(message.split("_")[2])
        motor_setpoint_value_label.config(text=f"Motor Setpoint: {setpoint_speed} RPM")
    elif message.startswith("motor_actual_"):
        actual_speed = int(message.split("_")[2])
        motor_actual_value_label.config(text=f"Motor Actual: {actual_speed} RPM")

    elif message.startswith("pc"):

        if message == "pc_bit_cnts_1_0":
            pc_bit_1_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_1_1":
            pc_bit_1_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_1_2":
            pc_bit_1_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_1_3":
            pc_bit_1_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_2_0":
            pc_bit_2_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_2_1":
            pc_bit_2_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_2_2":
            pc_bit_2_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_2_3":
            pc_bit_2_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_3_0":
            pc_bit_3_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_3_1":
            pc_bit_3_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_3_2":
            pc_bit_3_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_3_3":
            pc_bit_3_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_4_0":
            pc_bit_4_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_4_1":
            pc_bit_4_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_4_2":
            pc_bit_4_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_4_3":
            pc_bit_4_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_5_0":
            pc_bit_5_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_5_1":
            pc_bit_5_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_5_2":
            pc_bit_5_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_5_3":
            pc_bit_5_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_6_0":
            pc_bit_6_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_6_1":
            pc_bit_6_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_6_2":
            pc_bit_6_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_6_3":
            pc_bit_6_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_7_0":
            pc_bit_7_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_7_1":
            pc_bit_7_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_7_2":
            pc_bit_7_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_7_3":
            pc_bit_7_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_8_0":
            pc_bit_8_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_8_1":
            pc_bit_8_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_8_2":
            pc_bit_8_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_8_3":
            pc_bit_8_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_9_0":
            pc_bit_9_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_9_1":
            pc_bit_9_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_9_2":
            pc_bit_9_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_9_3":
            pc_bit_9_button.config(bg="yellow", text="Bit Flip")

        elif message == "pc_bit_cnts_10_0":
            pc_bit_10_button.config(bg="green", text="No fault")
        elif message == "pc_bit_cnts_10_1":
            pc_bit_10_button.config(bg="yellow", text="Stuck at 0")
        elif message == "pc_bit_cnts_10_2":
            pc_bit_10_button.config(bg="yellow", text="Stuck at 1")
        elif message == "pc_bit_cnts_10_3":
            pc_bit_10_button.config(bg="yellow", text="Bit Flip")


    elif message == "nv32_rst_1":
        update_led(neorv32_reset_led_canvas, neorv32_reset_led, "lightgrey")
    elif message == "nv32_rst_0":
        update_led(neorv32_reset_led_canvas, neorv32_reset_led, "red")

    elif message == "wd_en_1":
        update_led(watchdog_status_led_canvas, watchdog_status_led, "green")
    elif message == "wd_en_0":
        update_led(watchdog_status_led_canvas, watchdog_status_led, "lightgrey")

    # elif message == "system_err_1":
    #     update_led(system_error_led_canvas, system_error_led, "red")
    # elif message == "system_err_0":
    #     update_led(system_error_led_canvas, system_error_led, "lightgrey")

    elif message == "instr_info_en_1":
        watchdog_info_enable = True
        instruction_info_enable_button.config(text="Instruction Info Enabled")
    elif message == "instr_info_en_0":
        watchdog_info_enable = False
        instruction_info_enable_button.config(text="Instruction Info Disabled")

    elif message == "trap_trig_led_1":
        update_led(trap_triggered_by_exception_led_canvas, trap_triggered_by_exception_led, "red")
    elif message == "trap_trig_led_0":
        update_led(trap_triggered_by_exception_led_canvas, trap_triggered_by_exception_led, "lightgrey")

    elif message.startswith("instr_count_"):
        instruction_count = int(message.split("_")[2])
        watchdog_instructions_monitored_label.config(text=f"Total Instructions Monitored: {instruction_count}")
    elif message.startswith("instr_nf_count_"):
        instruction_no_fault_count = int(message.split("_")[3])
        watchdog_instructions_no_faults_monitored_label.config(text=f"With No Faults: {instruction_no_fault_count}")
    elif message.startswith("instr_f_count_"):
        instruction_fault_count = int(message.split("_")[3])
        watchdog_instructions_faults_monitored_label.config(text=f"With Faults: {instruction_fault_count}")

    elif message.startswith("fifo_wr_cycles_"):
        fifo_write_cycles = int(message.split("_")[3])
        fifo_write_cycles_label.config(text=f"FIFO Write Cycles: {fifo_write_cycles}")

    elif message == "spike_plot_en_1":
        spike_plot_enable = True
        spike_plot_enable_button.config(text="SNN Spike Plot Enabled")
    elif message == "spike_plot_en_0":
        spike_plot_enable = False
        spike_plot_enable_button.config(text="SNN Spike Plot Disabled")

########################################################################################################################################################

def update_listbox(selection):
    global dropdown_selected
    global no_faults_instruction_list
    global faults_instruction_list

    # Clear the existing items in the Listbox
    listbox_1.delete(0, 'end')

    # Populate the Listbox with options based on selection
    if selection == "No Faults":
        if (len(no_faults_instruction_list) > 0):
            options = range(1, len(no_faults_instruction_list) + 1)
        else:
            options = ['None']

    elif selection == "Faults":
        if (len(faults_instruction_list) > 0):
            options = range(1, len(faults_instruction_list) + 1)
        else:
            options = ['None']

    else:
        options = ['Error!']

    for each_option in options:
        listbox_1.insert('end', each_option)

    dropdown_selected = selection

########################################################################################################################################################

def clear_listbox():
    listbox_1.delete(0, 'end')

########################################################################################################################################################

def select_item(event):
    global dropdown_selected
    global listbox_num_selected
    global no_faults_instruction_list
    global faults_instruction_list
    global no_faults_features_list
    global faults_features_list

    IR_str = ""
    PC_last_str = ""
    PC_current_str = ""
    MTVEC_str = ""
    MEPC_str = ""
    RS1_str = ""

    cpu_branched_found = False
    cpu_trap_enter_found = False
    cpu_trap_exit_found = False
    JAL_instruction = False
    JALR_instruction = False

    listbox_num_selected = listbox_1.get(listbox_1.curselection())

    if (listbox_num_selected == "None"):
        selected_instruction_IR_label.config(text=f"IR: ")
        selected_instruction_IR_decoded_label.config(text="")
        selected_instruction_PC_last_label.config(text=f"PC (last): ")
        selected_instruction_PC_correct_label.config(text="PC (correct): ")
        selected_instruction_PC_current_label.config(text=f"PC (current): ")
        features_label.config(text=f"Features: ")
        features_15_label.config(text="")
        features_14_label.config(text="")
        features_13_label.config(text="")
        features_12_label.config(text="")
        features_11_label.config(text="")
        features_10_label.config(text="")
        features_9_label.config(text="")
        features_8_label.config(text="")
        features_7_label.config(text="")
        features_opcode_label.config(text="")
        SNN_response_label.config(text="SNN Response...", fg="black")

    elif (dropdown_selected == "No Faults"):

        IR_str = no_faults_instruction_list[listbox_num_selected - 1][0][4] + \
                 no_faults_instruction_list[listbox_num_selected - 1][0][5] + \
                 no_faults_instruction_list[listbox_num_selected - 1][0][6] + \
                 no_faults_instruction_list[listbox_num_selected - 1][0][7] + \
                 no_faults_instruction_list[listbox_num_selected - 1][0][8] + \
                 no_faults_instruction_list[listbox_num_selected - 1][0][9] + \
                 no_faults_instruction_list[listbox_num_selected - 1][0][10] + \
                 no_faults_instruction_list[listbox_num_selected - 1][0][11]

        PC_last_str = no_faults_instruction_list[listbox_num_selected - 1][0][17] + \
                      no_faults_instruction_list[listbox_num_selected - 1][0][18] + \
                      no_faults_instruction_list[listbox_num_selected - 1][0][19] + \
                      no_faults_instruction_list[listbox_num_selected - 1][0][20] + \
                      no_faults_instruction_list[listbox_num_selected - 1][0][21] + \
                      no_faults_instruction_list[listbox_num_selected - 1][0][22] + \
                      no_faults_instruction_list[listbox_num_selected - 1][0][23] + \
                      no_faults_instruction_list[listbox_num_selected - 1][0][24]

        instruction_len = len(no_faults_instruction_list[listbox_num_selected - 1])
        PC_current_str = no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][17] + \
                         no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][18] + \
                         no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][19] + \
                         no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][20] + \
                         no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][21] + \
                         no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][22] + \
                         no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][23] + \
                         no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][24]


        for i in range(len(no_faults_instruction_list[listbox_num_selected - 1])):
            if ("CPU_state= TRAP_ENTER" in no_faults_instruction_list[listbox_num_selected - 1][i]):
                cpu_trap_enter_found = True
                # get mtvec
                MTVEC_str = no_faults_instruction_list[listbox_num_selected - 1][0][47] + \
                            no_faults_instruction_list[listbox_num_selected - 1][0][48] + \
                            no_faults_instruction_list[listbox_num_selected - 1][0][49] + \
                            no_faults_instruction_list[listbox_num_selected - 1][0][50] + \
                            no_faults_instruction_list[listbox_num_selected - 1][0][51] + \
                            no_faults_instruction_list[listbox_num_selected - 1][0][52] + \
                            no_faults_instruction_list[listbox_num_selected - 1][0][53] + \
                            no_faults_instruction_list[listbox_num_selected - 1][0][54]

        for i in range(len(no_faults_instruction_list[listbox_num_selected - 1])):
            if ("CPU_state= TRAP_EXIT" in no_faults_instruction_list[listbox_num_selected - 1][i]):
                cpu_trap_exit_found = True
                # get mepc
                MEPC_str = no_faults_instruction_list[listbox_num_selected - 1][0][62] + \
                           no_faults_instruction_list[listbox_num_selected - 1][0][63] + \
                           no_faults_instruction_list[listbox_num_selected - 1][0][64] + \
                           no_faults_instruction_list[listbox_num_selected - 1][0][65] + \
                           no_faults_instruction_list[listbox_num_selected - 1][0][66] + \
                           no_faults_instruction_list[listbox_num_selected - 1][0][67] + \
                           no_faults_instruction_list[listbox_num_selected - 1][0][68] + \
                           no_faults_instruction_list[listbox_num_selected - 1][0][69]

        IR_decoded = decode_IR(IR_str)

        if (IR_decoded[0] == "B"):

            for i in range(len(no_faults_instruction_list[listbox_num_selected - 1])):
                if ("CPU_state= BRANCHED" in no_faults_instruction_list[listbox_num_selected - 1][i]):
                    cpu_branched_found = True
                    #get branch offset
                    branch_offset = decode_branch_address(IR_str)

            if (cpu_branched_found == True):
                IR_decoded = IR_decoded + " : taken"
            else:
                IR_decoded = IR_decoded + " : not taken"

        elif (len(IR_decoded) == 3 and IR_decoded[0] == "J" and IR_decoded[1] == "A" and IR_decoded[2] == "L"):
            JAL_instruction = True
            #get jal offset
            jal_offset = decode_jal_address(IR_str)

        elif (len(IR_decoded) == 4 and IR_decoded[0] == "J" and IR_decoded[1] == "A" and IR_decoded[2] == "L" and IR_decoded[3] == "R"):
            JALR_instruction = True
            #get jalr offset
            jalr_offset = decode_jalr_address(IR_str)
            #get RS1
            instruction_len = len(no_faults_instruction_list[listbox_num_selected - 1])
            RS1_str = no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][31] + \
                      no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][32] + \
                      no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][33] + \
                      no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][34] + \
                      no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][35] + \
                      no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][36] + \
                      no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][37] + \
                      no_faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][38]


        selected_instruction_IR_label.config(text=f"IR: 0x{IR_str}")
        selected_instruction_IR_decoded_label.config(text=f"{IR_decoded}")

        selected_instruction_PC_last_label.config(text=f"PC (last): 0x{PC_last_str}")

        if (cpu_trap_enter_found == True):
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{MTVEC_str}")
        elif (cpu_trap_exit_found == True):
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{MEPC_str}")
        elif (cpu_branched_found == True):
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{int(PC_last_str,16) + branch_offset:08X}")
        elif (JAL_instruction == True):
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{int(PC_last_str,16) + jal_offset:08X}")
        elif (JALR_instruction == True):
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{int(RS1_str,16) + jalr_offset:08X}")
        else:
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{int(PC_last_str,16) + 4:08X}")

        selected_instruction_PC_current_label.config(text=f"PC (current): 0x{PC_current_str}")

        features = swap_IR_opcode_in_features(no_faults_features_list[listbox_num_selected - 1])
        features_label.config(text=f"Features: {features}")
        features_15_label.config(text=f"{features[0]}")
        features_14_label.config(text=f"{features[1]}")
        features_13_label.config(text=f"{features[2]}")
        features_12_label.config(text=f"{features[3]}")
        features_11_label.config(text=f"{features[4]}")
        features_10_label.config(text=f"{features[5]}")
        features_9_label.config(text=f"{features[6]}")
        features_8_label.config(text=f"{features[7]}")
        features_7_label.config(text=f"{features[8]}")
        features_opcode_label.config(text=f"{features[9] + features[10] + features[11] + features[12] + features[13] + features[14] + features[15]}")

        SNN_response_label.config(text="No Fault Detected", fg="green")

        update_treeview("No Faults")

    elif (dropdown_selected == "Faults"):

        IR_str = faults_instruction_list[listbox_num_selected - 1][0][4] + \
                 faults_instruction_list[listbox_num_selected - 1][0][5] + \
                 faults_instruction_list[listbox_num_selected - 1][0][6] + \
                 faults_instruction_list[listbox_num_selected - 1][0][7] + \
                 faults_instruction_list[listbox_num_selected - 1][0][8] + \
                 faults_instruction_list[listbox_num_selected - 1][0][9] + \
                 faults_instruction_list[listbox_num_selected - 1][0][10] + \
                 faults_instruction_list[listbox_num_selected - 1][0][11]

        PC_last_str = faults_instruction_list[listbox_num_selected - 1][0][17] + \
                      faults_instruction_list[listbox_num_selected - 1][0][18] + \
                      faults_instruction_list[listbox_num_selected - 1][0][19] + \
                      faults_instruction_list[listbox_num_selected - 1][0][20] + \
                      faults_instruction_list[listbox_num_selected - 1][0][21] + \
                      faults_instruction_list[listbox_num_selected - 1][0][22] + \
                      faults_instruction_list[listbox_num_selected - 1][0][23] + \
                      faults_instruction_list[listbox_num_selected - 1][0][24]

        instruction_len = len(faults_instruction_list[listbox_num_selected - 1])
        PC_current_str = faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][17] + \
                         faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][18] + \
                         faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][19] + \
                         faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][20] + \
                         faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][21] + \
                         faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][22] + \
                         faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][23] + \
                         faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][24]


        for i in range(len(faults_instruction_list[listbox_num_selected - 1])):
            if ("CPU_state= TRAP_ENTER" in faults_instruction_list[listbox_num_selected - 1][i]):
                cpu_trap_enter_found = True
                # get mtvec
                MTVEC_str = faults_instruction_list[listbox_num_selected - 1][0][47] + \
                            faults_instruction_list[listbox_num_selected - 1][0][48] + \
                            faults_instruction_list[listbox_num_selected - 1][0][49] + \
                            faults_instruction_list[listbox_num_selected - 1][0][50] + \
                            faults_instruction_list[listbox_num_selected - 1][0][51] + \
                            faults_instruction_list[listbox_num_selected - 1][0][52] + \
                            faults_instruction_list[listbox_num_selected - 1][0][53] + \
                            faults_instruction_list[listbox_num_selected - 1][0][54]

        for i in range(len(faults_instruction_list[listbox_num_selected - 1])):
            if ("CPU_state= TRAP_EXIT" in faults_instruction_list[listbox_num_selected - 1][i]):
                cpu_trap_exit_found = True
                # get mepc
                MEPC_str = faults_instruction_list[listbox_num_selected - 1][0][62] + \
                           faults_instruction_list[listbox_num_selected - 1][0][63] + \
                           faults_instruction_list[listbox_num_selected - 1][0][64] + \
                           faults_instruction_list[listbox_num_selected - 1][0][65] + \
                           faults_instruction_list[listbox_num_selected - 1][0][66] + \
                           faults_instruction_list[listbox_num_selected - 1][0][67] + \
                           faults_instruction_list[listbox_num_selected - 1][0][68] + \
                           faults_instruction_list[listbox_num_selected - 1][0][69]

        IR_decoded = decode_IR(IR_str)

        if (IR_decoded[0] == "B"):

            for i in range(len(faults_instruction_list[listbox_num_selected - 1])):
                if ("CPU_state= BRANCHED" in faults_instruction_list[listbox_num_selected - 1][i]):
                    cpu_branched_found = True
                    #get branch offset
                    branch_offset = decode_branch_address(IR_str)

            if (cpu_branched_found == True):
                IR_decoded = IR_decoded + " : taken"
            else:
                IR_decoded = IR_decoded + " : not taken"

        elif (len(IR_decoded) == 3 and IR_decoded[0] == "J" and IR_decoded[1] == "A" and IR_decoded[2] == "L"):
            JAL_instruction = True
            #get jal offset
            jal_offset = decode_jal_address(IR_str)

        elif (len(IR_decoded) == 4 and IR_decoded[0] == "J" and IR_decoded[1] == "A" and IR_decoded[2] == "L" and IR_decoded[3] == "R"):
            JALR_instruction = True
            #get jalr offset
            jalr_offset = decode_jalr_address(IR_str)
            #get RS1
            instruction_len = len(faults_instruction_list[listbox_num_selected - 1])
            RS1_str = faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][31] + \
                      faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][32] + \
                      faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][33] + \
                      faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][34] + \
                      faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][35] + \
                      faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][36] + \
                      faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][37] + \
                      faults_instruction_list[listbox_num_selected - 1][instruction_len - 1][38]


        selected_instruction_IR_label.config(text=f"IR: 0x{IR_str}")
        selected_instruction_IR_decoded_label.config(text=f"{IR_decoded}")

        selected_instruction_PC_last_label.config(text=f"PC (last): 0x{PC_last_str}")

        if (cpu_trap_enter_found == True):
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{MTVEC_str}")
        elif (cpu_trap_exit_found == True):
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{MEPC_str}")
        elif (cpu_branched_found == True):
            selected_instruction_PC_correct_label.config(
                text=f"PC (correct): 0x{int(PC_last_str, 16) + branch_offset:08X}")
        elif (JAL_instruction == True):
            selected_instruction_PC_correct_label.config(
                text=f"PC (correct): 0x{int(PC_last_str, 16) + jal_offset:08X}")
        elif (JALR_instruction == True):
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{int(RS1_str, 16) + jalr_offset:08X}")
        else:
            selected_instruction_PC_correct_label.config(text=f"PC (correct): 0x{int(PC_last_str, 16) + 4:08X}")

        selected_instruction_PC_current_label.config(text=f"PC (current): 0x{PC_current_str}")

        features = swap_IR_opcode_in_features(faults_features_list[listbox_num_selected - 1])
        features_label.config(text=f"Features: {features}")
        features_15_label.config(text=f"{features[0]}")
        features_14_label.config(text=f"{features[1]}")
        features_13_label.config(text=f"{features[2]}")
        features_12_label.config(text=f"{features[3]}")
        features_11_label.config(text=f"{features[4]}")
        features_10_label.config(text=f"{features[5]}")
        features_9_label.config(text=f"{features[6]}")
        features_8_label.config(text=f"{features[7]}")
        features_7_label.config(text=f"{features[8]}")
        features_opcode_label.config(text=f"{features[9] + features[10] + features[11] + features[12] + features[13] + features[14] + features[15]}")

        SNN_response_label.config(text="Fault Detected!!", fg="red")

        update_treeview("Faults")

########################################################################################################################################################

def decode_IR(IR):
    IR_OPCODE_MASK = 0x7f

    FUNCT3_BITS_MASK = 0x7
    FUNCT3_SHIFT_NUM = 12

    FUNCT7_BITS_MASK = 0x7f
    FUNCT7_SHIFT_NUM = 25

    LOAD_OPCODE_MASK = 0x3
    LB_FUNCT3_MASK = 0x0
    LH_FUNCT3_MASK = 0x1
    LW_FUNCT3_MASK = 0x2
    LBU_FUNCT3_MASK = 0x4
    LHU_FUNCT3_MASK = 0x5

    STORE_OPCODE_MASK = 0x23
    SB_FUNCT3_MASK = 0x0
    SH_FUNCT3_MASK = 0x1
    SW_FUNCT3_MASK = 0x2

    FENCE_OPCODE_MASK = 0xf
    CSR_OPCODE_MASK = 0x73

    BRANCH_OPCODE_MASK = 0x63
    BEQ_FUNCT3_MASK = 0x0
    BNE_FUNCT3_MASK = 0x1
    BLT_FUNCT3_MASK = 0x4
    BGE_FUNCT3_MASK = 0x5
    BLTU_FUNCT3_MASK = 0x6
    BGEU_FUNCT3_MASK = 0x7

    JAL_OPCODE_MASK = 0x6f
    JALR_OPCODE_MASK = 0x67

    LUI_OPCODE_MASK = 0x37
    AUIPC_OPCODE_MASK = 0x17

    ALU_IMM_OPCODE_MASK = 0x13
    ADD_IMM_FUNCT3_MASK = 0x0
    SLT_IMM_FUNCT3_MASK = 0x2
    SLTU_IMM_FUNCT3_MASK = 0x3
    XOR_IMM_FUNCT3_MASK = 0x4
    OR_IMM_FUNCT3_MASK = 0x6
    AND_IMM_FUNCT3_MASK = 0x7
    SLL_IMM_FUNCT3_MASK = 0x1
    SRL_SRA_IMM_FUNCT3_MASK = 0x5

    ALU_OPCODE_MASK = 0x33
    ADD_SUB_FUNCT3_MASK = 0x0
    SLL_FUNCT3_MASK = 0x1
    SLT_FUNCT3_MASK = 0x2
    SLTU_FUNCT3_MASK = 0x3
    XOR_FUNCT3_MASK = 0x4
    SRL_SRA_FUNCT3_MASK = 0x5
    OR_FUNCT3_MASK = 0x6
    AND_FUNCT3_MASK = 0x7

    # casts 8 digit (for 32-bit value) hex string to integer
    IR_int = int(IR, 16)

    # AND the lower 7 bits of the IR integer with bitmask 0x7F to get the opcode
    IR_opcode_int = IR_int & IR_OPCODE_MASK

    if (IR_opcode_int == LOAD_OPCODE_MASK):

        funct3 = (IR_int >> FUNCT3_SHIFT_NUM) & FUNCT3_BITS_MASK

        if (funct3 == LB_FUNCT3_MASK):
            instruction = "Load (byte)"
        elif (funct3 == LH_FUNCT3_MASK):
            instruction = "Load (half-word)"
        elif (funct3 == LW_FUNCT3_MASK):
            instruction = "Load (word)"
        elif (funct3 == LBU_FUNCT3_MASK):
            instruction = "Load (byte unsigned)"
        elif (funct3 == LHU_FUNCT3_MASK):
            instruction = "Load (half-word unsigned)"

    elif (IR_opcode_int == STORE_OPCODE_MASK):

        funct3 = (IR_int >> FUNCT3_SHIFT_NUM) & FUNCT3_BITS_MASK

        if (funct3 == SB_FUNCT3_MASK):
            instruction = "Store (byte)"
        elif (funct3 == SH_FUNCT3_MASK):
            instruction = "Store (half-word)"
        elif (funct3 == SW_FUNCT3_MASK):
            instruction = "Store (word)"

    elif (IR_opcode_int == FENCE_OPCODE_MASK):
        instruction = "Fence"

    elif (IR_opcode_int == CSR_OPCODE_MASK):
        instruction = "CSR (R/W)"

    elif (IR_opcode_int == BRANCH_OPCODE_MASK):

        funct3 = (IR_int >> FUNCT3_SHIFT_NUM) & FUNCT3_BITS_MASK

        if (funct3 == BEQ_FUNCT3_MASK):
            instruction = "Branch - BEQ"
        elif (funct3 == BNE_FUNCT3_MASK):
            instruction = "Branch - BNE"
        elif (funct3 == BLT_FUNCT3_MASK):
            instruction = "Branch - BLT"
        elif (funct3 == BGE_FUNCT3_MASK):
            instruction = "Branch - BGE"
        elif (funct3 == BLTU_FUNCT3_MASK):
            instruction = "Branch - BLTU"
        elif (funct3 == BGEU_FUNCT3_MASK):
            instruction = "Branch - BGEU"

    elif (IR_opcode_int == JAL_OPCODE_MASK):
        instruction = "JAL"

    elif (IR_opcode_int == JALR_OPCODE_MASK):
        instruction = "JALR"

    elif (IR_opcode_int == ALU_IMM_OPCODE_MASK):

        funct3 = (IR_int >> FUNCT3_SHIFT_NUM) & FUNCT3_BITS_MASK

        funct7 = (IR_int >> FUNCT7_SHIFT_NUM) & FUNCT7_BITS_MASK

        if (funct3 == ADD_IMM_FUNCT3_MASK):
            instruction = "ADD (imm)"
        elif (funct3 == SLT_IMM_FUNCT3_MASK):
            instruction = "SLT (imm)"
        elif (funct3 == SLTU_IMM_FUNCT3_MASK):
            instruction = "SLTU (imm)"
        elif (funct3 == XOR_IMM_FUNCT3_MASK):
            instruction = "XOR (imm)"
        elif (funct3 == OR_IMM_FUNCT3_MASK):
            instruction = "OR (imm)"
        elif (funct3 == AND_IMM_FUNCT3_MASK):
            instruction = "AND (imm)"
        elif (funct3 == SLL_IMM_FUNCT3_MASK):
            instruction = "SLL (imm)"
        elif (funct3 == SRL_SRA_IMM_FUNCT3_MASK):
            if (funct7 == 0x0):
                instruction = "SRL (imm)"
            elif (funct7 == 0x20):
                instruction = "SRA (imm)"
            else:
                instruction = "Undefined (S imm)"
        else:
            instruction = "Undefined (ALU imm)"

    elif (IR_opcode_int == ALU_OPCODE_MASK):

        funct3 = (IR_int >> FUNCT3_SHIFT_NUM) & FUNCT3_BITS_MASK

        funct7 = (IR_int >> FUNCT7_SHIFT_NUM) & FUNCT7_BITS_MASK

        if (funct3 == ADD_SUB_FUNCT3_MASK):
            if (funct7 == 0x0):
                instruction = "ADD"
            elif (funct7 == 0x20):
                instruction = "SUB"
            else:
                instruction = "Undefined (A/S)"

        elif (funct3 == SLL_FUNCT3_MASK):
            instruction = "SLL"
        elif (funct3 == SLT_FUNCT3_MASK):
            instruction = "SLL"
        elif (funct3 == SLTU_FUNCT3_MASK):
            instruction = "SLL"
        elif (funct3 == XOR_FUNCT3_MASK):
            instruction = "XOR"
        elif (funct3 == SRL_SRA_FUNCT3_MASK):
            if (funct7 == 0x0):
                instruction = "SRL"
            elif (funct7 == 0x20):
                instruction = "SRA"
            else:
                instruction = "Undefined (S)"
        elif (funct3 == OR_FUNCT3_MASK):
            instruction = "OR"
        elif (funct3 == AND_FUNCT3_MASK):
            instruction = "AND"

    elif (IR_opcode_int == LUI_OPCODE_MASK):
        instruction = "LUI"

    elif (IR_opcode_int == AUIPC_OPCODE_MASK):
        instruction = "AUIPC"

    else:
        instruction = "Undefined (ALU)"

    return instruction

########################################################################################################################################################

# this function takes the instruction register (32-bit hex string) as input and returns the branch address offset
# RISC-V branch instruction immediate encoding:  31  |  30-> 25  |  24 -> 20  |  19 -> 15  |  14 -> 12  |  11 -> 7  |  6 -> 0
# branch address offset 12-bit positions =       12      10->5      rs2(X)       rs1(X)       100(X)      4->1, 11    opcode(X)
# (X) = don't care about these bits

def decode_branch_address(IR):
    # cast the instruction hex string to integer
    instruction = int(IR, 16)

    # mask the branch address offset specific bits, shift the masked result to lowest bit position and store the result to local variables
    instruction_bits_31_31 = (instruction & 0b10000000000000000000000000000000) >> 31
    instruction_bits_30_25 = (instruction & 0b01111110000000000000000000000000) >> 25
    instruction_bits_11_8  = (instruction & 0b00000000000000000000111100000000) >> 8
    instruction_bit_7      = (instruction & 0b00000000000000000000000010000000) >> 7

    # shift the masked results to the correct bit positions for branch instructions
    immediate_bit_12    = instruction_bits_31_31 << 12
    immediate_bit_11    = instruction_bit_7 << 11
    immediate_bits_10_5 = instruction_bits_30_25 << 5
    immediate_bits_4_1  = (instruction_bits_11_8 & 0b1111) << 1

    # logical OR on all immediate bits to form the absolute immediate value
    offset_address = immediate_bit_12 | immediate_bit_11 | immediate_bits_10_5 | immediate_bits_4_1

    # if the immediate value MSB is set, the value is negative.
    # take twos complement of the immediate value
    if offset_address & (1 << 12):
        offset_address -= (1 << 13)

    return offset_address

########################################################################################################################################################

# this function takes the instruction register (32-bit hex string) as input and returns the jal address offset
# RISC-V jal instruction immediate encoding:  31            ->          12     |  11 -> 7   |   6 -> 0
# jal address offset 12-bit positions =       20     10->1     11     19->12        rd(X)      opcode(X)
# (X) = don't care about these bits

def decode_jal_address(IR):
    # cast the instruction hex string to integer
    instruction = int(IR, 16)

    # mask the jal address offset specific bits and store the masked result to local variables
    instruction_bits_31_31 = instruction & 0b10000000000000000000000000000000
    instruction_bits_30_21 = instruction & 0b01111111111000000000000000000000
    instruction_bits_20_20 = instruction & 0b00000000000100000000000000000000
    instruction_bits_19_12 = instruction & 0b00000000000011111111000000000000

    # shift the masked results to the correct bit positions for jal instructions
    immediate_bits_20_20 = instruction_bits_31_31 >> 11
    immediate_bits_19_12 = instruction_bits_19_12
    immediate_bits_11_11 = instruction_bits_20_20 >> 9
    immediate_bits_10_01 = instruction_bits_30_21 >> 20
    immediate_bits_00_00 = 0

    # logical OR on all immediate bits to form the absolute immediate value
    offset_address = immediate_bits_20_20 | immediate_bits_19_12 | immediate_bits_11_11 | immediate_bits_10_01 | immediate_bits_00_00

    # if the immediate value MSB is set, the value is negative.
    # take twos complement of the immediate value
    if ((offset_address >> 20) == 1):
        offset_address = offset_address - (1 << 21)

    return offset_address

########################################################################################################################################################

# this function takes the instruction register (32-bit hex string) as input and returns the jalr address offset
# RISC-V jalr instruction immediate encoding:  31            ->          12     |  11 -> 7   |   6 -> 0
# jalr address offset 12-bit positions =       20     10->1     11     19->12        rd(X)      opcode(X)
# (X) = don't care about these bits

def decode_jalr_address(IR):
    # cast the instruction hex string to integer
    instruction = int(IR, 16)

    # mask the jalr address offset bits and store the masked result to local variable
    JALR_address_mask = 0b11111111111100000000000000000000

    # shift the result to the lowest bit position
    offset_address = (instruction & JALR_address_mask) >> 20

    # if the immediate value MSB is set, the value is negative.
    # take twos complement of the immediate value
    if ((offset_address >> 11) == 1):
        offset_address = offset_address - (1 << 12)

    return offset_address


def swap_IR_opcode_in_features(features_int):
    # lower 7 bits
    IR_opcode = features_int & 0b1111111

    # Reverse the lower 7 bits manually
    swapped_bits = 0
    for i in range(7):
        if (IR_opcode & (1 << i)) != 0:  # Check if the i-th bit is set
            swapped_bits |= (1 << (6 - i))  # Set the corresponding reversed bit

    # Clear the lower 7 bits in the original number and insert the swapped bits
    result = (features_int & ~0b1111111) | swapped_bits

    # Convert the result to a 16-bit binary string
    return f"{result:016b}"

########################################################################################################################################################

def update_progress_bar():
    global progress_bar_count
    global fifo_write_cycles

    progress_bar_count += 1
    progress_var.set((progress_bar_count / fifo_write_cycles) * 100)

    if (progress_bar_count >= fifo_write_cycles):
        progress_label.config(text=f"Data Upload: Done")
    else:
        progress_label.config(text=f"Data Upload: {round((progress_bar_count / fifo_write_cycles) * 100)}%")

########################################################################################################################################################

def reset_progress_bar():
    global progress_bar_count

    progress_bar_count = 0
    progress_var.set(0)

    progress_label.config(text=f"Data Upload: Idle")

########################################################################################################################################################

def progress_bar_count_subtract_one():
    global progress_bar_count

    progress_bar_count -= 1


def update_treeview(selection):

    global listbox_num_selected
    global no_faults_instruction_list
    global faults_instruction_list

    IR_str_temp = ""
    PC_str_temp = ""
    RS1_str_temp = ""
    MTVEC_str_temp = ""
    MEPC_str_temp = ""
    CPU_state_str_temp = ""

    treeview_data = []

    tree.delete(*tree.get_children())  # Clear the Treeview

    if selection == "No Faults" and listbox_num_selected != "None":
        if (len(no_faults_instruction_list) > 0):

            for i in range(len(no_faults_instruction_list[listbox_num_selected - 1])):

                buffer_list_temp = copy.deepcopy(no_faults_instruction_list[listbox_num_selected - 1][i])

                IR_str_temp = ""
                PC_str_temp = ""
                RS1_str_temp = ""
                MTVEC_str_temp = ""
                MEPC_str_temp = ""
                CPU_state_str_temp = ""

                for i in range(8):
                    IR_str_temp += buffer_list_temp[i + 4]

                for i in range(8):
                    PC_str_temp += buffer_list_temp[i + 17]

                for i in range(8):
                    RS1_str_temp += buffer_list_temp[i + 31]

                for i in range(8):
                    MTVEC_str_temp += buffer_list_temp[i + 47]

                for i in range(8):
                    MEPC_str_temp += buffer_list_temp[i + 62]

                CPU_state_str_temp = buffer_list_temp[93:]

                treeview_data.append(IR_str_temp)
                treeview_data.append(PC_str_temp)
                treeview_data.append(RS1_str_temp)
                treeview_data.append(MTVEC_str_temp)
                treeview_data.append(MEPC_str_temp)
                treeview_data.append(CPU_state_str_temp)

                tree.insert("", tk.END, values=treeview_data)  # add new rows

                treeview_data.clear()


    elif selection == "Faults" and listbox_num_selected != "None":
        if (len(faults_instruction_list) > 0):

            for i in range(len(faults_instruction_list[listbox_num_selected - 1])):

                buffer_list_temp = copy.deepcopy(faults_instruction_list[listbox_num_selected - 1][i])

                IR_str_temp = ""
                PC_str_temp = ""
                RS1_str_temp = ""
                MTVEC_str_temp = ""
                MEPC_str_temp = ""
                CPU_state_str_temp = ""

                for i in range(8):
                    IR_str_temp += buffer_list_temp[i + 4]

                for i in range(8):
                    PC_str_temp += buffer_list_temp[i + 17]

                for i in range(8):
                    RS1_str_temp += buffer_list_temp[i + 31]

                for i in range(8):
                    MTVEC_str_temp += buffer_list_temp[i + 47]

                for i in range(8):
                    MEPC_str_temp += buffer_list_temp[i + 62]

                CPU_state_str_temp = buffer_list_temp[93:]

                treeview_data.append(IR_str_temp)
                treeview_data.append(PC_str_temp)
                treeview_data.append(RS1_str_temp)
                treeview_data.append(MTVEC_str_temp)
                treeview_data.append(MEPC_str_temp)
                treeview_data.append(CPU_state_str_temp)

                tree.insert("", tk.END, values=treeview_data)  # Add new rows

                treeview_data.clear()

    else:
        treeview_data.clear()

########################################################################################################################################################

def clear_treeview():
    tree.delete(*tree.get_children())  # Clear the Treeview

########################################################################################################################################################

def clear_GUI():

    global no_faults_features_list
    global faults_features_list
    global neorv32_data_buffer_list
    global no_faults_instruction_list
    global faults_instruction_list

    selected_instruction_IR_label.config(text="IR: ")
    selected_instruction_IR_decoded_label.config(text="")
    features_label.config(text="Features: ")
    features_15_label.config(text="")
    features_14_label.config(text="")
    features_13_label.config(text="")
    features_12_label.config(text="")
    features_11_label.config(text="")
    features_10_label.config(text="")
    features_9_label.config(text="")
    features_8_label.config(text="")
    features_7_label.config(text="")
    features_opcode_label.config(text="")
    selected_instruction_PC_last_label.config(text="PC (last): ")
    selected_instruction_PC_correct_label.config(text="PC (correct): ")
    selected_instruction_PC_current_label.config(text="PC (current): ")
    SNN_response_label.config(text= "SNN Response...", fg="black")

    watchdog_instructions_monitored_label.config(text=f"Instructions Monitored:")
    watchdog_instructions_no_faults_monitored_label.config(text=f"With No Faults:")
    watchdog_instructions_faults_monitored_label.config(text=f"With Faults:")

    clear_treeview()

    clear_listbox()

    listbox_1.insert(0, 'None')

    clear_snn_spike_plot()


    no_faults_features_list.clear()
    faults_features_list.clear()
    neorv32_data_buffer_list.clear()
    no_faults_instruction_list.clear()
    faults_instruction_list.clear()


    # clear buffer treeview and listbox???
    progress_label.config(text=f"Data Upload: Idle")
    reset_progress_bar()

########################################################################################################################################################

def open_new_image_tab(img_sel):
    new_tab = tk.Toplevel(root)

    if (img_sel == "feature layer"):
        new_tab.title("Feature Layer")
        image_path = IMG_DIR / "Feature layer img.png"

    elif (img_sel == "snn"):
        new_tab.title("SNN")
        image_path = IMG_DIR / "snn 2.png"

    elif (img_sel == "neorv32"):
        new_tab.title("Neorv32")
        image_path = IMG_DIR / "neorv32.png"

    # load image from the repo folder
    large_image = Image.open(image_path)
    large_photo = ImageTk.PhotoImage(large_image)

    # create a Label in the new tab to display the image
    label = tk.Label(new_tab, image=large_photo)
    label.image = large_photo
    label.pack()

########################################################################################################################################################

def open_fifo_write_cycles_setup_tab():

    tab = tk.Toplevel(root)
    tab.title("Data FIFO Write Cycles Setup Tab")
    tab.geometry("240x140")

    tk.Label(tab, text="Min: 100  Max: 4000", font=("Helvetica", 10)).pack(pady=10)

    tk.Label(tab, text="FIFO Total Write Cycles").pack(pady=5)
    fifo_write_cycles_entry = tk.Entry(tab, width=20)
    fifo_write_cycles_entry.pack()

    def write_fifo_write_cycles_to_uB():

        entered_val = fifo_write_cycles_entry.get()

        if entered_val.isdigit():
            if ( (int(entered_val) >= 100) and (int(entered_val) <= 4000) ):
                send_uart_message(f"fifo_wr_cyc_{int(entered_val)}")
                tab.destroy()


    write_button = tk.Button(tab, text="Write", command=write_fifo_write_cycles_to_uB)
    write_button.pack(pady=10)



def decode_snn_spikes(spike_int_in, neuron_spikes_to_decode):

    global snn_spikes_buffer_list

    if (neuron_spikes_to_decode == "3"):
        for i in range(3):
            if (i == 0):
                neuron_spikes = f"{spike_int_in & 1023:010b}"
                swap_bits_str = swap_spike_bits(neuron_spikes)
                snn_spikes_buffer_list.append(swap_bits_str)
            elif (i == 1):
                neuron_spikes = f"{(spike_int_in >> 10) & 1023:010b}"
                swap_bits_str = swap_spike_bits(neuron_spikes)
                snn_spikes_buffer_list.append(swap_bits_str)
            elif (i == 2):
                neuron_spikes = f"{(spike_int_in >> 20) & 1023:010b}"
                swap_bits_str = swap_spike_bits(neuron_spikes)
                snn_spikes_buffer_list.append(swap_bits_str)

    elif (neuron_spikes_to_decode == "2"):
        for i in range(2):
            if (i == 0):
                neuron_spikes = f"{spike_int_in & 1023:010b}"
                swap_bits_str = swap_spike_bits(neuron_spikes)
                snn_spikes_buffer_list.append(swap_bits_str)
            elif (i == 1):
                neuron_spikes = f"{(spike_int_in >> 10) & 1023:010b}"
                swap_bits_str = swap_spike_bits(neuron_spikes)
                snn_spikes_buffer_list.append(swap_bits_str)

    elif (neuron_spikes_to_decode == "1"):
        neuron_spikes = f"{spike_int_in & 1023:010b}"
        swap_bits_str = swap_spike_bits(neuron_spikes)
        snn_spikes_buffer_list.append(swap_bits_str)

    return


def swap_spike_bits(bits_str_in):

    str_temp = ""
    bit_idx = 9

    for i in range(10):
        str_temp += bits_str_in[bit_idx]
        bit_idx -= 1

    return str_temp


def binary_strings_to_array(binary_strings):
    return np.array([[int(bit) for bit in neuron] for neuron in binary_strings])


def update_snn_spike_plot(in_data):
    global canvas

    num_input = 16
    num_hidden = 20
    num_output = 2

    input_data = in_data[:num_input]
    hidden_data = in_data[num_input:num_input + num_hidden]
    output_data = in_data[num_input + num_hidden:num_input + num_hidden + num_output]

    # Convert data to spike arrays
    input_spikes = binary_strings_to_array(input_data)
    hidden_spikes = binary_strings_to_array(hidden_data)
    output_spikes = binary_strings_to_array(output_data)

    # Helper function to plot spikes as a raster plot
    def plot_raster(spike_data, title, neuron_labels, ax=None):
        if ax is None:
            ax = plt.gca()
        for neuron_idx, spikes in enumerate(spike_data):
            spike_times = np.where(spikes == 1)[0]  # Find time indices with spikes
            ax.scatter(spike_times, neuron_idx * np.ones_like(spike_times),
                       marker='|', s=100, c="black")
        ax.set_yticks(range(len(neuron_labels)))
        ax.set_yticklabels(neuron_labels)
        ax.set_ylabel("Neuron Index")
        ax.set_title(title)
        ax.set_xlabel("Time Steps")
        ax.set_ylim(-1, len(spike_data))
        ax.grid(True, which='both', linestyle='--', linewidth=0.45)

        ax.set_xlim(-0.5, 9.5)
        ax.set_xticks(np.arange(0, 10, 1))  # Set ticks for each time step

    # Generate labels for neurons
    input_labels = ["IR Opcode Bit 6", "IR Opcode Bit 5", "IR Opcode Bit 4", "IR Opcode Bit 3", "IR Opcode Bit 2", "IR Opcode Bit 1", "IR Opcode Bit 0",
                    "CPU Branched State", "CPU Trap Enter State", "CPU Trap Exit State", "PC Increment", "Branch Valid", "JAL Valid", "JALR Valid",
                    "Trap Enter Valid", "Trap Exit Valid"]
    hidden_labels = [f"Neuron {i}" for i in range(num_hidden)]
    output_labels = ["No Fault (Neuron 0)", "Fault (Neuron 1)"]

    # Set predefined plot sizes and ratios
    height_ratios = [2.2, 2.3, 0.8]  # Adjust these ratios for layer sizes
    figsize = (8.3, 7)  # Figure size

    # Create a combined raster plot with different subplot heights
    fig, axs = plt.subplots(3, 1, figsize=figsize, sharex=True, gridspec_kw={'height_ratios': height_ratios})  # Adjust these ratios for layer sizes

    # Plot each layer
    plot_raster(input_spikes, "Input Spikes", input_labels, ax=axs[0])
    plot_raster(hidden_spikes, "Hidden Spikes", hidden_labels, ax=axs[1])
    plot_raster(output_spikes, "Output Spikes", output_labels, ax=axs[2])

    # Adjust layout and display the plot
    plt.tight_layout()

    # Destroy the previous canvas and add the updated one
    canvas.get_tk_widget().destroy()  # Remove the old canvas
    canvas = FigureCanvasTkAgg(fig, master=right_frame)  # Create new canvas
    canvas_widget = canvas.get_tk_widget()
    canvas_widget.place(x=2, y=2, width=879, height=743)  # Position the canvas
    canvas.draw()


def spike_plot_button_press():

    global listbox_num_selected
    global dropdown_selected
    global snn_spikes_no_faults_list
    global snn_spikes_faults_list

    if (dropdown_selected == "No Faults" and listbox_num_selected != "None"):
        if (len(snn_spikes_no_faults_list[listbox_num_selected-1]) > 0):
            spikes_copy = copy.deepcopy(snn_spikes_no_faults_list[listbox_num_selected - 1])
            update_snn_spike_plot(spikes_copy)

    elif (dropdown_selected == "Faults" and listbox_num_selected != "None"):
        if (len(snn_spikes_faults_list[listbox_num_selected - 1]) > 0):
            spikes_copy = copy.deepcopy(snn_spikes_faults_list[listbox_num_selected - 1])
            update_snn_spike_plot(spikes_copy)


# Creating the main window
root = tk.Tk()
root.title("ISCAS 2025 Live Demo - SNN-Based Smart Watchdog Monitor for RISC-V CPU")
root.geometry("1900x850")
root.config(bg="#2c3e50", background='lightgrey')
root.state('zoomed')  # Maximize to full screen

line_canvas = tk.Canvas(root, width=1900, height=850, bg="lightgrey", highlightthickness=0)
line_canvas.place(x=0, y=0)

line_canvas.create_line(800, 0, 800, 204, fill="black", width=7)
line_canvas.create_line(0, 200, 1900, 200, fill="black", width=7)

motor_control_panel_label = tk.Label(root, text="MOTOR CONTROL", font=("Helvetica", 24, "bold"), bg="lightgrey",
                                     fg="black")
motor_control_panel_label.place(x=250, y=0)

start_button = tk.Button(root, text="START", font=("Helvetica", 12, "bold"), bg="green", fg="black", width=6, height=2)
start_button.place(x=20, y=40)
start_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "motor_start"))
start_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "motor_start"))

stop_button = tk.Button(root, text="STOP", font=("Helvetica", 12, "bold"), bg="red", fg="black", width=6, height=2)
stop_button.place(x=100, y=40)
stop_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "motor_stop"))
stop_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "motor_stop"))

motor_run_status_label = tk.Label(root, text="Motor Running: ", font=("Helvetica", 14, "bold"), bg="lightgrey",
                                  fg="black")
motor_run_status_label.place(x=178, y=53)

motor_running_led_canvas = tk.Canvas(root, width=30, height=30, bg="#2c3e50", highlightthickness=0)
motor_running_led_canvas.place(x=330, y=52)
motor_running_led = motor_running_led_canvas.create_oval(5, 5, 25, 25, fill="lightgrey", outline="black")

change_direction_button = tk.Button(root, text="CHANGE DIRECTION", font=("Helvetica", 12, "bold"), bg="lightblue",
                                    fg="black", width=18, height=2)
change_direction_button.place(x=20, y=115)
change_direction_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "motor_dir"))
change_direction_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "motor_dir"))

forward_direction_label = tk.Label(root, text="Forward: ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
forward_direction_label.place(x=232, y=110)

forward_direction_led_canvas = tk.Canvas(root, width=30, height=30, bg="#2c3e50", highlightthickness=0)
forward_direction_led_canvas.place(x=330, y=110)
forward_direction_led = forward_direction_led_canvas.create_oval(5, 5, 25, 25, fill="lightgrey", outline="black")

reverse_direction_label = tk.Label(root, text="Reverse: ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
reverse_direction_label.place(x=230, y=145)

reverse_direction_led_canvas = tk.Canvas(root, width=30, height=30, bg="#2c3e50", highlightthickness=0)
reverse_direction_led_canvas.place(x=330, y=145)
reverse_direction_led = reverse_direction_led_canvas.create_oval(5, 5, 25, 25, fill="lightgrey", outline="black")

increase_speed_button = tk.Button(root, text="SETPOINT +", font=("Helvetica", 12, "bold"), bg="lightblue", fg="black",
                                  width=12, height=2)
increase_speed_button.place(x=375, y=50)
increase_speed_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "motor_speed_inc"))
increase_speed_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "motor_speed_inc"))

decrease_speed_button = tk.Button(root, text="SETPOINT -", font=("Helvetica", 12, "bold"), bg="lightblue", fg="black",
                                  width=12, height=2)
decrease_speed_button.place(x=375, y=120)
decrease_speed_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "motor_speed_dec"))
decrease_speed_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "motor_speed_dec"))

motor_setpoint_label = tk.Label(root, text="Motor Setpoint (RPM):", font=("Helvetica", 14, "bold"), bg="lightgrey",
                                fg="black")
motor_setpoint_label.place(x=517, y=45, width=200, height=30)

motor_setpoint_entry = tk.Entry(root, font=("Helvetica", 12), width=7)
motor_setpoint_entry.place(x=725, y=45, width=60, height=30)

motor_setpoint_button = tk.Button(root, text="Enter", font=("Helvetica", 12, "bold"), bg="grey", fg="black", width=5, height=1)
motor_setpoint_button.place(x=625, y=80)
motor_setpoint_button.bind("<ButtonPress>", lambda event: send_setpoint_uart_on_button_press())
motor_setpoint_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "motor_setpoint_conf"))

motor_setpoint_warning_label = tk.Label(root, text="", font=("Helvetica", 13), bg="lightgrey", fg="red")
motor_setpoint_warning_label.place(x=550, y=15, width=220, height=30)

motor_setpoint_value_label = tk.Label(root, text="Motor Setpoint: 0 RPM", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
motor_setpoint_value_label.place(x=505, y=130, width=280, height=28)

motor_actual_value_label = tk.Label(root, text="Motor Actual: 0 RPM", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
motor_actual_value_label.place(x=505, y=160, width=280, height=28)

fault_control_label = tk.Label(root, text="FAULT CONTROL", font=("Helvetica", 24, "bold"), bg="lightgrey", fg="black")
fault_control_label.place(x=1225, y=0)

program_counter_bits_label = tk.Label(root, text="Program Counter Bits Fault Setup", font=("Helvetica", 17, "bold"),
                                      bg="lightgrey", fg="black")
program_counter_bits_label.place(x=1100, y=69, width=380, height=30)

clear_all_faults_button = tk.Button(root, text="CLEAR ALL FAULT SETUPS", font=("Helvetica", 12, "bold"), bg="orange",
                                    fg="black", width=25, height=2)
clear_all_faults_button.place(x=825, y=5)
clear_all_faults_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "flts_clr_all"))
clear_all_faults_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "flts_clr_all"))

pc_bit_10_label = tk.Label(root, text="Bit 10", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_10_label.place(x=815, y=100, width=100, height=30)

pc_bit_10_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_10_button.place(x=815, y=135)
pc_bit_10_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_10"))
pc_bit_10_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_10"))

pc_bit_9_label = tk.Label(root, text="Bit 9", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_9_label.place(x=905, y=100, width=100, height=30)

pc_bit_9_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_9_button.place(x=905, y=135)
pc_bit_9_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_9"))
pc_bit_9_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_9"))

pc_bit_8_label = tk.Label(root, text="Bit 8", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_8_label.place(x=995, y=100, width=100, height=30)

pc_bit_8_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_8_button.place(x=995, y=135)
pc_bit_8_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_8"))
pc_bit_8_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_8"))

pc_bit_7_label = tk.Label(root, text="Bit 7", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_7_label.place(x=1085, y=100, width=100, height=30)

pc_bit_7_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_7_button.place(x=1085, y=135)
pc_bit_7_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_7"))
pc_bit_7_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_7"))

pc_bit_6_label = tk.Label(root, text="Bit 6", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_6_label.place(x=1175, y=100, width=100, height=30)

pc_bit_6_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_6_button.place(x=1175, y=135)
pc_bit_6_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_6"))
pc_bit_6_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_6"))

pc_bit_5_label = tk.Label(root, text="Bit 5", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_5_label.place(x=1265, y=100, width=100, height=30)

pc_bit_5_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_5_button.place(x=1265, y=135)
pc_bit_5_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_5"))
pc_bit_5_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_5"))

pc_bit_4_label = tk.Label(root, text="Bit 4", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_4_label.place(x=1355, y=100, width=100, height=30)

pc_bit_4_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_4_button.place(x=1355, y=135)
pc_bit_4_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_4"))
pc_bit_4_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_4"))

pc_bit_3_label = tk.Label(root, text="Bit 3", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_3_label.place(x=1445, y=100, width=100, height=30)

pc_bit_3_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_3_button.place(x=1445, y=135)
pc_bit_3_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_3"))
pc_bit_3_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_3"))

pc_bit_2_label = tk.Label(root, text="Bit 2", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_2_label.place(x=1535, y=100, width=100, height=30)

pc_bit_2_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_2_button.place(x=1535, y=135)
pc_bit_2_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_2"))
pc_bit_2_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_2"))

pc_bit_1_label = tk.Label(root, text="Bit 1", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
pc_bit_1_label.place(x=1625, y=100, width=90, height=30)

pc_bit_1_button = tk.Button(root, text="", font=("Helvetica", 12, "bold"), bg="lightgrey", fg="black", width=8, height=2)
pc_bit_1_button.place(x=1625, y=135)
pc_bit_1_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "pc_bit_1"))
pc_bit_1_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "pc_bit_1"))

inject_faults_button = tk.Button(root, text="INJECT FAULTS", font=("Helvetica", 12, "bold"), bg="orange", fg="black",
                                 width=13, height=2)
inject_faults_button.place(x=1750, y=69)
inject_faults_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "flts_inj"))
inject_faults_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "flts_inj"))

clear_faults_button = tk.Button(root, text="CLEAR FAULTS", font=("Helvetica", 12, "bold"), bg="orange", fg="black",
                                width=13, height=2)
clear_faults_button.place(x=1750, y=130)
clear_faults_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "flts_clr"))
clear_faults_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "flts_clr"))

faults_active_label = tk.Label(root, text="Faults Active:", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
faults_active_label.place(x=1725, y=20, width=140, height=30)

faults_active_led_canvas = tk.Canvas(root, width=30, height=30, bg="#2c3e50", highlightthickness=0)
faults_active_led_canvas.place(x=1865, y=20)
faults_active_led = faults_active_led_canvas.create_oval(5, 5, 25, 25, fill="lightgrey", outline="black")

watchdog_monitoring_label = tk.Label(root, text="SMART WATCHDOG MONITORING", font=("Helvetica", 24, "bold"),
                                     bg="lightgrey", fg="black")
watchdog_monitoring_label.place(x=620, y=205)

neorv32_reset_button = tk.Button(root, text="RISC-V Reset", font=("Helvetica", 12, "bold"), bg="grey", fg="black", width=11, height=2)
neorv32_reset_button.place(x=10, y=210)
neorv32_reset_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "nv32_rst"))
neorv32_reset_button.bind("<ButtonRelease>", lambda event: send_uart_on_button_release(event, "nv32_rst"))

neorv32_reset_label = tk.Label(root, text="RISC-V Reset:", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
neorv32_reset_label.place(x=131, y=220, width=150, height=30)

neorv32_reset_led_canvas = tk.Canvas(root, width=30, height=30, bg="#2c3e50", highlightthickness=0)
neorv32_reset_led_canvas.place(x=275, y=220)
neorv32_reset_led = neorv32_reset_led_canvas.create_oval(5, 5, 25, 25, fill="lightgrey", outline="black")

clear_gui_button = tk.Button(root, text="Clear GUI", font=("Helvetica", 12, "bold"), bg="white", fg="black", width=11, height=2)
clear_gui_button.place(x=400, y=210)
clear_gui_button.bind("<ButtonPress>", lambda event: clear_GUI())

watchdog_status_label = tk.Label(root, text="Watchdog Enabled:", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
watchdog_status_label.place(x=440, y=380, width=190, height=30)

watchdog_status_led_canvas = tk.Canvas(root, width=30, height=30, bg="#2c3e50", highlightthickness=0)
watchdog_status_led_canvas.place(x=630, y=380)
watchdog_status_led = watchdog_status_led_canvas.create_oval(5, 5, 25, 25, fill="lightgrey", outline="black")

snn_view_button = tk.Button(root, text="View", font=("Helvetica", 10, "bold"), bg="blue", fg="white", width=4, height=1)
snn_view_button.place(x=583, y=710)
snn_view_button.bind("<ButtonPress>", lambda event: open_new_image_tab("snn"))

neorv32_view_button = tk.Button(root, text="View", font=("Helvetica", 10, "bold"), bg="red", fg="white", width=4, height=1)
neorv32_view_button.place(x=40, y=710)
neorv32_view_button.bind("<ButtonPress>", lambda event: open_new_image_tab("neorv32"))

fifo_write_num_setup_button = tk.Button(root, text="Setup", font=("Helvetica", 10, "bold"), bg="orange", fg="white", width=5, height=1)
fifo_write_num_setup_button.place(x=166, y=710)
fifo_write_num_setup_button.bind("<ButtonPress>", lambda event: open_fifo_write_cycles_setup_tab())

image_label_2 = tk.Label(root)
image_label_2.place(x=11, y=415)

img_2 = tk.PhotoImage(file=IMG_DIR / "watchdog img.png")
image_label_2.config(image=img_2)

feature_layer_view_button = tk.Button(root, text="View", font=("Helvetica", 10, "bold"), bg="green", fg="white", width=4, height=1)
feature_layer_view_button.place(x=398, y=710)
feature_layer_view_button.bind("<ButtonPress>", lambda event: open_new_image_tab("feature layer"))

image_label_3 = tk.Label(root)
image_label_3.place(x=420, y=795)

img_3 = tk.PhotoImage(file=IMG_DIR / "features img.png")
image_label_3.config(image=img_3)

features_label = tk.Label(root, text="Features", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
features_label.place(x=550, y=765, width=400, height=30)

features_15_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_15_label.place(x=535, y=826)
features_14_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_14_label.place(x=535+29, y=826)
features_13_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_13_label.place(x=535+55, y=826)
features_12_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_12_label.place(x=535+84, y=826)
features_11_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_11_label.place(x=535+112, y=826)
features_10_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_10_label.place(x=535+141, y=826)
features_9_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_9_label.place(x=535+169, y=826)
features_8_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_8_label.place(x=535+196, y=826)
features_7_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_7_label.place(x=535+224, y=826)
features_opcode_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
features_opcode_label.place(x=535+255, y=826)

# system_error_label = tk.Label(root, text="System Error:", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
# system_error_label.place(x=50, y=750, width=150, height=30)

# system_error_led_canvas = tk.Canvas(root, width=30, height=30, bg="#2c3e50", highlightthickness=0)
# system_error_led_canvas.place(x=210, y=750)
# system_error_led = system_error_led_canvas.create_oval(5, 5, 25, 25, fill="lightgrey", outline="black")

instruction_info_enable_button = tk.Button(root, text="Instruction Info Disabled", font=("Helvetica", 12, "bold"), bg="white", fg="black", width=19, height=2)
instruction_info_enable_button.place(x=45, y=315)
instruction_info_enable_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "instr_info_en"))

progress_label = tk.Label(root, text="Data Upload: Idle", font=("Helvetica", 12), bg="lightgrey", fg="black")
progress_label.place(x=345, y=310)

progress_var = tk.IntVar()
progress_bar = ttk.Progressbar(root, orient="horizontal", length=200, mode="determinate", variable=progress_var)
progress_bar.place(x=315, y=330)

fifo_write_cycles_label = tk.Label(root, text="FIFO Write Cycles: ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
fifo_write_cycles_label.place(x=60, y=385, width=280, height=30)

watchdog_instructions_monitored_label = tk.Label(root, text="Total Instructions Monitored: ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
watchdog_instructions_monitored_label.place(x=600, y=250, width=320, height=30)

watchdog_instructions_no_faults_monitored_label = tk.Label(root, text="With No Faults: ",
                                                           font=("Helvetica", 14, "bold"), bg="lightgrey", fg="green", anchor=tk.W)
watchdog_instructions_no_faults_monitored_label.place(x=600, y=285, width=280, height=30)

watchdog_instructions_faults_monitored_label = tk.Label(root, text="With Faults: ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="red", anchor=tk.W)
watchdog_instructions_faults_monitored_label.place(x=600, y=320, width=280, height=30)

watchdog_instructions_breakdown_label = tk.Label(root, text="Instruction Analysis",
                                                 font=("Helvetica", 16, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
watchdog_instructions_breakdown_label.place(x=762, y=360, width=340, height=30)

no_faults_faults_dropdown_default_option = tk.StringVar(value="No Faults")
no_faults_faults_dropdown = tk.OptionMenu(root, no_faults_faults_dropdown_default_option, "No Faults", "Faults",command=update_listbox)
no_faults_faults_dropdown.place(x=765, y=410)

# instruction select listbox with scrollbar
frame_1 = tk.Frame(root)
frame_1.place(x=893, y=395)

scrollbar_1 = tk.Scrollbar(frame_1, orient='vertical')
listbox_1 = tk.Listbox(frame_1, height=4, width=8, yscrollcommand=scrollbar_1.set)
listbox_1.pack(side='left', fill='y')

scrollbar_1.config(command=listbox_1.yview)
scrollbar_1.pack(side='right', fill='y')

update_listbox("No Faults")
listbox_1.bind('<<ListboxSelect>>', select_item)

neorv32_raw_data_treeview_label = tk.Label(root, text="Neorv32 FIFO Instruction Buffer", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
neorv32_raw_data_treeview_label.place(x=50, y=755)

frame_2 = tk.Frame(root)
frame_2.place(x=8, y=782)

tree = ttk.Treeview(frame_2, columns=("Column1", "Column2", "Column3", "Column4", "Column5", "Column6",), show="headings", height=10)
tree.pack(side="left")

tree.heading("Column1", text="IR")
tree.heading("Column2", text="PC")
tree.heading("Column3", text="RS1")
tree.heading("Column4", text="MTVEC")
tree.heading("Column5", text="MEPC")
tree.heading("Column6", text="CPU States")

tree.column("Column1", width=60, anchor="center")
tree.column("Column2", width=60, anchor="center")
tree.column("Column3", width=60, anchor="center")
tree.column("Column4", width=60, anchor="center")
tree.column("Column5", width=60, anchor="center")
tree.column("Column6", width=79, anchor="center")

scrollbar2 = ttk.Scrollbar(frame_2, orient="vertical", command=tree.yview)
tree.configure(yscrollcommand=scrollbar2.set)
scrollbar2.pack(side="right", fill="y")

selected_instruction_IR_label = tk.Label(root, text="IR: ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
selected_instruction_IR_label.place(x=790, y=470, width=350, height=30)

selected_instruction_IR_decoded_label = tk.Label(root, text="", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
selected_instruction_IR_decoded_label.place(x=790, y=505, width=350, height=30)

selected_instruction_PC_last_label = tk.Label(root, text="PC (last): ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
selected_instruction_PC_last_label.place(x=760, y=535, width=300, height=30)

selected_instruction_PC_correct_label = tk.Label(root, text="PC (correct): ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
selected_instruction_PC_correct_label.place(x=760, y=565, width=300, height=30)

selected_instruction_PC_current_label = tk.Label(root, text="PC (current): ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
selected_instruction_PC_current_label.place(x=760, y=595, width=300, height=30)

SNN_response_label = tk.Label(root, text="SNN Response...", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black", anchor=tk.W)
SNN_response_label.place(x=770, y=640, width=300, height=30)

trap_triggered_by_exception_label = tk.Label(root, text="RISC-V Trap(s) Triggered: ", font=("Helvetica", 14, "bold"), bg="lightgrey", fg="black")
trap_triggered_by_exception_label.place(x=10, y=270, width=250, height=30)

trap_triggered_by_exception_led_canvas = tk.Canvas(root, width=30, height=30, bg="#2c3e50", highlightthickness=0)
trap_triggered_by_exception_led_canvas.place(x=257, y=270)
trap_triggered_by_exception_led = trap_triggered_by_exception_led_canvas.create_oval(5, 5, 25, 25, fill="lightgrey", outline="black")

spike_plot_enable_button = tk.Button(root, text="SNN Spike Plot Disabled", font=("Helvetica", 12, "bold"), bg="white", fg="black", width=20, height=2)
spike_plot_enable_button.place(x=1400, y=210)
spike_plot_enable_button.bind("<ButtonPress>", lambda event: send_uart_on_button_press(event, "spike_plt_en"))

spike_plot_button = tk.Button(root, text="Plot", font=("Helvetica", 12, "bold"), bg="white", fg="black", width=4, height=1)
spike_plot_button.place(x=1700, y=220)
spike_plot_button.bind("<ButtonPress>", lambda event: spike_plot_button_press())

right_frame = tk.Frame(root, width=885, height=750, bg="light grey")
right_frame.place(x=1025, y=263)


def clear_snn_spike_plot():
    global canvas

    if canvas is not None:
        canvas.get_tk_widget().destroy()

    create_blank_snn_spike_plot()


def create_blank_snn_spike_plot():

    num_input = 16
    num_hidden = 20
    num_output = 2
    num_timesteps = 10

    spike_data_input = np.zeros((num_input, num_timesteps))
    spike_data_hidden = np.zeros((num_hidden, num_timesteps))
    spike_data_output = np.zeros((num_output, num_timesteps))

    fig, axs = plt.subplots(3, 1, figsize=(8, 7), sharex=True, gridspec_kw={'height_ratios': [2.2, 2.3, 0.8]})

    # Helper function to plot spikes as a raster plot
    def plot_raster(spike_data, title, neuron_labels, ax):
        for neuron_idx, spikes in enumerate(spike_data):
            spike_times = np.where(spikes == 1)[0]  # Find time indices with spikes
            ax.scatter(spike_times, neuron_idx * np.ones_like(spike_times), marker='|', s=100, c="black")
        ax.set_yticks(range(len(neuron_labels)))
        ax.set_yticklabels(neuron_labels)
        ax.set_ylabel("Neuron Index")
        ax.set_title(title)
        ax.set_xlabel("Time Steps")
        ax.set_ylim(-1, len(spike_data))
        ax.grid(True, which='both', linestyle='--', linewidth=0.45)

        ax.set_xlim(-0.5, 9.5)
        ax.set_xticks(np.arange(0, 10, 1))  # Set ticks for each time step

    # Labels for neurons
    input_labels = ["IR Opcode Bit 6", "IR Opcode Bit 5", "IR Opcode Bit 4", "IR Opcode Bit 3", "IR Opcode Bit 2", "IR Opcode Bit 1", "IR Opcode Bit 0",
                    "CPU Branched State", "CPU Trap Enter State", "CPU Trap Exit State", "PC Increment", "Branch Valid", "JAL Valid", "JALR Valid",
                    "Trap Enter Valid", "Trap Exit Valid"]
    hidden_labels = [f"Neuron {i}" for i in range(num_hidden)]
    output_labels = ["No Fault (Neuron 0)", "Fault (Neuron 1)"]

    # Plot each layer with blank data
    plot_raster(spike_data_input, "Input Spikes", input_labels, axs[0])
    plot_raster(spike_data_hidden, "Hidden Spikes", hidden_labels, axs[1])
    plot_raster(spike_data_output, "Output Spikes", output_labels, axs[2])

    # Adjust layout and embed the figure into the Tkinter window
    plt.tight_layout()

    global canvas  # Declare canvas as global to access it in other functions
    canvas = FigureCanvasTkAgg(fig, master=right_frame)
    canvas_widget = canvas.get_tk_widget()
    canvas_widget.place(x=2, y=2, width=879, height=743)  # Position the canvas
    canvas.draw()


create_blank_snn_spike_plot()

###############

# run UART in another thread
def start_uart_thread():
    uart_thread = threading.Thread(target=read_uart_messages, daemon=True)
    uart_thread.start()

# initialize UART and run thread after the window is loaded
def on_window_open():
    init_uart()
    start_uart_thread()

root.after(100, on_window_open)  # Call the UART setup after the window opens

# start Tkinter event loop
root.mainloop()

