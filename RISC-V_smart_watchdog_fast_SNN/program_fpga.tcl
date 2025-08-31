# locate bitstream in folder
set script_dir [file dirname [info script]]
set bitfile [file join $script_dir "riscv_watchdog_fast_design_2_compressed.bit"]

# 2. open hardware manager and connect to FPGA
open_hw_manager
connect_hw_server
open_hw_target

# 3. select the first FPGA 
set my_device [lindex [get_hw_devices] 0]
current_hw_device $my_device
refresh_hw_device $my_device

# 4. program FPGA with compressed bitstream
set_property PROGRAM.FILE $bitfile $my_device
program_hw_devices $my_device

# 5. refresh FPGA
refresh_hw_device $my_device

puts "FPGA programmed :)"
