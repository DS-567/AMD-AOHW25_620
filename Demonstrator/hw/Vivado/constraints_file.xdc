
## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_i]
create_clock -period 10.000 -name clk_i -waveform {0.000 5.000} -add [get_ports clk_i]

## Buttons
set_property -dict {PACKAGE_PIN N17} [get_ports rst_i]
set_property IOSTANDARD LVCMOS33 [get_ports rst_i]

## LEDs
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports led0_o]

##Pmod Header JA
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports JA1_o]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports JA2_o]
        
##Pmod Header JB
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports JB1_o]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports JB2_o]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports JB3_i]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports JB4_o]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports JB7_o]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports JB8_o]

##Pmod Header JC
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports JC1_i]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports JC2_i]

##Pmod Header JD
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports JD1_o] 
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports JD2_o] 
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports JD3_o]  
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports JD4_i] 
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports JD7_i] 
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports JD8_i] 
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports JD9_i]  
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports JD10_i] 

##7 Segment Display
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports seg_a_o]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports seg_b_o]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports seg_c_o]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports seg_d_o]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports seg_e_o]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports seg_f_o]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports seg_g_o]

set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports anode_0_o]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports anode_1_o]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports anode_2_o]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports anode_3_o]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports anode_4_o]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports anode_5_o]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports anode_6_o]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports anode_7_o]

##USB-RS232 Interface
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports uart_tx_o]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports uart_rx_i]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

