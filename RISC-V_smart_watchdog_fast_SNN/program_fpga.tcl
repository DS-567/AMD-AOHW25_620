# locate bitstream in folder
set script_dir [file dirname [info script]]
set bit_path [file join $script_dir "riscv_watchdog_fast_design_2_compressed.bit"]
set ila_path [file join $script_dir "debug_nets.ltx"]

# open hardware manager and connect to FPGA
open_hw_manager
connect_hw_server
open_hw_target

# select the first FPGA 
set my_device [lindex [get_hw_devices] 0]
current_hw_device $my_device
refresh_hw_device $my_device

# program FPGA with compressed bitstream
set_property PROGRAM.FILE $bit_path $my_device
set_property PROBES.FILE $ila_path $my_device
program_hw_devices $my_device

# refresh FPGA
refresh_hw_device $my_device

puts "FPGA programmed :)"
