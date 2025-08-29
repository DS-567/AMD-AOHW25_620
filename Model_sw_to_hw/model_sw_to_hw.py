########################################################################################################################################################
### CODE DESCRIPTION ###

# this code loads the SNN model and writes all information to text files at the specified directory (top write path).
# Vivado reads these text files and initialises the SNN with the parameters.

# text files created:

#   neuron threshold
#   neuron biases
#   neuron weights

########################################################################################################################################################
### LIBRARY IMPORTS ###

import math
from pathlib import Path
import torch
import torch.nn as nn
import snntorch as snn
import os
import shutil
import sys
import json

########################################################################################################################################################
### SNN JSON PARAMETERS ###

# directory of script
BASE_DIR = Path(__file__).resolve().parent
MODEL_LOAD_PATH  = BASE_DIR / "smart_watchdog_snn_model.pth"
SNN_JSON_DIR  = BASE_DIR / "SNN_config.json"

# Load config.json
with open(SNN_JSON_DIR) as f:
    config = json.load(f)

num_whole_bits = config["num_whole_bits"]
num_fractional_bits = config["num_fractional_bits"]

num_inputs = config["num_inputs"]
num_hidden = config["num_hidden"]
num_outputs = config["num_outputs"]

beta = config["beta"]
threshold = config["threshold"]
reset_mechanism = config["reset_mechanism"]

bias_text = config["bias"]

if (bias_text == "enabled"):
    bias = True
elif (bias_text == "disabled"):
    bias = False
else:
    print("Incorrect bias parameter - must be either enabled or disabled!")
    sys.exit(0)
    
########################################################################################################################################################
### FUNCTION DECLARATIONS ###

# this function returns True if the input parameter is a whole number, else False

def is_whole(n):
    return n % 1 == 0

########################################################################################################################################################

# this function takes an number as input parameter a number of bits input and returns a binary string of the whole part

def convert_whole_part(whole_part, total_len):
    # local string buffer varibles
    str_temp = ''
    padded_str_temp = ''

    # get the integer and fractional parts of the input number
    frac_part, int_part = math.modf(whole_part)

    div_result = int_part / 2

    if (not is_whole(div_result)):
        str_temp = '1' + str_temp
    else:
        str_temp = '0' + str_temp
    while (div_result != 0):
        _, div_result = math.modf(div_result)
        div_result = div_result / 2
        if (not is_whole(div_result)):
            str_temp = '1' + str_temp
        else:
            str_temp = '0' + str_temp
    padded_str_temp = pad_start_with_zeros(total_len, str_temp)
    return padded_str_temp

########################################################################################################################################################

# this function takes an number as input parameter a number of bits input and returns a binary string of the fractional part

def convert_fractional_part(fractional_part, total_len):
    # local string buffer varibles
    str_temp = ''
    padded_str_temp = ''

    # get the integer and fractional parts of the input number
    frac_part, int_part = math.modf(fractional_part)
    bit_counter = 0
    while (1):
        mult_result = frac_part * 2
        frac_part, int_part = math.modf(mult_result)
        if (int_part == 0):
            str_temp = str_temp + '0'
        else:
            str_temp = str_temp + '1'
        if (mult_result == 0):
            break
        bit_counter += 1
        if (bit_counter == num_fractional_bits):
            break
    padded_str_temp = pad_end_with_zeros(total_len, str_temp)
    return padded_str_temp

########################################################################################################################################################

# this function pads the start of the input string (str) with zeros to reach the length specified in the other input parameter (desired_str_len)

def pad_start_with_zeros(desired_str_len, str):
    # local copy of string
    str_temp = str

    # if input string length is less than desired
    if (len(str_temp) < desired_str_len):
        # find out how short
        loop_num = desired_str_len - len(str)
        # loop through number of times
        for i in range(loop_num):
            # add zeros to start
            str_temp = '0' + str_temp
    return str_temp

########################################################################################################################################################

# this function pads the end of the input string (str) with zeros to reach the length specified in the other input parameter (desired_str_len)

