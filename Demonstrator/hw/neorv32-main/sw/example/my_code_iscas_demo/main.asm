
main.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <__crt0_entry>:
       0:	000020b7          	lui	ra,0x2
       4:	80008093          	addi	ra,ra,-2048 # 1800 <__muldf3+0x290>
       8:	30009073          	csrw	mstatus,ra
       c:	00000097          	auipc	ra,0x0
      10:	12c08093          	addi	ra,ra,300 # 138 <__crt0_trap_handler>
      14:	30509073          	csrw	mtvec,ra
      18:	30401073          	csrw	mie,zero

0000001c <__crt0_pointer_init>:
      1c:	80002217          	auipc	tp,0x80002
      20:	fe320213          	addi	tp,tp,-29 # 80001fff <__crt0_stack_end+0x0>
      24:	ffc27113          	andi	sp,tp,-4
      28:	80001297          	auipc	t0,0x80001
      2c:	81028293          	addi	t0,t0,-2032 # 80000838 <__crt0_stack_end+0xffffe839>
      30:	ffc2f193          	andi	gp,t0,-4

00000034 <__crt0_reg_file_init>:
      34:	00000313          	li	t1,0
      38:	00000393          	li	t2,0
      3c:	00000413          	li	s0,0
      40:	00000493          	li	s1,0
      44:	00000813          	li	a6,0
      48:	00000893          	li	a7,0
      4c:	00000913          	li	s2,0
      50:	00000993          	li	s3,0
      54:	00000a13          	li	s4,0
      58:	00000a93          	li	s5,0
      5c:	00000b13          	li	s6,0
      60:	00000b93          	li	s7,0
      64:	00000c13          	li	s8,0
      68:	00000c93          	li	s9,0
      6c:	00000d13          	li	s10,0
      70:	00000d93          	li	s11,0
      74:	00000e13          	li	t3,0
      78:	00000e93          	li	t4,0
      7c:	00000f13          	li	t5,0
      80:	00000f93          	li	t6,0

00000084 <__crt0_copy_data>:
      84:	00003597          	auipc	a1,0x3
      88:	3c858593          	addi	a1,a1,968 # 344c <__RODATA_END__>
      8c:	80000617          	auipc	a2,0x80000
      90:	f7460613          	addi	a2,a2,-140 # 80000000 <__crt0_stack_end+0xffffe001>
      94:	80000697          	auipc	a3,0x80000
      98:	fa468693          	addi	a3,a3,-92 # 80000038 <__crt0_stack_end+0xffffe039>
      9c:	00c58e63          	beq	a1,a2,b8 <__crt0_clear_bss>

000000a0 <__crt0_copy_data_loop>:
      a0:	00d65c63          	bge	a2,a3,b8 <__crt0_clear_bss>
      a4:	0005a703          	lw	a4,0(a1)
      a8:	00e62023          	sw	a4,0(a2)
      ac:	00458593          	addi	a1,a1,4
      b0:	00460613          	addi	a2,a2,4
      b4:	fedff06f          	j	a0 <__crt0_copy_data_loop>

000000b8 <__crt0_clear_bss>:
      b8:	80000717          	auipc	a4,0x80000
      bc:	f8070713          	addi	a4,a4,-128 # 80000038 <__crt0_stack_end+0xffffe039>
      c0:	95018793          	addi	a5,gp,-1712 # 80000188 <__BSS_END__>

000000c4 <__crt0_clear_bss_loop>:
      c4:	00f75863          	bge	a4,a5,d4 <__crt0_call_constructors>
      c8:	00072023          	sw	zero,0(a4)
      cc:	00470713          	addi	a4,a4,4
      d0:	ff5ff06f          	j	c4 <__crt0_clear_bss_loop>

000000d4 <__crt0_call_constructors>:
      d4:	00003417          	auipc	s0,0x3
      d8:	23c40413          	addi	s0,s0,572 # 3310 <__etext>
      dc:	00003497          	auipc	s1,0x3
      e0:	23448493          	addi	s1,s1,564 # 3310 <__etext>

000000e4 <__crt0_call_constructors_loop>:
      e4:	00945a63          	bge	s0,s1,f8 <__crt0_call_constructors_loop_end>
      e8:	00042083          	lw	ra,0(s0)
      ec:	000080e7          	jalr	ra
      f0:	00440413          	addi	s0,s0,4
      f4:	ff1ff06f          	j	e4 <__crt0_call_constructors_loop>

000000f8 <__crt0_call_constructors_loop_end>:
      f8:	00000513          	li	a0,0
      fc:	00000593          	li	a1,0
     100:	078000ef          	jal	ra,178 <main>

00000104 <__crt0_main_exit>:
     104:	30401073          	csrw	mie,zero
     108:	34051073          	csrw	mscratch,a0

0000010c <__crt0_call_destructors>:
     10c:	00003417          	auipc	s0,0x3
     110:	20440413          	addi	s0,s0,516 # 3310 <__etext>
     114:	00003497          	auipc	s1,0x3
     118:	1fc48493          	addi	s1,s1,508 # 3310 <__etext>

0000011c <__crt0_call_destructors_loop>:
     11c:	00945a63          	bge	s0,s1,130 <__crt0_call_destructors_loop_end>
     120:	00042083          	lw	ra,0(s0)
     124:	000080e7          	jalr	ra
     128:	00440413          	addi	s0,s0,4
     12c:	ff1ff06f          	j	11c <__crt0_call_destructors_loop>

00000130 <__crt0_call_destructors_loop_end>:
     130:	10500073          	wfi
     134:	ffdff06f          	j	130 <__crt0_call_destructors_loop_end>

00000138 <__crt0_trap_handler>:
     138:	34041073          	csrw	mscratch,s0
     13c:	34202473          	csrr	s0,mcause
     140:	01f45413          	srli	s0,s0,0x1f
     144:	02041663          	bnez	s0,170 <__crt0_trap_handler_end>
     148:	34102473          	csrr	s0,mepc
     14c:	00440413          	addi	s0,s0,4
     150:	34141073          	csrw	mepc,s0
     154:	34a02473          	csrr	s0,0x34a
     158:	00347413          	andi	s0,s0,3
     15c:	ffd40413          	addi	s0,s0,-3
     160:	00040863          	beqz	s0,170 <__crt0_trap_handler_end>
     164:	34102473          	csrr	s0,mepc
     168:	ffe40413          	addi	s0,s0,-2
     16c:	34141073          	csrw	mepc,s0

00000170 <__crt0_trap_handler_end>:
     170:	34002473          	csrr	s0,mscratch
     174:	30200073          	mret

00000178 <main>:

// running motor actual rpm sum (summed every millisceond)
uint32_t motor_actual_rpm_sum = 0;

