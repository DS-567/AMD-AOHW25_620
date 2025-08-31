# locate bitstream in folder
set script_dir [file dirname [info script]]
set bitfile [file join $script_dir "riscv_watchdog_fast_design_2_compressed.bit"]

# open hardware manager and connect to FPGA
open_hw_manager
connect_hw_server
open_hw_target

# select the first FPGA 
set my_device [lindex [get_hw_devices] 0]
current_hw_device $my_device
refresh_hw_device $my_device

# verify it is the VC709 Virtex-7 connected
set dev_name [get_property PART $my_device]
set expected_part "xc7vx690tffg1761-2L"  ;# VC709 FPGA part

if {$dev_name != $expected_part} {
    puts "ERROR: This FPGA ($dev_name) is not the expected VC709 device ($expected_part)."
    puts "Programming aborted - wrong FPGA connected!"
    exit
}

# 4. program FPGA with compressed bitstream
set_property PROGRAM.FILE $bitfile $my_device
program_hw_devices $my_device

# 5. refresh FPGA
refresh_hw_device $my_device

puts "FPGA programmed :)"