def pad_end_with_zeros(desired_str_len, str):
    # local copy of string
    str_temp = str

    # if input string length is less than desired
    if (len(str_temp) < desired_str_len):
        # find out how short
        loop_num = desired_str_len - len(str)
        # loop through number of times
        for i in range(loop_num):
            # add zeros to end
            str_temp = str_temp + '0'
    return str_temp

########################################################################################################################################################

# this function creates / opens a file and writes a single string to it

def write_single_parameter_to_file(path, converted_parameter):

    # check if file exists
    file = Path(path)
    if file.is_file():
        # if exists, open
        f = open(path, "w")
    else:
        # if not existing, create
        f = open(path, "x")

    # write string to file
    f.write(converted_parameter)

    # close file
    f.close()
    return

########################################################################################################################################################

# this function creates / opens a file and writes a list of strings to it

def write_parameter_list_to_file(path, converted_parameter_list):

    # check if file exists
    file = Path(path)
    if file.is_file():
        # if exists, open
        f = open(path, "w")
    else:
        # if not existing, create
        f = open(path, "x")

    # loop through the list
    for i in range(len(converted_parameter_list)):
        # write string to file
        f.write(converted_parameter_list[i])
        f.write("\n")

    # close file
    f.close()
    return

########################################################################################################################################################

def twos_complement_fixed_point(binary_str):

    if (len(binary_str) != 24):
        print("Binary string must be 24 bits long")

    # convert binary string to integer
    int_value = int(binary_str, 2)

    # check if the value is negative
    if binary_str[0] == '1':  # if MSB is 1
        int_value -= 2 ** 24  # adjust for two's complement

    # two's complement value as integer
    twos_complement_value = -int_value

    # convert back to binary string
    if twos_complement_value < 0:
        twos_complement_value += 2 ** 24  # adjust back for negative value

    # convert the integer back to a binary string with 24 bits
    binary_result = format(twos_complement_value, '024b')

    return binary_result

########################################################################################################################################################
### MODEL INITILISATION ###

# network is not stimulated (used) in this script other than to allow loading the model using torch.load(file_path)
# this allows the weights and biases to be accessed for the loaded model!

# define SNN model
class Net(nn.Module):
    def __init__(self):
        super().__init__()

        # initialize all layers
        self.fc_hid = nn.Linear(num_inputs, num_hidden, bias=bias)
        self.lif_hid = snn.Leaky(beta=beta, threshold=threshold, reset_mechanism=reset_mechanism)
        self.fc_out = nn.Linear(num_hidden, num_outputs, bias=bias)
        self.lif_out = snn.Leaky(beta=beta, threshold=threshold, reset_mechanism=reset_mechanism)

    # define forward pass
    def forward(self, x):

        # initialize all lif states at t=0
        lif_hid_mem = self.lif_hid.init_leaky()
        lif_out_mem = self.lif_out.init_leaky()

        # record all the lif neurons in network
        lif_hid_spk_rec = []
        lif_hid_mem_rec = []
        lif_out_spk_rec = []
        lif_out_mem_rec = []

        # stimulate network with input spikes
        for step in range(num_steps):
            spk_to_hid = self.fc_hid(x[step])
            lif_hid_spk, lif_hid_mem = self.lif_hid(spk_to_hid, lif_hid_mem)

            spk_to_out = self.fc_out(lif_hid_spk)
            lif_out_spk, lif_out_mem = self.lif_out(spk_to_out, lif_out_mem)

            lif_hid_spk_rec.append(lif_hid_spk)
            lif_hid_mem_rec.append(lif_hid_mem)
            lif_out_spk_rec.append(lif_out_spk)
            lif_out_mem_rec.append(lif_out_mem)

        # return all LIF neuron internal states
        return torch.stack(lif_hid_spk_rec, dim=0), torch.stack(lif_hid_mem_rec, dim=0), torch.stack(lif_out_spk_rec, dim=0), torch.stack(lif_out_mem_rec, dim=0)

# device configuration
device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")

# sent model to device
net = Net().to(device)

