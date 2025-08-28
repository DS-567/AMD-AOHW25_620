#### Fault Injection and Smart Watchdog Monitoring Circuit

The fault setup and fault injection control circuits allows users to both setup and then inject various single and multiple faults into the bits 1 to 10 of the RISC-V processor program counter to introduce control flow errors. LEDs provide indiciation to the status of fault selections and injection.

The smart watchdog monitoring circuit showcases the smart watchdogs response on RISC-V control flow to users, with a green and red LED indicating the status, e.g. no faults detected (green) or fault detected (red). The smart watchdog can be disabled with a switch and the RISC-V can also be reset with another switch. In the case of the trap being triggered after faults are injected, a trap triggered LED indicates this scenario.

The buttons and switches are read by the FPGA using 2 parallel to serial shift registers (74HC165s) and the LEDs are driven by the FPGA using 6 serial to parallel shift registers (74AHCT595s).
