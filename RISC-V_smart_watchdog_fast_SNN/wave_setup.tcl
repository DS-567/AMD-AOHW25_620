add_wave [get_hw_probes {neorv32_reset}]
add_wave [get_hw_probes {watchdog_2_inst/S_Current_State}]    
add_wave [get_hw_probes {fifo_empty}]   
add_wave [get_hw_probes {fifo_rd_en}]     
add_wave [get_hw_probes {fifo_rd_valid}]  
add_wave [get_hw_probes {watchdog_2_inst/features}]  
add_wave [get_hw_probes {watchdog_2_inst/SNN_ready}]  
add_wave [get_hw_probes {watchdog_2_inst/SNN_trigger}] 
add_wave [get_hw_probes {watchdog_2_inst/fast_SNN_inst/input_layer_spikes}] 
add_wave [get_hw_probes {watchdog_2_inst/fast_SNN_inst/hidden_layer_spikes}]
add_wave [get_hw_probes {watchdog_2_inst/fast_SNN_inst/output_layer_spikes}]
add_wave -radix unsigned [get_hw_probes {watchdog_2_inst/fast_SNN_inst/timestep_counter_reg}]
add_wave [get_hw_probes {watchdog_2_inst/SNN_done}]  
add_wave [get_hw_probes {SNN_class_zero}] 
add_wave [get_hw_probes {SNN_class_one}]