# load model parameters
net.load_state_dict(torch.load(MODEL_LOAD_PATH))

# get hidden and output layer biases and weights as lists
hidden_biases_list = net.fc_hid.bias.tolist()
hidden_weights_list = net.fc_hid.weight.tolist()
output_biases_list = net.fc_out.bias.tolist()
output_weights_list = net.fc_out.weight.tolist()

# round hidden layer biases to 4 decimal places
for i in range(len(hidden_biases_list)):
    hidden_biases_list[i] = round(hidden_biases_list[i], 4)

# round hidden layer weights to 4 decimal places
for i in range(len(hidden_weights_list)):
    for j in range(len(hidden_weights_list[i])):
        hidden_weights_list[i][j] = round(hidden_weights_list[i][j], 4)

# round output layer biases to 4 decimal places
for i in range(len(output_biases_list)):
    output_biases_list[i] = round(output_biases_list[i], 4)

# round output layer weights to 4 decimal places
for i in range(len(output_weights_list)):
    for j in range(len(output_weights_list[i])):
        output_weights_list[i][j] = round(output_weights_list[i][j], 4)

########################################################################################################################################################
### CREATE TOP FOLDER ###

# path for writing text files to
top_write_path = BASE_DIR / "setup text files"

# remove folder if exists
if top_write_path.exists() and top_write_path.is_dir():
    shutil.rmtree(top_write_path)

# createfolder
top_write_path.mkdir(parents=True, exist_ok=True)

########################################################################################################################################################
### DECLARE VARIABLES ###

# temporary string variables
sign_MSB = ''
whole_str = ''
fractional_str = ''
converted_str = ''

# list to buffer the converted weights for each neuron before writing to file
converted_parameter_buffer = []

########################################################################################################################################################
### WRITE THRESHOLD TO FILE ###

# convert whole part of threshold to binary string
whole_str = convert_whole_part(threshold, num_whole_bits)

# convert fractional part of threshold to binary string
fractional_str = convert_fractional_part(threshold, num_fractional_bits)

# join whole and fractional binary strings
# (don't need to add an extra zero at front of threshold string this time!)
converted_str = whole_str + fractional_str

# threshold text file write path
file_path = top_write_path / "threshold.txt"

# write threshold to text file
write_single_parameter_to_file(file_path, converted_str)

########################################################################################################################################################
### WRITE BIASES TO FILE ###

# write hidden layer biases to text file (hidden layer is called layer 1 on FPGA!)

# hidden layer file path extension string
file_path_extension = "layer 1 biases"

# create folder at file path extension
directory_temp = top_write_path / file_path_extension
if not os.path.exists(directory_temp):
    os.makedirs(directory_temp)

# loop through each bias in the list
for i in range(len(hidden_biases_list)):

    # check if positive or negative
    if (float(hidden_biases_list[i]) >= 0.):
        # positive
        sign_MSB = '0'
    else:
        # negative, set sign bit
        sign_MSB = '1'

    # convert whole part of bias to binary string
    whole_str = convert_whole_part(hidden_biases_list[i], num_whole_bits)

    # convert fractional part of bias to binary string
    fractional_str = convert_fractional_part(hidden_biases_list[i], num_fractional_bits)

    # join whole and fractional binary strings
    converted_str = whole_str + fractional_str

    # check if sign bit is 1 (negative value)
    if (sign_MSB == '1'):
        converted_str = twos_complement_fixed_point(converted_str)

    str_index = "neuron " + str(i) + ".txt"

    # neuron bias text file write path
    file_path = top_write_path / file_path_extension / str_index

    # write neuron bias to text file
    write_single_parameter_to_file(file_path, converted_str)


# write output layer biases to text file (output layer is called layer 2 on FPGA!)

# output layer file path extension string
file_path_extension = "layer 2 biases"

# create folder at file path extension
directory_temp = top_write_path / file_path_extension
if not os.path.exists(directory_temp):
    os.makedirs(directory_temp)

