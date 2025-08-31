# close and open hardware manager
close_hw
open_hw

# connect to local hw_server
connect_hw_server

# auto connect
open_hw_target

# select first FPGA device found
set my_device [lindex [get_hw_devices] 0]
current_hw_device $my_device
refresh_hw_device $my_device

# Set bitstream path
cd C:/riscv_watchdog_fast_design_2
set_property PROGRAM.FILE {riscv_watchdog_fast_design_2_compressed.bit} $my_device

# program FPGA
program_hw_devices $my_device

# (Optional) Refresh after programming
refresh_hw_device $my_device

puts "FPGA programmed :)"
