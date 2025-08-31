open_hw

# Connect to local hw_server
connect_hw_server

# Auto connect to the first available target
open_hw_target

# Pick the first FPGA device found
set my_device [lindex [get_hw_devices] 0]
current_hw_device $my_device
refresh_hw_device $my_device

# Set your bitstream path
set_property PROGRAM.FILE {C:/riscv_watchdog_fast_design_2/riscv_watchdog_fast_design_2_compressed.bit} $my_device

# Program the device
program_hw_devices $my_device

# (Optional) Refresh after programming
refresh_hw_device $my_device

puts "FPGA programmed :)"