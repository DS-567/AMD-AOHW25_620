
## Buttons
set_property -dict {PACKAGE_PIN AV39} [get_ports rst_i]
set_property IOSTANDARD LVCMOS18 [get_ports rst_i]

## LEDs
set_property PACKAGE_PIN AM39 [get_ports led0_o]
set_property IOSTANDARD LVCMOS18 [get_ports led0_o]

set_property PACKAGE_PIN AU39 [get_ports led7_o]
set_property IOSTANDARD LVCMOS18 [get_ports led7_o]

set_property SLEW SLOW [get_ports led0_o]
set_property SLEW SLOW [get_ports led7_o]

set_property DRIVE 4 [get_ports led0_o]
set_property DRIVE 4 [get_ports led7_o]

# UART
set_property PACKAGE_PIN AU36 [get_ports uart_tx_o]
set_property IOSTANDARD LVCMOS18 [get_ports uart_tx_o]

set_property PACKAGE_PIN AU33 [get_ports uart_rx_i]
set_property IOSTANDARD LVCMOS18 [get_ports uart_rx_i]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