# loop through each bias in the list
for i in range(len(output_biases_list)):

    # check if positive or negative
    if (float(output_biases_list[i]) >= 0.):
        # positive
        sign_MSB = '0'
    else:
        # negative, set sign bit
        sign_MSB = '1'

    # convert whole part of bias to binary string
    whole_str = convert_whole_part(output_biases_list[i], num_whole_bits)

    # convert fractional part of bias to binary string
    fractional_str = convert_fractional_part(output_biases_list[i], num_fractional_bits)

    # join whole and fractional binary strings
    converted_str = whole_str + fractional_str

    # check if sign bit is 1 (negative value)
    if (sign_MSB == '1'):
        converted_str = twos_complement_fixed_point(converted_str)

    str_index = "neuron " + str(i) + ".txt"

    # neuron bias text file write path
    file_path = top_write_path / file_path_extension / str_index

    # write neuron bias to text file
    write_single_parameter_to_file(file_path, converted_str)

########################################################################################################################################################
### WRITE WEIGHTS TO FILE ###

# write hidden layer weights to text file

# hidden layer file path extension string
file_path_extension = "layer 1 weights"

# create folder at file path extension
directory_temp = top_write_path / file_path_extension
if not os.path.exists(directory_temp):
    os.makedirs(directory_temp)

# loop through each weight list in the list of lists
for i in range(len(hidden_weights_list)):
    # loop through each weight in the list
    for j in range(len(hidden_weights_list[i])):
        # check if positive or negative
        if (float(hidden_weights_list[i][j]) >= 0.):
            # positive
            sign_MSB = '0'
        else:
            # negative
            sign_MSB = '1'

        # convert whole part of weight to binary string
        whole_str = convert_whole_part(hidden_weights_list[i][j], num_whole_bits)

        # convert fractional part of weight to binary string
        fractional_str = convert_fractional_part(hidden_weights_list[i][j], num_fractional_bits)

        # join whole and fractional binary strings
        converted_str = whole_str + fractional_str

        # check if sign bit is 1 (negative value)
        if (sign_MSB == '1'):
            converted_str = twos_complement_fixed_point(converted_str)

        # append to buffer list
        converted_parameter_buffer.append(converted_str)
    
    str_index = "neuron " + str(i) + ".txt"

    # hidden neuron weight text file write path
    file_path = top_write_path / file_path_extension / str_index

    # write hidden neuron weight list to text file
    write_parameter_list_to_file(file_path, converted_parameter_buffer)

    # clear buffer for next hidden neuron weight list
    converted_parameter_buffer.clear()


# write output layer weights to text file

# output layer file path extension string
file_path_extension = "layer 2 weights"

# create folder at file path extension
directory_temp = top_write_path / file_path_extension
if not os.path.exists(directory_temp):
    os.makedirs(directory_temp)

# loop through each weight list in the list of lists
for i in range(len(output_weights_list)):
    # loop through each weight in the list
    for j in range(len(output_weights_list[i])):
        # check if positive or negative
        if (float(output_weights_list[i][j]) >= 0.):
            # positive
            sign_MSB = '0'
        else:
            # negative
            sign_MSB = '1'

        # convert whole part of weight to binary string
        whole_str = convert_whole_part(output_weights_list[i][j], num_whole_bits)

        # convert fractional part of weight to binary string
        fractional_str = convert_fractional_part(output_weights_list[i][j], num_fractional_bits)

        # join whole and fractional binary strings
        converted_str = whole_str + fractional_str

        # check if sign bit is 1 (negative value)
        if (sign_MSB == '1'):
            converted_str = twos_complement_fixed_point(converted_str)

        # append to buffer list
        converted_parameter_buffer.append(converted_str)

    str_index = "neuron " + str(i) + ".txt"

    # output neuron weight text file write path
    file_path = top_write_path / file_path_extension / str_index

    # write output neuron weight list to text file
    write_parameter_list_to_file(file_path, converted_parameter_buffer)

    # clear buffer for next neuron weight list
    converted_parameter_buffer.clear()

########################################################################################################################################################
### SCRIPT DONE ###

# print
print("")
print("Model setup text files generated!")
print("(Fast SNN)")