// main function call
int main() {
     178:	fc010113          	addi	sp,sp,-64
     17c:	02912a23          	sw	s1,52(sp)
 **************************************************************************/
inline void __attribute__ ((always_inline)) neorv32_cpu_csr_write(const int csr_id, uint32_t data) {

  uint32_t csr_data = data;

  asm volatile ("csrw %[input_i], %[input_j]" :  : [input_i] "i" (csr_id), [input_j] "r" (csr_data));
     180:	000014b7          	lui	s1,0x1
     184:	02112e23          	sw	ra,60(sp)
     188:	02812c23          	sw	s0,56(sp)
     18c:	03212823          	sw	s2,48(sp)
     190:	03312623          	sw	s3,44(sp)
     194:	03412423          	sw	s4,40(sp)
     198:	03512223          	sw	s5,36(sp)
     19c:	03612023          	sw	s6,32(sp)
     1a0:	01712e23          	sw	s7,28(sp)
     1a4:	01812c23          	sw	s8,24(sp)
     1a8:	01912a23          	sw	s9,20(sp)
     1ac:	01a12823          	sw	s10,16(sp)
     1b0:	01b12623          	sw	s11,12(sp)
     1b4:	8c448793          	addi	a5,s1,-1852 # 8c4 <global_trap_handler>
     1b8:	30579073          	csrw	mtvec,a5

  // setup global trap handler (FOR ALL TRAPS!)
  neorv32_cpu_csr_write(CSR_MTVEC, (uint32_t)&global_trap_handler);

  // check if GPTMR unit is implemented
  if (neorv32_gptmr_available() == 0) {
     1bc:	19d000ef          	jal	ra,b58 <neorv32_gptmr_available>
     1c0:	46050463          	beqz	a0,628 <main+0x4b0>
    return 1;
  }
  
  // check if PWM unit is implemented
  if (neorv32_pwm_available() == 0) {
     1c4:	205000ef          	jal	ra,bc8 <neorv32_pwm_available>
     1c8:	46050063          	beqz	a0,628 <main+0x4b0>
    return 1;
  }

  // check if GPIO unit is implemented
  if (neorv32_gpio_available() == 0) {
     1cc:	0d5000ef          	jal	ra,aa0 <neorv32_gpio_available>
     1d0:	44050c63          	beqz	a0,628 <main+0x4b0>
    return 1;
  }

  // clear GPIO output port
  neorv32_gpio_port_set(0);
     1d4:	00000513          	li	a0,0
     1d8:	00000593          	li	a1,0
     1dc:	15d000ef          	jal	ra,b38 <neorv32_gpio_port_set>

  // configure timer for 1kHz continuous ticks 
  neorv32_gptmr_setup(CLK_PRSC_8, NEORV32_SYSINFO->CLK / 8000, 1); 
     1e0:	e0002503          	lw	a0,-512(zero) # fffffe00 <__crt0_stack_end+0x7fffde01>
     1e4:	000025b7          	lui	a1,0x2
     1e8:	f4058593          	addi	a1,a1,-192 # 1f40 <__addsf3+0x314>
     1ec:	02c030ef          	jal	ra,3218 <__hidden___udivsi3>
     1f0:	00050593          	mv	a1,a0
     1f4:	00100613          	li	a2,1
     1f8:	00200513          	li	a0,2
     1fc:	16d000ef          	jal	ra,b68 <neorv32_gptmr_setup>
 **************************************************************************/
inline void __attribute__ ((always_inline)) neorv32_cpu_csr_set(const int csr_id, uint32_t mask) {

  uint32_t csr_data = mask;

  asm volatile ("csrs %[input_i], %[input_j]" :  : [input_i] "i" (csr_id), [input_j] "r" (csr_data));
     200:	100007b7          	lui	a5,0x10000
     204:	3047a073          	csrs	mie,a5
     208:	00800793          	li	a5,8
     20c:	3007a073          	csrs	mstatus,a5
  // enable timer interrupt
  neorv32_cpu_csr_set(CSR_MIE, 1 << GPTMR_FIRQ_ENABLE);   // enable GPTMR FIRQ channel
  neorv32_cpu_csr_set(CSR_MSTATUS, 1 << CSR_MSTATUS_MIE); // enable machine-mode interrupts

  // setup the XIRQ 
  err_cnt = neorv32_xirq_setup();
     210:	2c9000ef          	jal	ra,cd8 <neorv32_xirq_setup>
     214:	84a1ac23          	sw	a0,-1960(gp) # 80000090 <err_cnt>
  if (err_cnt) {
     218:	40051863          	bnez	a0,628 <main+0x4b0>
      return 1;
  }

  // install the XIRQ 
  err_cnt = neorv32_xirq_install(0, global_trap_handler);
     21c:	8c448593          	addi	a1,s1,-1852
     220:	31d000ef          	jal	ra,d3c <neorv32_xirq_install>
     224:	84a1ac23          	sw	a0,-1960(gp) # 80000090 <err_cnt>
  if (err_cnt) {
     228:	40051063          	bnez	a0,628 <main+0x4b0>
     22c:	000017b7          	lui	a5,0x1
     230:	80078793          	addi	a5,a5,-2048 # 800 <motor_control_pi+0xdc>
     234:	3047a073          	csrs	mie,a5
    return 1;
  }

  // Enable interrupts
  neorv32_cpu_csr_set(CSR_MIE, 1 << CSR_MIE_MEIE);
  neorv32_xirq_channel_enable(0);
     238:	2e9000ef          	jal	ra,d20 <neorv32_xirq_channel_enable>
  neorv32_xirq_global_enable();
     23c:	2d9000ef          	jal	ra,d14 <neorv32_xirq_global_enable>

  // configure and enable PWM
  neorv32_pwm_setup(2.6);
     240:	00200513          	li	a0,2
     244:	195000ef          	jal	ra,bd8 <neorv32_pwm_setup>

  // motor control states 
	enum state_machine {MOTOR_IDLE, MOTOR_FORWARD, MOTOR_REVERSE, MOTOR_STOP};

	// motor control state and initialise to idle state
	enum state_machine motor_ctrl_state = MOTOR_IDLE;
     248:	00000d13          	li	s10,0

  while(1) {
    
    // process every 1ms
    if (timer_interrupt_tick == 1){
     24c:	00100c93          	li	s9,1
     250:	80000437          	lui	s0,0x80000
      
      // incrememt tick counter
      tick_counter += 1;
     254:	800004b7          	lui	s1,0x80000
    if (timer_interrupt_tick == 1){
     258:	800007b7          	lui	a5,0x80000
     25c:	03e7c783          	lbu	a5,62(a5) # 8000003e <__crt0_stack_end+0xffffe03f>
     260:	25979263          	bne	a5,s9,4a4 <main+0x32c>
      tick_counter += 1;
     264:	03c4d783          	lhu	a5,60(s1) # 8000003c <__crt0_stack_end+0xffffe03d>
     268:	00178793          	addi	a5,a5,1
     26c:	02f49e23          	sh	a5,60(s1)

      // get all control inputs (0 = not pressed or active / 1 = pressed or active)
      pcb_motor_stop_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PCB_MOTOR_STOP_BUTTON_GPIO_INPUT);
     270:	82c1a783          	lw	a5,-2004(gp) # 80000064 <control_inputs_gpio_upper>
}


// return either 0 or 1 depending on the input bit value
uint8_t get_input_bit(uint32_t input_data, uint8_t bit_num){
  uint8_t bit_val = (input_data >> bit_num) & 1;
     274:	0017f713          	andi	a4,a5,1
      pcb_motor_stop_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PCB_MOTOR_STOP_BUTTON_GPIO_INPUT);
     278:	82e182a3          	sb	a4,-2011(gp) # 8000005d <pcb_motor_stop_button>
  uint8_t bit_val = (input_data >> bit_num) & 1;
     27c:	0017d713          	srli	a4,a5,0x1
     280:	00177713          	andi	a4,a4,1
     284:	0027d513          	srli	a0,a5,0x2
      pcb_motor_start_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PCB_MOTOR_START_BUTTON_GPIO_INPUT);
     288:	82e18223          	sb	a4,-2012(gp) # 8000005c <pcb_motor_start_button>
  uint8_t bit_val = (input_data >> bit_num) & 1;
     28c:	00157513          	andi	a0,a0,1
      pcb_motor_direction_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PCB_MOTOR_DIRECTION_BUTTON_GPIO_INPUT);
     290:	82a181a3          	sb	a0,-2013(gp) # 8000005b <pcb_motor_direction_button>
  uint8_t bit_val = (input_data >> bit_num) & 1;
     294:	0047d713          	srli	a4,a5,0x4
     298:	00177713          	andi	a4,a4,1
      python_motor_stop_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_STOP_BUTTON_GPIO_INPUT);
     29c:	82e180a3          	sb	a4,-2015(gp) # 80000059 <python_motor_stop_button>
  uint8_t bit_val = (input_data >> bit_num) & 1;
     2a0:	0057d713          	srli	a4,a5,0x5
     2a4:	00177713          	andi	a4,a4,1
      python_motor_start_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_START_BUTTON_GPIO_INPUT);
     2a8:	82e18023          	sb	a4,-2016(gp) # 80000058 <python_motor_start_button>
  uint8_t bit_val = (input_data >> bit_num) & 1;
     2ac:	0067d713          	srli	a4,a5,0x6
     2b0:	00177713          	andi	a4,a4,1
     2b4:	0077d593          	srli	a1,a5,0x7
      python_motor_direction_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_DIRECTION_BUTTON_GPIO_INPUT);
     2b8:	80e18fa3          	sb	a4,-2017(gp) # 80000057 <python_motor_direction_button>
  uint8_t bit_val = (input_data >> bit_num) & 1;
     2bc:	0015f593          	andi	a1,a1,1
     2c0:	0087d613          	srli	a2,a5,0x8
      python_motor_increase_speed_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_INCREASE_SPEED_GPIO_INPUT);
     2c4:	80b18ea3          	sb	a1,-2019(gp) # 80000055 <python_motor_increase_speed_button>
  uint8_t bit_val = (input_data >> bit_num) & 1;
     2c8:	00167613          	andi	a2,a2,1
      python_motor_decrease_speed_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_DECREASE_SPEED_GPIO_INPUT);
     2cc:	80c18da3          	sb	a2,-2021(gp) # 80000053 <python_motor_decrease_speed_button>
  uint8_t bit_val = (input_data >> bit_num) & 1;
     2d0:	0097d693          	srli	a3,a5,0x9
     2d4:	0016f693          	andi	a3,a3,1
      python_confirm_setpoint_speed_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_CONFIRM_SPEED_SETPOINT_GPIO_INPUT);
     2d8:	80d18ca3          	sb	a3,-2023(gp) # 80000051 <python_confirm_setpoint_speed_button>
      if ( ((pcb_motor_direction_button == 1) && (pcb_motor_direction_button_last != 1)) || 
     2dc:	00050663          	beqz	a0,2e8 <main+0x170>
     2e0:	8221c303          	lbu	t1,-2014(gp) # 8000005a <pcb_motor_direction_button_last>
     2e4:	01931863          	bne	t1,s9,2f4 <main+0x17c>
     2e8:	00070e63          	beqz	a4,304 <main+0x18c>
              ((python_motor_direction_button == 1) && (python_motor_direction_button_last != 1)) ){
     2ec:	81e1c303          	lbu	t1,-2018(gp) # 80000056 <python_motor_direction_button_last>
     2f0:	01930a63          	beq	t1,s9,304 <main+0x18c>
          direction = (direction ^ 0x01) & 0x01;
     2f4:	03044303          	lbu	t1,48(s0) # 80000030 <__crt0_stack_end+0xffffe031>
     2f8:	fff34313          	not	t1,t1
     2fc:	00137313          	andi	t1,t1,1
     300:	02640823          	sb	t1,48(s0)
      python_motor_direction_button_last = python_motor_direction_button;
     304:	80e18f23          	sb	a4,-2018(gp) # 80000056 <python_motor_direction_button_last>
      pcb_motor_direction_button_last = pcb_motor_direction_button;
     308:	82a18123          	sb	a0,-2014(gp) # 8000005a <pcb_motor_direction_button_last>
      if ( (python_motor_increase_speed_button == 1) && (python_motor_increase_speed_button_last != 1) ){
     30c:	80000737          	lui	a4,0x80000
     310:	02058263          	beqz	a1,334 <main+0x1bc>
     314:	81c1c503          	lbu	a0,-2020(gp) # 80000054 <python_motor_increase_speed_button_last>
     318:	01950e63          	beq	a0,s9,334 <main+0x1bc>
        if ( (motor_setpoint_rpm + 50) <= MOTOR_SETPOINT_MAX){
     31c:	03472503          	lw	a0,52(a4) # 80000034 <__crt0_stack_end+0xffffe035>
     320:	00001337          	lui	t1,0x1
     324:	fa030313          	addi	t1,t1,-96 # fa0 <__adddf3+0x21c>
     328:	03250513          	addi	a0,a0,50
     32c:	00a36463          	bltu	t1,a0,334 <main+0x1bc>
          motor_setpoint_rpm += 50;
     330:	02a72a23          	sw	a0,52(a4)
      python_motor_increase_speed_button_last = python_motor_increase_speed_button;
     334:	80b18e23          	sb	a1,-2020(gp) # 80000054 <python_motor_increase_speed_button_last>
      if ( (python_motor_decrease_speed_button == 1) && (python_motor_decrease_speed_button_last != 1) ){
     338:	02060063          	beqz	a2,358 <main+0x1e0>
     33c:	81a1c583          	lbu	a1,-2022(gp) # 80000052 <python_motor_decrease_speed_button_last>
     340:	01958c63          	beq	a1,s9,358 <main+0x1e0>
        if ( (motor_setpoint_rpm - 50) >= MOTOR_SETPOINT_MIN){
     344:	03472583          	lw	a1,52(a4)
     348:	7cf00313          	li	t1,1999
     34c:	fce58593          	addi	a1,a1,-50
     350:	00b37463          	bgeu	t1,a1,358 <main+0x1e0>
          motor_setpoint_rpm -= 50;
     354:	02b72a23          	sw	a1,52(a4)
      python_motor_decrease_speed_button_last = python_motor_decrease_speed_button;
     358:	80c18d23          	sb	a2,-2022(gp) # 80000052 <python_motor_decrease_speed_button_last>
      if ( (python_confirm_setpoint_speed_button == 1) && (python_confirm_setpoint_speed_button_last != 1) ){
     35c:	02068663          	beqz	a3,388 <main+0x210>
     360:	8181c603          	lbu	a2,-2024(gp) # 80000050 <python_confirm_setpoint_speed_button_last>
     364:	03960263          	beq	a2,s9,388 <main+0x210>
        motor_setpoint_rpm_temp = (control_inputs_gpio_upper >> 10) & 0xFFFF;
     368:	00a7d793          	srli	a5,a5,0xa
     36c:	01079793          	slli	a5,a5,0x10
     370:	0107d793          	srli	a5,a5,0x10
     374:	80f1aa23          	sw	a5,-2028(gp) # 8000004c <motor_setpoint_rpm_temp>
        if (motor_setpoint_rpm_temp <= MOTOR_SETPOINT_MAX){
     378:	00001637          	lui	a2,0x1
     37c:	fa060613          	addi	a2,a2,-96 # fa0 <__adddf3+0x21c>
     380:	16f67863          	bgeu	a2,a5,4f0 <main+0x378>
          motor_setpoint_rpm = motor_setpoint_rpm_temp;
     384:	02f72a23          	sw	a5,52(a4)
      decimal_to_bcd(motor_setpoint_rpm, &bcd_thousands, &bcd_hundreds, &bcd_tens, &bcd_ones);
     388:	03472d83          	lw	s11,52(a4)
     38c:	85018613          	addi	a2,gp,-1968 # 80000088 <bcd_hundreds>
      python_confirm_setpoint_speed_button_last = python_confirm_setpoint_speed_button;
     390:	80d18c23          	sb	a3,-2024(gp) # 80000050 <python_confirm_setpoint_speed_button_last>
      decimal_to_bcd(motor_setpoint_rpm, &bcd_thousands, &bcd_hundreds, &bcd_tens, &bcd_ones);
     394:	000d8513          	mv	a0,s11
     398:	84c18693          	addi	a3,gp,-1972 # 80000084 <bcd_tens>
     39c:	84818713          	addi	a4,gp,-1976 # 80000080 <bcd_ones>
     3a0:	85418593          	addi	a1,gp,-1964 # 8000008c <bcd_thousands>
     3a4:	2c4000ef          	jal	ra,668 <decimal_to_bcd>
      gpio_outputs |= bcd_ones << 16;
     3a8:	8481a783          	lw	a5,-1976(gp) # 80000080 <bcd_ones>
      gpio_outputs |= bcd_tens << 20;
     3ac:	84c1a703          	lw	a4,-1972(gp) # 80000084 <bcd_tens>
      gpio_outputs |= motor_setpoint_rpm & 0xFFFF;
     3b0:	00010c37          	lui	s8,0x10
      gpio_outputs |= bcd_ones << 16;
     3b4:	01079793          	slli	a5,a5,0x10
      gpio_outputs |= bcd_tens << 20;
     3b8:	01471713          	slli	a4,a4,0x14
      gpio_outputs |= bcd_thousands << 28;
     3bc:	00e7e7b3          	or	a5,a5,a4
      gpio_outputs |= bcd_hundreds << 24;
     3c0:	8501a703          	lw	a4,-1968(gp) # 80000088 <bcd_hundreds>
      gpio_outputs |= motor_setpoint_rpm & 0xFFFF;
     3c4:	fffc0c13          	addi	s8,s8,-1 # ffff <__RODATA_END__+0xcbb3>
     3c8:	018dfdb3          	and	s11,s11,s8
      gpio_outputs |= bcd_hundreds << 24;
     3cc:	01871713          	slli	a4,a4,0x18
      gpio_outputs |= bcd_thousands << 28;
     3d0:	00e7e7b3          	or	a5,a5,a4
     3d4:	8541a703          	lw	a4,-1964(gp) # 8000008c <bcd_thousands>
      neorv32_gpio_port_set(gpio_outputs);
     3d8:	00000593          	li	a1,0
      gpio_outputs |= bcd_thousands << 28;
     3dc:	01c71713          	slli	a4,a4,0x1c
     3e0:	00e7e7b3          	or	a5,a5,a4
      gpio_outputs |= motor_setpoint_rpm & 0xFFFF;
     3e4:	01b7e533          	or	a0,a5,s11
     3e8:	82a1a423          	sw	a0,-2008(gp) # 80000060 <gpio_outputs>
      neorv32_gpio_port_set(gpio_outputs);
     3ec:	74c000ef          	jal	ra,b38 <neorv32_gpio_port_set>
      neorv32_gpio_pin_set(NEORV32_SETPOINT_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT);     
     3f0:	02000513          	li	a0,32
     3f4:	6bc000ef          	jal	ra,ab0 <neorv32_gpio_pin_set>
      neorv32_gpio_pin_clr(NEORV32_SETPOINT_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT);     
     3f8:	02000513          	li	a0,32
     3fc:	6e4000ef          	jal	ra,ae0 <neorv32_gpio_pin_clr>
      motor_actual_rpm_sum += motor_actual_rpm;
     400:	80000337          	lui	t1,0x80000
     404:	03832503          	lw	a0,56(t1) # 80000038 <__crt0_stack_end+0xffffe039>
     408:	8101a783          	lw	a5,-2032(gp) # 80000048 <motor_actual_rpm>
      if (tick_counter == MOTOR_ACTUAL_SPEED_FILTER_MS){
     40c:	03c4d703          	lhu	a4,60(s1)
      motor_actual_rpm_sum += motor_actual_rpm;
     410:	00f50533          	add	a0,a0,a5
     414:	02a32c23          	sw	a0,56(t1)
      if (tick_counter == MOTOR_ACTUAL_SPEED_FILTER_MS){
     418:	14d00793          	li	a5,333
     41c:	08f71063          	bne	a4,a5,49c <main+0x324>
        uint16_t motor_speed_avg = motor_actual_rpm_sum / MOTOR_ACTUAL_SPEED_FILTER_MS;
     420:	14d00593          	li	a1,333
     424:	5f5020ef          	jal	ra,3218 <__hidden___udivsi3>
     428:	01857c33          	and	s8,a0,s8
        decimal_to_bcd(motor_speed_avg, &bcd_thousands, &bcd_hundreds, &bcd_tens, &bcd_ones);
     42c:	84c18693          	addi	a3,gp,-1972 # 80000084 <bcd_tens>
     430:	85018613          	addi	a2,gp,-1968 # 80000088 <bcd_hundreds>
     434:	84818713          	addi	a4,gp,-1976 # 80000080 <bcd_ones>
     438:	85418593          	addi	a1,gp,-1964 # 8000008c <bcd_thousands>
     43c:	000c0513          	mv	a0,s8
     440:	228000ef          	jal	ra,668 <decimal_to_bcd>
        gpio_outputs |= bcd_ones << 16;
     444:	8481a783          	lw	a5,-1976(gp) # 80000080 <bcd_ones>
        gpio_outputs |= bcd_tens << 20;
     448:	84c1a703          	lw	a4,-1972(gp) # 80000084 <bcd_tens>
        neorv32_gpio_port_set(gpio_outputs);
     44c:	00000593          	li	a1,0
        gpio_outputs |= bcd_ones << 16;
     450:	01079793          	slli	a5,a5,0x10
        gpio_outputs |= bcd_tens << 20;
     454:	01471713          	slli	a4,a4,0x14
        gpio_outputs |= bcd_thousands << 28;
     458:	00e7e7b3          	or	a5,a5,a4
        gpio_outputs |= bcd_hundreds << 24;
     45c:	8501a703          	lw	a4,-1968(gp) # 80000088 <bcd_hundreds>
     460:	01871713          	slli	a4,a4,0x18
        gpio_outputs |= bcd_thousands << 28;
     464:	00e7e7b3          	or	a5,a5,a4
     468:	8541a703          	lw	a4,-1964(gp) # 8000008c <bcd_thousands>
     46c:	01c71713          	slli	a4,a4,0x1c
     470:	00e7e7b3          	or	a5,a5,a4
        gpio_outputs |= motor_speed_avg & 0xFFFF;
     474:	0187e533          	or	a0,a5,s8
     478:	82a1a423          	sw	a0,-2008(gp) # 80000060 <gpio_outputs>
        neorv32_gpio_port_set(gpio_outputs);
     47c:	6bc000ef          	jal	ra,b38 <neorv32_gpio_port_set>
        neorv32_gpio_pin_set(NEORV32_ACTUAL_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT);    
     480:	02200513          	li	a0,34
     484:	62c000ef          	jal	ra,ab0 <neorv32_gpio_pin_set>
        neorv32_gpio_pin_clr(NEORV32_ACTUAL_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT);    
     488:	02200513          	li	a0,34
     48c:	654000ef          	jal	ra,ae0 <neorv32_gpio_pin_clr>
        motor_actual_rpm_sum = 0;
     490:	80000337          	lui	t1,0x80000
        tick_counter = 0;
     494:	02049e23          	sh	zero,60(s1)
        motor_actual_rpm_sum = 0;
     498:	02032c23          	sw	zero,56(t1) # 80000038 <__crt0_stack_end+0xffffe039>
      timer_interrupt_tick = 0;
     49c:	800007b7          	lui	a5,0x80000
     4a0:	02078f23          	sb	zero,62(a5) # 8000003e <__crt0_stack_end+0xffffe03f>
    switch (motor_ctrl_state) {
     4a4:	00200793          	li	a5,2
     4a8:	0efd0c63          	beq	s10,a5,5a0 <main+0x428>
     4ac:	05a7ea63          	bltu	a5,s10,500 <main+0x388>
     4b0:	0a0d1263          	bnez	s10,554 <main+0x3dc>
        neorv32_pwm_set(0, 0);			
     4b4:	00000593          	li	a1,0
     4b8:	00000513          	li	a0,0
        motor_speed_control_enable = 0;
     4bc:	800186a3          	sb	zero,-2035(gp) # 80000045 <motor_speed_control_enable>
        neorv32_pwm_set(0, 0);			
     4c0:	734000ef          	jal	ra,bf4 <neorv32_pwm_set>
        pi_integral = 0.0;			
     4c4:	800007b7          	lui	a5,0x80000
     4c8:	00000713          	li	a4,0
        neorv32_gpio_pin_clr(NEORV32_MOTOR_RUNNING_LED_GPIO_OUTPUT); 
     4cc:	00100513          	li	a0,1
        pi_integral = 0.0;			
     4d0:	04e7a023          	sw	a4,64(a5) # 80000040 <__crt0_stack_end+0xffffe041>
        neorv32_gpio_pin_clr(NEORV32_MOTOR_RUNNING_LED_GPIO_OUTPUT); 
     4d4:	60c000ef          	jal	ra,ae0 <neorv32_gpio_pin_clr>
        if ( (pcb_motor_stop_button == 0) && (python_motor_stop_button == 0) ){
     4d8:	8251c783          	lbu	a5,-2011(gp) # 8000005d <pcb_motor_stop_button>
     4dc:	8211c703          	lbu	a4,-2015(gp) # 80000059 <python_motor_stop_button>
     4e0:	00e7e7b3          	or	a5,a5,a4
     4e4:	04078863          	beqz	a5,534 <main+0x3bc>
              motor_ctrl_state = MOTOR_REVERSE;
     4e8:	00000d13          	li	s10,0
     4ec:	01c0006f          	j	508 <main+0x390>
          motor_setpoint_rpm = motor_setpoint_rpm_temp;
     4f0:	02f72a23          	sw	a5,52(a4)
        if (motor_setpoint_rpm_temp >= MOTOR_SETPOINT_MIN){
     4f4:	7cf00613          	li	a2,1999
     4f8:	e8f678e3          	bgeu	a2,a5,388 <main+0x210>
     4fc:	e89ff06f          	j	384 <main+0x20c>
    switch (motor_ctrl_state) {
     500:	00300793          	li	a5,3
     504:	0cfd0a63          	beq	s10,a5,5d8 <main+0x460>
    if (direction == 1){
     508:	03044783          	lbu	a5,48(s0)
     50c:	11979663          	bne	a5,s9,618 <main+0x4a0>
      neorv32_gpio_pin_set(NEORV32_MOTOR_FORWARD_LED_GPIO_OUTPUT); 
     510:	00200513          	li	a0,2
     514:	59c000ef          	jal	ra,ab0 <neorv32_gpio_pin_set>
      neorv32_gpio_pin_clr(NEORV32_MOTOR_REVERSE_LED_GPIO_OUTPUT);
     518:	00300513          	li	a0,3
      neorv32_gpio_pin_clr(NEORV32_MOTOR_FORWARD_LED_GPIO_OUTPUT);
     51c:	5c4000ef          	jal	ra,ae0 <neorv32_gpio_pin_clr>
    neorv32_gpio_pin_set(NEORV32_MOTOR_CONTROL_REG_WRITE_GPIO_OUTPUT);  
     520:	02100513          	li	a0,33
     524:	58c000ef          	jal	ra,ab0 <neorv32_gpio_pin_set>
    neorv32_gpio_pin_clr(NEORV32_MOTOR_CONTROL_REG_WRITE_GPIO_OUTPUT); 
     528:	02100513          	li	a0,33
     52c:	5b4000ef          	jal	ra,ae0 <neorv32_gpio_pin_clr>
    if (timer_interrupt_tick == 1){
     530:	d29ff06f          	j	258 <main+0xe0>
          if ( (pcb_motor_start_button == 1) || (python_motor_start_button == 1) ){
     534:	8241c783          	lbu	a5,-2012(gp) # 8000005c <pcb_motor_start_button>
     538:	01978663          	beq	a5,s9,544 <main+0x3cc>
     53c:	8201c783          	lbu	a5,-2016(gp) # 80000058 <python_motor_start_button>
     540:	fb9794e3          	bne	a5,s9,4e8 <main+0x370>
            if (direction == 1){
     544:	03044783          	lbu	a5,48(s0)
     548:	0b978e63          	beq	a5,s9,604 <main+0x48c>
              motor_ctrl_state = MOTOR_REVERSE;
     54c:	00200d13          	li	s10,2
     550:	fb9ff06f          	j	508 <main+0x390>
        motor_speed_control_enable = 1;
     554:	00100793          	li	a5,1
        neorv32_gpio_pin_set(NEORV32_MOTOR_DIRECTION_GPIO_OUTPUT); 
     558:	00000513          	li	a0,0
        motor_speed_control_enable = 1;
     55c:	80f186a3          	sb	a5,-2035(gp) # 80000045 <motor_speed_control_enable>
        neorv32_gpio_pin_set(NEORV32_MOTOR_DIRECTION_GPIO_OUTPUT); 
     560:	550000ef          	jal	ra,ab0 <neorv32_gpio_pin_set>
        neorv32_gpio_pin_set(NEORV32_MOTOR_RUNNING_LED_GPIO_OUTPUT); 
     564:	00100513          	li	a0,1
     568:	548000ef          	jal	ra,ab0 <neorv32_gpio_pin_set>
        if ( (pcb_motor_stop_button == 1) || (python_motor_stop_button == 1) ){
     56c:	8251c783          	lbu	a5,-2011(gp) # 8000005d <pcb_motor_stop_button>
          motor_ctrl_state = MOTOR_STOP;
     570:	00300d13          	li	s10,3
        if ( (pcb_motor_stop_button == 1) || (python_motor_stop_button == 1) ){
     574:	01978a63          	beq	a5,s9,588 <main+0x410>
     578:	8211c783          	lbu	a5,-2015(gp) # 80000059 <python_motor_stop_button>
     57c:	00100d13          	li	s10,1
     580:	01979463          	bne	a5,s9,588 <main+0x410>
          motor_ctrl_state = MOTOR_STOP;
     584:	00300d13          	li	s10,3
        if (direction == 0){
     588:	03044783          	lbu	a5,48(s0)
     58c:	f6079ee3          	bnez	a5,508 <main+0x390>
          change_dir = 1;
     590:	00100713          	li	a4,1
     594:	80e18623          	sb	a4,-2036(gp) # 80000044 <change_dir>
          motor_ctrl_state = MOTOR_STOP;
     598:	00300d13          	li	s10,3
     59c:	f6dff06f          	j	508 <main+0x390>
        motor_speed_control_enable = 1;					
     5a0:	00100793          	li	a5,1
        neorv32_gpio_pin_clr(NEORV32_MOTOR_DIRECTION_GPIO_OUTPUT); 
     5a4:	00000513          	li	a0,0
        motor_speed_control_enable = 1;					
     5a8:	80f186a3          	sb	a5,-2035(gp) # 80000045 <motor_speed_control_enable>
        neorv32_gpio_pin_clr(NEORV32_MOTOR_DIRECTION_GPIO_OUTPUT); 
     5ac:	534000ef          	jal	ra,ae0 <neorv32_gpio_pin_clr>
        neorv32_gpio_pin_set(NEORV32_MOTOR_RUNNING_LED_GPIO_OUTPUT); 
     5b0:	00100513          	li	a0,1
     5b4:	4fc000ef          	jal	ra,ab0 <neorv32_gpio_pin_set>
        if ( (pcb_motor_stop_button == 1) || (python_motor_stop_button == 1) ){
     5b8:	8251c783          	lbu	a5,-2011(gp) # 8000005d <pcb_motor_stop_button>
     5bc:	01978663          	beq	a5,s9,5c8 <main+0x450>
     5c0:	8211c783          	lbu	a5,-2015(gp) # 80000059 <python_motor_stop_button>
     5c4:	01979463          	bne	a5,s9,5cc <main+0x454>
          motor_ctrl_state = MOTOR_STOP;
     5c8:	00300d13          	li	s10,3
        if (direction == 1){
     5cc:	03044783          	lbu	a5,48(s0)
     5d0:	f3979ce3          	bne	a5,s9,508 <main+0x390>
     5d4:	fbdff06f          	j	590 <main+0x418>
        neorv32_pwm_set(0, 0);
     5d8:	00000593          	li	a1,0
     5dc:	00000513          	li	a0,0
        motor_speed_control_enable = 0;
     5e0:	800186a3          	sb	zero,-2035(gp) # 80000045 <motor_speed_control_enable>
        neorv32_pwm_set(0, 0);
     5e4:	610000ef          	jal	ra,bf4 <neorv32_pwm_set>
        if (change_dir == 1){
     5e8:	80c1c683          	lbu	a3,-2036(gp) # 80000044 <change_dir>
     5ec:	03969063          	bne	a3,s9,60c <main+0x494>
          if (motor_actual_rpm == 0){
     5f0:	8101a703          	lw	a4,-2032(gp) # 80000048 <motor_actual_rpm>
     5f4:	fa0712e3          	bnez	a4,598 <main+0x420>
            if (direction == 1){
     5f8:	03044703          	lbu	a4,48(s0)
              change_dir = 0;
     5fc:	80018623          	sb	zero,-2036(gp) # 80000044 <change_dir>
            if (direction == 1){
     600:	f59716e3          	bne	a4,s9,54c <main+0x3d4>
              motor_ctrl_state = MOTOR_FORWARD;
     604:	00100d13          	li	s10,1
     608:	f01ff06f          	j	508 <main+0x390>
          if (motor_actual_rpm == 0){
     60c:	8101a783          	lw	a5,-2032(gp) # 80000048 <motor_actual_rpm>
     610:	ec078ce3          	beqz	a5,4e8 <main+0x370>
     614:	f85ff06f          	j	598 <main+0x420>
      neorv32_gpio_pin_set(NEORV32_MOTOR_REVERSE_LED_GPIO_OUTPUT); 
     618:	00300513          	li	a0,3
     61c:	494000ef          	jal	ra,ab0 <neorv32_gpio_pin_set>
      neorv32_gpio_pin_clr(NEORV32_MOTOR_FORWARD_LED_GPIO_OUTPUT);
     620:	00200513          	li	a0,2
     624:	ef9ff06f          	j	51c <main+0x3a4>
}
     628:	03c12083          	lw	ra,60(sp)
     62c:	03812403          	lw	s0,56(sp)
     630:	03412483          	lw	s1,52(sp)
     634:	03012903          	lw	s2,48(sp)
     638:	02c12983          	lw	s3,44(sp)
     63c:	02812a03          	lw	s4,40(sp)
     640:	02412a83          	lw	s5,36(sp)
     644:	02012b03          	lw	s6,32(sp)
     648:	01c12b83          	lw	s7,28(sp)
     64c:	01812c03          	lw	s8,24(sp)
     650:	01412c83          	lw	s9,20(sp)
     654:	01012d03          	lw	s10,16(sp)
     658:	00c12d83          	lw	s11,12(sp)
     65c:	00100513          	li	a0,1
     660:	04010113          	addi	sp,sp,64
     664:	00008067          	ret

00000668 <decimal_to_bcd>:
  int hundreds_temp = 0;
  int tens_temp = 0;
  int ones_temp = 0;
  
  //Compute thousands value
  if (decimal_input == 0){
     668:	08050463          	beqz	a0,6f0 <decimal_to_bcd+0x88>
    *hundreds = hundreds_temp; 
    *tens = tens_temp; 
    *ones = ones_temp; 
  }

  else if(decimal_input < 1000){
     66c:	3e700793          	li	a5,999
  int thousands_temp = 0;
     670:	00000893          	li	a7,0
  else if(decimal_input < 1000){
     674:	02a7d063          	bge	a5,a0,694 <decimal_to_bcd+0x2c>
  int sub_result_carry_forward = 0;
     678:	00000793          	li	a5,0

  else{
    sub_result = decimal_input;

        while (sub_result >= 0){
          sub_result = sub_result - 1000;
     67c:	c1850513          	addi	a0,a0,-1000

            if (sub_result >= 0){
     680:	00054863          	bltz	a0,690 <decimal_to_bcd+0x28>
                sub_result_carry_forward = sub_result;
                thousands_temp += 1;
     684:	00188893          	addi	a7,a7,1
     688:	00050793          	mv	a5,a0
     68c:	ff1ff06f          	j	67c <decimal_to_bcd+0x14>
     690:	00078513          	mv	a0,a5
            }
        }
      } 
  
  //Compute hundreds value
  if (sub_result_carry_forward >= 100){
     694:	06300793          	li	a5,99
  int hundreds_temp = 0;
     698:	00000813          	li	a6,0
  if (sub_result_carry_forward >= 100){
     69c:	00a7dc63          	bge	a5,a0,6b4 <decimal_to_bcd+0x4c>
    sub_result = sub_result_carry_forward;

    while (sub_result >= 0){
            sub_result = sub_result - 100;
     6a0:	f9c50793          	addi	a5,a0,-100

            if (sub_result >= 0){
     6a4:	0007c863          	bltz	a5,6b4 <decimal_to_bcd+0x4c>
                sub_result_carry_forward = sub_result;
                hundreds_temp += 1;
     6a8:	00180813          	addi	a6,a6,1
     6ac:	00078513          	mv	a0,a5
     6b0:	ff1ff06f          	j	6a0 <decimal_to_bcd+0x38>
            }
    }
  }

  //Compute tens value
  if (sub_result_carry_forward >= 10){
     6b4:	00900313          	li	t1,9
  int tens_temp = 0;
     6b8:	00000793          	li	a5,0
  if (sub_result_carry_forward >= 10){
     6bc:	00a35c63          	bge	t1,a0,6d4 <decimal_to_bcd+0x6c>
    sub_result = sub_result_carry_forward;

    while (sub_result >= 0){
            sub_result = sub_result - 10;
     6c0:	ff650313          	addi	t1,a0,-10

            if (sub_result >= 0){
     6c4:	00034863          	bltz	t1,6d4 <decimal_to_bcd+0x6c>
                sub_result_carry_forward = sub_result;
                tens_temp += 1;
     6c8:	00178793          	addi	a5,a5,1
     6cc:	00030513          	mv	a0,t1
     6d0:	ff1ff06f          	j	6c0 <decimal_to_bcd+0x58>
            }
    }
  }

  //Compute ones value
  if (sub_result_carry_forward >= 1){
     6d4:	00055463          	bgez	a0,6dc <decimal_to_bcd+0x74>
     6d8:	00000513          	li	a0,0
            if (sub_result >= 0){
              ones_temp += 1;
            }
    }
  }
  *thousands = thousands_temp; 
     6dc:	0115a023          	sw	a7,0(a1)
  *hundreds = hundreds_temp; 
     6e0:	01062023          	sw	a6,0(a2)
  *tens = tens_temp; 
     6e4:	00f6a023          	sw	a5,0(a3)
  *ones = ones_temp;
     6e8:	00a72023          	sw	a0,0(a4)
}
     6ec:	00008067          	ret
  int thousands_temp = 0;
     6f0:	00000893          	li	a7,0
  int hundreds_temp = 0;
     6f4:	00000813          	li	a6,0
  int tens_temp = 0;
     6f8:	00000793          	li	a5,0
     6fc:	fe1ff06f          	j	6dc <decimal_to_bcd+0x74>

00000700 <set_pwm_duty_cycle>:

    // limit duty cycle to within min and max ranges
    if (duty_cycle < PWM_MIN_DUTY_CYCLE) {
        duty_cycle = PWM_MIN_DUTY_CYCLE;
    }
    if (duty_cycle > PWM_MAX_DUTY_CYCLE) {
     700:	0ff00793          	li	a5,255
     704:	00a7da63          	bge	a5,a0,718 <set_pwm_duty_cycle+0x18>
     708:	0ff00513          	li	a0,255
        duty_cycle = PWM_MAX_DUTY_CYCLE;
    }
    
    // set the PWM duty cycle output to within min and max ranges
    neorv32_pwm_set(0, duty_cycle);
     70c:	0ff57593          	zext.b	a1,a0
     710:	00000513          	li	a0,0
     714:	4e00006f          	j	bf4 <neorv32_pwm_set>
     718:	fe055ae3          	bgez	a0,70c <set_pwm_duty_cycle+0xc>
     71c:	00000513          	li	a0,0
     720:	fedff06f          	j	70c <set_pwm_duty_cycle+0xc>

00000724 <motor_control_pi>:
void motor_control_pi(int setpoint, int current_speed){
     724:	fe010113          	addi	sp,sp,-32
     728:	00112e23          	sw	ra,28(sp)
     72c:	00812c23          	sw	s0,24(sp)
     730:	00912a23          	sw	s1,20(sp)
     734:	01212823          	sw	s2,16(sp)
     738:	00058493          	mv	s1,a1
     73c:	01312623          	sw	s3,12(sp)
     740:	01412423          	sw	s4,8(sp)
    float error = (float)setpoint - (float)current_speed;
     744:	728020ef          	jal	ra,2e6c <__floatsisf>
     748:	00050413          	mv	s0,a0
     74c:	00048513          	mv	a0,s1
     750:	71c020ef          	jal	ra,2e6c <__floatsisf>
     754:	00050593          	mv	a1,a0
     758:	00040513          	mv	a0,s0
     75c:	1e4020ef          	jal	ra,2940 <__subsf3>
    pi_integral += error * (PI_UPDATE_PERIOD_MS / 1000.0);
     760:	021020ef          	jal	ra,2f80 <__extendsfdf2>
     764:	80000a37          	lui	s4,0x80000
     768:	00050913          	mv	s2,a0
     76c:	040a2503          	lw	a0,64(s4) # 80000040 <__crt0_stack_end+0xffffe041>
     770:	00058493          	mv	s1,a1
     774:	00d020ef          	jal	ra,2f80 <__extendsfdf2>
     778:	800007b7          	lui	a5,0x80000
     77c:	0007a603          	lw	a2,0(a5) # 80000000 <__crt0_stack_end+0xffffe001>
     780:	0047a683          	lw	a3,4(a5)
     784:	00050993          	mv	s3,a0
     788:	00058413          	mv	s0,a1
     78c:	00090513          	mv	a0,s2
     790:	00048593          	mv	a1,s1
     794:	5dd000ef          	jal	ra,1570 <__muldf3>
     798:	00050613          	mv	a2,a0
     79c:	00058693          	mv	a3,a1
     7a0:	00098513          	mv	a0,s3
     7a4:	00040593          	mv	a1,s0
     7a8:	5dc000ef          	jal	ra,d84 <__adddf3>
     7ac:	0b1020ef          	jal	ra,305c <__truncdfsf2>
    if (pi_integral < MIN_INTEGRAL) {
     7b0:	800007b7          	lui	a5,0x80000
     7b4:	01c7a983          	lw	s3,28(a5) # 8000001c <__crt0_stack_end+0xffffe01d>
    pi_integral += error * (PI_UPDATE_PERIOD_MS / 1000.0);
     7b8:	00050413          	mv	s0,a0
    if (pi_integral < MIN_INTEGRAL) {
     7bc:	00098593          	mv	a1,s3
     7c0:	541010ef          	jal	ra,2500 <__lesf2>
     7c4:	0e054863          	bltz	a0,8b4 <motor_control_pi+0x190>
    if (pi_integral > MAX_INTEGRAL) {
     7c8:	800007b7          	lui	a5,0x80000
     7cc:	0187a983          	lw	s3,24(a5) # 80000018 <__crt0_stack_end+0xffffe019>
     7d0:	00040513          	mv	a0,s0
     7d4:	00098593          	mv	a1,s3
     7d8:	44d010ef          	jal	ra,2424 <__gesf2>
     7dc:	0ca04c63          	bgtz	a0,8b4 <motor_control_pi+0x190>
    float pi_output = (Kp * error) + (Ki * pi_integral);
     7e0:	00040513          	mv	a0,s0
    pi_integral += error * (PI_UPDATE_PERIOD_MS / 1000.0);
     7e4:	048a2023          	sw	s0,64(s4)
    float pi_output = (Kp * error) + (Ki * pi_integral);
     7e8:	798020ef          	jal	ra,2f80 <__extendsfdf2>
     7ec:	800007b7          	lui	a5,0x80000
     7f0:	0087a603          	lw	a2,8(a5) # 80000008 <__crt0_stack_end+0xffffe009>
     7f4:	00c7a683          	lw	a3,12(a5)
     7f8:	579000ef          	jal	ra,1570 <__muldf3>
     7fc:	800007b7          	lui	a5,0x80000
     800:	0107a603          	lw	a2,16(a5) # 80000010 <__crt0_stack_end+0xffffe011>
     804:	0147a683          	lw	a3,20(a5)
     808:	00058413          	mv	s0,a1
     80c:	00050993          	mv	s3,a0
     810:	00048593          	mv	a1,s1
     814:	00090513          	mv	a0,s2
     818:	559000ef          	jal	ra,1570 <__muldf3>
     81c:	00050613          	mv	a2,a0
     820:	00058693          	mv	a3,a1
     824:	00098513          	mv	a0,s3
     828:	00040593          	mv	a1,s0
     82c:	558000ef          	jal	ra,d84 <__adddf3>
     830:	02d020ef          	jal	ra,305c <__truncdfsf2>
    if (pi_output < MIN_RPM_ERROR) {
     834:	800007b7          	lui	a5,0x80000
     838:	0247a903          	lw	s2,36(a5) # 80000024 <__crt0_stack_end+0xffffe025>
    float pi_output = (Kp * error) + (Ki * pi_integral);
     83c:	00050413          	mv	s0,a0
    if (pi_output < MIN_RPM_ERROR) {
     840:	800004b7          	lui	s1,0x80000
     844:	00090593          	mv	a1,s2
     848:	4b9010ef          	jal	ra,2500 <__lesf2>
     84c:	06054863          	bltz	a0,8bc <motor_control_pi+0x198>
    if (pi_output > MAX_RPM_ERROR) {
     850:	0204a903          	lw	s2,32(s1) # 80000020 <__crt0_stack_end+0xffffe021>
     854:	00040513          	mv	a0,s0
     858:	00090593          	mv	a1,s2
     85c:	3c9010ef          	jal	ra,2424 <__gesf2>
     860:	04a04e63          	bgtz	a0,8bc <motor_control_pi+0x198>
    int pi_duty_cycle = ((pi_output - MIN_RPM_ERROR) * (PWM_MAX_DUTY_CYCLE - PWM_MIN_DUTY_CYCLE)) / (MAX_RPM_ERROR - MIN_RPM_ERROR) + PWM_MIN_DUTY_CYCLE;
     864:	0204a583          	lw	a1,32(s1)
     868:	00040513          	mv	a0,s0
     86c:	3c0010ef          	jal	ra,1c2c <__addsf3>
     870:	800007b7          	lui	a5,0x80000
     874:	0287a583          	lw	a1,40(a5) # 80000028 <__crt0_stack_end+0xffffe029>
     878:	565010ef          	jal	ra,25dc <__mulsf3>
     87c:	800007b7          	lui	a5,0x80000
     880:	02c7a583          	lw	a1,44(a5) # 8000002c <__crt0_stack_end+0xffffe02d>
     884:	019010ef          	jal	ra,209c <__divsf3>
     888:	00000593          	li	a1,0
     88c:	3a0010ef          	jal	ra,1c2c <__addsf3>
     890:	56c020ef          	jal	ra,2dfc <__fixsfsi>
}
     894:	01812403          	lw	s0,24(sp)
     898:	01c12083          	lw	ra,28(sp)
     89c:	01412483          	lw	s1,20(sp)
     8a0:	01012903          	lw	s2,16(sp)
     8a4:	00c12983          	lw	s3,12(sp)
     8a8:	00812a03          	lw	s4,8(sp)
     8ac:	02010113          	addi	sp,sp,32
    set_pwm_duty_cycle(pi_duty_cycle);
     8b0:	e51ff06f          	j	700 <set_pwm_duty_cycle>
     8b4:	00098413          	mv	s0,s3
     8b8:	f29ff06f          	j	7e0 <motor_control_pi+0xbc>
        pi_output = MAX_RPM_ERROR;
     8bc:	00090413          	mv	s0,s2
     8c0:	fa5ff06f          	j	864 <motor_control_pi+0x140>

000008c4 <global_trap_handler>:
void __attribute__((interrupt)) global_trap_handler(void) {
     8c4:	fa010113          	addi	sp,sp,-96
     8c8:	04112e23          	sw	ra,92(sp)
     8cc:	04512c23          	sw	t0,88(sp)
     8d0:	04612a23          	sw	t1,84(sp)
     8d4:	04712823          	sw	t2,80(sp)
     8d8:	04812623          	sw	s0,76(sp)
     8dc:	04912423          	sw	s1,72(sp)
     8e0:	04a12223          	sw	a0,68(sp)
     8e4:	04b12023          	sw	a1,64(sp)
     8e8:	02c12e23          	sw	a2,60(sp)
     8ec:	02d12c23          	sw	a3,56(sp)
     8f0:	02e12a23          	sw	a4,52(sp)
     8f4:	02f12823          	sw	a5,48(sp)
     8f8:	03012623          	sw	a6,44(sp)
     8fc:	03112423          	sw	a7,40(sp)
     900:	03212223          	sw	s2,36(sp)
     904:	03312023          	sw	s3,32(sp)
     908:	01412e23          	sw	s4,28(sp)
     90c:	01512c23          	sw	s5,24(sp)
     910:	01612a23          	sw	s6,20(sp)
     914:	01c12823          	sw	t3,16(sp)
     918:	01d12623          	sw	t4,12(sp)
     91c:	01e12423          	sw	t5,8(sp)
     920:	01f12223          	sw	t6,4(sp)
  asm volatile ("csrr %[result], %[input_i]" : [result] "=r" (csr_data) : [input_i] "i" (csr_id));
     924:	342027f3          	csrr	a5,mcause
  uint32_t src = NEORV32_XIRQ->ESC;
     928:	fffff737          	lui	a4,0xfffff
     92c:	30872403          	lw	s0,776(a4) # fffff308 <__crt0_stack_end+0x7fffd309>
  if (mcause == GPTMR_TRAP_CODE) {
     930:	80000737          	lui	a4,0x80000
     934:	01c70693          	addi	a3,a4,28 # 8000001c <__crt0_stack_end+0xffffe01d>
     938:	10d79263          	bne	a5,a3,a3c <global_trap_handler+0x178>
    neorv32_gptmr_trigger_matched(); 
     93c:	25c000ef          	jal	ra,b98 <neorv32_gptmr_trigger_matched>
    timer_interrupt_tick = 1;
     940:	800007b7          	lui	a5,0x80000
     944:	00100a13          	li	s4,1
     948:	03478f23          	sb	s4,62(a5) # 8000003e <__crt0_stack_end+0xffffe03f>
    gpio_inputs = neorv32_gpio_port_get();
     94c:	1fc000ef          	jal	ra,b48 <neorv32_gpio_port_get>
     950:	84a1a023          	sw	a0,-1984(gp) # 80000078 <gpio_inputs>
     954:	84b1a223          	sw	a1,-1980(gp) # 8000007c <gpio_inputs+0x4>
    motor_encoder_counter_gpio_lower = gpio_inputs & 0xFFFFFFFF;
     958:	8401aa83          	lw	s5,-1984(gp) # 80000078 <gpio_inputs>
    new_encoder_pulses_count = abs(motor_encoder_counter_gpio_lower - last_encoder_pulses_count);                                                
     95c:	8301a503          	lw	a0,-2000(gp) # 80000068 <last_encoder_pulses_count>
    motor_encoder_counter_gpio_lower = gpio_inputs & 0xFFFFFFFF;
     960:	8351ac23          	sw	s5,-1992(gp) # 80000070 <motor_encoder_counter_gpio_lower>
    new_encoder_pulses_count = abs(motor_encoder_counter_gpio_lower - last_encoder_pulses_count);                                                
     964:	40aa8533          	sub	a0,s5,a0
     968:	41f55793          	srai	a5,a0,0x1f
     96c:	00a7c533          	xor	a0,a5,a0
    motor_actual_rpm = ( (new_encoder_pulses_count * 60000) / ENCODER_PPR);
     970:	0000f5b7          	lui	a1,0xf
    new_encoder_pulses_count = abs(motor_encoder_counter_gpio_lower - last_encoder_pulses_count);                                                
     974:	40f50533          	sub	a0,a0,a5
    motor_actual_rpm = ( (new_encoder_pulses_count * 60000) / ENCODER_PPR);
     978:	a6058593          	addi	a1,a1,-1440 # ea60 <__RODATA_END__+0xb614>
    new_encoder_pulses_count = abs(motor_encoder_counter_gpio_lower - last_encoder_pulses_count);                                                
     97c:	82a1aa23          	sw	a0,-1996(gp) # 8000006c <new_encoder_pulses_count>
    motor_actual_rpm = ( (new_encoder_pulses_count * 60000) / ENCODER_PPR);
     980:	06d020ef          	jal	ra,31ec <__mulsi3>
     984:	000015b7          	lui	a1,0x1
     988:	fa058593          	addi	a1,a1,-96 # fa0 <__adddf3+0x21c>
     98c:	08d020ef          	jal	ra,3218 <__hidden___udivsi3>
     990:	80a1a823          	sw	a0,-2032(gp) # 80000048 <motor_actual_rpm>
    if (motor_speed_control_enable == 1){
     994:	80d1c783          	lbu	a5,-2035(gp) # 80000045 <motor_speed_control_enable>
    motor_encoder_counter_gpio_lower = gpio_inputs & 0xFFFFFFFF;
     998:	8441ab03          	lw	s6,-1980(gp) # 8000007c <gpio_inputs+0x4>
    last_encoder_pulses_count = motor_encoder_counter_gpio_lower;
     99c:	8351a823          	sw	s5,-2000(gp) # 80000068 <last_encoder_pulses_count>
    motor_actual_rpm = ( (new_encoder_pulses_count * 60000) / ENCODER_PPR);
     9a0:	00050593          	mv	a1,a0
    if (motor_speed_control_enable == 1){
     9a4:	01479863          	bne	a5,s4,9b4 <global_trap_handler+0xf0>
      motor_control_pi(motor_setpoint_rpm, motor_actual_rpm);
     9a8:	800007b7          	lui	a5,0x80000
     9ac:	0347a503          	lw	a0,52(a5) # 80000034 <__crt0_stack_end+0xffffe035>
     9b0:	d75ff0ef          	jal	ra,724 <motor_control_pi>
    control_inputs_gpio_upper = (gpio_inputs >> 32) & 0xFFFFFFFF;
     9b4:	8401a603          	lw	a2,-1984(gp) # 80000078 <gpio_inputs>
     9b8:	8441a683          	lw	a3,-1980(gp) # 8000007c <gpio_inputs+0x4>
     9bc:	82d1a623          	sw	a3,-2004(gp) # 80000064 <control_inputs_gpio_upper>
  NEORV32_XIRQ->EIP = ~(1 << src);
     9c0:	00100793          	li	a5,1
     9c4:	008797b3          	sll	a5,a5,s0
     9c8:	fffff737          	lui	a4,0xfffff
}
     9cc:	04c12403          	lw	s0,76(sp)
  NEORV32_XIRQ->EIP = ~(1 << src);
     9d0:	fff7c793          	not	a5,a5
     9d4:	30f72223          	sw	a5,772(a4) # fffff304 <__crt0_stack_end+0x7fffd305>
  NEORV32_XIRQ->ESC = 0;
     9d8:	30072423          	sw	zero,776(a4)
}
     9dc:	05c12083          	lw	ra,92(sp)
     9e0:	05812283          	lw	t0,88(sp)
     9e4:	05412303          	lw	t1,84(sp)
     9e8:	05012383          	lw	t2,80(sp)
     9ec:	04812483          	lw	s1,72(sp)
     9f0:	04412503          	lw	a0,68(sp)
     9f4:	04012583          	lw	a1,64(sp)
     9f8:	03c12603          	lw	a2,60(sp)
     9fc:	03812683          	lw	a3,56(sp)
     a00:	03412703          	lw	a4,52(sp)
     a04:	03012783          	lw	a5,48(sp)
     a08:	02c12803          	lw	a6,44(sp)
     a0c:	02812883          	lw	a7,40(sp)
     a10:	02412903          	lw	s2,36(sp)
     a14:	02012983          	lw	s3,32(sp)
     a18:	01c12a03          	lw	s4,28(sp)
     a1c:	01812a83          	lw	s5,24(sp)
     a20:	01412b03          	lw	s6,20(sp)
     a24:	01012e03          	lw	t3,16(sp)
     a28:	00c12e83          	lw	t4,12(sp)
     a2c:	00812f03          	lw	t5,8(sp)
     a30:	00412f83          	lw	t6,4(sp)
     a34:	06010113          	addi	sp,sp,96
     a38:	30200073          	mret
  else if (mcause == 0x80000018) { 
     a3c:	01870713          	addi	a4,a4,24
     a40:	04e79263          	bne	a5,a4,a84 <global_trap_handler+0x1c0>
    if (src == NEORV32_PCB_SETPOINT_ENCODER_CHA_RISING_XIRQ){  
     a44:	f6041ee3          	bnez	s0,9c0 <global_trap_handler+0xfc>
      if (neorv32_gpio_pin_get(35) == 0){
     a48:	02300513          	li	a0,35
     a4c:	0c8000ef          	jal	ra,b14 <neorv32_gpio_pin_get>
     a50:	800007b7          	lui	a5,0x80000
        if ( (motor_setpoint_rpm + 50) <= MOTOR_SETPOINT_MAX){
     a54:	0347a703          	lw	a4,52(a5) # 80000034 <__crt0_stack_end+0xffffe035>
      if (neorv32_gpio_pin_get(35) == 0){
     a58:	00051e63          	bnez	a0,a74 <global_trap_handler+0x1b0>
        if ( (motor_setpoint_rpm + 50) <= MOTOR_SETPOINT_MAX){
     a5c:	000016b7          	lui	a3,0x1
     a60:	03270713          	addi	a4,a4,50
     a64:	fa068693          	addi	a3,a3,-96 # fa0 <__adddf3+0x21c>
     a68:	f4e6ece3          	bltu	a3,a4,9c0 <global_trap_handler+0xfc>
          motor_setpoint_rpm -= 50;
     a6c:	02e7aa23          	sw	a4,52(a5)
     a70:	f51ff06f          	j	9c0 <global_trap_handler+0xfc>
        if ( (motor_setpoint_rpm - 50) >= MOTOR_SETPOINT_MIN){
     a74:	fce70713          	addi	a4,a4,-50
     a78:	7cf00693          	li	a3,1999
     a7c:	f4e6f2e3          	bgeu	a3,a4,9c0 <global_trap_handler+0xfc>
     a80:	fedff06f          	j	a6c <global_trap_handler+0x1a8>
  else if (((mcause >> 31) == 0) && (mcause != TRAP_CODE_I_ACCESS)) {
     a84:	f207cee3          	bltz	a5,9c0 <global_trap_handler+0xfc>
     a88:	00100713          	li	a4,1
     a8c:	f2e78ae3          	beq	a5,a4,9c0 <global_trap_handler+0xfc>
     a90:	341027f3          	csrr	a5,mepc
    rte_mepc += 4; 
     a94:	00478793          	addi	a5,a5,4
  asm volatile ("csrw %[input_i], %[input_j]" :  : [input_i] "i" (csr_id), [input_j] "r" (csr_data));
     a98:	34179073          	csrw	mepc,a5
}
     a9c:	f25ff06f          	j	9c0 <global_trap_handler+0xfc>

00000aa0 <neorv32_gpio_available>:
 *
 * @return 0 if GPIO was not synthesized, 1 if GPIO is available.
 **************************************************************************/
int neorv32_gpio_available(void) {

  if (NEORV32_SYSINFO->SOC & (1 << SYSINFO_SOC_IO_GPIO)) {
     aa0:	e0802503          	lw	a0,-504(zero) # fffffe08 <__crt0_stack_end+0x7fffde09>
     aa4:	00f55513          	srli	a0,a0,0xf
    return 1;
  }
  else {
    return 0;
  }
}
     aa8:	00157513          	andi	a0,a0,1
     aac:	00008067          	ret

00000ab0 <neorv32_gpio_pin_set>:
 *
 * @param[in] pin Output pin number to be set (0..63).
 **************************************************************************/
void neorv32_gpio_pin_set(int pin) {

  uint32_t mask = (uint32_t)(1 << (pin & 0x1f));
     ab0:	00100793          	li	a5,1

  if (pin < 32) {
     ab4:	01f00713          	li	a4,31
  uint32_t mask = (uint32_t)(1 << (pin & 0x1f));
     ab8:	00a797b3          	sll	a5,a5,a0
  if (pin < 32) {
     abc:	00a74a63          	blt	a4,a0,ad0 <neorv32_gpio_pin_set+0x20>
    NEORV32_GPIO->OUTPUT_LO |= mask;
     ac0:	c0802703          	lw	a4,-1016(zero) # fffffc08 <__crt0_stack_end+0x7fffdc09>
     ac4:	00f767b3          	or	a5,a4,a5
     ac8:	c0f02423          	sw	a5,-1016(zero) # fffffc08 <__crt0_stack_end+0x7fffdc09>
     acc:	00008067          	ret
  }
  else {
    NEORV32_GPIO->OUTPUT_HI |= mask;
     ad0:	c0c02703          	lw	a4,-1012(zero) # fffffc0c <__crt0_stack_end+0x7fffdc0d>
     ad4:	00f767b3          	or	a5,a4,a5
     ad8:	c0f02623          	sw	a5,-1012(zero) # fffffc0c <__crt0_stack_end+0x7fffdc0d>
  }
}
     adc:	00008067          	ret

00000ae0 <neorv32_gpio_pin_clr>:
 *
 * @param[in] pin Output pin number to be cleared (0..63).
 **************************************************************************/
void neorv32_gpio_pin_clr(int pin) {

  uint32_t mask = (uint32_t)(1 << (pin & 0x1f));
     ae0:	00100793          	li	a5,1
     ae4:	00a797b3          	sll	a5,a5,a0

  if (pin < 32) {
     ae8:	01f00713          	li	a4,31
    NEORV32_GPIO->OUTPUT_LO &= ~mask;
     aec:	fff7c793          	not	a5,a5
  if (pin < 32) {
     af0:	00a74a63          	blt	a4,a0,b04 <neorv32_gpio_pin_clr+0x24>
    NEORV32_GPIO->OUTPUT_LO &= ~mask;
     af4:	c0802703          	lw	a4,-1016(zero) # fffffc08 <__crt0_stack_end+0x7fffdc09>
     af8:	00f777b3          	and	a5,a4,a5
     afc:	c0f02423          	sw	a5,-1016(zero) # fffffc08 <__crt0_stack_end+0x7fffdc09>
     b00:	00008067          	ret
  }
  else {
    NEORV32_GPIO->OUTPUT_HI &= ~mask;
     b04:	c0c02703          	lw	a4,-1012(zero) # fffffc0c <__crt0_stack_end+0x7fffdc0d>
     b08:	00f777b3          	and	a5,a4,a5
     b0c:	c0f02623          	sw	a5,-1012(zero) # fffffc0c <__crt0_stack_end+0x7fffdc0d>
  }
}
     b10:	00008067          	ret

00000b14 <neorv32_gpio_pin_get>:
 * @param[in] pin Input pin to be read (0..63).
 * @return =0 if pin is low, !=0 if pin is high.
 **************************************************************************/
uint32_t neorv32_gpio_pin_get(int pin) {

  uint32_t mask = (uint32_t)(1 << (pin & 0x1f));
     b14:	00100793          	li	a5,1

  if (pin < 32) {
     b18:	01f00713          	li	a4,31
  uint32_t mask = (uint32_t)(1 << (pin & 0x1f));
     b1c:	00a797b3          	sll	a5,a5,a0
  if (pin < 32) {
     b20:	00a74863          	blt	a4,a0,b30 <neorv32_gpio_pin_get+0x1c>
    return NEORV32_GPIO->INPUT_LO & mask;
     b24:	c0002703          	lw	a4,-1024(zero) # fffffc00 <__crt0_stack_end+0x7fffdc01>
  }
  else {
    return NEORV32_GPIO->INPUT_HI & mask;
     b28:	00f77533          	and	a0,a4,a5
  }
}
     b2c:	00008067          	ret
    return NEORV32_GPIO->INPUT_HI & mask;
     b30:	c0402703          	lw	a4,-1020(zero) # fffffc04 <__crt0_stack_end+0x7fffdc05>
     b34:	ff5ff06f          	j	b28 <neorv32_gpio_pin_get+0x14>

00000b38 <neorv32_gpio_port_set>:
    uint64_t uint64;
    uint32_t uint32[sizeof(uint64_t)/sizeof(uint32_t)];
  } data;

  data.uint64 = port_data;
  NEORV32_GPIO->OUTPUT_LO = data.uint32[0];
     b38:	c0000793          	li	a5,-1024
     b3c:	00a7a423          	sw	a0,8(a5)
  NEORV32_GPIO->OUTPUT_HI = data.uint32[1];
     b40:	00b7a623          	sw	a1,12(a5)
}
     b44:	00008067          	ret

00000b48 <neorv32_gpio_port_get>:
  union {
    uint64_t uint64;
    uint32_t uint32[sizeof(uint64_t)/sizeof(uint32_t)];
  } data;

  data.uint32[0] = NEORV32_GPIO->INPUT_LO;
     b48:	c0000793          	li	a5,-1024
     b4c:	0007a503          	lw	a0,0(a5)
  data.uint32[1] = NEORV32_GPIO->INPUT_HI;
     b50:	0047a583          	lw	a1,4(a5)

  return data.uint64;
}
     b54:	00008067          	ret

00000b58 <neorv32_gptmr_available>:
 *
 * @return 0 if GPTMR was not synthesized, 1 if GPTMR is available.
 **************************************************************************/
int neorv32_gptmr_available(void) {

  if (NEORV32_SYSINFO->SOC & (1 << SYSINFO_SOC_IO_GPTMR)) {
     b58:	e0802503          	lw	a0,-504(zero) # fffffe08 <__crt0_stack_end+0x7fffde09>
     b5c:	01c55513          	srli	a0,a0,0x1c
    return 1;
  }
  else {
    return 0;
  }
}
     b60:	00157513          	andi	a0,a0,1
     b64:	00008067          	ret

00000b68 <neorv32_gptmr_setup>:
 * @param[in] threshold Threshold value, counter will reset to zero when reaching this.
 * @param[in] match_irq Fire interrupt when counter matches threshold value.
 **************************************************************************/
void neorv32_gptmr_setup(int prsc, uint32_t threshold, int match_irq) {

  NEORV32_GPTMR->CTRL  = 0; // reset configuration
     b68:	fffff7b7          	lui	a5,0xfffff
  NEORV32_GPTMR->THRES = threshold;
  NEORV32_GPTMR->COUNT = 0; // reset counter

  uint32_t tmp = 0;
  tmp |= (uint32_t)(1         & 0x01) << GPTMR_CTRL_EN;
  tmp |= (uint32_t)(prsc      & 0x07) << GPTMR_CTRL_PRSC0;
     b6c:	00151513          	slli	a0,a0,0x1
  tmp |= (uint32_t)(match_irq & 0x01) << GPTMR_CTRL_IRQM;
     b70:	00461613          	slli	a2,a2,0x4
  NEORV32_GPTMR->CTRL  = 0; // reset configuration
     b74:	1007a023          	sw	zero,256(a5) # fffff100 <__crt0_stack_end+0x7fffd101>
  tmp |= (uint32_t)(prsc      & 0x07) << GPTMR_CTRL_PRSC0;
     b78:	00e57513          	andi	a0,a0,14
  tmp |= (uint32_t)(match_irq & 0x01) << GPTMR_CTRL_IRQM;
     b7c:	01067613          	andi	a2,a2,16
  NEORV32_GPTMR->THRES = threshold;
     b80:	10b7a223          	sw	a1,260(a5)
  tmp |= (uint32_t)(match_irq & 0x01) << GPTMR_CTRL_IRQM;
     b84:	00c56533          	or	a0,a0,a2
  NEORV32_GPTMR->COUNT = 0; // reset counter
     b88:	1007a423          	sw	zero,264(a5)
  tmp |= (uint32_t)(match_irq & 0x01) << GPTMR_CTRL_IRQM;
     b8c:	00156513          	ori	a0,a0,1
  NEORV32_GPTMR->CTRL = tmp;
     b90:	10a7a023          	sw	a0,256(a5)
}
     b94:	00008067          	ret

00000b98 <neorv32_gptmr_trigger_matched>:
 *
 * @return 1 if match trigger has fired, 0 if not.
 **************************************************************************/
int neorv32_gptmr_trigger_matched(void) {

  uint32_t tmp = NEORV32_GPTMR->CTRL;
     b98:	fffff6b7          	lui	a3,0xfffff
     b9c:	1006a783          	lw	a5,256(a3) # fffff100 <__crt0_stack_end+0x7fffd101>

  if (tmp & (1 << GPTMR_CTRL_TRIGM)) {
     ba0:	40000737          	lui	a4,0x40000
    tmp &= ~((uint32_t)(1 << GPTMR_CTRL_TRIGM));
    NEORV32_GPTMR->CTRL = tmp;
    return 1;
  }
  else {
    return 0;
     ba4:	00000513          	li	a0,0
  if (tmp & (1 << GPTMR_CTRL_TRIGM)) {
     ba8:	00e7f733          	and	a4,a5,a4
     bac:	00070c63          	beqz	a4,bc4 <neorv32_gptmr_trigger_matched+0x2c>
    tmp &= ~((uint32_t)(1 << GPTMR_CTRL_TRIGM));
     bb0:	c0000737          	lui	a4,0xc0000
     bb4:	fff70713          	addi	a4,a4,-1 # bfffffff <__crt0_stack_end+0x3fffe000>
     bb8:	00e7f7b3          	and	a5,a5,a4
    NEORV32_GPTMR->CTRL = tmp;
     bbc:	10f6a023          	sw	a5,256(a3)
    return 1;
     bc0:	00100513          	li	a0,1
  }
}
     bc4:	00008067          	ret

00000bc8 <neorv32_pwm_available>:
 *
 * @return 0 if PWM was not synthesized, 1 if PWM is available.
 **************************************************************************/
int neorv32_pwm_available(void) {

  if (NEORV32_SYSINFO->SOC & (1 << SYSINFO_SOC_IO_PWM)) {
     bc8:	e0802503          	lw	a0,-504(zero) # fffffe08 <__crt0_stack_end+0x7fffde09>
     bcc:	01455513          	srli	a0,a0,0x14
    return 1;
  }
  else {
    return 0;
  }
}
     bd0:	00157513          	andi	a0,a0,1
     bd4:	00008067          	ret

00000bd8 <neorv32_pwm_setup>:

  uint32_t ct_enable = 1;
  ct_enable = ct_enable << PWM_CTRL_EN;

  uint32_t ct_prsc = (uint32_t)(prsc & 0x07);
  ct_prsc = ct_prsc << PWM_CTRL_PRSC0;
     bd8:	00151513          	slli	a0,a0,0x1
  NEORV32_PWM->CTRL = 0; // reset
     bdc:	fffff7b7          	lui	a5,0xfffff
  ct_prsc = ct_prsc << PWM_CTRL_PRSC0;
     be0:	00e57513          	andi	a0,a0,14
  NEORV32_PWM->CTRL = 0; // reset
     be4:	0007a023          	sw	zero,0(a5) # fffff000 <__crt0_stack_end+0x7fffd001>

  NEORV32_PWM->CTRL = ct_enable | ct_prsc;
     be8:	00156513          	ori	a0,a0,1
     bec:	00a7a023          	sw	a0,0(a5)
}
     bf0:	00008067          	ret

00000bf4 <neorv32_pwm_set>:
 * @param[in] channel Channel select (0..11).
 * @param[in] dc Duty cycle (8-bit, LSB-aligned).
 **************************************************************************/
void neorv32_pwm_set(int channel, uint8_t dc) {

  if (channel > 11) {
     bf4:	00b00793          	li	a5,11
     bf8:	04a7ce63          	blt	a5,a0,c54 <neorv32_pwm_set+0x60>
  }

  const uint32_t dc_mask = 0xff;
  uint32_t dc_new  = (uint32_t)dc;

  uint32_t tmp = NEORV32_PWM->DC[channel/4];
     bfc:	41f55793          	srai	a5,a0,0x1f
     c00:	0037f793          	andi	a5,a5,3
     c04:	00a787b3          	add	a5,a5,a0
     c08:	ffc7f793          	andi	a5,a5,-4
     c0c:	fffff737          	lui	a4,0xfffff
     c10:	00f70733          	add	a4,a4,a5

  tmp &= ~(dc_mask << ((channel % 4) * 8)); // clear previous duty cycle
     c14:	800007b7          	lui	a5,0x80000
     c18:	00378793          	addi	a5,a5,3 # 80000003 <__crt0_stack_end+0xffffe004>
  uint32_t tmp = NEORV32_PWM->DC[channel/4];
     c1c:	00472683          	lw	a3,4(a4) # fffff004 <__crt0_stack_end+0x7fffd005>
  tmp &= ~(dc_mask << ((channel % 4) * 8)); // clear previous duty cycle
     c20:	00f57533          	and	a0,a0,a5
     c24:	00055863          	bgez	a0,c34 <neorv32_pwm_set+0x40>
     c28:	fff50513          	addi	a0,a0,-1
     c2c:	ffc56513          	ori	a0,a0,-4
     c30:	00150513          	addi	a0,a0,1
     c34:	00351513          	slli	a0,a0,0x3
     c38:	0ff00793          	li	a5,255
     c3c:	00a797b3          	sll	a5,a5,a0
     c40:	fff7c793          	not	a5,a5
     c44:	00d7f7b3          	and	a5,a5,a3
  tmp |=   dc_new  << ((channel % 4) * 8);  // set new duty cycle
     c48:	00a595b3          	sll	a1,a1,a0
     c4c:	00f5e5b3          	or	a1,a1,a5

  NEORV32_PWM->DC[channel/4] = tmp;
     c50:	00b72223          	sw	a1,4(a4)
}
     c54:	00008067          	ret

00000c58 <neorv32_rte_handler_install>:
 **************************************************************************/
int neorv32_rte_handler_install(int id, void (*handler)(void)) {

  // id valid?
  uint32_t index = (uint32_t)id;
  if (index < ((uint32_t)NEORV32_RTE_NUM_TRAPS)) {
     c58:	01c00793          	li	a5,28
     c5c:	02a7e063          	bltu	a5,a0,c7c <neorv32_rte_handler_install+0x24>
    __neorv32_rte_vector_lut[index] = (uint32_t)handler; // install handler
     c60:	800007b7          	lui	a5,0x80000
     c64:	00251513          	slli	a0,a0,0x2
     c68:	09478793          	addi	a5,a5,148 # 80000094 <__crt0_stack_end+0xffffe095>
     c6c:	00a787b3          	add	a5,a5,a0
     c70:	00b7a023          	sw	a1,0(a5)
    return 0;
     c74:	00000513          	li	a0,0
     c78:	00008067          	ret
  }
  return -1;
     c7c:	fff00513          	li	a0,-1
}
     c80:	00008067          	ret

00000c84 <__neorv32_xirq_core>:

/**********************************************************************//**
 * This is the actual second-level (F)IRQ handler for the XIRQ. It will
 * call the previously installed handler if an XIRQ fires.
 **************************************************************************/
static void __neorv32_xirq_core(void) {
     c84:	ff010113          	addi	sp,sp,-16
     c88:	00812423          	sw	s0,8(sp)

  // get highest-priority XIRQ channel
  uint32_t src = NEORV32_XIRQ->ESC;
     c8c:	fffff437          	lui	s0,0xfffff
     c90:	30842703          	lw	a4,776(s0) # fffff308 <__crt0_stack_end+0x7fffd309>

  // clear the currently pending XIRQ interrupt
  NEORV32_XIRQ->EIP = ~(1 << src);
     c94:	00100793          	li	a5,1
static void __neorv32_xirq_core(void) {
     c98:	00112623          	sw	ra,12(sp)
  NEORV32_XIRQ->EIP = ~(1 << src);
     c9c:	00e797b3          	sll	a5,a5,a4
     ca0:	fff7c793          	not	a5,a5
     ca4:	30f42223          	sw	a5,772(s0)

  // execute handler
  uint32_t xirq_handler = __neorv32_xirq_vector_lut[src];
     ca8:	00271713          	slli	a4,a4,0x2
     cac:	8d018793          	addi	a5,gp,-1840 # 80000108 <__neorv32_xirq_vector_lut>
     cb0:	00e787b3          	add	a5,a5,a4
  void (*handler_pnt)(void);
  handler_pnt = (void*)xirq_handler;
  (*handler_pnt)();
     cb4:	0007a783          	lw	a5,0(a5)
     cb8:	000780e7          	jalr	a5

  NEORV32_XIRQ->ESC = 0; // acknowledge the current XIRQ interrupt
}
     cbc:	00c12083          	lw	ra,12(sp)
  NEORV32_XIRQ->ESC = 0; // acknowledge the current XIRQ interrupt
     cc0:	30042423          	sw	zero,776(s0)
}
     cc4:	00812403          	lw	s0,8(sp)
     cc8:	01010113          	addi	sp,sp,16
     ccc:	00008067          	ret

00000cd0 <__neorv32_xirq_dummy_handler>:
/**********************************************************************//**
 * XIRQ dummy handler.
 **************************************************************************/
static void __neorv32_xirq_dummy_handler(void) {

  asm volatile ("nop");
     cd0:	00000013          	nop
}
     cd4:	00008067          	ret

00000cd8 <neorv32_xirq_setup>:
  NEORV32_XIRQ->EIE = 0; // disable all input channels
     cd8:	fffff737          	lui	a4,0xfffff
     cdc:	30072023          	sw	zero,768(a4) # fffff300 <__crt0_stack_end+0x7fffd301>
  NEORV32_XIRQ->EIP = 0; // clear all pending IRQs
     ce0:	30072223          	sw	zero,772(a4)
  NEORV32_XIRQ->ESC = 0; // acknowledge (clear) XIRQ interrupt
     ce4:	30072423          	sw	zero,776(a4)
  for (i=0; i<32; i++) {
     ce8:	8d018793          	addi	a5,gp,-1840 # 80000108 <__neorv32_xirq_vector_lut>
    __neorv32_xirq_vector_lut[i] = (uint32_t)(&__neorv32_xirq_dummy_handler);
     cec:	00001737          	lui	a4,0x1
     cf0:	08078693          	addi	a3,a5,128
     cf4:	cd070713          	addi	a4,a4,-816 # cd0 <__neorv32_xirq_dummy_handler>
     cf8:	00e7a023          	sw	a4,0(a5)
  for (i=0; i<32; i++) {
     cfc:	00478793          	addi	a5,a5,4
     d00:	fed79ce3          	bne	a5,a3,cf8 <neorv32_xirq_setup+0x20>
  return neorv32_rte_handler_install(XIRQ_RTE_ID, __neorv32_xirq_core);
     d04:	000015b7          	lui	a1,0x1
     d08:	c8458593          	addi	a1,a1,-892 # c84 <__neorv32_xirq_core>
     d0c:	01500513          	li	a0,21
     d10:	f49ff06f          	j	c58 <neorv32_rte_handler_install>

00000d14 <neorv32_xirq_global_enable>:
  asm volatile ("csrs %[input_i], %[input_j]" :  : [input_i] "i" (csr_id), [input_j] "r" (csr_data));
     d14:	010007b7          	lui	a5,0x1000
     d18:	3047a073          	csrs	mie,a5
}
     d1c:	00008067          	ret

00000d20 <neorv32_xirq_channel_enable>:
  NEORV32_XIRQ->EIE |= 1 << channel;
     d20:	fffff737          	lui	a4,0xfffff
     d24:	30072683          	lw	a3,768(a4) # fffff300 <__crt0_stack_end+0x7fffd301>
     d28:	00100793          	li	a5,1
     d2c:	00a797b3          	sll	a5,a5,a0
     d30:	00d7e7b3          	or	a5,a5,a3
     d34:	30f72023          	sw	a5,768(a4)
}
     d38:	00008067          	ret

00000d3c <neorv32_xirq_install>:
  if (channel < 32) {
     d3c:	01f00793          	li	a5,31
     d40:	02a7ce63          	blt	a5,a0,d7c <neorv32_xirq_install+0x40>
    __neorv32_xirq_vector_lut[channel] = (uint32_t)handler; // install handler
     d44:	00251713          	slli	a4,a0,0x2
     d48:	8d018793          	addi	a5,gp,-1840 # 80000108 <__neorv32_xirq_vector_lut>
     d4c:	00e787b3          	add	a5,a5,a4
     d50:	00b7a023          	sw	a1,0(a5) # 1000000 <__RODATA_END__+0xffcbb4>
    uint32_t mask = 1 << channel;
     d54:	00100793          	li	a5,1
     d58:	00a797b3          	sll	a5,a5,a0
    NEORV32_XIRQ->EIP = ~mask; // clear if pending
     d5c:	fffff737          	lui	a4,0xfffff
     d60:	fff7c613          	not	a2,a5
     d64:	30c72223          	sw	a2,772(a4) # fffff304 <__crt0_stack_end+0x7fffd305>
    NEORV32_XIRQ->EIE |= mask; // enable channel
     d68:	30072683          	lw	a3,768(a4)
    return 0;
     d6c:	00000513          	li	a0,0
    NEORV32_XIRQ->EIE |= mask; // enable channel
     d70:	00f6e7b3          	or	a5,a3,a5
     d74:	30f72023          	sw	a5,768(a4)
    return 0;
     d78:	00008067          	ret
  return 1;
     d7c:	00100513          	li	a0,1
}
     d80:	00008067          	ret

00000d84 <__adddf3>:
     d84:	00100737          	lui	a4,0x100
     d88:	fff70713          	addi	a4,a4,-1 # fffff <__RODATA_END__+0xfcbb3>
     d8c:	fe010113          	addi	sp,sp,-32
     d90:	00b777b3          	and	a5,a4,a1
     d94:	0146d893          	srli	a7,a3,0x14
     d98:	00d77733          	and	a4,a4,a3
     d9c:	00812c23          	sw	s0,24(sp)
     da0:	00912a23          	sw	s1,20(sp)
     da4:	0145d413          	srli	s0,a1,0x14
     da8:	01f5d493          	srli	s1,a1,0x1f
     dac:	00379593          	slli	a1,a5,0x3
     db0:	01d55793          	srli	a5,a0,0x1d
     db4:	7ff47413          	andi	s0,s0,2047
     db8:	00b7e7b3          	or	a5,a5,a1
     dbc:	7ff8f893          	andi	a7,a7,2047
     dc0:	00371593          	slli	a1,a4,0x3
     dc4:	00112e23          	sw	ra,28(sp)
     dc8:	01d65713          	srli	a4,a2,0x1d
     dcc:	01212823          	sw	s2,16(sp)
     dd0:	01312623          	sw	s3,12(sp)
     dd4:	01f6d693          	srli	a3,a3,0x1f
     dd8:	00b76733          	or	a4,a4,a1
     ddc:	00351513          	slli	a0,a0,0x3
     de0:	00361613          	slli	a2,a2,0x3
     de4:	411405b3          	sub	a1,s0,a7
     de8:	30d49a63          	bne	s1,a3,10fc <__adddf3+0x378>
     dec:	16b05463          	blez	a1,f54 <__adddf3+0x1d0>
     df0:	0a089063          	bnez	a7,e90 <__adddf3+0x10c>
     df4:	00c766b3          	or	a3,a4,a2
     df8:	70068863          	beqz	a3,1508 <__adddf3+0x784>
     dfc:	fff58693          	addi	a3,a1,-1
     e00:	08069063          	bnez	a3,e80 <__adddf3+0xfc>
     e04:	00c50633          	add	a2,a0,a2
     e08:	00a636b3          	sltu	a3,a2,a0
     e0c:	00e78733          	add	a4,a5,a4
     e10:	00d707b3          	add	a5,a4,a3
     e14:	00800737          	lui	a4,0x800
     e18:	00e7f733          	and	a4,a5,a4
     e1c:	00060513          	mv	a0,a2
     e20:	2a071863          	bnez	a4,10d0 <__adddf3+0x34c>
     e24:	00100413          	li	s0,1
     e28:	00757713          	andi	a4,a0,7
     e2c:	02070063          	beqz	a4,e4c <__adddf3+0xc8>
     e30:	00f57713          	andi	a4,a0,15
     e34:	00400693          	li	a3,4
     e38:	00d70a63          	beq	a4,a3,e4c <__adddf3+0xc8>
     e3c:	00450713          	addi	a4,a0,4
     e40:	00a736b3          	sltu	a3,a4,a0
     e44:	00d787b3          	add	a5,a5,a3
     e48:	00070513          	mv	a0,a4
     e4c:	008005b7          	lui	a1,0x800
     e50:	00b7f5b3          	and	a1,a5,a1
     e54:	6c058c63          	beqz	a1,152c <__adddf3+0x7a8>
     e58:	00140413          	addi	s0,s0,1
     e5c:	7ff00713          	li	a4,2047
     e60:	0ae40263          	beq	s0,a4,f04 <__adddf3+0x180>
     e64:	ff800737          	lui	a4,0xff800
     e68:	fff70713          	addi	a4,a4,-1 # ff7fffff <__crt0_stack_end+0x7f7fe000>
     e6c:	00e7f7b3          	and	a5,a5,a4
     e70:	00355513          	srli	a0,a0,0x3
     e74:	01d79593          	slli	a1,a5,0x1d
     e78:	00a5e5b3          	or	a1,a1,a0
     e7c:	6240006f          	j	14a0 <__adddf3+0x71c>
     e80:	7ff00813          	li	a6,2047
     e84:	09059463          	bne	a1,a6,f0c <__adddf3+0x188>
     e88:	7ff00413          	li	s0,2047
     e8c:	f9dff06f          	j	e28 <__adddf3+0xa4>
     e90:	7ff00693          	li	a3,2047
     e94:	f8d40ae3          	beq	s0,a3,e28 <__adddf3+0xa4>
     e98:	03800693          	li	a3,56
     e9c:	06b6cc63          	blt	a3,a1,f14 <__adddf3+0x190>
     ea0:	008006b7          	lui	a3,0x800
     ea4:	00d76733          	or	a4,a4,a3
     ea8:	00058693          	mv	a3,a1
     eac:	01f00593          	li	a1,31
     eb0:	06d5c863          	blt	a1,a3,f20 <__adddf3+0x19c>
     eb4:	02000813          	li	a6,32
     eb8:	40d80833          	sub	a6,a6,a3
     ebc:	00d658b3          	srl	a7,a2,a3
     ec0:	010715b3          	sll	a1,a4,a6
     ec4:	01061833          	sll	a6,a2,a6
     ec8:	0115e5b3          	or	a1,a1,a7
     ecc:	01003833          	snez	a6,a6
     ed0:	0105e633          	or	a2,a1,a6
     ed4:	00d756b3          	srl	a3,a4,a3
     ed8:	00a60533          	add	a0,a2,a0
     edc:	00f686b3          	add	a3,a3,a5
     ee0:	00c53633          	sltu	a2,a0,a2
     ee4:	00c687b3          	add	a5,a3,a2
     ee8:	00800737          	lui	a4,0x800
     eec:	00e7f733          	and	a4,a5,a4
     ef0:	f2070ce3          	beqz	a4,e28 <__adddf3+0xa4>
     ef4:	00140413          	addi	s0,s0,1
     ef8:	7ff00713          	li	a4,2047
     efc:	1ce41c63          	bne	s0,a4,10d4 <__adddf3+0x350>
     f00:	7ff00413          	li	s0,2047
     f04:	00000793          	li	a5,0
     f08:	1900006f          	j	1098 <__adddf3+0x314>
     f0c:	03800593          	li	a1,56
     f10:	f8d5dee3          	bge	a1,a3,eac <__adddf3+0x128>
     f14:	00000693          	li	a3,0
     f18:	00100613          	li	a2,1
     f1c:	fbdff06f          	j	ed8 <__adddf3+0x154>
     f20:	fe068593          	addi	a1,a3,-32 # 7fffe0 <__RODATA_END__+0x7fcb94>
     f24:	02000893          	li	a7,32
     f28:	00b755b3          	srl	a1,a4,a1
     f2c:	00000813          	li	a6,0
     f30:	01168863          	beq	a3,a7,f40 <__adddf3+0x1bc>
     f34:	04000813          	li	a6,64
     f38:	40d80833          	sub	a6,a6,a3
     f3c:	01071833          	sll	a6,a4,a6
     f40:	00c86833          	or	a6,a6,a2
     f44:	01003833          	snez	a6,a6
     f48:	0105e633          	or	a2,a1,a6
     f4c:	00000693          	li	a3,0
     f50:	f89ff06f          	j	ed8 <__adddf3+0x154>
     f54:	0c058e63          	beqz	a1,1030 <__adddf3+0x2ac>
     f58:	408885b3          	sub	a1,a7,s0
     f5c:	02041463          	bnez	s0,f84 <__adddf3+0x200>
     f60:	00a7e6b3          	or	a3,a5,a0
     f64:	58068e63          	beqz	a3,1500 <__adddf3+0x77c>
     f68:	fff58693          	addi	a3,a1,-1 # 7fffff <__RODATA_END__+0x7fcbb3>
     f6c:	e8068ce3          	beqz	a3,e04 <__adddf3+0x80>
     f70:	7ff00813          	li	a6,2047
     f74:	07059a63          	bne	a1,a6,fe8 <__adddf3+0x264>
     f78:	00070793          	mv	a5,a4
     f7c:	00060513          	mv	a0,a2
     f80:	f09ff06f          	j	e88 <__adddf3+0x104>
     f84:	7ff00693          	li	a3,2047
     f88:	fed888e3          	beq	a7,a3,f78 <__adddf3+0x1f4>
     f8c:	03800693          	li	a3,56
     f90:	06b6c063          	blt	a3,a1,ff0 <__adddf3+0x26c>
     f94:	008006b7          	lui	a3,0x800
     f98:	00d7e7b3          	or	a5,a5,a3
     f9c:	00058693          	mv	a3,a1
     fa0:	01f00593          	li	a1,31
     fa4:	04d5cc63          	blt	a1,a3,ffc <__adddf3+0x278>
     fa8:	02000813          	li	a6,32
     fac:	40d80833          	sub	a6,a6,a3
     fb0:	010795b3          	sll	a1,a5,a6
     fb4:	00d55333          	srl	t1,a0,a3
     fb8:	01051833          	sll	a6,a0,a6
     fbc:	0065e5b3          	or	a1,a1,t1
     fc0:	01003833          	snez	a6,a6
     fc4:	0105e5b3          	or	a1,a1,a6
     fc8:	00d7d6b3          	srl	a3,a5,a3
     fcc:	00c58633          	add	a2,a1,a2
     fd0:	00e686b3          	add	a3,a3,a4
     fd4:	00b635b3          	sltu	a1,a2,a1
     fd8:	00060513          	mv	a0,a2
     fdc:	00b687b3          	add	a5,a3,a1
     fe0:	00088413          	mv	s0,a7
     fe4:	f05ff06f          	j	ee8 <__adddf3+0x164>
     fe8:	03800593          	li	a1,56
     fec:	fad5dae3          	bge	a1,a3,fa0 <__adddf3+0x21c>
     ff0:	00000693          	li	a3,0
     ff4:	00100593          	li	a1,1
     ff8:	fd5ff06f          	j	fcc <__adddf3+0x248>
     ffc:	fe068593          	addi	a1,a3,-32 # 7fffe0 <__RODATA_END__+0x7fcb94>
    1000:	02000313          	li	t1,32
    1004:	00b7d5b3          	srl	a1,a5,a1
    1008:	00000813          	li	a6,0
    100c:	00668863          	beq	a3,t1,101c <__adddf3+0x298>
    1010:	04000813          	li	a6,64
    1014:	40d80833          	sub	a6,a6,a3
    1018:	01079833          	sll	a6,a5,a6
    101c:	00a86833          	or	a6,a6,a0
    1020:	01003833          	snez	a6,a6
    1024:	0105e5b3          	or	a1,a1,a6
    1028:	00000693          	li	a3,0
    102c:	fa1ff06f          	j	fcc <__adddf3+0x248>
    1030:	00140693          	addi	a3,s0,1
    1034:	7fe6f593          	andi	a1,a3,2046
    1038:	06059463          	bnez	a1,10a0 <__adddf3+0x31c>
    103c:	00a7e6b3          	or	a3,a5,a0
    1040:	04041063          	bnez	s0,1080 <__adddf3+0x2fc>
    1044:	4c068663          	beqz	a3,1510 <__adddf3+0x78c>
    1048:	00c766b3          	or	a3,a4,a2
    104c:	dc068ee3          	beqz	a3,e28 <__adddf3+0xa4>
    1050:	00c50633          	add	a2,a0,a2
    1054:	00a636b3          	sltu	a3,a2,a0
    1058:	00e78733          	add	a4,a5,a4
    105c:	00d707b3          	add	a5,a4,a3
    1060:	00800737          	lui	a4,0x800
    1064:	00e7f733          	and	a4,a5,a4
    1068:	00060513          	mv	a0,a2
    106c:	da070ee3          	beqz	a4,e28 <__adddf3+0xa4>
    1070:	ff800737          	lui	a4,0xff800
    1074:	fff70713          	addi	a4,a4,-1 # ff7fffff <__crt0_stack_end+0x7f7fe000>
    1078:	00e7f7b3          	and	a5,a5,a4
    107c:	da9ff06f          	j	e24 <__adddf3+0xa0>
    1080:	ee068ce3          	beqz	a3,f78 <__adddf3+0x1f4>
    1084:	00c76633          	or	a2,a4,a2
    1088:	e00600e3          	beqz	a2,e88 <__adddf3+0x104>
    108c:	00000493          	li	s1,0
    1090:	7ff00413          	li	s0,2047
    1094:	000807b7          	lui	a5,0x80
    1098:	00000593          	li	a1,0
    109c:	4080006f          	j	14a4 <__adddf3+0x720>
    10a0:	7ff00593          	li	a1,2047
    10a4:	e4b68ee3          	beq	a3,a1,f00 <__adddf3+0x17c>
    10a8:	00c50633          	add	a2,a0,a2
    10ac:	00a63533          	sltu	a0,a2,a0
    10b0:	00e78733          	add	a4,a5,a4
    10b4:	00a70733          	add	a4,a4,a0
    10b8:	01f71513          	slli	a0,a4,0x1f
    10bc:	00165613          	srli	a2,a2,0x1
    10c0:	00c56533          	or	a0,a0,a2
    10c4:	00175793          	srli	a5,a4,0x1
    10c8:	00068413          	mv	s0,a3
    10cc:	d5dff06f          	j	e28 <__adddf3+0xa4>
    10d0:	00200413          	li	s0,2
    10d4:	ff800737          	lui	a4,0xff800
    10d8:	fff70713          	addi	a4,a4,-1 # ff7fffff <__crt0_stack_end+0x7f7fe000>
    10dc:	00e7f7b3          	and	a5,a5,a4
    10e0:	00155713          	srli	a4,a0,0x1
    10e4:	00157513          	andi	a0,a0,1
    10e8:	00a76733          	or	a4,a4,a0
    10ec:	01f79513          	slli	a0,a5,0x1f
    10f0:	00e56533          	or	a0,a0,a4
    10f4:	0017d793          	srli	a5,a5,0x1
    10f8:	d31ff06f          	j	e28 <__adddf3+0xa4>
    10fc:	0eb05e63          	blez	a1,11f8 <__adddf3+0x474>
    1100:	04089663          	bnez	a7,114c <__adddf3+0x3c8>
    1104:	00c766b3          	or	a3,a4,a2
    1108:	40068063          	beqz	a3,1508 <__adddf3+0x784>
    110c:	fff58693          	addi	a3,a1,-1
    1110:	02069063          	bnez	a3,1130 <__adddf3+0x3ac>
    1114:	40c50633          	sub	a2,a0,a2
    1118:	00c536b3          	sltu	a3,a0,a2
    111c:	40e78733          	sub	a4,a5,a4
    1120:	00060513          	mv	a0,a2
    1124:	40d707b3          	sub	a5,a4,a3
    1128:	00100413          	li	s0,1
    112c:	07c0006f          	j	11a8 <__adddf3+0x424>
    1130:	7ff00813          	li	a6,2047
    1134:	d5058ae3          	beq	a1,a6,e88 <__adddf3+0x104>
    1138:	03800593          	li	a1,56
    113c:	02d5d663          	bge	a1,a3,1168 <__adddf3+0x3e4>
    1140:	00000693          	li	a3,0
    1144:	00100613          	li	a2,1
    1148:	04c0006f          	j	1194 <__adddf3+0x410>
    114c:	7ff00693          	li	a3,2047
    1150:	ccd40ce3          	beq	s0,a3,e28 <__adddf3+0xa4>
    1154:	03800693          	li	a3,56
    1158:	feb6c4e3          	blt	a3,a1,1140 <__adddf3+0x3bc>
    115c:	008006b7          	lui	a3,0x800
    1160:	00d76733          	or	a4,a4,a3
    1164:	00058693          	mv	a3,a1
    1168:	01f00593          	li	a1,31
    116c:	04d5cc63          	blt	a1,a3,11c4 <__adddf3+0x440>
    1170:	02000813          	li	a6,32
    1174:	40d80833          	sub	a6,a6,a3
    1178:	00d658b3          	srl	a7,a2,a3
    117c:	010715b3          	sll	a1,a4,a6
    1180:	01061833          	sll	a6,a2,a6
    1184:	0115e5b3          	or	a1,a1,a7
    1188:	01003833          	snez	a6,a6
    118c:	0105e633          	or	a2,a1,a6
    1190:	00d756b3          	srl	a3,a4,a3
    1194:	40c50633          	sub	a2,a0,a2
    1198:	00c53733          	sltu	a4,a0,a2
    119c:	40d786b3          	sub	a3,a5,a3
    11a0:	00060513          	mv	a0,a2
    11a4:	40e687b3          	sub	a5,a3,a4
    11a8:	00800737          	lui	a4,0x800
    11ac:	00e7f6b3          	and	a3,a5,a4
    11b0:	c6068ce3          	beqz	a3,e28 <__adddf3+0xa4>
    11b4:	fff70713          	addi	a4,a4,-1 # 7fffff <__RODATA_END__+0x7fcbb3>
    11b8:	00e7f9b3          	and	s3,a5,a4
    11bc:	00050913          	mv	s2,a0
    11c0:	1fc0006f          	j	13bc <__adddf3+0x638>
    11c4:	fe068593          	addi	a1,a3,-32 # 7fffe0 <__RODATA_END__+0x7fcb94>
    11c8:	02000893          	li	a7,32
    11cc:	00b755b3          	srl	a1,a4,a1
    11d0:	00000813          	li	a6,0
    11d4:	01168863          	beq	a3,a7,11e4 <__adddf3+0x460>
    11d8:	04000813          	li	a6,64
    11dc:	40d80833          	sub	a6,a6,a3
    11e0:	01071833          	sll	a6,a4,a6
    11e4:	00c86833          	or	a6,a6,a2
    11e8:	01003833          	snez	a6,a6
    11ec:	0105e633          	or	a2,a1,a6
    11f0:	00000693          	li	a3,0
    11f4:	fa1ff06f          	j	1194 <__adddf3+0x410>
    11f8:	0e058c63          	beqz	a1,12f0 <__adddf3+0x56c>
    11fc:	40888833          	sub	a6,a7,s0
    1200:	04041263          	bnez	s0,1244 <__adddf3+0x4c0>
    1204:	00a7e5b3          	or	a1,a5,a0
    1208:	30058a63          	beqz	a1,151c <__adddf3+0x798>
    120c:	fff80593          	addi	a1,a6,-1
    1210:	00059e63          	bnez	a1,122c <__adddf3+0x4a8>
    1214:	40a60533          	sub	a0,a2,a0
    1218:	40f70733          	sub	a4,a4,a5
    121c:	00a63633          	sltu	a2,a2,a0
    1220:	40c707b3          	sub	a5,a4,a2
    1224:	00068493          	mv	s1,a3
    1228:	f01ff06f          	j	1128 <__adddf3+0x3a4>
    122c:	7ff00313          	li	t1,2047
    1230:	06681c63          	bne	a6,t1,12a8 <__adddf3+0x524>
    1234:	00070793          	mv	a5,a4
    1238:	00060513          	mv	a0,a2
    123c:	7ff00413          	li	s0,2047
    1240:	0d80006f          	j	1318 <__adddf3+0x594>
    1244:	7ff00593          	li	a1,2047
    1248:	feb886e3          	beq	a7,a1,1234 <__adddf3+0x4b0>
    124c:	03800593          	li	a1,56
    1250:	0705c063          	blt	a1,a6,12b0 <__adddf3+0x52c>
    1254:	008005b7          	lui	a1,0x800
    1258:	00b7e7b3          	or	a5,a5,a1
    125c:	00080593          	mv	a1,a6
    1260:	01f00813          	li	a6,31
    1264:	04b84c63          	blt	a6,a1,12bc <__adddf3+0x538>
    1268:	02000313          	li	t1,32
    126c:	40b30333          	sub	t1,t1,a1
    1270:	00b55e33          	srl	t3,a0,a1
    1274:	00679833          	sll	a6,a5,t1
    1278:	00651333          	sll	t1,a0,t1
    127c:	01c86833          	or	a6,a6,t3
    1280:	00603333          	snez	t1,t1
    1284:	00686533          	or	a0,a6,t1
    1288:	00b7d5b3          	srl	a1,a5,a1
    128c:	40a60533          	sub	a0,a2,a0
    1290:	40b705b3          	sub	a1,a4,a1
    1294:	00a63633          	sltu	a2,a2,a0
    1298:	40c587b3          	sub	a5,a1,a2
    129c:	00088413          	mv	s0,a7
    12a0:	00068493          	mv	s1,a3
    12a4:	f05ff06f          	j	11a8 <__adddf3+0x424>
    12a8:	03800813          	li	a6,56
    12ac:	fab85ae3          	bge	a6,a1,1260 <__adddf3+0x4dc>
    12b0:	00000593          	li	a1,0
    12b4:	00100513          	li	a0,1
    12b8:	fd5ff06f          	j	128c <__adddf3+0x508>
    12bc:	fe058813          	addi	a6,a1,-32 # 7fffe0 <__RODATA_END__+0x7fcb94>
    12c0:	02000e13          	li	t3,32
    12c4:	0107d833          	srl	a6,a5,a6
    12c8:	00000313          	li	t1,0
    12cc:	01c58863          	beq	a1,t3,12dc <__adddf3+0x558>
    12d0:	04000313          	li	t1,64
    12d4:	40b30333          	sub	t1,t1,a1
    12d8:	00679333          	sll	t1,a5,t1
    12dc:	00a36333          	or	t1,t1,a0
    12e0:	00603333          	snez	t1,t1
    12e4:	00686533          	or	a0,a6,t1
    12e8:	00000593          	li	a1,0
    12ec:	fa1ff06f          	j	128c <__adddf3+0x508>
    12f0:	00140593          	addi	a1,s0,1
    12f4:	7fe5f593          	andi	a1,a1,2046
    12f8:	08059863          	bnez	a1,1388 <__adddf3+0x604>
    12fc:	00a7e833          	or	a6,a5,a0
    1300:	00c765b3          	or	a1,a4,a2
    1304:	06041263          	bnez	s0,1368 <__adddf3+0x5e4>
    1308:	00081c63          	bnez	a6,1320 <__adddf3+0x59c>
    130c:	10058e63          	beqz	a1,1428 <__adddf3+0x6a4>
    1310:	00070793          	mv	a5,a4
    1314:	00060513          	mv	a0,a2
    1318:	00068493          	mv	s1,a3
    131c:	b0dff06f          	j	e28 <__adddf3+0xa4>
    1320:	b00584e3          	beqz	a1,e28 <__adddf3+0xa4>
    1324:	40c508b3          	sub	a7,a0,a2
    1328:	011535b3          	sltu	a1,a0,a7
    132c:	40e78833          	sub	a6,a5,a4
    1330:	40b80833          	sub	a6,a6,a1
    1334:	008005b7          	lui	a1,0x800
    1338:	00b875b3          	and	a1,a6,a1
    133c:	00058c63          	beqz	a1,1354 <__adddf3+0x5d0>
    1340:	40a60533          	sub	a0,a2,a0
    1344:	40f70733          	sub	a4,a4,a5
    1348:	00a63633          	sltu	a2,a2,a0
    134c:	40c707b3          	sub	a5,a4,a2
    1350:	fc9ff06f          	j	1318 <__adddf3+0x594>
    1354:	0108e5b3          	or	a1,a7,a6
    1358:	0c058863          	beqz	a1,1428 <__adddf3+0x6a4>
    135c:	00080793          	mv	a5,a6
    1360:	00088513          	mv	a0,a7
    1364:	ac5ff06f          	j	e28 <__adddf3+0xa4>
    1368:	00081c63          	bnez	a6,1380 <__adddf3+0x5fc>
    136c:	1e058663          	beqz	a1,1558 <__adddf3+0x7d4>
    1370:	00070793          	mv	a5,a4
    1374:	00060513          	mv	a0,a2
    1378:	00068493          	mv	s1,a3
    137c:	b0dff06f          	j	e88 <__adddf3+0x104>
    1380:	b00584e3          	beqz	a1,e88 <__adddf3+0x104>
    1384:	d09ff06f          	j	108c <__adddf3+0x308>
    1388:	40c505b3          	sub	a1,a0,a2
    138c:	00b53833          	sltu	a6,a0,a1
    1390:	40e789b3          	sub	s3,a5,a4
    1394:	410989b3          	sub	s3,s3,a6
    1398:	00800837          	lui	a6,0x800
    139c:	0109f833          	and	a6,s3,a6
    13a0:	00058913          	mv	s2,a1
    13a4:	06080c63          	beqz	a6,141c <__adddf3+0x698>
    13a8:	40a60933          	sub	s2,a2,a0
    13ac:	40f70733          	sub	a4,a4,a5
    13b0:	01263633          	sltu	a2,a2,s2
    13b4:	40c709b3          	sub	s3,a4,a2
    13b8:	00068493          	mv	s1,a3
    13bc:	06098a63          	beqz	s3,1430 <__adddf3+0x6ac>
    13c0:	00098513          	mv	a0,s3
    13c4:	701010ef          	jal	ra,32c4 <__clzsi2>
    13c8:	ff850793          	addi	a5,a0,-8
    13cc:	02000693          	li	a3,32
    13d0:	40f686b3          	sub	a3,a3,a5
    13d4:	00f99733          	sll	a4,s3,a5
    13d8:	00d956b3          	srl	a3,s2,a3
    13dc:	00e6e6b3          	or	a3,a3,a4
    13e0:	00f919b3          	sll	s3,s2,a5
    13e4:	1087c263          	blt	a5,s0,14e8 <__adddf3+0x764>
    13e8:	408787b3          	sub	a5,a5,s0
    13ec:	00178793          	addi	a5,a5,1 # 80001 <__RODATA_END__+0x7cbb5>
    13f0:	02000713          	li	a4,32
    13f4:	40f70733          	sub	a4,a4,a5
    13f8:	00e69533          	sll	a0,a3,a4
    13fc:	00f9d633          	srl	a2,s3,a5
    1400:	00e99733          	sll	a4,s3,a4
    1404:	00c56533          	or	a0,a0,a2
    1408:	00e03733          	snez	a4,a4
    140c:	00e56533          	or	a0,a0,a4
    1410:	00f6d7b3          	srl	a5,a3,a5
    1414:	00000413          	li	s0,0
    1418:	a11ff06f          	j	e28 <__adddf3+0xa4>
    141c:	0135e5b3          	or	a1,a1,s3
    1420:	f8059ee3          	bnez	a1,13bc <__adddf3+0x638>
    1424:	00000413          	li	s0,0
    1428:	00000793          	li	a5,0
    142c:	1240006f          	j	1550 <__adddf3+0x7cc>
    1430:	00090513          	mv	a0,s2
    1434:	691010ef          	jal	ra,32c4 <__clzsi2>
    1438:	01850793          	addi	a5,a0,24
    143c:	01f00713          	li	a4,31
    1440:	f8f756e3          	bge	a4,a5,13cc <__adddf3+0x648>
    1444:	ff850513          	addi	a0,a0,-8
    1448:	00a916b3          	sll	a3,s2,a0
    144c:	0487c063          	blt	a5,s0,148c <__adddf3+0x708>
    1450:	40878533          	sub	a0,a5,s0
    1454:	00150793          	addi	a5,a0,1
    1458:	f8f75ce3          	bge	a4,a5,13f0 <__adddf3+0x66c>
    145c:	fe150513          	addi	a0,a0,-31
    1460:	02000613          	li	a2,32
    1464:	00a6d733          	srl	a4,a3,a0
    1468:	00000513          	li	a0,0
    146c:	00c78863          	beq	a5,a2,147c <__adddf3+0x6f8>
    1470:	04000513          	li	a0,64
    1474:	40f50533          	sub	a0,a0,a5
    1478:	00a69533          	sll	a0,a3,a0
    147c:	00a03533          	snez	a0,a0
    1480:	00e56533          	or	a0,a0,a4
    1484:	00000793          	li	a5,0
    1488:	f8dff06f          	j	1414 <__adddf3+0x690>
    148c:	40f40433          	sub	s0,s0,a5
    1490:	ff8007b7          	lui	a5,0xff800
    1494:	fff78793          	addi	a5,a5,-1 # ff7fffff <__crt0_stack_end+0x7f7fe000>
    1498:	00f6f7b3          	and	a5,a3,a5
    149c:	01d79593          	slli	a1,a5,0x1d
    14a0:	0037d793          	srli	a5,a5,0x3
    14a4:	01441413          	slli	s0,s0,0x14
    14a8:	7ff00737          	lui	a4,0x7ff00
    14ac:	00c79793          	slli	a5,a5,0xc
    14b0:	00c7d793          	srli	a5,a5,0xc
    14b4:	00e47433          	and	s0,s0,a4
    14b8:	00f46433          	or	s0,s0,a5
    14bc:	01f49493          	slli	s1,s1,0x1f
    14c0:	009467b3          	or	a5,s0,s1
    14c4:	01c12083          	lw	ra,28(sp)
    14c8:	01812403          	lw	s0,24(sp)
    14cc:	01412483          	lw	s1,20(sp)
    14d0:	01012903          	lw	s2,16(sp)
    14d4:	00c12983          	lw	s3,12(sp)
    14d8:	00058513          	mv	a0,a1
    14dc:	00078593          	mv	a1,a5
    14e0:	02010113          	addi	sp,sp,32
    14e4:	00008067          	ret
    14e8:	40f40433          	sub	s0,s0,a5
    14ec:	ff8007b7          	lui	a5,0xff800
    14f0:	fff78793          	addi	a5,a5,-1 # ff7fffff <__crt0_stack_end+0x7f7fe000>
    14f4:	00f6f7b3          	and	a5,a3,a5
    14f8:	00098513          	mv	a0,s3
    14fc:	92dff06f          	j	e28 <__adddf3+0xa4>
    1500:	00070793          	mv	a5,a4
    1504:	00060513          	mv	a0,a2
    1508:	00058413          	mv	s0,a1
    150c:	91dff06f          	j	e28 <__adddf3+0xa4>
    1510:	00070793          	mv	a5,a4
    1514:	00060513          	mv	a0,a2
    1518:	911ff06f          	j	e28 <__adddf3+0xa4>
    151c:	00070793          	mv	a5,a4
    1520:	00060513          	mv	a0,a2
    1524:	00080413          	mv	s0,a6
    1528:	df1ff06f          	j	1318 <__adddf3+0x594>
    152c:	01d79713          	slli	a4,a5,0x1d
    1530:	00355513          	srli	a0,a0,0x3
    1534:	7ff00693          	li	a3,2047
    1538:	00a76733          	or	a4,a4,a0
    153c:	0037d793          	srli	a5,a5,0x3
    1540:	02d41463          	bne	s0,a3,1568 <__adddf3+0x7e4>
    1544:	00f76733          	or	a4,a4,a5
    1548:	000807b7          	lui	a5,0x80
    154c:	9a070ae3          	beqz	a4,f00 <__adddf3+0x17c>
    1550:	00000493          	li	s1,0
    1554:	f51ff06f          	j	14a4 <__adddf3+0x720>
    1558:	00000493          	li	s1,0
    155c:	7ff00413          	li	s0,2047
    1560:	000807b7          	lui	a5,0x80
    1564:	f41ff06f          	j	14a4 <__adddf3+0x720>
    1568:	00070593          	mv	a1,a4
    156c:	f39ff06f          	j	14a4 <__adddf3+0x720>

00001570 <__muldf3>:
    1570:	fd010113          	addi	sp,sp,-48
    1574:	01512a23          	sw	s5,20(sp)
    1578:	0145da93          	srli	s5,a1,0x14
    157c:	02812423          	sw	s0,40(sp)
    1580:	02912223          	sw	s1,36(sp)
    1584:	03212023          	sw	s2,32(sp)
    1588:	01312e23          	sw	s3,28(sp)
    158c:	01612823          	sw	s6,16(sp)
    1590:	00c59493          	slli	s1,a1,0xc
    1594:	02112623          	sw	ra,44(sp)
    1598:	01412c23          	sw	s4,24(sp)
    159c:	01712623          	sw	s7,12(sp)
    15a0:	7ffafa93          	andi	s5,s5,2047
    15a4:	00050413          	mv	s0,a0
    15a8:	00060b13          	mv	s6,a2
    15ac:	00068913          	mv	s2,a3
    15b0:	00c4d493          	srli	s1,s1,0xc
    15b4:	01f5d993          	srli	s3,a1,0x1f
    15b8:	3c0a8063          	beqz	s5,1978 <__muldf3+0x408>
    15bc:	7ff00793          	li	a5,2047
    15c0:	42fa8263          	beq	s5,a5,19e4 <__muldf3+0x474>
    15c4:	00349493          	slli	s1,s1,0x3
    15c8:	01d55793          	srli	a5,a0,0x1d
    15cc:	0097e7b3          	or	a5,a5,s1
    15d0:	008004b7          	lui	s1,0x800
    15d4:	0097e4b3          	or	s1,a5,s1
    15d8:	00351a13          	slli	s4,a0,0x3
    15dc:	c01a8a93          	addi	s5,s5,-1023
    15e0:	00000b93          	li	s7,0
    15e4:	01495713          	srli	a4,s2,0x14
    15e8:	00c91413          	slli	s0,s2,0xc
    15ec:	7ff77713          	andi	a4,a4,2047
    15f0:	00c45413          	srli	s0,s0,0xc
    15f4:	01f95913          	srli	s2,s2,0x1f
    15f8:	42070263          	beqz	a4,1a1c <__muldf3+0x4ac>
    15fc:	7ff00793          	li	a5,2047
    1600:	48f70663          	beq	a4,a5,1a8c <__muldf3+0x51c>
    1604:	00341413          	slli	s0,s0,0x3
    1608:	01db5793          	srli	a5,s6,0x1d
    160c:	0087e7b3          	or	a5,a5,s0
    1610:	00800437          	lui	s0,0x800
    1614:	0087e433          	or	s0,a5,s0
    1618:	c0170693          	addi	a3,a4,-1023 # 7feffc01 <__RODATA_END__+0x7fefc7b5>
    161c:	003b1793          	slli	a5,s6,0x3
    1620:	00000613          	li	a2,0
    1624:	002b9713          	slli	a4,s7,0x2
    1628:	00da8ab3          	add	s5,s5,a3
    162c:	00c76733          	or	a4,a4,a2
    1630:	00a00693          	li	a3,10
    1634:	0129c833          	xor	a6,s3,s2
    1638:	001a8893          	addi	a7,s5,1
    163c:	4ce6c863          	blt	a3,a4,1b0c <__muldf3+0x59c>
    1640:	00200693          	li	a3,2
    1644:	48e6c063          	blt	a3,a4,1ac4 <__muldf3+0x554>
    1648:	fff70713          	addi	a4,a4,-1
    164c:	00100693          	li	a3,1
    1650:	48e6fc63          	bgeu	a3,a4,1ae8 <__muldf3+0x578>
    1654:	00010937          	lui	s2,0x10
    1658:	fff90e13          	addi	t3,s2,-1 # ffff <__RODATA_END__+0xcbb3>
    165c:	010a5293          	srli	t0,s4,0x10
    1660:	01c7ffb3          	and	t6,a5,t3
    1664:	01ca7a33          	and	s4,s4,t3
    1668:	0107df13          	srli	t5,a5,0x10
    166c:	000a0513          	mv	a0,s4
    1670:	000f8593          	mv	a1,t6
    1674:	379010ef          	jal	ra,31ec <__mulsi3>
    1678:	00050793          	mv	a5,a0
    167c:	000f0593          	mv	a1,t5
    1680:	000a0513          	mv	a0,s4
    1684:	369010ef          	jal	ra,31ec <__mulsi3>
    1688:	00050e93          	mv	t4,a0
    168c:	000f8593          	mv	a1,t6
    1690:	00028513          	mv	a0,t0
    1694:	359010ef          	jal	ra,31ec <__mulsi3>
    1698:	00050393          	mv	t2,a0
    169c:	000f0593          	mv	a1,t5
    16a0:	00028513          	mv	a0,t0
    16a4:	349010ef          	jal	ra,31ec <__mulsi3>
    16a8:	0107d313          	srli	t1,a5,0x10
    16ac:	007e8eb3          	add	t4,t4,t2
    16b0:	01d30333          	add	t1,t1,t4
    16b4:	00050713          	mv	a4,a0
    16b8:	00737463          	bgeu	t1,t2,16c0 <__muldf3+0x150>
    16bc:	01250733          	add	a4,a0,s2
    16c0:	01035993          	srli	s3,t1,0x10
    16c4:	01c37333          	and	t1,t1,t3
    16c8:	01c7f7b3          	and	a5,a5,t3
    16cc:	01031313          	slli	t1,t1,0x10
    16d0:	01c47e33          	and	t3,s0,t3
    16d4:	00f30333          	add	t1,t1,a5
    16d8:	01045913          	srli	s2,s0,0x10
    16dc:	000a0513          	mv	a0,s4
    16e0:	000e0593          	mv	a1,t3
    16e4:	309010ef          	jal	ra,31ec <__mulsi3>
    16e8:	00050393          	mv	t2,a0
    16ec:	00090593          	mv	a1,s2
    16f0:	000a0513          	mv	a0,s4
    16f4:	2f9010ef          	jal	ra,31ec <__mulsi3>
    16f8:	00050e93          	mv	t4,a0
    16fc:	000e0593          	mv	a1,t3
    1700:	00028513          	mv	a0,t0
    1704:	2e9010ef          	jal	ra,31ec <__mulsi3>
    1708:	00050413          	mv	s0,a0
    170c:	00090593          	mv	a1,s2
    1710:	00028513          	mv	a0,t0
    1714:	2d9010ef          	jal	ra,31ec <__mulsi3>
    1718:	0103d693          	srli	a3,t2,0x10
    171c:	008e8eb3          	add	t4,t4,s0
    1720:	01d686b3          	add	a3,a3,t4
    1724:	00050793          	mv	a5,a0
    1728:	0086f663          	bgeu	a3,s0,1734 <__muldf3+0x1c4>
    172c:	00010637          	lui	a2,0x10
    1730:	00c507b3          	add	a5,a0,a2
    1734:	00010a37          	lui	s4,0x10
    1738:	fffa0e93          	addi	t4,s4,-1 # ffff <__RODATA_END__+0xcbb3>
    173c:	0106d293          	srli	t0,a3,0x10
    1740:	00f282b3          	add	t0,t0,a5
    1744:	01d6f7b3          	and	a5,a3,t4
    1748:	01d3f3b3          	and	t2,t2,t4
    174c:	01079793          	slli	a5,a5,0x10
    1750:	007787b3          	add	a5,a5,t2
    1754:	01d4feb3          	and	t4,s1,t4
    1758:	00f98433          	add	s0,s3,a5
    175c:	000e8513          	mv	a0,t4
    1760:	0104d993          	srli	s3,s1,0x10
    1764:	000f8593          	mv	a1,t6
    1768:	285010ef          	jal	ra,31ec <__mulsi3>
    176c:	00050493          	mv	s1,a0
    1770:	000f0593          	mv	a1,t5
    1774:	000e8513          	mv	a0,t4
    1778:	275010ef          	jal	ra,31ec <__mulsi3>
    177c:	00050393          	mv	t2,a0
    1780:	000f8593          	mv	a1,t6
    1784:	00098513          	mv	a0,s3
    1788:	265010ef          	jal	ra,31ec <__mulsi3>
    178c:	00050f93          	mv	t6,a0
    1790:	000f0593          	mv	a1,t5
    1794:	00098513          	mv	a0,s3
    1798:	255010ef          	jal	ra,31ec <__mulsi3>
    179c:	0104d693          	srli	a3,s1,0x10
    17a0:	01f383b3          	add	t2,t2,t6
    17a4:	007686b3          	add	a3,a3,t2
    17a8:	00050613          	mv	a2,a0
    17ac:	01f6f463          	bgeu	a3,t6,17b4 <__muldf3+0x244>
    17b0:	01450633          	add	a2,a0,s4
    17b4:	00010a37          	lui	s4,0x10
    17b8:	fffa0393          	addi	t2,s4,-1 # ffff <__RODATA_END__+0xcbb3>
    17bc:	0106df93          	srli	t6,a3,0x10
    17c0:	0076f6b3          	and	a3,a3,t2
    17c4:	01069693          	slli	a3,a3,0x10
    17c8:	0074f4b3          	and	s1,s1,t2
    17cc:	00cf8fb3          	add	t6,t6,a2
    17d0:	00968f33          	add	t5,a3,s1
    17d4:	000e8513          	mv	a0,t4
    17d8:	000e0593          	mv	a1,t3
    17dc:	211010ef          	jal	ra,31ec <__mulsi3>
    17e0:	00050493          	mv	s1,a0
    17e4:	00090593          	mv	a1,s2
    17e8:	000e8513          	mv	a0,t4
    17ec:	201010ef          	jal	ra,31ec <__mulsi3>
    17f0:	00050e93          	mv	t4,a0
    17f4:	000e0593          	mv	a1,t3
    17f8:	00098513          	mv	a0,s3
    17fc:	1f1010ef          	jal	ra,31ec <__mulsi3>
    1800:	00050e13          	mv	t3,a0
    1804:	00090593          	mv	a1,s2
    1808:	00098513          	mv	a0,s3
    180c:	1e1010ef          	jal	ra,31ec <__mulsi3>
    1810:	0104d613          	srli	a2,s1,0x10
    1814:	01ce8eb3          	add	t4,t4,t3
    1818:	01d60633          	add	a2,a2,t4
    181c:	00050593          	mv	a1,a0
    1820:	01c67463          	bgeu	a2,t3,1828 <__muldf3+0x2b8>
    1824:	014505b3          	add	a1,a0,s4
    1828:	007676b3          	and	a3,a2,t2
    182c:	01069693          	slli	a3,a3,0x10
    1830:	0074f4b3          	and	s1,s1,t2
    1834:	00870733          	add	a4,a4,s0
    1838:	009686b3          	add	a3,a3,s1
    183c:	005682b3          	add	t0,a3,t0
    1840:	00f737b3          	sltu	a5,a4,a5
    1844:	00f287b3          	add	a5,t0,a5
    1848:	00d2b6b3          	sltu	a3,t0,a3
    184c:	0057b2b3          	sltu	t0,a5,t0
    1850:	01065613          	srli	a2,a2,0x10
    1854:	0056e6b3          	or	a3,a3,t0
    1858:	00c686b3          	add	a3,a3,a2
    185c:	01e70633          	add	a2,a4,t5
    1860:	01f78fb3          	add	t6,a5,t6
    1864:	00e63733          	sltu	a4,a2,a4
    1868:	00ef8733          	add	a4,t6,a4
    186c:	00ffb433          	sltu	s0,t6,a5
    1870:	01f73fb3          	sltu	t6,a4,t6
    1874:	01f46433          	or	s0,s0,t6
    1878:	00d40433          	add	s0,s0,a3
    187c:	00b40433          	add	s0,s0,a1
    1880:	01775793          	srli	a5,a4,0x17
    1884:	00941413          	slli	s0,s0,0x9
    1888:	00f46433          	or	s0,s0,a5
    188c:	00961793          	slli	a5,a2,0x9
    1890:	0067e7b3          	or	a5,a5,t1
    1894:	00f037b3          	snez	a5,a5
    1898:	01765613          	srli	a2,a2,0x17
    189c:	00971713          	slli	a4,a4,0x9
    18a0:	00c7e7b3          	or	a5,a5,a2
    18a4:	00e7e7b3          	or	a5,a5,a4
    18a8:	01000737          	lui	a4,0x1000
    18ac:	00e47733          	and	a4,s0,a4
    18b0:	28070063          	beqz	a4,1b30 <__muldf3+0x5c0>
    18b4:	0017d713          	srli	a4,a5,0x1
    18b8:	0017f793          	andi	a5,a5,1
    18bc:	00f76733          	or	a4,a4,a5
    18c0:	01f41793          	slli	a5,s0,0x1f
    18c4:	00f767b3          	or	a5,a4,a5
    18c8:	00145413          	srli	s0,s0,0x1
    18cc:	3ff88693          	addi	a3,a7,1023
    18d0:	26d05463          	blez	a3,1b38 <__muldf3+0x5c8>
    18d4:	0077f713          	andi	a4,a5,7
    18d8:	02070063          	beqz	a4,18f8 <__muldf3+0x388>
    18dc:	00f7f713          	andi	a4,a5,15
    18e0:	00400613          	li	a2,4
    18e4:	00c70a63          	beq	a4,a2,18f8 <__muldf3+0x388>
    18e8:	00478713          	addi	a4,a5,4 # 80004 <__RODATA_END__+0x7cbb8>
    18ec:	00f73633          	sltu	a2,a4,a5
    18f0:	00c40433          	add	s0,s0,a2
    18f4:	00070793          	mv	a5,a4
    18f8:	01000737          	lui	a4,0x1000
    18fc:	00e47733          	and	a4,s0,a4
    1900:	00070a63          	beqz	a4,1914 <__muldf3+0x3a4>
    1904:	ff000737          	lui	a4,0xff000
    1908:	fff70713          	addi	a4,a4,-1 # feffffff <__crt0_stack_end+0x7effe000>
    190c:	00e47433          	and	s0,s0,a4
    1910:	40088693          	addi	a3,a7,1024
    1914:	7fe00713          	li	a4,2046
    1918:	2ed74a63          	blt	a4,a3,1c0c <__muldf3+0x69c>
    191c:	01d41713          	slli	a4,s0,0x1d
    1920:	0037d793          	srli	a5,a5,0x3
    1924:	00f76733          	or	a4,a4,a5
    1928:	00345413          	srli	s0,s0,0x3
    192c:	00c41413          	slli	s0,s0,0xc
    1930:	00c45413          	srli	s0,s0,0xc
    1934:	01469693          	slli	a3,a3,0x14
    1938:	02c12083          	lw	ra,44(sp)
    193c:	0086e6b3          	or	a3,a3,s0
    1940:	02812403          	lw	s0,40(sp)
    1944:	01f81813          	slli	a6,a6,0x1f
    1948:	0106e7b3          	or	a5,a3,a6
    194c:	02412483          	lw	s1,36(sp)
    1950:	02012903          	lw	s2,32(sp)
    1954:	01c12983          	lw	s3,28(sp)
    1958:	01812a03          	lw	s4,24(sp)
    195c:	01412a83          	lw	s5,20(sp)
    1960:	01012b03          	lw	s6,16(sp)
    1964:	00c12b83          	lw	s7,12(sp)
    1968:	00070513          	mv	a0,a4
    196c:	00078593          	mv	a1,a5
    1970:	03010113          	addi	sp,sp,48
    1974:	00008067          	ret
    1978:	00a4ea33          	or	s4,s1,a0
    197c:	080a0063          	beqz	s4,19fc <__muldf3+0x48c>
    1980:	04048063          	beqz	s1,19c0 <__muldf3+0x450>
    1984:	00048513          	mv	a0,s1
    1988:	13d010ef          	jal	ra,32c4 <__clzsi2>
    198c:	ff550713          	addi	a4,a0,-11
    1990:	01d00793          	li	a5,29
    1994:	ff850693          	addi	a3,a0,-8
    1998:	40e787b3          	sub	a5,a5,a4
    199c:	00d494b3          	sll	s1,s1,a3
    19a0:	00f457b3          	srl	a5,s0,a5
    19a4:	0097e7b3          	or	a5,a5,s1
    19a8:	00d414b3          	sll	s1,s0,a3
    19ac:	c0d00a93          	li	s5,-1011
    19b0:	00048a13          	mv	s4,s1
    19b4:	40aa8ab3          	sub	s5,s5,a0
    19b8:	00078493          	mv	s1,a5
    19bc:	c25ff06f          	j	15e0 <__muldf3+0x70>
    19c0:	105010ef          	jal	ra,32c4 <__clzsi2>
    19c4:	00050793          	mv	a5,a0
    19c8:	01578713          	addi	a4,a5,21
    19cc:	01c00693          	li	a3,28
    19d0:	02050513          	addi	a0,a0,32
    19d4:	fae6dee3          	bge	a3,a4,1990 <__muldf3+0x420>
    19d8:	ff878793          	addi	a5,a5,-8
    19dc:	00f417b3          	sll	a5,s0,a5
    19e0:	fcdff06f          	j	19ac <__muldf3+0x43c>
    19e4:	00a4ea33          	or	s4,s1,a0
    19e8:	020a0263          	beqz	s4,1a0c <__muldf3+0x49c>
    19ec:	00050a13          	mv	s4,a0
    19f0:	7ff00a93          	li	s5,2047
    19f4:	00300b93          	li	s7,3
    19f8:	bedff06f          	j	15e4 <__muldf3+0x74>
    19fc:	00000493          	li	s1,0
    1a00:	00000a93          	li	s5,0
    1a04:	00100b93          	li	s7,1
    1a08:	bddff06f          	j	15e4 <__muldf3+0x74>
    1a0c:	00000493          	li	s1,0
    1a10:	7ff00a93          	li	s5,2047
    1a14:	00200b93          	li	s7,2
    1a18:	bcdff06f          	j	15e4 <__muldf3+0x74>
    1a1c:	016467b3          	or	a5,s0,s6
    1a20:	08078263          	beqz	a5,1aa4 <__muldf3+0x534>
    1a24:	04040063          	beqz	s0,1a64 <__muldf3+0x4f4>
    1a28:	00040513          	mv	a0,s0
    1a2c:	099010ef          	jal	ra,32c4 <__clzsi2>
    1a30:	ff550693          	addi	a3,a0,-11
    1a34:	01d00713          	li	a4,29
    1a38:	ff850793          	addi	a5,a0,-8
    1a3c:	40d70733          	sub	a4,a4,a3
    1a40:	00f41433          	sll	s0,s0,a5
    1a44:	00eb5733          	srl	a4,s6,a4
    1a48:	00876733          	or	a4,a4,s0
    1a4c:	00fb1433          	sll	s0,s6,a5
    1a50:	c0d00693          	li	a3,-1011
    1a54:	00040793          	mv	a5,s0
    1a58:	40a686b3          	sub	a3,a3,a0
    1a5c:	00070413          	mv	s0,a4
    1a60:	bc1ff06f          	j	1620 <__muldf3+0xb0>
    1a64:	000b0513          	mv	a0,s6
    1a68:	05d010ef          	jal	ra,32c4 <__clzsi2>
    1a6c:	00050793          	mv	a5,a0
    1a70:	01578693          	addi	a3,a5,21
    1a74:	01c00713          	li	a4,28
    1a78:	02050513          	addi	a0,a0,32
    1a7c:	fad75ce3          	bge	a4,a3,1a34 <__muldf3+0x4c4>
    1a80:	ff878793          	addi	a5,a5,-8
    1a84:	00fb1733          	sll	a4,s6,a5
    1a88:	fc9ff06f          	j	1a50 <__muldf3+0x4e0>
    1a8c:	016467b3          	or	a5,s0,s6
    1a90:	02078263          	beqz	a5,1ab4 <__muldf3+0x544>
    1a94:	000b0793          	mv	a5,s6
    1a98:	7ff00693          	li	a3,2047
    1a9c:	00300613          	li	a2,3
    1aa0:	b85ff06f          	j	1624 <__muldf3+0xb4>
    1aa4:	00000413          	li	s0,0
    1aa8:	00000693          	li	a3,0
    1aac:	00100613          	li	a2,1
    1ab0:	b75ff06f          	j	1624 <__muldf3+0xb4>
    1ab4:	00000413          	li	s0,0
    1ab8:	7ff00693          	li	a3,2047
    1abc:	00200613          	li	a2,2
    1ac0:	b65ff06f          	j	1624 <__muldf3+0xb4>
    1ac4:	00100693          	li	a3,1
    1ac8:	00e696b3          	sll	a3,a3,a4
    1acc:	5306f713          	andi	a4,a3,1328
    1ad0:	04071863          	bnez	a4,1b20 <__muldf3+0x5b0>
    1ad4:	2406f593          	andi	a1,a3,576
    1ad8:	10059c63          	bnez	a1,1bf0 <__muldf3+0x680>
    1adc:	0886f693          	andi	a3,a3,136
    1ae0:	b6068ae3          	beqz	a3,1654 <__muldf3+0xe4>
    1ae4:	00090813          	mv	a6,s2
    1ae8:	00200713          	li	a4,2
    1aec:	12e60063          	beq	a2,a4,1c0c <__muldf3+0x69c>
    1af0:	00300713          	li	a4,3
    1af4:	10e60663          	beq	a2,a4,1c00 <__muldf3+0x690>
    1af8:	00100713          	li	a4,1
    1afc:	dce618e3          	bne	a2,a4,18cc <__muldf3+0x35c>
    1b00:	00000413          	li	s0,0
    1b04:	00000713          	li	a4,0
    1b08:	0ac0006f          	j	1bb4 <__muldf3+0x644>
    1b0c:	00f00693          	li	a3,15
    1b10:	0ed70863          	beq	a4,a3,1c00 <__muldf3+0x690>
    1b14:	00b00693          	li	a3,11
    1b18:	00098813          	mv	a6,s3
    1b1c:	fcd704e3          	beq	a4,a3,1ae4 <__muldf3+0x574>
    1b20:	00048413          	mv	s0,s1
    1b24:	000a0793          	mv	a5,s4
    1b28:	000b8613          	mv	a2,s7
    1b2c:	fbdff06f          	j	1ae8 <__muldf3+0x578>
    1b30:	000a8893          	mv	a7,s5
    1b34:	d99ff06f          	j	18cc <__muldf3+0x35c>
    1b38:	00100613          	li	a2,1
    1b3c:	00068c63          	beqz	a3,1b54 <__muldf3+0x5e4>
    1b40:	40d60633          	sub	a2,a2,a3
    1b44:	03800713          	li	a4,56
    1b48:	fac74ce3          	blt	a4,a2,1b00 <__muldf3+0x590>
    1b4c:	01f00713          	li	a4,31
    1b50:	06c74663          	blt	a4,a2,1bbc <__muldf3+0x64c>
    1b54:	41e88893          	addi	a7,a7,1054
    1b58:	00c7d733          	srl	a4,a5,a2
    1b5c:	011797b3          	sll	a5,a5,a7
    1b60:	00f037b3          	snez	a5,a5
    1b64:	011418b3          	sll	a7,s0,a7
    1b68:	0117e7b3          	or	a5,a5,a7
    1b6c:	00e7e7b3          	or	a5,a5,a4
    1b70:	00c45433          	srl	s0,s0,a2
    1b74:	0077f713          	andi	a4,a5,7
    1b78:	02070063          	beqz	a4,1b98 <__muldf3+0x628>
    1b7c:	00f7f713          	andi	a4,a5,15
    1b80:	00400693          	li	a3,4
    1b84:	00d70a63          	beq	a4,a3,1b98 <__muldf3+0x628>
    1b88:	00478713          	addi	a4,a5,4
    1b8c:	00f736b3          	sltu	a3,a4,a5
    1b90:	00d40433          	add	s0,s0,a3
    1b94:	00070793          	mv	a5,a4
    1b98:	00800737          	lui	a4,0x800
    1b9c:	00e47733          	and	a4,s0,a4
    1ba0:	06071e63          	bnez	a4,1c1c <__muldf3+0x6ac>
    1ba4:	01d41713          	slli	a4,s0,0x1d
    1ba8:	0037d793          	srli	a5,a5,0x3
    1bac:	00f76733          	or	a4,a4,a5
    1bb0:	00345413          	srli	s0,s0,0x3
    1bb4:	00000693          	li	a3,0
    1bb8:	d75ff06f          	j	192c <__muldf3+0x3bc>
    1bbc:	fe100713          	li	a4,-31
    1bc0:	40d70733          	sub	a4,a4,a3
    1bc4:	02000593          	li	a1,32
    1bc8:	00e45733          	srl	a4,s0,a4
    1bcc:	00000693          	li	a3,0
    1bd0:	00b60663          	beq	a2,a1,1bdc <__muldf3+0x66c>
    1bd4:	43e88893          	addi	a7,a7,1086
    1bd8:	011416b3          	sll	a3,s0,a7
    1bdc:	00f6e6b3          	or	a3,a3,a5
    1be0:	00d036b3          	snez	a3,a3
    1be4:	00d767b3          	or	a5,a4,a3
    1be8:	00000413          	li	s0,0
    1bec:	f89ff06f          	j	1b74 <__muldf3+0x604>
    1bf0:	00080437          	lui	s0,0x80
    1bf4:	7ff00693          	li	a3,2047
    1bf8:	00000813          	li	a6,0
    1bfc:	d31ff06f          	j	192c <__muldf3+0x3bc>
    1c00:	00080437          	lui	s0,0x80
    1c04:	00000713          	li	a4,0
    1c08:	fedff06f          	j	1bf4 <__muldf3+0x684>
    1c0c:	00000413          	li	s0,0
    1c10:	00000713          	li	a4,0
    1c14:	7ff00693          	li	a3,2047
    1c18:	d15ff06f          	j	192c <__muldf3+0x3bc>
    1c1c:	00000413          	li	s0,0
    1c20:	00000713          	li	a4,0
    1c24:	00100693          	li	a3,1
    1c28:	d05ff06f          	j	192c <__muldf3+0x3bc>

00001c2c <__addsf3>:
    1c2c:	ff010113          	addi	sp,sp,-16
    1c30:	00800737          	lui	a4,0x800
    1c34:	fff70713          	addi	a4,a4,-1 # 7fffff <__RODATA_END__+0x7fcbb3>
    1c38:	0175d613          	srli	a2,a1,0x17
    1c3c:	00812423          	sw	s0,8(sp)
    1c40:	01755413          	srli	s0,a0,0x17
    1c44:	00a777b3          	and	a5,a4,a0
    1c48:	01212023          	sw	s2,0(sp)
    1c4c:	00b77733          	and	a4,a4,a1
    1c50:	0ff47413          	zext.b	s0,s0
    1c54:	0ff67613          	zext.b	a2,a2
    1c58:	00112623          	sw	ra,12(sp)
    1c5c:	00912223          	sw	s1,4(sp)
    1c60:	01f55913          	srli	s2,a0,0x1f
    1c64:	01f5d593          	srli	a1,a1,0x1f
    1c68:	00379793          	slli	a5,a5,0x3
    1c6c:	00371713          	slli	a4,a4,0x3
    1c70:	40c406b3          	sub	a3,s0,a2
    1c74:	20b91863          	bne	s2,a1,1e84 <__addsf3+0x258>
    1c78:	12d05863          	blez	a3,1da8 <__addsf3+0x17c>
    1c7c:	02061e63          	bnez	a2,1cb8 <__addsf3+0x8c>
    1c80:	1e070e63          	beqz	a4,1e7c <__addsf3+0x250>
    1c84:	fff68613          	addi	a2,a3,-1
    1c88:	02061063          	bnez	a2,1ca8 <__addsf3+0x7c>
    1c8c:	00e787b3          	add	a5,a5,a4
    1c90:	04000737          	lui	a4,0x4000
    1c94:	00e7f733          	and	a4,a5,a4
    1c98:	00200413          	li	s0,2
    1c9c:	0e071863          	bnez	a4,1d8c <__addsf3+0x160>
    1ca0:	00100413          	li	s0,1
    1ca4:	0340006f          	j	1cd8 <__addsf3+0xac>
    1ca8:	0ff00593          	li	a1,255
    1cac:	02b69063          	bne	a3,a1,1ccc <__addsf3+0xa0>
    1cb0:	0ff00413          	li	s0,255
    1cb4:	0240006f          	j	1cd8 <__addsf3+0xac>
    1cb8:	0ff00613          	li	a2,255
    1cbc:	00c40e63          	beq	s0,a2,1cd8 <__addsf3+0xac>
    1cc0:	04000637          	lui	a2,0x4000
    1cc4:	00c76733          	or	a4,a4,a2
    1cc8:	00068613          	mv	a2,a3
    1ccc:	01b00693          	li	a3,27
    1cd0:	08c6d263          	bge	a3,a2,1d54 <__addsf3+0x128>
    1cd4:	00178793          	addi	a5,a5,1
    1cd8:	0077f713          	andi	a4,a5,7
    1cdc:	00070a63          	beqz	a4,1cf0 <__addsf3+0xc4>
    1ce0:	00f7f713          	andi	a4,a5,15
    1ce4:	00400693          	li	a3,4
    1ce8:	00d70463          	beq	a4,a3,1cf0 <__addsf3+0xc4>
    1cec:	00478793          	addi	a5,a5,4
    1cf0:	04000737          	lui	a4,0x4000
    1cf4:	00e7f733          	and	a4,a5,a4
    1cf8:	38070063          	beqz	a4,2078 <__neorv32_ram_size+0x78>
    1cfc:	00140413          	addi	s0,s0,1 # 80001 <__RODATA_END__+0x7cbb5>
    1d00:	0ff00713          	li	a4,255
    1d04:	00000493          	li	s1,0
    1d08:	00e40a63          	beq	s0,a4,1d1c <__addsf3+0xf0>
    1d0c:	0037d493          	srli	s1,a5,0x3
    1d10:	1f8007b7          	lui	a5,0x1f800
    1d14:	fff78793          	addi	a5,a5,-1 # 1f7fffff <__RODATA_END__+0x1f7fcbb3>
    1d18:	00f4f4b3          	and	s1,s1,a5
    1d1c:	01741413          	slli	s0,s0,0x17
    1d20:	7f8007b7          	lui	a5,0x7f800
    1d24:	00949493          	slli	s1,s1,0x9
    1d28:	0094d493          	srli	s1,s1,0x9
    1d2c:	00f47433          	and	s0,s0,a5
    1d30:	00946433          	or	s0,s0,s1
    1d34:	01f91513          	slli	a0,s2,0x1f
    1d38:	00c12083          	lw	ra,12(sp)
    1d3c:	00a46533          	or	a0,s0,a0
    1d40:	00812403          	lw	s0,8(sp)
    1d44:	00412483          	lw	s1,4(sp)
    1d48:	00012903          	lw	s2,0(sp)
    1d4c:	01010113          	addi	sp,sp,16
    1d50:	00008067          	ret
    1d54:	02000693          	li	a3,32
    1d58:	40c686b3          	sub	a3,a3,a2
    1d5c:	00c755b3          	srl	a1,a4,a2
    1d60:	00d71733          	sll	a4,a4,a3
    1d64:	00e03733          	snez	a4,a4
    1d68:	00e5e733          	or	a4,a1,a4
    1d6c:	00e787b3          	add	a5,a5,a4
    1d70:	04000737          	lui	a4,0x4000
    1d74:	00e7f733          	and	a4,a5,a4
    1d78:	f60700e3          	beqz	a4,1cd8 <__addsf3+0xac>
    1d7c:	00140413          	addi	s0,s0,1
    1d80:	0ff00713          	li	a4,255
    1d84:	00000493          	li	s1,0
    1d88:	f8e40ae3          	beq	s0,a4,1d1c <__addsf3+0xf0>
    1d8c:	7e000737          	lui	a4,0x7e000
    1d90:	0017f693          	andi	a3,a5,1
    1d94:	fff70713          	addi	a4,a4,-1 # 7dffffff <__RODATA_END__+0x7dffcbb3>
    1d98:	0017d793          	srli	a5,a5,0x1
    1d9c:	00e7f7b3          	and	a5,a5,a4
    1da0:	00d7e7b3          	or	a5,a5,a3
    1da4:	f35ff06f          	j	1cd8 <__addsf3+0xac>
    1da8:	06068a63          	beqz	a3,1e1c <__addsf3+0x1f0>
    1dac:	408606b3          	sub	a3,a2,s0
    1db0:	02041063          	bnez	s0,1dd0 <__addsf3+0x1a4>
    1db4:	2a078263          	beqz	a5,2058 <__neorv32_ram_size+0x58>
    1db8:	fff68593          	addi	a1,a3,-1
    1dbc:	ec0588e3          	beqz	a1,1c8c <__addsf3+0x60>
    1dc0:	0ff00513          	li	a0,255
    1dc4:	02a69063          	bne	a3,a0,1de4 <__addsf3+0x1b8>
    1dc8:	00070793          	mv	a5,a4
    1dcc:	ee5ff06f          	j	1cb0 <__addsf3+0x84>
    1dd0:	0ff00593          	li	a1,255
    1dd4:	feb60ae3          	beq	a2,a1,1dc8 <__addsf3+0x19c>
    1dd8:	040005b7          	lui	a1,0x4000
    1ddc:	00b7e7b3          	or	a5,a5,a1
    1de0:	00068593          	mv	a1,a3
    1de4:	01b00693          	li	a3,27
    1de8:	00b6d863          	bge	a3,a1,1df8 <__addsf3+0x1cc>
    1dec:	00170793          	addi	a5,a4,1
    1df0:	00060413          	mv	s0,a2
    1df4:	ee5ff06f          	j	1cd8 <__addsf3+0xac>
    1df8:	02000693          	li	a3,32
    1dfc:	40b686b3          	sub	a3,a3,a1
    1e00:	00b7d533          	srl	a0,a5,a1
    1e04:	00d797b3          	sll	a5,a5,a3
    1e08:	00f037b3          	snez	a5,a5
    1e0c:	00f567b3          	or	a5,a0,a5
    1e10:	00e787b3          	add	a5,a5,a4
    1e14:	00060413          	mv	s0,a2
    1e18:	f59ff06f          	j	1d70 <__addsf3+0x144>
    1e1c:	00140693          	addi	a3,s0,1
    1e20:	0fe6f613          	andi	a2,a3,254
    1e24:	04061463          	bnez	a2,1e6c <__addsf3+0x240>
    1e28:	02041663          	bnez	s0,1e54 <__addsf3+0x228>
    1e2c:	22078a63          	beqz	a5,2060 <__neorv32_ram_size+0x60>
    1e30:	ea0704e3          	beqz	a4,1cd8 <__addsf3+0xac>
    1e34:	00e787b3          	add	a5,a5,a4
    1e38:	04000737          	lui	a4,0x4000
    1e3c:	00e7f733          	and	a4,a5,a4
    1e40:	e8070ce3          	beqz	a4,1cd8 <__addsf3+0xac>
    1e44:	fc000737          	lui	a4,0xfc000
    1e48:	fff70713          	addi	a4,a4,-1 # fbffffff <__crt0_stack_end+0x7bffe000>
    1e4c:	00e7f7b3          	and	a5,a5,a4
    1e50:	e51ff06f          	j	1ca0 <__addsf3+0x74>
    1e54:	f6078ae3          	beqz	a5,1dc8 <__addsf3+0x19c>
    1e58:	e4070ce3          	beqz	a4,1cb0 <__addsf3+0x84>
    1e5c:	00000913          	li	s2,0
    1e60:	0ff00413          	li	s0,255
    1e64:	004004b7          	lui	s1,0x400
    1e68:	eb5ff06f          	j	1d1c <__addsf3+0xf0>
    1e6c:	0ff00613          	li	a2,255
    1e70:	22c68063          	beq	a3,a2,2090 <__neorv32_ram_size+0x90>
    1e74:	00e78733          	add	a4,a5,a4
    1e78:	00175793          	srli	a5,a4,0x1
    1e7c:	00068413          	mv	s0,a3
    1e80:	e59ff06f          	j	1cd8 <__addsf3+0xac>
    1e84:	08d05063          	blez	a3,1f04 <__addsf3+0x2d8>
    1e88:	06061263          	bnez	a2,1eec <__addsf3+0x2c0>
    1e8c:	fe0708e3          	beqz	a4,1e7c <__addsf3+0x250>
    1e90:	fff68613          	addi	a2,a3,-1
    1e94:	00061863          	bnez	a2,1ea4 <__addsf3+0x278>
    1e98:	40e787b3          	sub	a5,a5,a4
    1e9c:	00100413          	li	s0,1
    1ea0:	0340006f          	j	1ed4 <__addsf3+0x2a8>
    1ea4:	0ff00593          	li	a1,255
    1ea8:	e0b684e3          	beq	a3,a1,1cb0 <__addsf3+0x84>
    1eac:	01b00593          	li	a1,27
    1eb0:	00100693          	li	a3,1
    1eb4:	00c5ce63          	blt	a1,a2,1ed0 <__addsf3+0x2a4>
    1eb8:	02000693          	li	a3,32
    1ebc:	40c686b3          	sub	a3,a3,a2
    1ec0:	00c755b3          	srl	a1,a4,a2
    1ec4:	00d71733          	sll	a4,a4,a3
    1ec8:	00e03733          	snez	a4,a4
    1ecc:	00e5e6b3          	or	a3,a1,a4
    1ed0:	40d787b3          	sub	a5,a5,a3
    1ed4:	040004b7          	lui	s1,0x4000
    1ed8:	0097f733          	and	a4,a5,s1
    1edc:	de070ee3          	beqz	a4,1cd8 <__addsf3+0xac>
    1ee0:	fff48493          	addi	s1,s1,-1 # 3ffffff <__RODATA_END__+0x3ffcbb3>
    1ee4:	0097f4b3          	and	s1,a5,s1
    1ee8:	1140006f          	j	1ffc <__addsf3+0x3d0>
    1eec:	0ff00613          	li	a2,255
    1ef0:	dec404e3          	beq	s0,a2,1cd8 <__addsf3+0xac>
    1ef4:	04000637          	lui	a2,0x4000
    1ef8:	00c76733          	or	a4,a4,a2
    1efc:	00068613          	mv	a2,a3
    1f00:	fadff06f          	j	1eac <__addsf3+0x280>
    1f04:	08068063          	beqz	a3,1f84 <__addsf3+0x358>
    1f08:	408606b3          	sub	a3,a2,s0
    1f0c:	02041863          	bnez	s0,1f3c <__addsf3+0x310>
    1f10:	14078c63          	beqz	a5,2068 <__neorv32_ram_size+0x68>
    1f14:	fff68513          	addi	a0,a3,-1
    1f18:	00051863          	bnez	a0,1f28 <__addsf3+0x2fc>
    1f1c:	40f707b3          	sub	a5,a4,a5
    1f20:	00058913          	mv	s2,a1
    1f24:	f79ff06f          	j	1e9c <__addsf3+0x270>
    1f28:	0ff00813          	li	a6,255
    1f2c:	03069263          	bne	a3,a6,1f50 <__addsf3+0x324>
    1f30:	00070793          	mv	a5,a4
    1f34:	0ff00413          	li	s0,255
    1f38:	1380006f          	j	2070 <__neorv32_ram_size+0x70>
    1f3c:	0ff00513          	li	a0,255
    1f40:	fea608e3          	beq	a2,a0,1f30 <__addsf3+0x304>
    1f44:	04000537          	lui	a0,0x4000
    1f48:	00a7e7b3          	or	a5,a5,a0
    1f4c:	00068513          	mv	a0,a3
    1f50:	01b00813          	li	a6,27
    1f54:	00100693          	li	a3,1
    1f58:	00a84e63          	blt	a6,a0,1f74 <__addsf3+0x348>
    1f5c:	02000693          	li	a3,32
    1f60:	40a686b3          	sub	a3,a3,a0
    1f64:	00a7d833          	srl	a6,a5,a0
    1f68:	00d797b3          	sll	a5,a5,a3
    1f6c:	00f037b3          	snez	a5,a5
    1f70:	00f866b3          	or	a3,a6,a5
    1f74:	40d707b3          	sub	a5,a4,a3
    1f78:	00060413          	mv	s0,a2
    1f7c:	00058913          	mv	s2,a1
    1f80:	f55ff06f          	j	1ed4 <__addsf3+0x2a8>
    1f84:	00140693          	addi	a3,s0,1
    1f88:	0fe6f693          	andi	a3,a3,254
    1f8c:	04069c63          	bnez	a3,1fe4 <__addsf3+0x3b8>
    1f90:	04041063          	bnez	s0,1fd0 <__addsf3+0x3a4>
    1f94:	00079a63          	bnez	a5,1fa8 <__addsf3+0x37c>
    1f98:	00070793          	mv	a5,a4
    1f9c:	0c071a63          	bnez	a4,2070 <__neorv32_ram_size+0x70>
    1fa0:	00000493          	li	s1,0
    1fa4:	0240006f          	j	1fc8 <__addsf3+0x39c>
    1fa8:	d20708e3          	beqz	a4,1cd8 <__addsf3+0xac>
    1fac:	40e784b3          	sub	s1,a5,a4
    1fb0:	040006b7          	lui	a3,0x4000
    1fb4:	00d4f6b3          	and	a3,s1,a3
    1fb8:	40f707b3          	sub	a5,a4,a5
    1fbc:	0a069a63          	bnez	a3,2070 <__neorv32_ram_size+0x70>
    1fc0:	00048793          	mv	a5,s1
    1fc4:	d0049ae3          	bnez	s1,1cd8 <__addsf3+0xac>
    1fc8:	00000913          	li	s2,0
    1fcc:	d51ff06f          	j	1d1c <__addsf3+0xf0>
    1fd0:	e80794e3          	bnez	a5,1e58 <__addsf3+0x22c>
    1fd4:	e80704e3          	beqz	a4,1e5c <__addsf3+0x230>
    1fd8:	00070793          	mv	a5,a4
    1fdc:	00058913          	mv	s2,a1
    1fe0:	cd1ff06f          	j	1cb0 <__addsf3+0x84>
    1fe4:	40e784b3          	sub	s1,a5,a4
    1fe8:	040006b7          	lui	a3,0x4000
    1fec:	00d4f6b3          	and	a3,s1,a3
    1ff0:	04068463          	beqz	a3,2038 <__neorv32_ram_size+0x38>
    1ff4:	40f704b3          	sub	s1,a4,a5
    1ff8:	00058913          	mv	s2,a1
    1ffc:	00048513          	mv	a0,s1
    2000:	2c4010ef          	jal	ra,32c4 <__clzsi2>
    2004:	ffb50513          	addi	a0,a0,-5 # 3fffffb <__RODATA_END__+0x3ffcbaf>
    2008:	00a494b3          	sll	s1,s1,a0
    200c:	02854c63          	blt	a0,s0,2044 <__neorv32_ram_size+0x44>
    2010:	40850533          	sub	a0,a0,s0
    2014:	00150513          	addi	a0,a0,1
    2018:	02000713          	li	a4,32
    201c:	40a70733          	sub	a4,a4,a0
    2020:	00a4d7b3          	srl	a5,s1,a0
    2024:	00e494b3          	sll	s1,s1,a4
    2028:	009034b3          	snez	s1,s1
    202c:	0097e7b3          	or	a5,a5,s1
    2030:	00000413          	li	s0,0
    2034:	ca5ff06f          	j	1cd8 <__addsf3+0xac>
    2038:	fc0492e3          	bnez	s1,1ffc <__addsf3+0x3d0>
    203c:	00000413          	li	s0,0
    2040:	f89ff06f          	j	1fc8 <__addsf3+0x39c>
    2044:	fc0007b7          	lui	a5,0xfc000
    2048:	fff78793          	addi	a5,a5,-1 # fbffffff <__crt0_stack_end+0x7bffe000>
    204c:	40a40433          	sub	s0,s0,a0
    2050:	00f4f7b3          	and	a5,s1,a5
    2054:	c85ff06f          	j	1cd8 <__addsf3+0xac>
    2058:	00070793          	mv	a5,a4
    205c:	e21ff06f          	j	1e7c <__addsf3+0x250>
    2060:	00070793          	mv	a5,a4
    2064:	c75ff06f          	j	1cd8 <__addsf3+0xac>
    2068:	00070793          	mv	a5,a4
    206c:	00068413          	mv	s0,a3
    2070:	00058913          	mv	s2,a1
    2074:	c65ff06f          	j	1cd8 <__addsf3+0xac>
    2078:	0037d493          	srli	s1,a5,0x3
    207c:	0ff00793          	li	a5,255
    2080:	c8f41ee3          	bne	s0,a5,1d1c <__addsf3+0xf0>
    2084:	c8048ce3          	beqz	s1,1d1c <__addsf3+0xf0>
    2088:	004004b7          	lui	s1,0x400
    208c:	f3dff06f          	j	1fc8 <__addsf3+0x39c>
    2090:	0ff00413          	li	s0,255
    2094:	00000493          	li	s1,0
    2098:	c85ff06f          	j	1d1c <__addsf3+0xf0>

0000209c <__divsf3>:
    209c:	fd010113          	addi	sp,sp,-48
    20a0:	02912223          	sw	s1,36(sp)
    20a4:	01755493          	srli	s1,a0,0x17
    20a8:	03212023          	sw	s2,32(sp)
    20ac:	01512a23          	sw	s5,20(sp)
    20b0:	01612823          	sw	s6,16(sp)
    20b4:	00951a93          	slli	s5,a0,0x9
    20b8:	02112623          	sw	ra,44(sp)
    20bc:	02812423          	sw	s0,40(sp)
    20c0:	01312e23          	sw	s3,28(sp)
    20c4:	01412c23          	sw	s4,24(sp)
    20c8:	01712623          	sw	s7,12(sp)
    20cc:	01812423          	sw	s8,8(sp)
    20d0:	0ff4f493          	zext.b	s1,s1
    20d4:	00058b13          	mv	s6,a1
    20d8:	009ada93          	srli	s5,s5,0x9
    20dc:	01f55913          	srli	s2,a0,0x1f
    20e0:	08048463          	beqz	s1,2168 <__divsf3+0xcc>
    20e4:	0ff00793          	li	a5,255
    20e8:	0af48063          	beq	s1,a5,2188 <__divsf3+0xec>
    20ec:	003a9a93          	slli	s5,s5,0x3
    20f0:	040007b7          	lui	a5,0x4000
    20f4:	00faeab3          	or	s5,s5,a5
    20f8:	f8148493          	addi	s1,s1,-127 # 3fff81 <__RODATA_END__+0x3fcb35>
    20fc:	00000b93          	li	s7,0
    2100:	017b5793          	srli	a5,s6,0x17
    2104:	009b1413          	slli	s0,s6,0x9
    2108:	0ff7f793          	zext.b	a5,a5
    210c:	00945413          	srli	s0,s0,0x9
    2110:	01fb5b13          	srli	s6,s6,0x1f
    2114:	08078a63          	beqz	a5,21a8 <__divsf3+0x10c>
    2118:	0ff00713          	li	a4,255
    211c:	0ae78663          	beq	a5,a4,21c8 <__divsf3+0x12c>
    2120:	00341413          	slli	s0,s0,0x3
    2124:	04000737          	lui	a4,0x4000
    2128:	00e46433          	or	s0,s0,a4
    212c:	f8178793          	addi	a5,a5,-127 # 3ffff81 <__RODATA_END__+0x3ffcb35>
    2130:	00000713          	li	a4,0
    2134:	40f48a33          	sub	s4,s1,a5
    2138:	002b9793          	slli	a5,s7,0x2
    213c:	00e7e7b3          	or	a5,a5,a4
    2140:	fff78793          	addi	a5,a5,-1
    2144:	00e00693          	li	a3,14
    2148:	016949b3          	xor	s3,s2,s6
    214c:	0cf6e663          	bltu	a3,a5,2218 <__divsf3+0x17c>
    2150:	000036b7          	lui	a3,0x3
    2154:	00279793          	slli	a5,a5,0x2
    2158:	31068693          	addi	a3,a3,784 # 3310 <__etext>
    215c:	00d787b3          	add	a5,a5,a3
    2160:	0007a783          	lw	a5,0(a5)
    2164:	00078067          	jr	a5
    2168:	020a8a63          	beqz	s5,219c <__divsf3+0x100>
    216c:	000a8513          	mv	a0,s5
    2170:	154010ef          	jal	ra,32c4 <__clzsi2>
    2174:	ffb50793          	addi	a5,a0,-5
    2178:	f8a00493          	li	s1,-118
    217c:	00fa9ab3          	sll	s5,s5,a5
    2180:	40a484b3          	sub	s1,s1,a0
    2184:	f79ff06f          	j	20fc <__divsf3+0x60>
    2188:	0ff00493          	li	s1,255
    218c:	00300b93          	li	s7,3
    2190:	f60a98e3          	bnez	s5,2100 <__divsf3+0x64>
    2194:	00200b93          	li	s7,2
    2198:	f69ff06f          	j	2100 <__divsf3+0x64>
    219c:	00000493          	li	s1,0
    21a0:	00100b93          	li	s7,1
    21a4:	f5dff06f          	j	2100 <__divsf3+0x64>
    21a8:	02040a63          	beqz	s0,21dc <__divsf3+0x140>
    21ac:	00040513          	mv	a0,s0
    21b0:	114010ef          	jal	ra,32c4 <__clzsi2>
    21b4:	ffb50793          	addi	a5,a0,-5
    21b8:	00f41433          	sll	s0,s0,a5
    21bc:	f8a00793          	li	a5,-118
    21c0:	40a787b3          	sub	a5,a5,a0
    21c4:	f6dff06f          	j	2130 <__divsf3+0x94>
    21c8:	0ff00793          	li	a5,255
    21cc:	00300713          	li	a4,3
    21d0:	f60412e3          	bnez	s0,2134 <__divsf3+0x98>
    21d4:	00200713          	li	a4,2
    21d8:	f5dff06f          	j	2134 <__divsf3+0x98>
    21dc:	00000793          	li	a5,0
    21e0:	00100713          	li	a4,1
    21e4:	f51ff06f          	j	2134 <__divsf3+0x98>
    21e8:	00090993          	mv	s3,s2
    21ec:	000a8413          	mv	s0,s5
    21f0:	000b8713          	mv	a4,s7
    21f4:	00200793          	li	a5,2
    21f8:	22f70063          	beq	a4,a5,2418 <__divsf3+0x37c>
    21fc:	00300793          	li	a5,3
    2200:	20f70463          	beq	a4,a5,2408 <__divsf3+0x36c>
    2204:	00100793          	li	a5,1
    2208:	0ef71c63          	bne	a4,a5,2300 <__divsf3+0x264>
    220c:	00000793          	li	a5,0
    2210:	00000713          	li	a4,0
    2214:	1340006f          	j	2348 <__divsf3+0x2ac>
    2218:	00541c13          	slli	s8,s0,0x5
    221c:	168afa63          	bgeu	s5,s0,2390 <__divsf3+0x2f4>
    2220:	fffa0a13          	addi	s4,s4,-1
    2224:	00000413          	li	s0,0
    2228:	010c5b13          	srli	s6,s8,0x10
    222c:	00010937          	lui	s2,0x10
    2230:	000b0593          	mv	a1,s6
    2234:	fff90913          	addi	s2,s2,-1 # ffff <__RODATA_END__+0xcbb3>
    2238:	000a8513          	mv	a0,s5
    223c:	7dd000ef          	jal	ra,3218 <__hidden___udivsi3>
    2240:	012c7933          	and	s2,s8,s2
    2244:	00050593          	mv	a1,a0
    2248:	00050b93          	mv	s7,a0
    224c:	00090513          	mv	a0,s2
    2250:	79d000ef          	jal	ra,31ec <__mulsi3>
    2254:	00050493          	mv	s1,a0
    2258:	000b0593          	mv	a1,s6
    225c:	000a8513          	mv	a0,s5
    2260:	000010ef          	jal	ra,3260 <__umodsi3>
    2264:	01045793          	srli	a5,s0,0x10
    2268:	01051513          	slli	a0,a0,0x10
    226c:	00a7e7b3          	or	a5,a5,a0
    2270:	000b8413          	mv	s0,s7
    2274:	0097fe63          	bgeu	a5,s1,2290 <__divsf3+0x1f4>
    2278:	00fc07b3          	add	a5,s8,a5
    227c:	fffb8413          	addi	s0,s7,-1
    2280:	0187e863          	bltu	a5,s8,2290 <__divsf3+0x1f4>
    2284:	0097f663          	bgeu	a5,s1,2290 <__divsf3+0x1f4>
    2288:	ffeb8413          	addi	s0,s7,-2
    228c:	018787b3          	add	a5,a5,s8
    2290:	409784b3          	sub	s1,a5,s1
    2294:	000b0593          	mv	a1,s6
    2298:	00048513          	mv	a0,s1
    229c:	77d000ef          	jal	ra,3218 <__hidden___udivsi3>
    22a0:	00050593          	mv	a1,a0
    22a4:	00050a93          	mv	s5,a0
    22a8:	00090513          	mv	a0,s2
    22ac:	741000ef          	jal	ra,31ec <__mulsi3>
    22b0:	00050913          	mv	s2,a0
    22b4:	000b0593          	mv	a1,s6
    22b8:	00048513          	mv	a0,s1
    22bc:	7a5000ef          	jal	ra,3260 <__umodsi3>
    22c0:	01051793          	slli	a5,a0,0x10
    22c4:	000a8713          	mv	a4,s5
    22c8:	0327f263          	bgeu	a5,s2,22ec <__divsf3+0x250>
    22cc:	018786b3          	add	a3,a5,s8
    22d0:	00f6b633          	sltu	a2,a3,a5
    22d4:	fffa8713          	addi	a4,s5,-1
    22d8:	00068793          	mv	a5,a3
    22dc:	00061863          	bnez	a2,22ec <__divsf3+0x250>
    22e0:	0126f663          	bgeu	a3,s2,22ec <__divsf3+0x250>
    22e4:	ffea8713          	addi	a4,s5,-2
    22e8:	018687b3          	add	a5,a3,s8
    22ec:	01041413          	slli	s0,s0,0x10
    22f0:	412787b3          	sub	a5,a5,s2
    22f4:	00e46433          	or	s0,s0,a4
    22f8:	00f037b3          	snez	a5,a5
    22fc:	00f46433          	or	s0,s0,a5
    2300:	07fa0713          	addi	a4,s4,127
    2304:	0ae05063          	blez	a4,23a4 <__divsf3+0x308>
    2308:	00747793          	andi	a5,s0,7
    230c:	00078a63          	beqz	a5,2320 <__divsf3+0x284>
    2310:	00f47793          	andi	a5,s0,15
    2314:	00400693          	li	a3,4
    2318:	00d78463          	beq	a5,a3,2320 <__divsf3+0x284>
    231c:	00440413          	addi	s0,s0,4
    2320:	080007b7          	lui	a5,0x8000
    2324:	00f477b3          	and	a5,s0,a5
    2328:	00078a63          	beqz	a5,233c <__divsf3+0x2a0>
    232c:	f80007b7          	lui	a5,0xf8000
    2330:	fff78793          	addi	a5,a5,-1 # f7ffffff <__crt0_stack_end+0x77ffe000>
    2334:	00f47433          	and	s0,s0,a5
    2338:	080a0713          	addi	a4,s4,128
    233c:	0fe00793          	li	a5,254
    2340:	0ce7cc63          	blt	a5,a4,2418 <__divsf3+0x37c>
    2344:	00345793          	srli	a5,s0,0x3
    2348:	02c12083          	lw	ra,44(sp)
    234c:	02812403          	lw	s0,40(sp)
    2350:	00979793          	slli	a5,a5,0x9
    2354:	01771713          	slli	a4,a4,0x17
    2358:	0097d793          	srli	a5,a5,0x9
    235c:	01f99513          	slli	a0,s3,0x1f
    2360:	00f76733          	or	a4,a4,a5
    2364:	02412483          	lw	s1,36(sp)
    2368:	02012903          	lw	s2,32(sp)
    236c:	01c12983          	lw	s3,28(sp)
    2370:	01812a03          	lw	s4,24(sp)
    2374:	01412a83          	lw	s5,20(sp)
    2378:	01012b03          	lw	s6,16(sp)
    237c:	00c12b83          	lw	s7,12(sp)
    2380:	00812c03          	lw	s8,8(sp)
    2384:	00a76533          	or	a0,a4,a0
    2388:	03010113          	addi	sp,sp,48
    238c:	00008067          	ret
    2390:	01fa9413          	slli	s0,s5,0x1f
    2394:	001ada93          	srli	s5,s5,0x1
    2398:	e91ff06f          	j	2228 <__divsf3+0x18c>
    239c:	000b0993          	mv	s3,s6
    23a0:	e55ff06f          	j	21f4 <__divsf3+0x158>
    23a4:	00100693          	li	a3,1
    23a8:	00070c63          	beqz	a4,23c0 <__divsf3+0x324>
    23ac:	40e686b3          	sub	a3,a3,a4
    23b0:	01b00613          	li	a2,27
    23b4:	00000793          	li	a5,0
    23b8:	00000713          	li	a4,0
    23bc:	f8d646e3          	blt	a2,a3,2348 <__divsf3+0x2ac>
    23c0:	09ea0493          	addi	s1,s4,158
    23c4:	00d456b3          	srl	a3,s0,a3
    23c8:	00941433          	sll	s0,s0,s1
    23cc:	00803433          	snez	s0,s0
    23d0:	0086e7b3          	or	a5,a3,s0
    23d4:	0077f713          	andi	a4,a5,7
    23d8:	00070a63          	beqz	a4,23ec <__divsf3+0x350>
    23dc:	00f7f713          	andi	a4,a5,15
    23e0:	00400693          	li	a3,4
    23e4:	00d70463          	beq	a4,a3,23ec <__divsf3+0x350>
    23e8:	00478793          	addi	a5,a5,4
    23ec:	04000737          	lui	a4,0x4000
    23f0:	00e7f733          	and	a4,a5,a4
    23f4:	0037d793          	srli	a5,a5,0x3
    23f8:	f40708e3          	beqz	a4,2348 <__divsf3+0x2ac>
    23fc:	00000793          	li	a5,0
    2400:	00100713          	li	a4,1
    2404:	f45ff06f          	j	2348 <__divsf3+0x2ac>
    2408:	004007b7          	lui	a5,0x400
    240c:	0ff00713          	li	a4,255
    2410:	00000993          	li	s3,0
    2414:	f35ff06f          	j	2348 <__divsf3+0x2ac>
    2418:	00000793          	li	a5,0
    241c:	0ff00713          	li	a4,255
    2420:	f29ff06f          	j	2348 <__divsf3+0x2ac>

00002424 <__gesf2>:
    2424:	00800737          	lui	a4,0x800
    2428:	fff70713          	addi	a4,a4,-1 # 7fffff <__RODATA_END__+0x7fcbb3>
    242c:	01755693          	srli	a3,a0,0x17
    2430:	00a77633          	and	a2,a4,a0
    2434:	01f55793          	srli	a5,a0,0x1f
    2438:	0ff6f693          	zext.b	a3,a3
    243c:	0175d513          	srli	a0,a1,0x17
    2440:	0ff00813          	li	a6,255
    2444:	00b77733          	and	a4,a4,a1
    2448:	0ff57513          	zext.b	a0,a0
    244c:	01f5d593          	srli	a1,a1,0x1f
    2450:	03069863          	bne	a3,a6,2480 <__gesf2+0x5c>
    2454:	08061e63          	bnez	a2,24f0 <__gesf2+0xcc>
    2458:	00d50a63          	beq	a0,a3,246c <__gesf2+0x48>
    245c:	00100513          	li	a0,1
    2460:	06078c63          	beqz	a5,24d8 <__gesf2+0xb4>
    2464:	fff00513          	li	a0,-1
    2468:	00008067          	ret
    246c:	ffe00513          	li	a0,-2
    2470:	06071463          	bnez	a4,24d8 <__gesf2+0xb4>
    2474:	feb794e3          	bne	a5,a1,245c <__gesf2+0x38>
    2478:	00000513          	li	a0,0
    247c:	00008067          	ret
    2480:	03051463          	bne	a0,a6,24a8 <__gesf2+0x84>
    2484:	ffe00513          	li	a0,-2
    2488:	04071863          	bnez	a4,24d8 <__gesf2+0xb4>
    248c:	00069463          	bnez	a3,2494 <__gesf2+0x70>
    2490:	04060863          	beqz	a2,24e0 <__gesf2+0xbc>
    2494:	fcb794e3          	bne	a5,a1,245c <__gesf2+0x38>
    2498:	fff00513          	li	a0,-1
    249c:	02078e63          	beqz	a5,24d8 <__gesf2+0xb4>
    24a0:	00078513          	mv	a0,a5
    24a4:	00008067          	ret
    24a8:	02068263          	beqz	a3,24cc <__gesf2+0xa8>
    24ac:	fa0508e3          	beqz	a0,245c <__gesf2+0x38>
    24b0:	fab796e3          	bne	a5,a1,245c <__gesf2+0x38>
    24b4:	fad544e3          	blt	a0,a3,245c <__gesf2+0x38>
    24b8:	fea6c0e3          	blt	a3,a0,2498 <__gesf2+0x74>
    24bc:	fac760e3          	bltu	a4,a2,245c <__gesf2+0x38>
    24c0:	00000513          	li	a0,0
    24c4:	00e67a63          	bgeu	a2,a4,24d8 <__gesf2+0xb4>
    24c8:	fd1ff06f          	j	2498 <__gesf2+0x74>
    24cc:	fc0512e3          	bnez	a0,2490 <__gesf2+0x6c>
    24d0:	00071663          	bnez	a4,24dc <__gesf2+0xb8>
    24d4:	f80614e3          	bnez	a2,245c <__gesf2+0x38>
    24d8:	00008067          	ret
    24dc:	00061e63          	bnez	a2,24f8 <__gesf2+0xd4>
    24e0:	fff00513          	li	a0,-1
    24e4:	fe058ae3          	beqz	a1,24d8 <__gesf2+0xb4>
    24e8:	00058513          	mv	a0,a1
    24ec:	00008067          	ret
    24f0:	ffe00513          	li	a0,-2
    24f4:	00008067          	ret
    24f8:	fcb782e3          	beq	a5,a1,24bc <__gesf2+0x98>
    24fc:	f61ff06f          	j	245c <__gesf2+0x38>

00002500 <__lesf2>:
    2500:	00800737          	lui	a4,0x800
    2504:	fff70713          	addi	a4,a4,-1 # 7fffff <__RODATA_END__+0x7fcbb3>
    2508:	01755693          	srli	a3,a0,0x17
    250c:	00a77633          	and	a2,a4,a0
    2510:	01f55793          	srli	a5,a0,0x1f
    2514:	0ff6f693          	zext.b	a3,a3
    2518:	0175d513          	srli	a0,a1,0x17
    251c:	0ff00813          	li	a6,255
    2520:	00b77733          	and	a4,a4,a1
    2524:	0ff57513          	zext.b	a0,a0
    2528:	01f5d593          	srli	a1,a1,0x1f
    252c:	03069863          	bne	a3,a6,255c <__lesf2+0x5c>
    2530:	08061e63          	bnez	a2,25cc <__lesf2+0xcc>
    2534:	00d50a63          	beq	a0,a3,2548 <__lesf2+0x48>
    2538:	00100513          	li	a0,1
    253c:	06078c63          	beqz	a5,25b4 <__lesf2+0xb4>
    2540:	fff00513          	li	a0,-1
    2544:	00008067          	ret
    2548:	00200513          	li	a0,2
    254c:	06071463          	bnez	a4,25b4 <__lesf2+0xb4>
    2550:	feb794e3          	bne	a5,a1,2538 <__lesf2+0x38>
    2554:	00000513          	li	a0,0
    2558:	00008067          	ret
    255c:	03051463          	bne	a0,a6,2584 <__lesf2+0x84>
    2560:	00200513          	li	a0,2
    2564:	04071863          	bnez	a4,25b4 <__lesf2+0xb4>
    2568:	00069463          	bnez	a3,2570 <__lesf2+0x70>
    256c:	04060863          	beqz	a2,25bc <__lesf2+0xbc>
    2570:	fcb794e3          	bne	a5,a1,2538 <__lesf2+0x38>
    2574:	fff00513          	li	a0,-1
    2578:	02078e63          	beqz	a5,25b4 <__lesf2+0xb4>
    257c:	00078513          	mv	a0,a5
    2580:	00008067          	ret
    2584:	02068263          	beqz	a3,25a8 <__lesf2+0xa8>
    2588:	fa0508e3          	beqz	a0,2538 <__lesf2+0x38>
    258c:	fab796e3          	bne	a5,a1,2538 <__lesf2+0x38>
    2590:	fad544e3          	blt	a0,a3,2538 <__lesf2+0x38>
    2594:	fea6c0e3          	blt	a3,a0,2574 <__lesf2+0x74>
    2598:	fac760e3          	bltu	a4,a2,2538 <__lesf2+0x38>
    259c:	00000513          	li	a0,0
    25a0:	00e67a63          	bgeu	a2,a4,25b4 <__lesf2+0xb4>
    25a4:	fd1ff06f          	j	2574 <__lesf2+0x74>
    25a8:	fc0512e3          	bnez	a0,256c <__lesf2+0x6c>
    25ac:	00071663          	bnez	a4,25b8 <__lesf2+0xb8>
    25b0:	f80614e3          	bnez	a2,2538 <__lesf2+0x38>
    25b4:	00008067          	ret
    25b8:	00061e63          	bnez	a2,25d4 <__lesf2+0xd4>
    25bc:	fff00513          	li	a0,-1
    25c0:	fe058ae3          	beqz	a1,25b4 <__lesf2+0xb4>
    25c4:	00058513          	mv	a0,a1
    25c8:	00008067          	ret
    25cc:	00200513          	li	a0,2
    25d0:	00008067          	ret
    25d4:	fcb782e3          	beq	a5,a1,2598 <__lesf2+0x98>
    25d8:	f61ff06f          	j	2538 <__lesf2+0x38>

000025dc <__mulsf3>:
    25dc:	fe010113          	addi	sp,sp,-32
    25e0:	01212823          	sw	s2,16(sp)
    25e4:	01755913          	srli	s2,a0,0x17
    25e8:	00912a23          	sw	s1,20(sp)
    25ec:	01312623          	sw	s3,12(sp)
    25f0:	01512223          	sw	s5,4(sp)
    25f4:	00951493          	slli	s1,a0,0x9
    25f8:	00112e23          	sw	ra,28(sp)
    25fc:	00812c23          	sw	s0,24(sp)
    2600:	01412423          	sw	s4,8(sp)
    2604:	0ff97913          	zext.b	s2,s2
    2608:	00058a93          	mv	s5,a1
    260c:	0094d493          	srli	s1,s1,0x9
    2610:	01f55993          	srli	s3,a0,0x1f
    2614:	1a090e63          	beqz	s2,27d0 <__mulsf3+0x1f4>
    2618:	0ff00793          	li	a5,255
    261c:	1cf90a63          	beq	s2,a5,27f0 <__mulsf3+0x214>
    2620:	00349493          	slli	s1,s1,0x3
    2624:	040007b7          	lui	a5,0x4000
    2628:	00f4e4b3          	or	s1,s1,a5
    262c:	f8190913          	addi	s2,s2,-127
    2630:	00000a13          	li	s4,0
    2634:	017ad793          	srli	a5,s5,0x17
    2638:	009a9413          	slli	s0,s5,0x9
    263c:	0ff7f793          	zext.b	a5,a5
    2640:	00945413          	srli	s0,s0,0x9
    2644:	01fada93          	srli	s5,s5,0x1f
    2648:	1c078463          	beqz	a5,2810 <__mulsf3+0x234>
    264c:	0ff00713          	li	a4,255
    2650:	1ee78063          	beq	a5,a4,2830 <__mulsf3+0x254>
    2654:	00341413          	slli	s0,s0,0x3
    2658:	04000737          	lui	a4,0x4000
    265c:	00e46433          	or	s0,s0,a4
    2660:	f8178793          	addi	a5,a5,-127 # 3ffff81 <__RODATA_END__+0x3ffcb35>
    2664:	00000713          	li	a4,0
    2668:	00f90933          	add	s2,s2,a5
    266c:	002a1793          	slli	a5,s4,0x2
    2670:	00e7e7b3          	or	a5,a5,a4
    2674:	00a00693          	li	a3,10
    2678:	0159c833          	xor	a6,s3,s5
    267c:	00190893          	addi	a7,s2,1
    2680:	20f6cc63          	blt	a3,a5,2898 <__mulsf3+0x2bc>
    2684:	00200693          	li	a3,2
    2688:	1cf6c463          	blt	a3,a5,2850 <__mulsf3+0x274>
    268c:	fff78793          	addi	a5,a5,-1
    2690:	00100693          	li	a3,1
    2694:	1ef6f063          	bgeu	a3,a5,2874 <__mulsf3+0x298>
    2698:	00010eb7          	lui	t4,0x10
    269c:	fffe8313          	addi	t1,t4,-1 # ffff <__RODATA_END__+0xcbb3>
    26a0:	0104df93          	srli	t6,s1,0x10
    26a4:	01045f13          	srli	t5,s0,0x10
    26a8:	0064f4b3          	and	s1,s1,t1
    26ac:	00647433          	and	s0,s0,t1
    26b0:	00048513          	mv	a0,s1
    26b4:	00040593          	mv	a1,s0
    26b8:	335000ef          	jal	ra,31ec <__mulsi3>
    26bc:	00050713          	mv	a4,a0
    26c0:	000f0593          	mv	a1,t5
    26c4:	00048513          	mv	a0,s1
    26c8:	325000ef          	jal	ra,31ec <__mulsi3>
    26cc:	00050793          	mv	a5,a0
    26d0:	00040593          	mv	a1,s0
    26d4:	000f8513          	mv	a0,t6
    26d8:	315000ef          	jal	ra,31ec <__mulsi3>
    26dc:	00050e13          	mv	t3,a0
    26e0:	000f0593          	mv	a1,t5
    26e4:	000f8513          	mv	a0,t6
    26e8:	305000ef          	jal	ra,31ec <__mulsi3>
    26ec:	01075413          	srli	s0,a4,0x10
    26f0:	01c787b3          	add	a5,a5,t3
    26f4:	00f40433          	add	s0,s0,a5
    26f8:	00050693          	mv	a3,a0
    26fc:	01c47463          	bgeu	s0,t3,2704 <__mulsf3+0x128>
    2700:	01d506b3          	add	a3,a0,t4
    2704:	006477b3          	and	a5,s0,t1
    2708:	00677733          	and	a4,a4,t1
    270c:	01079793          	slli	a5,a5,0x10
    2710:	00e787b3          	add	a5,a5,a4
    2714:	00679713          	slli	a4,a5,0x6
    2718:	01045413          	srli	s0,s0,0x10
    271c:	00e03733          	snez	a4,a4
    2720:	01a7d793          	srli	a5,a5,0x1a
    2724:	00d40433          	add	s0,s0,a3
    2728:	00f767b3          	or	a5,a4,a5
    272c:	00641413          	slli	s0,s0,0x6
    2730:	00f46433          	or	s0,s0,a5
    2734:	080007b7          	lui	a5,0x8000
    2738:	00f477b3          	and	a5,s0,a5
    273c:	16078e63          	beqz	a5,28b8 <__mulsf3+0x2dc>
    2740:	00145793          	srli	a5,s0,0x1
    2744:	00147413          	andi	s0,s0,1
    2748:	0087e433          	or	s0,a5,s0
    274c:	07f88513          	addi	a0,a7,127
    2750:	16a05863          	blez	a0,28c0 <__mulsf3+0x2e4>
    2754:	00747793          	andi	a5,s0,7
    2758:	00078a63          	beqz	a5,276c <__mulsf3+0x190>
    275c:	00f47793          	andi	a5,s0,15
    2760:	00400713          	li	a4,4
    2764:	00e78463          	beq	a5,a4,276c <__mulsf3+0x190>
    2768:	00440413          	addi	s0,s0,4
    276c:	080007b7          	lui	a5,0x8000
    2770:	00f477b3          	and	a5,s0,a5
    2774:	00078a63          	beqz	a5,2788 <__mulsf3+0x1ac>
    2778:	f80007b7          	lui	a5,0xf8000
    277c:	fff78793          	addi	a5,a5,-1 # f7ffffff <__crt0_stack_end+0x77ffe000>
    2780:	00f47433          	and	s0,s0,a5
    2784:	08088513          	addi	a0,a7,128
    2788:	0fe00793          	li	a5,254
    278c:	1aa7c463          	blt	a5,a0,2934 <__mulsf3+0x358>
    2790:	00345793          	srli	a5,s0,0x3
    2794:	01c12083          	lw	ra,28(sp)
    2798:	01812403          	lw	s0,24(sp)
    279c:	00979793          	slli	a5,a5,0x9
    27a0:	01751513          	slli	a0,a0,0x17
    27a4:	0097d793          	srli	a5,a5,0x9
    27a8:	00f56533          	or	a0,a0,a5
    27ac:	01f81813          	slli	a6,a6,0x1f
    27b0:	01412483          	lw	s1,20(sp)
    27b4:	01012903          	lw	s2,16(sp)
    27b8:	00c12983          	lw	s3,12(sp)
    27bc:	00812a03          	lw	s4,8(sp)
    27c0:	00412a83          	lw	s5,4(sp)
    27c4:	01056533          	or	a0,a0,a6
    27c8:	02010113          	addi	sp,sp,32
    27cc:	00008067          	ret
    27d0:	02048a63          	beqz	s1,2804 <__mulsf3+0x228>
    27d4:	00048513          	mv	a0,s1
    27d8:	2ed000ef          	jal	ra,32c4 <__clzsi2>
    27dc:	ffb50793          	addi	a5,a0,-5
    27e0:	f8a00913          	li	s2,-118
    27e4:	00f494b3          	sll	s1,s1,a5
    27e8:	40a90933          	sub	s2,s2,a0
    27ec:	e45ff06f          	j	2630 <__mulsf3+0x54>
    27f0:	0ff00913          	li	s2,255
    27f4:	00300a13          	li	s4,3
    27f8:	e2049ee3          	bnez	s1,2634 <__mulsf3+0x58>
    27fc:	00200a13          	li	s4,2
    2800:	e35ff06f          	j	2634 <__mulsf3+0x58>
    2804:	00000913          	li	s2,0
    2808:	00100a13          	li	s4,1
    280c:	e29ff06f          	j	2634 <__mulsf3+0x58>
    2810:	02040a63          	beqz	s0,2844 <__mulsf3+0x268>
    2814:	00040513          	mv	a0,s0
    2818:	2ad000ef          	jal	ra,32c4 <__clzsi2>
    281c:	ffb50793          	addi	a5,a0,-5
    2820:	00f41433          	sll	s0,s0,a5
    2824:	f8a00793          	li	a5,-118
    2828:	40a787b3          	sub	a5,a5,a0
    282c:	e39ff06f          	j	2664 <__mulsf3+0x88>
    2830:	0ff00793          	li	a5,255
    2834:	00300713          	li	a4,3
    2838:	e20418e3          	bnez	s0,2668 <__mulsf3+0x8c>
    283c:	00200713          	li	a4,2
    2840:	e29ff06f          	j	2668 <__mulsf3+0x8c>
    2844:	00000793          	li	a5,0
    2848:	00100713          	li	a4,1
    284c:	e1dff06f          	j	2668 <__mulsf3+0x8c>
    2850:	00100693          	li	a3,1
    2854:	00f697b3          	sll	a5,a3,a5
    2858:	5307f693          	andi	a3,a5,1328
    285c:	04069863          	bnez	a3,28ac <__mulsf3+0x2d0>
    2860:	2407f693          	andi	a3,a5,576
    2864:	0c069063          	bnez	a3,2924 <__mulsf3+0x348>
    2868:	0887f793          	andi	a5,a5,136
    286c:	e20786e3          	beqz	a5,2698 <__mulsf3+0xbc>
    2870:	000a8813          	mv	a6,s5
    2874:	00200793          	li	a5,2
    2878:	0af70e63          	beq	a4,a5,2934 <__mulsf3+0x358>
    287c:	00300793          	li	a5,3
    2880:	0af70263          	beq	a4,a5,2924 <__mulsf3+0x348>
    2884:	00100793          	li	a5,1
    2888:	ecf712e3          	bne	a4,a5,274c <__mulsf3+0x170>
    288c:	00000793          	li	a5,0
    2890:	00000513          	li	a0,0
    2894:	f01ff06f          	j	2794 <__mulsf3+0x1b8>
    2898:	00f00693          	li	a3,15
    289c:	08d78463          	beq	a5,a3,2924 <__mulsf3+0x348>
    28a0:	00b00693          	li	a3,11
    28a4:	00098813          	mv	a6,s3
    28a8:	fcd784e3          	beq	a5,a3,2870 <__mulsf3+0x294>
    28ac:	00048413          	mv	s0,s1
    28b0:	000a0713          	mv	a4,s4
    28b4:	fc1ff06f          	j	2874 <__mulsf3+0x298>
    28b8:	00090893          	mv	a7,s2
    28bc:	e91ff06f          	j	274c <__mulsf3+0x170>
    28c0:	00100713          	li	a4,1
    28c4:	00050c63          	beqz	a0,28dc <__mulsf3+0x300>
    28c8:	40a70733          	sub	a4,a4,a0
    28cc:	01b00693          	li	a3,27
    28d0:	00000793          	li	a5,0
    28d4:	00000513          	li	a0,0
    28d8:	eae6cee3          	blt	a3,a4,2794 <__mulsf3+0x1b8>
    28dc:	09e88893          	addi	a7,a7,158
    28e0:	00e45733          	srl	a4,s0,a4
    28e4:	01141433          	sll	s0,s0,a7
    28e8:	00803433          	snez	s0,s0
    28ec:	008767b3          	or	a5,a4,s0
    28f0:	0077f713          	andi	a4,a5,7
    28f4:	00070a63          	beqz	a4,2908 <__mulsf3+0x32c>
    28f8:	00f7f713          	andi	a4,a5,15
    28fc:	00400693          	li	a3,4
    2900:	00d70463          	beq	a4,a3,2908 <__mulsf3+0x32c>
    2904:	00478793          	addi	a5,a5,4
    2908:	04000737          	lui	a4,0x4000
    290c:	00e7f733          	and	a4,a5,a4
    2910:	0037d793          	srli	a5,a5,0x3
    2914:	f6070ee3          	beqz	a4,2890 <__mulsf3+0x2b4>
    2918:	00000793          	li	a5,0
    291c:	00100513          	li	a0,1
    2920:	e75ff06f          	j	2794 <__mulsf3+0x1b8>
    2924:	004007b7          	lui	a5,0x400
    2928:	0ff00513          	li	a0,255
    292c:	00000813          	li	a6,0
    2930:	e65ff06f          	j	2794 <__mulsf3+0x1b8>
    2934:	00000793          	li	a5,0
    2938:	0ff00513          	li	a0,255
    293c:	e59ff06f          	j	2794 <__mulsf3+0x1b8>

00002940 <__subsf3>:
    2940:	00800737          	lui	a4,0x800
    2944:	ff010113          	addi	sp,sp,-16
    2948:	01755793          	srli	a5,a0,0x17
    294c:	fff70713          	addi	a4,a4,-1 # 7fffff <__RODATA_END__+0x7fcbb3>
    2950:	0175d613          	srli	a2,a1,0x17
    2954:	00912223          	sw	s1,4(sp)
    2958:	01212023          	sw	s2,0(sp)
    295c:	00a776b3          	and	a3,a4,a0
    2960:	0ff7f913          	zext.b	s2,a5
    2964:	00112623          	sw	ra,12(sp)
    2968:	00b777b3          	and	a5,a4,a1
    296c:	00812423          	sw	s0,8(sp)
    2970:	0ff67613          	zext.b	a2,a2
    2974:	0ff00813          	li	a6,255
    2978:	01f55493          	srli	s1,a0,0x1f
    297c:	01f5d593          	srli	a1,a1,0x1f
    2980:	00369513          	slli	a0,a3,0x3
    2984:	00379793          	slli	a5,a5,0x3
    2988:	09061e63          	bne	a2,a6,2a24 <__subsf3+0xe4>
    298c:	f0190713          	addi	a4,s2,-255
    2990:	00078e63          	beqz	a5,29ac <__subsf3+0x6c>
    2994:	00058693          	mv	a3,a1
    2998:	2ab49063          	bne	s1,a1,2c38 <__subsf3+0x2f8>
    299c:	1c070463          	beqz	a4,2b64 <__subsf3+0x224>
    29a0:	0c091463          	bnez	s2,2a68 <__subsf3+0x128>
    29a4:	0ff00913          	li	s2,255
    29a8:	1700006f          	j	2b18 <__subsf3+0x1d8>
    29ac:	0015c693          	xori	a3,a1,1
    29b0:	28d49e63          	bne	s1,a3,2c4c <__subsf3+0x30c>
    29b4:	1a070863          	beqz	a4,2b64 <__subsf3+0x224>
    29b8:	fe0906e3          	beqz	s2,29a4 <__subsf3+0x64>
    29bc:	0ff00913          	li	s2,255
    29c0:	04000737          	lui	a4,0x4000
    29c4:	00e7f733          	and	a4,a5,a4
    29c8:	40070463          	beqz	a4,2dd0 <__subsf3+0x490>
    29cc:	00190913          	addi	s2,s2,1
    29d0:	0ff00713          	li	a4,255
    29d4:	00000413          	li	s0,0
    29d8:	00e90a63          	beq	s2,a4,29ec <__subsf3+0xac>
    29dc:	0037d413          	srli	s0,a5,0x3
    29e0:	1f8007b7          	lui	a5,0x1f800
    29e4:	fff78793          	addi	a5,a5,-1 # 1f7fffff <__RODATA_END__+0x1f7fcbb3>
    29e8:	00f47433          	and	s0,s0,a5
    29ec:	01791793          	slli	a5,s2,0x17
    29f0:	7f800737          	lui	a4,0x7f800
    29f4:	00941413          	slli	s0,s0,0x9
    29f8:	00945413          	srli	s0,s0,0x9
    29fc:	00e7f7b3          	and	a5,a5,a4
    2a00:	00c12083          	lw	ra,12(sp)
    2a04:	0087e7b3          	or	a5,a5,s0
    2a08:	00812403          	lw	s0,8(sp)
    2a0c:	01f49513          	slli	a0,s1,0x1f
    2a10:	00012903          	lw	s2,0(sp)
    2a14:	00412483          	lw	s1,4(sp)
    2a18:	00a7e533          	or	a0,a5,a0
    2a1c:	01010113          	addi	sp,sp,16
    2a20:	00008067          	ret
    2a24:	0015c693          	xori	a3,a1,1
    2a28:	40c90733          	sub	a4,s2,a2
    2a2c:	18d49a63          	bne	s1,a3,2bc0 <__subsf3+0x280>
    2a30:	0ce05663          	blez	a4,2afc <__subsf3+0x1bc>
    2a34:	02061e63          	bnez	a2,2a70 <__subsf3+0x130>
    2a38:	38078463          	beqz	a5,2dc0 <__subsf3+0x480>
    2a3c:	fff70693          	addi	a3,a4,-1 # 7f7fffff <__RODATA_END__+0x7f7fcbb3>
    2a40:	02069063          	bnez	a3,2a60 <__subsf3+0x120>
    2a44:	00a787b3          	add	a5,a5,a0
    2a48:	04000737          	lui	a4,0x4000
    2a4c:	00e7f733          	and	a4,a5,a4
    2a50:	00200913          	li	s2,2
    2a54:	08071663          	bnez	a4,2ae0 <__subsf3+0x1a0>
    2a58:	00100913          	li	s2,1
    2a5c:	0300006f          	j	2a8c <__subsf3+0x14c>
    2a60:	03071063          	bne	a4,a6,2a80 <__subsf3+0x140>
    2a64:	00050793          	mv	a5,a0
    2a68:	0ff00913          	li	s2,255
    2a6c:	0200006f          	j	2a8c <__subsf3+0x14c>
    2a70:	35090c63          	beq	s2,a6,2dc8 <__subsf3+0x488>
    2a74:	040006b7          	lui	a3,0x4000
    2a78:	00d7e7b3          	or	a5,a5,a3
    2a7c:	00070693          	mv	a3,a4
    2a80:	01b00713          	li	a4,27
    2a84:	02d75263          	bge	a4,a3,2aa8 <__subsf3+0x168>
    2a88:	00150793          	addi	a5,a0,1
    2a8c:	0077f713          	andi	a4,a5,7
    2a90:	f20708e3          	beqz	a4,29c0 <__subsf3+0x80>
    2a94:	00f7f713          	andi	a4,a5,15
    2a98:	00400693          	li	a3,4
    2a9c:	f2d702e3          	beq	a4,a3,29c0 <__subsf3+0x80>
    2aa0:	00478793          	addi	a5,a5,4
    2aa4:	f1dff06f          	j	29c0 <__subsf3+0x80>
    2aa8:	02000713          	li	a4,32
    2aac:	40d70733          	sub	a4,a4,a3
    2ab0:	00e79733          	sll	a4,a5,a4
    2ab4:	00d7d633          	srl	a2,a5,a3
    2ab8:	00e03733          	snez	a4,a4
    2abc:	00e667b3          	or	a5,a2,a4
    2ac0:	00a787b3          	add	a5,a5,a0
    2ac4:	04000737          	lui	a4,0x4000
    2ac8:	00e7f733          	and	a4,a5,a4
    2acc:	fc0700e3          	beqz	a4,2a8c <__subsf3+0x14c>
    2ad0:	00190913          	addi	s2,s2,1
    2ad4:	0ff00713          	li	a4,255
    2ad8:	00000413          	li	s0,0
    2adc:	f0e908e3          	beq	s2,a4,29ec <__subsf3+0xac>
    2ae0:	7e000737          	lui	a4,0x7e000
    2ae4:	0017f693          	andi	a3,a5,1
    2ae8:	fff70713          	addi	a4,a4,-1 # 7dffffff <__RODATA_END__+0x7dffcbb3>
    2aec:	0017d793          	srli	a5,a5,0x1
    2af0:	00e7f7b3          	and	a5,a5,a4
    2af4:	00d7e7b3          	or	a5,a5,a3
    2af8:	f95ff06f          	j	2a8c <__subsf3+0x14c>
    2afc:	06070463          	beqz	a4,2b64 <__subsf3+0x224>
    2b00:	412606b3          	sub	a3,a2,s2
    2b04:	00090863          	beqz	s2,2b14 <__subsf3+0x1d4>
    2b08:	04000737          	lui	a4,0x4000
    2b0c:	00e56533          	or	a0,a0,a4
    2b10:	01c0006f          	j	2b2c <__subsf3+0x1ec>
    2b14:	00068913          	mv	s2,a3
    2b18:	f6050ae3          	beqz	a0,2a8c <__subsf3+0x14c>
    2b1c:	fff90693          	addi	a3,s2,-1
    2b20:	f20682e3          	beqz	a3,2a44 <__subsf3+0x104>
    2b24:	0ff00713          	li	a4,255
    2b28:	f6e902e3          	beq	s2,a4,2a8c <__subsf3+0x14c>
    2b2c:	01b00713          	li	a4,27
    2b30:	00d75863          	bge	a4,a3,2b40 <__subsf3+0x200>
    2b34:	00178793          	addi	a5,a5,1
    2b38:	00060913          	mv	s2,a2
    2b3c:	f51ff06f          	j	2a8c <__subsf3+0x14c>
    2b40:	02000713          	li	a4,32
    2b44:	40d70733          	sub	a4,a4,a3
    2b48:	00e51733          	sll	a4,a0,a4
    2b4c:	00d555b3          	srl	a1,a0,a3
    2b50:	00e03733          	snez	a4,a4
    2b54:	00e5e733          	or	a4,a1,a4
    2b58:	00e787b3          	add	a5,a5,a4
    2b5c:	00060913          	mv	s2,a2
    2b60:	f65ff06f          	j	2ac4 <__subsf3+0x184>
    2b64:	00190713          	addi	a4,s2,1
    2b68:	0fe77693          	andi	a3,a4,254
    2b6c:	02069e63          	bnez	a3,2ba8 <__subsf3+0x268>
    2b70:	02091663          	bnez	s2,2b9c <__subsf3+0x25c>
    2b74:	f0050ce3          	beqz	a0,2a8c <__subsf3+0x14c>
    2b78:	24078863          	beqz	a5,2dc8 <__subsf3+0x488>
    2b7c:	00a787b3          	add	a5,a5,a0
    2b80:	04000737          	lui	a4,0x4000
    2b84:	00e7f733          	and	a4,a5,a4
    2b88:	f00702e3          	beqz	a4,2a8c <__subsf3+0x14c>
    2b8c:	fc000737          	lui	a4,0xfc000
    2b90:	fff70713          	addi	a4,a4,-1 # fbffffff <__crt0_stack_end+0x7bffe000>
    2b94:	00e7f7b3          	and	a5,a5,a4
    2b98:	ec1ff06f          	j	2a58 <__subsf3+0x118>
    2b9c:	ec0506e3          	beqz	a0,2a68 <__subsf3+0x128>
    2ba0:	ec0782e3          	beqz	a5,2a64 <__subsf3+0x124>
    2ba4:	1980006f          	j	2d3c <__subsf3+0x3fc>
    2ba8:	0ff00693          	li	a3,255
    2bac:	22d70e63          	beq	a4,a3,2de8 <__subsf3+0x4a8>
    2bb0:	00f507b3          	add	a5,a0,a5
    2bb4:	0017d793          	srli	a5,a5,0x1
    2bb8:	00070913          	mv	s2,a4
    2bbc:	ed1ff06f          	j	2a8c <__subsf3+0x14c>
    2bc0:	0ae05063          	blez	a4,2c60 <__subsf3+0x320>
    2bc4:	06061063          	bnez	a2,2c24 <__subsf3+0x2e4>
    2bc8:	1e078c63          	beqz	a5,2dc0 <__subsf3+0x480>
    2bcc:	fff70693          	addi	a3,a4,-1
    2bd0:	00069863          	bnez	a3,2be0 <__subsf3+0x2a0>
    2bd4:	40f507b3          	sub	a5,a0,a5
    2bd8:	00100913          	li	s2,1
    2bdc:	0300006f          	j	2c0c <__subsf3+0x2cc>
    2be0:	e90702e3          	beq	a4,a6,2a64 <__subsf3+0x124>
    2be4:	01b00613          	li	a2,27
    2be8:	00100713          	li	a4,1
    2bec:	00d64e63          	blt	a2,a3,2c08 <__subsf3+0x2c8>
    2bf0:	02000713          	li	a4,32
    2bf4:	40d70733          	sub	a4,a4,a3
    2bf8:	00e79733          	sll	a4,a5,a4
    2bfc:	00d7d633          	srl	a2,a5,a3
    2c00:	00e03733          	snez	a4,a4
    2c04:	00e66733          	or	a4,a2,a4
    2c08:	40e507b3          	sub	a5,a0,a4
    2c0c:	04000437          	lui	s0,0x4000
    2c10:	0087f733          	and	a4,a5,s0
    2c14:	e6070ce3          	beqz	a4,2a8c <__subsf3+0x14c>
    2c18:	fff40413          	addi	s0,s0,-1 # 3ffffff <__RODATA_END__+0x3ffcbb3>
    2c1c:	0087f433          	and	s0,a5,s0
    2c20:	1440006f          	j	2d64 <__subsf3+0x424>
    2c24:	1b090263          	beq	s2,a6,2dc8 <__subsf3+0x488>
    2c28:	040006b7          	lui	a3,0x4000
    2c2c:	00d7e7b3          	or	a5,a5,a3
    2c30:	00070693          	mv	a3,a4
    2c34:	fb1ff06f          	j	2be4 <__subsf3+0x2a4>
    2c38:	0a070663          	beqz	a4,2ce4 <__subsf3+0x3a4>
    2c3c:	04090663          	beqz	s2,2c88 <__subsf3+0x348>
    2c40:	0ff00913          	li	s2,255
    2c44:	00058493          	mv	s1,a1
    2c48:	e45ff06f          	j	2a8c <__subsf3+0x14c>
    2c4c:	08070c63          	beqz	a4,2ce4 <__subsf3+0x3a4>
    2c50:	04090263          	beqz	s2,2c94 <__subsf3+0x354>
    2c54:	0ff00913          	li	s2,255
    2c58:	00068493          	mv	s1,a3
    2c5c:	d65ff06f          	j	29c0 <__subsf3+0x80>
    2c60:	08070263          	beqz	a4,2ce4 <__subsf3+0x3a4>
    2c64:	412605b3          	sub	a1,a2,s2
    2c68:	06091663          	bnez	s2,2cd4 <__subsf3+0x394>
    2c6c:	00068493          	mv	s1,a3
    2c70:	00058913          	mv	s2,a1
    2c74:	e0050ce3          	beqz	a0,2a8c <__subsf3+0x14c>
    2c78:	fff90593          	addi	a1,s2,-1
    2c7c:	02059063          	bnez	a1,2c9c <__subsf3+0x35c>
    2c80:	40a787b3          	sub	a5,a5,a0
    2c84:	f55ff06f          	j	2bd8 <__subsf3+0x298>
    2c88:	00058493          	mv	s1,a1
    2c8c:	0ff00913          	li	s2,255
    2c90:	fe5ff06f          	j	2c74 <__subsf3+0x334>
    2c94:	00068493          	mv	s1,a3
    2c98:	ff5ff06f          	j	2c8c <__subsf3+0x34c>
    2c9c:	0ff00713          	li	a4,255
    2ca0:	dee906e3          	beq	s2,a4,2a8c <__subsf3+0x14c>
    2ca4:	01b00693          	li	a3,27
    2ca8:	00100713          	li	a4,1
    2cac:	00b6ce63          	blt	a3,a1,2cc8 <__subsf3+0x388>
    2cb0:	02000713          	li	a4,32
    2cb4:	40b70733          	sub	a4,a4,a1
    2cb8:	00e51733          	sll	a4,a0,a4
    2cbc:	00b556b3          	srl	a3,a0,a1
    2cc0:	00e03733          	snez	a4,a4
    2cc4:	00e6e733          	or	a4,a3,a4
    2cc8:	40e787b3          	sub	a5,a5,a4
    2ccc:	00060913          	mv	s2,a2
    2cd0:	f3dff06f          	j	2c0c <__subsf3+0x2cc>
    2cd4:	04000737          	lui	a4,0x4000
    2cd8:	00e56533          	or	a0,a0,a4
    2cdc:	00068493          	mv	s1,a3
    2ce0:	fc5ff06f          	j	2ca4 <__subsf3+0x364>
    2ce4:	00190713          	addi	a4,s2,1
    2ce8:	0fe77713          	andi	a4,a4,254
    2cec:	06071063          	bnez	a4,2d4c <__subsf3+0x40c>
    2cf0:	04091063          	bnez	s2,2d30 <__subsf3+0x3f0>
    2cf4:	00051863          	bnez	a0,2d04 <__subsf3+0x3c4>
    2cf8:	0e078e63          	beqz	a5,2df4 <__subsf3+0x4b4>
    2cfc:	00068493          	mv	s1,a3
    2d00:	d8dff06f          	j	2a8c <__subsf3+0x14c>
    2d04:	0c078263          	beqz	a5,2dc8 <__subsf3+0x488>
    2d08:	40f50433          	sub	s0,a0,a5
    2d0c:	04000737          	lui	a4,0x4000
    2d10:	00e47733          	and	a4,s0,a4
    2d14:	00070663          	beqz	a4,2d20 <__subsf3+0x3e0>
    2d18:	40a787b3          	sub	a5,a5,a0
    2d1c:	fe1ff06f          	j	2cfc <__subsf3+0x3bc>
    2d20:	00040793          	mv	a5,s0
    2d24:	d60414e3          	bnez	s0,2a8c <__subsf3+0x14c>
    2d28:	00000493          	li	s1,0
    2d2c:	cc1ff06f          	j	29ec <__subsf3+0xac>
    2d30:	e60518e3          	bnez	a0,2ba0 <__subsf3+0x260>
    2d34:	00068493          	mv	s1,a3
    2d38:	d20798e3          	bnez	a5,2a68 <__subsf3+0x128>
    2d3c:	00000493          	li	s1,0
    2d40:	0ff00913          	li	s2,255
    2d44:	00400437          	lui	s0,0x400
    2d48:	ca5ff06f          	j	29ec <__subsf3+0xac>
    2d4c:	40f50433          	sub	s0,a0,a5
    2d50:	04000737          	lui	a4,0x4000
    2d54:	00e47733          	and	a4,s0,a4
    2d58:	04070463          	beqz	a4,2da0 <__subsf3+0x460>
    2d5c:	40a78433          	sub	s0,a5,a0
    2d60:	00068493          	mv	s1,a3
    2d64:	00040513          	mv	a0,s0
    2d68:	55c000ef          	jal	ra,32c4 <__clzsi2>
    2d6c:	ffb50513          	addi	a0,a0,-5
    2d70:	00a41433          	sll	s0,s0,a0
    2d74:	03254c63          	blt	a0,s2,2dac <__subsf3+0x46c>
    2d78:	41250533          	sub	a0,a0,s2
    2d7c:	00150513          	addi	a0,a0,1
    2d80:	02000713          	li	a4,32
    2d84:	40a70733          	sub	a4,a4,a0
    2d88:	00a457b3          	srl	a5,s0,a0
    2d8c:	00e41433          	sll	s0,s0,a4
    2d90:	00803433          	snez	s0,s0
    2d94:	0087e7b3          	or	a5,a5,s0
    2d98:	00000913          	li	s2,0
    2d9c:	cf1ff06f          	j	2a8c <__subsf3+0x14c>
    2da0:	fc0412e3          	bnez	s0,2d64 <__subsf3+0x424>
    2da4:	00000913          	li	s2,0
    2da8:	f81ff06f          	j	2d28 <__subsf3+0x3e8>
    2dac:	fc0007b7          	lui	a5,0xfc000
    2db0:	fff78793          	addi	a5,a5,-1 # fbffffff <__crt0_stack_end+0x7bffe000>
    2db4:	40a90933          	sub	s2,s2,a0
    2db8:	00f477b3          	and	a5,s0,a5
    2dbc:	cd1ff06f          	j	2a8c <__subsf3+0x14c>
    2dc0:	00050793          	mv	a5,a0
    2dc4:	df5ff06f          	j	2bb8 <__subsf3+0x278>
    2dc8:	00050793          	mv	a5,a0
    2dcc:	cc1ff06f          	j	2a8c <__subsf3+0x14c>
    2dd0:	0037d413          	srli	s0,a5,0x3
    2dd4:	0ff00793          	li	a5,255
    2dd8:	c0f91ae3          	bne	s2,a5,29ec <__subsf3+0xac>
    2ddc:	c00408e3          	beqz	s0,29ec <__subsf3+0xac>
    2de0:	00400437          	lui	s0,0x400
    2de4:	f45ff06f          	j	2d28 <__subsf3+0x3e8>
    2de8:	0ff00913          	li	s2,255
    2dec:	00000413          	li	s0,0
    2df0:	bfdff06f          	j	29ec <__subsf3+0xac>
    2df4:	00000413          	li	s0,0
    2df8:	f31ff06f          	j	2d28 <__subsf3+0x3e8>

00002dfc <__fixsfsi>:
    2dfc:	00800637          	lui	a2,0x800
    2e00:	01755713          	srli	a4,a0,0x17
    2e04:	fff60793          	addi	a5,a2,-1 # 7fffff <__RODATA_END__+0x7fcbb3>
    2e08:	0ff77713          	zext.b	a4,a4
    2e0c:	07e00593          	li	a1,126
    2e10:	00a7f7b3          	and	a5,a5,a0
    2e14:	01f55693          	srli	a3,a0,0x1f
    2e18:	04e5d663          	bge	a1,a4,2e64 <__fixsfsi+0x68>
    2e1c:	09d00593          	li	a1,157
    2e20:	00e5da63          	bge	a1,a4,2e34 <__fixsfsi+0x38>
    2e24:	80000537          	lui	a0,0x80000
    2e28:	fff54513          	not	a0,a0
    2e2c:	00a68533          	add	a0,a3,a0
    2e30:	00008067          	ret
    2e34:	00c7e533          	or	a0,a5,a2
    2e38:	09500793          	li	a5,149
    2e3c:	00e7dc63          	bge	a5,a4,2e54 <__fixsfsi+0x58>
    2e40:	f6a70713          	addi	a4,a4,-150 # 3ffff6a <__RODATA_END__+0x3ffcb1e>
    2e44:	00e51533          	sll	a0,a0,a4
    2e48:	02068063          	beqz	a3,2e68 <__fixsfsi+0x6c>
    2e4c:	40a00533          	neg	a0,a0
    2e50:	00008067          	ret
    2e54:	09600793          	li	a5,150
    2e58:	40e787b3          	sub	a5,a5,a4
    2e5c:	00f55533          	srl	a0,a0,a5
    2e60:	fe9ff06f          	j	2e48 <__fixsfsi+0x4c>
    2e64:	00000513          	li	a0,0
    2e68:	00008067          	ret

00002e6c <__floatsisf>:
    2e6c:	ff010113          	addi	sp,sp,-16
    2e70:	00112623          	sw	ra,12(sp)
    2e74:	00812423          	sw	s0,8(sp)
    2e78:	00912223          	sw	s1,4(sp)
    2e7c:	00050793          	mv	a5,a0
    2e80:	0e050663          	beqz	a0,2f6c <__floatsisf+0x100>
    2e84:	41f55713          	srai	a4,a0,0x1f
    2e88:	00a74433          	xor	s0,a4,a0
    2e8c:	40e40433          	sub	s0,s0,a4
    2e90:	01f55493          	srli	s1,a0,0x1f
    2e94:	00040513          	mv	a0,s0
    2e98:	42c000ef          	jal	ra,32c4 <__clzsi2>
    2e9c:	09e00793          	li	a5,158
    2ea0:	40a787b3          	sub	a5,a5,a0
    2ea4:	09600713          	li	a4,150
    2ea8:	04f74063          	blt	a4,a5,2ee8 <__floatsisf+0x7c>
    2eac:	00800713          	li	a4,8
    2eb0:	0ce50463          	beq	a0,a4,2f78 <__floatsisf+0x10c>
    2eb4:	ff850513          	addi	a0,a0,-8 # 7ffffff8 <__crt0_stack_end+0xffffdff9>
    2eb8:	00a41433          	sll	s0,s0,a0
    2ebc:	00941413          	slli	s0,s0,0x9
    2ec0:	00945413          	srli	s0,s0,0x9
    2ec4:	01779793          	slli	a5,a5,0x17
    2ec8:	00c12083          	lw	ra,12(sp)
    2ecc:	0087e7b3          	or	a5,a5,s0
    2ed0:	00812403          	lw	s0,8(sp)
    2ed4:	01f49513          	slli	a0,s1,0x1f
    2ed8:	00a7e533          	or	a0,a5,a0
    2edc:	00412483          	lw	s1,4(sp)
    2ee0:	01010113          	addi	sp,sp,16
    2ee4:	00008067          	ret
    2ee8:	09900713          	li	a4,153
    2eec:	06f75663          	bge	a4,a5,2f58 <__floatsisf+0xec>
    2ef0:	00500713          	li	a4,5
    2ef4:	40a70733          	sub	a4,a4,a0
    2ef8:	01b50693          	addi	a3,a0,27
    2efc:	00e45733          	srl	a4,s0,a4
    2f00:	00d41433          	sll	s0,s0,a3
    2f04:	00803433          	snez	s0,s0
    2f08:	00876433          	or	s0,a4,s0
    2f0c:	fc000737          	lui	a4,0xfc000
    2f10:	fff70713          	addi	a4,a4,-1 # fbffffff <__crt0_stack_end+0x7bffe000>
    2f14:	00747693          	andi	a3,s0,7
    2f18:	00e47733          	and	a4,s0,a4
    2f1c:	00068a63          	beqz	a3,2f30 <__floatsisf+0xc4>
    2f20:	00f47413          	andi	s0,s0,15
    2f24:	00400693          	li	a3,4
    2f28:	00d40463          	beq	s0,a3,2f30 <__floatsisf+0xc4>
    2f2c:	00470713          	addi	a4,a4,4
    2f30:	040006b7          	lui	a3,0x4000
    2f34:	00d776b3          	and	a3,a4,a3
    2f38:	00068c63          	beqz	a3,2f50 <__floatsisf+0xe4>
    2f3c:	fc0007b7          	lui	a5,0xfc000
    2f40:	fff78793          	addi	a5,a5,-1 # fbffffff <__crt0_stack_end+0x7bffe000>
    2f44:	00f77733          	and	a4,a4,a5
    2f48:	09f00793          	li	a5,159
    2f4c:	40a787b3          	sub	a5,a5,a0
    2f50:	00375413          	srli	s0,a4,0x3
    2f54:	f69ff06f          	j	2ebc <__floatsisf+0x50>
    2f58:	00500693          	li	a3,5
    2f5c:	ffb50713          	addi	a4,a0,-5
    2f60:	fad506e3          	beq	a0,a3,2f0c <__floatsisf+0xa0>
    2f64:	00e41433          	sll	s0,s0,a4
    2f68:	fa5ff06f          	j	2f0c <__floatsisf+0xa0>
    2f6c:	00000493          	li	s1,0
    2f70:	00000413          	li	s0,0
    2f74:	f49ff06f          	j	2ebc <__floatsisf+0x50>
    2f78:	09600793          	li	a5,150
    2f7c:	f41ff06f          	j	2ebc <__floatsisf+0x50>

00002f80 <__extendsfdf2>:
    2f80:	01755713          	srli	a4,a0,0x17
    2f84:	0ff77713          	zext.b	a4,a4
    2f88:	ff010113          	addi	sp,sp,-16
    2f8c:	00170793          	addi	a5,a4,1
    2f90:	00812423          	sw	s0,8(sp)
    2f94:	00912223          	sw	s1,4(sp)
    2f98:	00951413          	slli	s0,a0,0x9
    2f9c:	00112623          	sw	ra,12(sp)
    2fa0:	0fe7f793          	andi	a5,a5,254
    2fa4:	00945413          	srli	s0,s0,0x9
    2fa8:	01f55493          	srli	s1,a0,0x1f
    2fac:	04078263          	beqz	a5,2ff0 <__extendsfdf2+0x70>
    2fb0:	00345793          	srli	a5,s0,0x3
    2fb4:	38070713          	addi	a4,a4,896
    2fb8:	01d41413          	slli	s0,s0,0x1d
    2fbc:	00c79793          	slli	a5,a5,0xc
    2fc0:	00c7d793          	srli	a5,a5,0xc
    2fc4:	01471713          	slli	a4,a4,0x14
    2fc8:	01f49513          	slli	a0,s1,0x1f
    2fcc:	00f76733          	or	a4,a4,a5
    2fd0:	00c12083          	lw	ra,12(sp)
    2fd4:	00a767b3          	or	a5,a4,a0
    2fd8:	00040513          	mv	a0,s0
    2fdc:	00812403          	lw	s0,8(sp)
    2fe0:	00412483          	lw	s1,4(sp)
    2fe4:	00078593          	mv	a1,a5
    2fe8:	01010113          	addi	sp,sp,16
    2fec:	00008067          	ret
    2ff0:	04071663          	bnez	a4,303c <__extendsfdf2+0xbc>
    2ff4:	00000793          	li	a5,0
    2ff8:	fc0402e3          	beqz	s0,2fbc <__extendsfdf2+0x3c>
    2ffc:	00040513          	mv	a0,s0
    3000:	2c4000ef          	jal	ra,32c4 <__clzsi2>
    3004:	00a00793          	li	a5,10
    3008:	02a7c263          	blt	a5,a0,302c <__extendsfdf2+0xac>
    300c:	00b00793          	li	a5,11
    3010:	40a787b3          	sub	a5,a5,a0
    3014:	01550713          	addi	a4,a0,21
    3018:	00f457b3          	srl	a5,s0,a5
    301c:	00e41433          	sll	s0,s0,a4
    3020:	38900713          	li	a4,905
    3024:	40a70733          	sub	a4,a4,a0
    3028:	f95ff06f          	j	2fbc <__extendsfdf2+0x3c>
    302c:	ff550793          	addi	a5,a0,-11
    3030:	00f417b3          	sll	a5,s0,a5
    3034:	00000413          	li	s0,0
    3038:	fe9ff06f          	j	3020 <__extendsfdf2+0xa0>
    303c:	00000793          	li	a5,0
    3040:	00040a63          	beqz	s0,3054 <__extendsfdf2+0xd4>
    3044:	00345793          	srli	a5,s0,0x3
    3048:	00080737          	lui	a4,0x80
    304c:	01d41413          	slli	s0,s0,0x1d
    3050:	00e7e7b3          	or	a5,a5,a4
    3054:	7ff00713          	li	a4,2047
    3058:	f65ff06f          	j	2fbc <__extendsfdf2+0x3c>

0000305c <__truncdfsf2>:
    305c:	00c59713          	slli	a4,a1,0xc
    3060:	0145d813          	srli	a6,a1,0x14
    3064:	00975713          	srli	a4,a4,0x9
    3068:	7ff87813          	andi	a6,a6,2047
    306c:	01d55793          	srli	a5,a0,0x1d
    3070:	00e7e7b3          	or	a5,a5,a4
    3074:	00180713          	addi	a4,a6,1 # 800001 <__RODATA_END__+0x7fcbb5>
    3078:	7fe77713          	andi	a4,a4,2046
    307c:	01f5d593          	srli	a1,a1,0x1f
    3080:	00351613          	slli	a2,a0,0x3
    3084:	0e070063          	beqz	a4,3164 <__truncdfsf2+0x108>
    3088:	c8080693          	addi	a3,a6,-896
    308c:	0fe00713          	li	a4,254
    3090:	14d74663          	blt	a4,a3,31dc <__truncdfsf2+0x180>
    3094:	0ad04463          	bgtz	a3,313c <__truncdfsf2+0xe0>
    3098:	fe900713          	li	a4,-23
    309c:	14e6c463          	blt	a3,a4,31e4 <__truncdfsf2+0x188>
    30a0:	00800537          	lui	a0,0x800
    30a4:	01e00713          	li	a4,30
    30a8:	00a7e533          	or	a0,a5,a0
    30ac:	40d70733          	sub	a4,a4,a3
    30b0:	01f00793          	li	a5,31
    30b4:	04e7c663          	blt	a5,a4,3100 <__truncdfsf2+0xa4>
    30b8:	c8280813          	addi	a6,a6,-894
    30bc:	00e65733          	srl	a4,a2,a4
    30c0:	01061633          	sll	a2,a2,a6
    30c4:	00c03633          	snez	a2,a2
    30c8:	01051533          	sll	a0,a0,a6
    30cc:	00a66633          	or	a2,a2,a0
    30d0:	00c76733          	or	a4,a4,a2
    30d4:	00777793          	andi	a5,a4,7
    30d8:	0a079663          	bnez	a5,3184 <__truncdfsf2+0x128>
    30dc:	00375793          	srli	a5,a4,0x3
    30e0:	00000693          	li	a3,0
    30e4:	00979793          	slli	a5,a5,0x9
    30e8:	0097d793          	srli	a5,a5,0x9
    30ec:	01769693          	slli	a3,a3,0x17
    30f0:	00f6e6b3          	or	a3,a3,a5
    30f4:	01f59513          	slli	a0,a1,0x1f
    30f8:	00a6e533          	or	a0,a3,a0
    30fc:	00008067          	ret
    3100:	ffe00793          	li	a5,-2
    3104:	40d787b3          	sub	a5,a5,a3
    3108:	02000893          	li	a7,32
    310c:	00f557b3          	srl	a5,a0,a5
    3110:	00000693          	li	a3,0
    3114:	01170663          	beq	a4,a7,3120 <__truncdfsf2+0xc4>
    3118:	ca280813          	addi	a6,a6,-862
    311c:	010516b3          	sll	a3,a0,a6
    3120:	00c6e6b3          	or	a3,a3,a2
    3124:	00d036b3          	snez	a3,a3
    3128:	00d7e7b3          	or	a5,a5,a3
    312c:	0077f713          	andi	a4,a5,7
    3130:	06071463          	bnez	a4,3198 <__truncdfsf2+0x13c>
    3134:	0037d793          	srli	a5,a5,0x3
    3138:	fa9ff06f          	j	30e0 <__truncdfsf2+0x84>
    313c:	00651713          	slli	a4,a0,0x6
    3140:	00379793          	slli	a5,a5,0x3
    3144:	00e03733          	snez	a4,a4
    3148:	00f76733          	or	a4,a4,a5
    314c:	01d65613          	srli	a2,a2,0x1d
    3150:	00c76733          	or	a4,a4,a2
    3154:	00777793          	andi	a5,a4,7
    3158:	04079a63          	bnez	a5,31ac <__truncdfsf2+0x150>
    315c:	00375793          	srli	a5,a4,0x3
    3160:	f85ff06f          	j	30e4 <__truncdfsf2+0x88>
    3164:	08080063          	beqz	a6,31e4 <__truncdfsf2+0x188>
    3168:	00c7e7b3          	or	a5,a5,a2
    316c:	0ff00693          	li	a3,255
    3170:	f6078ae3          	beqz	a5,30e4 <__truncdfsf2+0x88>
    3174:	00000593          	li	a1,0
    3178:	0ff00693          	li	a3,255
    317c:	004007b7          	lui	a5,0x400
    3180:	f65ff06f          	j	30e4 <__truncdfsf2+0x88>
    3184:	00f77793          	andi	a5,a4,15
    3188:	00400693          	li	a3,4
    318c:	f4d788e3          	beq	a5,a3,30dc <__truncdfsf2+0x80>
    3190:	00000693          	li	a3,0
    3194:	0280006f          	j	31bc <__truncdfsf2+0x160>
    3198:	00f7f713          	andi	a4,a5,15
    319c:	00400693          	li	a3,4
    31a0:	f8d70ae3          	beq	a4,a3,3134 <__truncdfsf2+0xd8>
    31a4:	00478793          	addi	a5,a5,4 # 400004 <__RODATA_END__+0x3fcbb8>
    31a8:	f8dff06f          	j	3134 <__truncdfsf2+0xd8>
    31ac:	00f77613          	andi	a2,a4,15
    31b0:	00400513          	li	a0,4
    31b4:	00375793          	srli	a5,a4,0x3
    31b8:	f2a606e3          	beq	a2,a0,30e4 <__truncdfsf2+0x88>
    31bc:	00470713          	addi	a4,a4,4 # 80004 <__RODATA_END__+0x7cbb8>
    31c0:	04000637          	lui	a2,0x4000
    31c4:	00c77633          	and	a2,a4,a2
    31c8:	00375793          	srli	a5,a4,0x3
    31cc:	f0060ce3          	beqz	a2,30e4 <__truncdfsf2+0x88>
    31d0:	00168693          	addi	a3,a3,1 # 4000001 <__RODATA_END__+0x3ffcbb5>
    31d4:	00000793          	li	a5,0
    31d8:	f0dff06f          	j	30e4 <__truncdfsf2+0x88>
    31dc:	0ff00693          	li	a3,255
    31e0:	ff5ff06f          	j	31d4 <__truncdfsf2+0x178>
    31e4:	00000693          	li	a3,0
    31e8:	fedff06f          	j	31d4 <__truncdfsf2+0x178>

000031ec <__mulsi3>:
    31ec:	00050613          	mv	a2,a0
    31f0:	00000513          	li	a0,0
    31f4:	0015f693          	andi	a3,a1,1
    31f8:	00068463          	beqz	a3,3200 <__mulsi3+0x14>
    31fc:	00c50533          	add	a0,a0,a2
    3200:	0015d593          	srli	a1,a1,0x1
    3204:	00161613          	slli	a2,a2,0x1
    3208:	fe0596e3          	bnez	a1,31f4 <__mulsi3+0x8>
    320c:	00008067          	ret

00003210 <__divsi3>:
    3210:	06054063          	bltz	a0,3270 <__umodsi3+0x10>
    3214:	0605c663          	bltz	a1,3280 <__umodsi3+0x20>

00003218 <__hidden___udivsi3>:
    3218:	00058613          	mv	a2,a1
    321c:	00050593          	mv	a1,a0
    3220:	fff00513          	li	a0,-1
    3224:	02060c63          	beqz	a2,325c <__hidden___udivsi3+0x44>
    3228:	00100693          	li	a3,1
    322c:	00b67a63          	bgeu	a2,a1,3240 <__hidden___udivsi3+0x28>
    3230:	00c05863          	blez	a2,3240 <__hidden___udivsi3+0x28>
    3234:	00161613          	slli	a2,a2,0x1
    3238:	00169693          	slli	a3,a3,0x1
    323c:	feb66ae3          	bltu	a2,a1,3230 <__hidden___udivsi3+0x18>
    3240:	00000513          	li	a0,0
    3244:	00c5e663          	bltu	a1,a2,3250 <__hidden___udivsi3+0x38>
    3248:	40c585b3          	sub	a1,a1,a2
    324c:	00d56533          	or	a0,a0,a3
    3250:	0016d693          	srli	a3,a3,0x1
    3254:	00165613          	srli	a2,a2,0x1
    3258:	fe0696e3          	bnez	a3,3244 <__hidden___udivsi3+0x2c>
    325c:	00008067          	ret

00003260 <__umodsi3>:
    3260:	00008293          	mv	t0,ra
    3264:	fb5ff0ef          	jal	ra,3218 <__hidden___udivsi3>
    3268:	00058513          	mv	a0,a1
    326c:	00028067          	jr	t0
    3270:	40a00533          	neg	a0,a0
    3274:	00b04863          	bgtz	a1,3284 <__umodsi3+0x24>
    3278:	40b005b3          	neg	a1,a1
    327c:	f9dff06f          	j	3218 <__hidden___udivsi3>
    3280:	40b005b3          	neg	a1,a1
    3284:	00008293          	mv	t0,ra
    3288:	f91ff0ef          	jal	ra,3218 <__hidden___udivsi3>
    328c:	40a00533          	neg	a0,a0
    3290:	00028067          	jr	t0

00003294 <__modsi3>:
    3294:	00008293          	mv	t0,ra
    3298:	0005ca63          	bltz	a1,32ac <__modsi3+0x18>
    329c:	00054c63          	bltz	a0,32b4 <__modsi3+0x20>
    32a0:	f79ff0ef          	jal	ra,3218 <__hidden___udivsi3>
    32a4:	00058513          	mv	a0,a1
    32a8:	00028067          	jr	t0
    32ac:	40b005b3          	neg	a1,a1
    32b0:	fe0558e3          	bgez	a0,32a0 <__modsi3+0xc>
    32b4:	40a00533          	neg	a0,a0
    32b8:	f61ff0ef          	jal	ra,3218 <__hidden___udivsi3>
    32bc:	40b00533          	neg	a0,a1
    32c0:	00028067          	jr	t0

000032c4 <__clzsi2>:
    32c4:	000107b7          	lui	a5,0x10
    32c8:	02f57a63          	bgeu	a0,a5,32fc <__clzsi2+0x38>
    32cc:	10053793          	sltiu	a5,a0,256
    32d0:	0017c793          	xori	a5,a5,1
    32d4:	00379793          	slli	a5,a5,0x3
    32d8:	00003737          	lui	a4,0x3
    32dc:	02000693          	li	a3,32
    32e0:	40f686b3          	sub	a3,a3,a5
    32e4:	00f55533          	srl	a0,a0,a5
    32e8:	34c70793          	addi	a5,a4,844 # 334c <__clz_tab>
    32ec:	00a787b3          	add	a5,a5,a0
    32f0:	0007c503          	lbu	a0,0(a5) # 10000 <__RODATA_END__+0xcbb4>
    32f4:	40a68533          	sub	a0,a3,a0
    32f8:	00008067          	ret
    32fc:	01000737          	lui	a4,0x1000
    3300:	01000793          	li	a5,16
    3304:	fce56ae3          	bltu	a0,a4,32d8 <__clzsi2+0x14>
    3308:	01800793          	li	a5,24
    330c:	fcdff06f          	j	32d8 <__clzsi2+0x14>
