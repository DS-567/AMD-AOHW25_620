# locate bitstream in folder
set script_dir [file dirname [info script]]
set bit_path [file join $script_dir "riscv_watchdog_fast_design_2_compressed.bit"]
set ila_path [file join $script_dir "debug_nets.ltx"]

# open hardware manager and connect to FPGA
open_hw_manager
connect_hw_server
open_hw_target

current_hw_device [get_hw_devices xc7vx690t_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7vx690t_0] 0]
set_property PROGRAM.FILE $bit_path [get_hw_devices xc7vx690t_0]
set_property PROBES.FILE $ila_path [get_hw_devices xc7vx690t_0]
program_hw_devices [get_hw_devices xc7vx690t_0]
refresh_hw_device [get_hw_devices xc7vx690t_0]

display_hw_ila_data [ get_hw_ila_data hw_ila_data_1 -of_objects [get_hw_ilas -of_objects [get_hw_devices xc7vx690t_0] -filter {CELL_NAME=~"u_ila_0"}]]

puts "FPGA programmed :)"



