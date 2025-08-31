 `set_property TRIGGER_CONDITION rising_edge [get_hw_probes start_pulse]`
 `set_property C_TRIGGER_POSITION 0 [get_hw_ilas hw_ila_1]`
 `waveform zoomfull`
 `add_wave [get_hw_probes {neorv32_reset}]`
 `add_wave [get_hw_probes {watchdog_2_inst/S_Current_State}]`     
 `add_wave [get_hw_probes {fifo_empty}]`     
 `add_wave [get_hw_probes {fifo_rd_en}]`     
 `add_wave [get_hw_probes {fifo_rd_valid}]`  
 `add_wave -radix binary [get_hw_probes {watchdog_2_inst/features}]`  
 `add_wave [get_hw_probes {watchdog_2_inst/SNN_ready}]`  
 `add_wave [get_hw_probes {watchdog_2_inst/SNN_trigger}]` 
 `add_wave -radix unsigned [get_hw_probes {watchdog_2_inst/fast_SNN_inst/timestep_counter_reg}]` 
 `add_wave [get_hw_probes {watchdog_2_inst/SNN_done}]`  
 `add_wave [get_hw_probes {SNN_class_zero}]` 
 `add_wave [get_hw_probes {SNN_class_one}]` 
 `run_hw_ila [get_hw_ilas hw_ila_1]`