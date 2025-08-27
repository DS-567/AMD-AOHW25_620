
// neorv32 library
#include <neorv32.h>

// Constants

// setpoint encoder channel A XIRQ on neorv32
# define NEORV32_PCB_SETPOINT_ENCODER_CHA_RISING_XIRQ 0

// position in upper 32-bit GPIO inputs on neorv32 (GPIO inputs are 64-bits wide)
#define NEORV32_PCB_MOTOR_STOP_BUTTON_GPIO_INPUT 0
#define NEORV32_PCB_MOTOR_START_BUTTON_GPIO_INPUT 1
#define NEORV32_PCB_MOTOR_DIRECTION_BUTTON_GPIO_INPUT 2
#define NEORV32_PCB_SETPOINT_ENCODER_CH_B_GPIO_INPUT 3
#define NEORV32_PYTHON_MOTOR_STOP_BUTTON_GPIO_INPUT 4
#define NEORV32_PYTHON_MOTOR_START_BUTTON_GPIO_INPUT 5
#define NEORV32_PYTHON_MOTOR_DIRECTION_BUTTON_GPIO_INPUT 6
#define NEORV32_PYTHON_MOTOR_INCREASE_SPEED_GPIO_INPUT 7
#define NEORV32_PYTHON_MOTOR_DECREASE_SPEED_GPIO_INPUT 8
#define NEORV32_PYTHON_CONFIRM_SPEED_SETPOINT_GPIO_INPUT 9

// position in lower 32-bit GPIO outputs on neorv32 
#define NEORV32_MOTOR_DIRECTION_GPIO_OUTPUT 0
#define NEORV32_MOTOR_RUNNING_LED_GPIO_OUTPUT 1
#define NEORV32_MOTOR_FORWARD_LED_GPIO_OUTPUT 2
#define NEORV32_MOTOR_REVERSE_LED_GPIO_OUTPUT 3

// position in upper 32-bit GPIO outputs on neorv32 
#define NEORV32_SETPOINT_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT 32
#define NEORV32_MOTOR_CONTROL_REG_WRITE_GPIO_OUTPUT 33
#define NEORV32_ACTUAL_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT 34

// motor actual speed encoder pulses per revolution (all edges counted: 1000ppr encoder x 4 = 4000ppr)
#define ENCODER_PPR 4000   

// PI control update rate (in milliseconds)
#define PI_UPDATE_PERIOD_MS 1

// PI control co-efficients (proportional and integral)
#define Kp 35.0                   
#define Ki 40.0

// PWM min and max duty cycle (neorv32 has an 8-bit PWM output)
#define PWM_MIN_DUTY_CYCLE 0
#define PWM_MAX_DUTY_CYCLE 255

// safe range of motor actual speed errors that may be calculated
#define MIN_RPM_ERROR -4000
#define MAX_RPM_ERROR 4000

// capping the max and min integral that can wind up
#define MIN_INTEGRAL -50000
#define MAX_INTEGRAL 50000

// filter time to average actual motor speed for steady displaying (in milliseconds)
#define MOTOR_ACTUAL_SPEED_FILTER_MS 333   

// operating speed range of motor (rpm)
#define MOTOR_SETPOINT_MIN 2000
#define MOTOR_SETPOINT_MAX 4000

// Function Prototypes

uint8_t get_input_bit(uint32_t input_data, uint8_t bit_num);
void decimal_to_bcd(int decimal_input, int*thousands, int*hundreds, int*tens, int*ones);
void global_trap_handler(void);
void motor_control_pi(int setpoint, int current_speed);
void set_pwm_duty_cycle(int duty_cycle);

// Global Variables

// store return value from XIRQ setup and install function calls for checking
int err_cnt = 0;

// stores each computed bcd value for each of the 4 digits
int bcd_thousands = 0;
int bcd_hundreds = 0;
int bcd_tens = 0;
int bcd_ones = 0;

// stores the complete 64-bit GPIO input port
volatile uint64_t gpio_inputs = 0;

// stores the motor actual speed encoder pulse counter from hardware (lower 32-bits of 64-bit input port)
uint32_t motor_encoder_counter_gpio_lower = 0;

// stores new and last encoder pulse counter
uint32_t new_encoder_pulses_count = 0;
uint32_t last_encoder_pulses_count = 0;

// stores the control buttons and setpoint speed parameters (upper 32-bits of 64-bit input port)
uint32_t control_inputs_gpio_upper = 0;

// stores the value to write to GPIO outputs
uint32_t gpio_outputs = 0;

// motor stop and start buttons on PCB
uint8_t pcb_motor_stop_button = 0;
uint8_t pcb_motor_start_button = 0;

// motor direction button on PCB (and last)
uint8_t pcb_motor_direction_button = 0;
uint8_t pcb_motor_direction_button_last = 0;

// motor stop and start buttons on Python GUI
uint8_t python_motor_stop_button = 0;
uint8_t python_motor_start_button = 0;

// motor direction button on Python GUI (and last)
uint8_t python_motor_direction_button = 0;
uint8_t python_motor_direction_button_last = 0;

// motor increase speed button on Python GUI (and last)
uint8_t python_motor_increase_speed_button = 0;
uint8_t python_motor_increase_speed_button_last = 0;

// motor decrease speed button on Python GUI (and last)
uint8_t python_motor_decrease_speed_button = 0;
uint8_t python_motor_decrease_speed_button_last = 0;

// motor confrm speed setpoint (ENTER) button on Python GUI (and last)
uint8_t python_confirm_setpoint_speed_button = 0;
uint8_t python_confirm_setpoint_speed_button_last = 0;

// motor setpoint rpm (and temp)
uint32_t motor_setpoint_rpm = 2000;
uint32_t motor_setpoint_rpm_temp = 0;

// motor actual rpm
uint32_t motor_actual_rpm = 0;

// enable / disable PI speed control computation (disabled when motor is stopped)
uint8_t motor_speed_control_enable = 0;

// motor direction selected (1 = forwards / 0 = reverse)
uint8_t direction = 1;

// change direction request from PCB or on Python GUI (1 = change direction required / 0 = ignore)
uint8_t change_dir = 0;

// stores the PI integral
float pi_integral = 0.0;

// stores the timer interrupt tick from trap handler (used in main function)
uint8_t timer_interrupt_tick = 0;

// timer interrupt tick counter (determines when to compute average motor actual speed and refresh 7-segment display)
uint16_t tick_counter = 0;

// running motor actual rpm sum (summed every millisceond)
uint32_t motor_actual_rpm_sum = 0;

// main function call
int main() {

  // setup global trap handler (FOR ALL TRAPS!)
  neorv32_cpu_csr_write(CSR_MTVEC, (uint32_t)&global_trap_handler);

  // check if GPTMR unit is implemented
  if (neorv32_gptmr_available() == 0) {
    return 1;
  }
  
  // check if PWM unit is implemented
  if (neorv32_pwm_available() == 0) {
    return 1;
  }

  // check if GPIO unit is implemented
  if (neorv32_gpio_available() == 0) {
    return 1;
  }

  // clear GPIO output port
  neorv32_gpio_port_set(0);

  // configure timer for 1kHz continuous ticks 
  neorv32_gptmr_setup(CLK_PRSC_8, NEORV32_SYSINFO->CLK / 8000, 1); 

  // enable timer interrupt
  neorv32_cpu_csr_set(CSR_MIE, 1 << GPTMR_FIRQ_ENABLE);   // enable GPTMR FIRQ channel
  neorv32_cpu_csr_set(CSR_MSTATUS, 1 << CSR_MSTATUS_MIE); // enable machine-mode interrupts

  // setup the XIRQ 
  err_cnt = neorv32_xirq_setup();
  if (err_cnt) {
      return 1;
  }

  // install the XIRQ 
  err_cnt = neorv32_xirq_install(0, global_trap_handler);
  if (err_cnt) {
    return 1;
  }

  // Enable interrupts
  neorv32_cpu_csr_set(CSR_MIE, 1 << CSR_MIE_MEIE);
  neorv32_xirq_channel_enable(0);
  neorv32_xirq_global_enable();

  // configure and enable PWM
  neorv32_pwm_setup(2.6);

  // motor control states 
	enum state_machine {MOTOR_IDLE, MOTOR_FORWARD, MOTOR_REVERSE, MOTOR_STOP};

	// motor control state and initialise to idle state
	enum state_machine motor_ctrl_state = MOTOR_IDLE;

  while(1) {
    
    // process every 1ms
    if (timer_interrupt_tick == 1){
      
      // incrememt tick counter
      tick_counter += 1;

      // get all control inputs (0 = not pressed or active / 1 = pressed or active)
      pcb_motor_stop_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PCB_MOTOR_STOP_BUTTON_GPIO_INPUT);
      pcb_motor_start_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PCB_MOTOR_START_BUTTON_GPIO_INPUT);
      pcb_motor_direction_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PCB_MOTOR_DIRECTION_BUTTON_GPIO_INPUT);

      python_motor_stop_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_STOP_BUTTON_GPIO_INPUT);
      python_motor_start_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_START_BUTTON_GPIO_INPUT);
      python_motor_direction_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_DIRECTION_BUTTON_GPIO_INPUT);

      python_motor_increase_speed_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_INCREASE_SPEED_GPIO_INPUT);
      python_motor_decrease_speed_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_MOTOR_DECREASE_SPEED_GPIO_INPUT);
      python_confirm_setpoint_speed_button = get_input_bit(control_inputs_gpio_upper, NEORV32_PYTHON_CONFIRM_SPEED_SETPOINT_GPIO_INPUT);

      // check for motor direction buttons press (rising edge)
      if ( ((pcb_motor_direction_button == 1) && (pcb_motor_direction_button_last != 1)) || 
              ((python_motor_direction_button == 1) && (python_motor_direction_button_last != 1)) ){
          // toggle bit 0 only
          direction = (direction ^ 0x01) & 0x01;
      }

      // store last input read
      pcb_motor_direction_button_last = pcb_motor_direction_button;
      python_motor_direction_button_last = python_motor_direction_button;

      // check for motor speed increase buttons press (rising edge)
      if ( (python_motor_increase_speed_button == 1) && (python_motor_increase_speed_button_last != 1) ){
        
        // only increase speed if within acceptable range
        if ( (motor_setpoint_rpm + 50) <= MOTOR_SETPOINT_MAX){
          motor_setpoint_rpm += 50;
        }
      }

      // store last input read
      python_motor_increase_speed_button_last = python_motor_increase_speed_button;

      // check for motor speed decrease buttons press (rising edge)
      if ( (python_motor_decrease_speed_button == 1) && (python_motor_decrease_speed_button_last != 1) ){
        
        // only decrease speed if within acceptable range
        if ( (motor_setpoint_rpm - 50) >= MOTOR_SETPOINT_MIN){
          motor_setpoint_rpm -= 50;
        }
      }

      // store last input read
      python_motor_decrease_speed_button_last = python_motor_decrease_speed_button;

      // check for motor confirm setpoint speed button press (rising edge)
      if ( (python_confirm_setpoint_speed_button == 1) && (python_confirm_setpoint_speed_button_last != 1) ){
        motor_setpoint_rpm_temp = (control_inputs_gpio_upper >> 10) & 0xFFFF;

        // only confirm new speed setpoint if within acceptable range
        if (motor_setpoint_rpm_temp <= MOTOR_SETPOINT_MAX){
          motor_setpoint_rpm = motor_setpoint_rpm_temp;
        }

        // only confirm new speed setpoint if within acceptable range
        if (motor_setpoint_rpm_temp >= MOTOR_SETPOINT_MIN){
          motor_setpoint_rpm = motor_setpoint_rpm_temp;
        }
      }

      // store last input read
      python_confirm_setpoint_speed_button_last = python_confirm_setpoint_speed_button;

      // compute motor setpoint speed BCD digit values
      // Lower 16-bits = decimal value for Python GUI
      // Upper 16-bits = BCD values for 7-segment display
      decimal_to_bcd(motor_setpoint_rpm, &bcd_thousands, &bcd_hundreds, &bcd_tens, &bcd_ones);
      gpio_outputs = 0;
      gpio_outputs |= bcd_ones << 16;
      gpio_outputs |= bcd_tens << 20;
      gpio_outputs |= bcd_hundreds << 24;
      gpio_outputs |= bcd_thousands << 28;
      gpio_outputs |= motor_setpoint_rpm & 0xFFFF;

      // set the 32-bit lower GPIO output port to computed speed values
      neorv32_gpio_port_set(gpio_outputs);

      // write to setpoint motor speed register in hardware (toggle register write enable signal)
      neorv32_gpio_pin_set(NEORV32_SETPOINT_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT);     
      neorv32_gpio_pin_clr(NEORV32_SETPOINT_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT);     
      
      // keep sum of the motor actual speed every millisecond
      motor_actual_rpm_sum += motor_actual_rpm;

      // if motor actual speed filter time has passed (333 milliseconds)
      if (tick_counter == MOTOR_ACTUAL_SPEED_FILTER_MS){

        // compute average motor actual RPM for displaying
        uint16_t motor_speed_avg = motor_actual_rpm_sum / MOTOR_ACTUAL_SPEED_FILTER_MS;

      // compute motor setpoint speed BCD digit values
      // Lower 16-bits = decimal value for Python GUI
      // Upper 16-bits = BCD values for 7-segment display
        decimal_to_bcd(motor_speed_avg, &bcd_thousands, &bcd_hundreds, &bcd_tens, &bcd_ones);
        gpio_outputs = 0;
        gpio_outputs |= bcd_ones << 16;
        gpio_outputs |= bcd_tens << 20;
        gpio_outputs |= bcd_hundreds << 24;
        gpio_outputs |= bcd_thousands << 28;
        gpio_outputs |= motor_speed_avg & 0xFFFF;

        // set the 32-bit lower GPIO output port to computed speed values
        neorv32_gpio_port_set(gpio_outputs);

        // write to actual motor speed register in hardware (toggle register write enable signal)
        neorv32_gpio_pin_set(NEORV32_ACTUAL_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT);    
        neorv32_gpio_pin_clr(NEORV32_ACTUAL_RPM_SEVEN_SEG_REG_WRITE_GPIO_OUTPUT);    

        // clear tick counter
        tick_counter = 0;

        // clear the motor actual speed sum
        motor_actual_rpm_sum = 0;
      }

      // clear the timer interrupt tick
      timer_interrupt_tick = 0;
    }


    // motor control switch statement
    switch (motor_ctrl_state) {
      
      // motor idle state
			case MOTOR_IDLE: 

        // disable PI speed control algorithm in trap handler
        motor_speed_control_enable = 0;

        // disable PWM output
        neorv32_pwm_set(0, 0);			

        // clear the PI integral 
        pi_integral = 0.0;			
        
        // clear the motor running output (LED on PCB and Python GUI)
        neorv32_gpio_pin_clr(NEORV32_MOTOR_RUNNING_LED_GPIO_OUTPUT); 

        // ensure no stop buttons are pressed (on PCB and Python GUI)
        if ( (pcb_motor_stop_button == 0) && (python_motor_stop_button == 0) ){

          // check for either start buttons pressed (on PCB and Python GUI)
          if ( (pcb_motor_start_button == 1) || (python_motor_start_button == 1) ){

            // forward direction selected
            if (direction == 1){
              motor_ctrl_state = MOTOR_FORWARD;
            }  

            // reverse direction selected      
            else{
              motor_ctrl_state = MOTOR_REVERSE;
            }
          }
        }

        break;
      
      // motor run forwards state
      case MOTOR_FORWARD: 								

        // enable PI speed control algorithm in trap handler
        motor_speed_control_enable = 1;

        // set the motor direction output for H-bridge driver circuit (1 = forwards / 0 = reverse)
        neorv32_gpio_pin_set(NEORV32_MOTOR_DIRECTION_GPIO_OUTPUT); 

        // set the motor running output (LED on PCB and on Python GUI)
        neorv32_gpio_pin_set(NEORV32_MOTOR_RUNNING_LED_GPIO_OUTPUT); 

        // check for either stop buttons pressed (on PCB and Python GUI)
        if ( (pcb_motor_stop_button == 1) || (python_motor_stop_button == 1) ){
          motor_ctrl_state = MOTOR_STOP;
        }

        // direction selected has changed (either on PCB and Python GUI)
        if (direction == 0){
          motor_ctrl_state = MOTOR_STOP;

          // change direction request set
          change_dir = 1;
        } 

        break;
      
      // motor run reverse state
      case MOTOR_REVERSE: 

        // enable PI speed control algorithm in trap handler
        motor_speed_control_enable = 1;					

      // clear the motor direction output for H-bridge driver circuit (1 = forwards / 0 = reverse)
        neorv32_gpio_pin_clr(NEORV32_MOTOR_DIRECTION_GPIO_OUTPUT); 

        // set the motor running output (LED on PCB and on Python GUI)
        neorv32_gpio_pin_set(NEORV32_MOTOR_RUNNING_LED_GPIO_OUTPUT); 

        // check for either stop buttons pressed (on PCB and Python GUI)
        if ( (pcb_motor_stop_button == 1) || (python_motor_stop_button == 1) ){
          motor_ctrl_state = MOTOR_STOP;
        }

        // direction selected has changed (either on PCB and Python GUI)
        if (direction == 1){
          motor_ctrl_state = MOTOR_STOP;

          // change direction request set
          change_dir = 1;
        }

        break;

      // motor stop state
      case MOTOR_STOP: 				

        // disable PI speed control algorithm in trap handler
        motor_speed_control_enable = 0;

        // disable PWM output
        neorv32_pwm_set(0, 0);

        // change direction request requires processed
        if (change_dir == 1){

          // wait for motor to stop rotating
          if (motor_actual_rpm == 0){

            // motor was going in reverse, change to forward
            if (direction == 1){
              motor_ctrl_state = MOTOR_FORWARD;

              // change direction request clear
              change_dir = 0;
            }

            // motor was going in forward, change to reverse
            else{
              motor_ctrl_state = MOTOR_REVERSE;

              // change direction request clear
              change_dir = 0;
            }
          }  
        }
        
        // otherwise there is no direction change request
        else{

          // wait for motor to stop rotating
          if (motor_actual_rpm == 0){
            motor_ctrl_state = MOTOR_IDLE;
          }
        }
           
        break;
    }

    // update motor direction selected LEDs (on PCB and Python GUI)
    // forward selected
    if (direction == 1){

      // set the forward selected LED
      neorv32_gpio_pin_set(NEORV32_MOTOR_FORWARD_LED_GPIO_OUTPUT); 

      // clear the reverse selected LED
      neorv32_gpio_pin_clr(NEORV32_MOTOR_REVERSE_LED_GPIO_OUTPUT);
    }

    // reverse selected
    else{

      // set the reverse selected LED
      neorv32_gpio_pin_set(NEORV32_MOTOR_REVERSE_LED_GPIO_OUTPUT); 

      // clear the forward selected LED
      neorv32_gpio_pin_clr(NEORV32_MOTOR_FORWARD_LED_GPIO_OUTPUT);
    }

    // write to motor control register in hardware (toggle register write enable signal)
    neorv32_gpio_pin_set(NEORV32_MOTOR_CONTROL_REG_WRITE_GPIO_OUTPUT);  
    neorv32_gpio_pin_clr(NEORV32_MOTOR_CONTROL_REG_WRITE_GPIO_OUTPUT); 
  
  }

  return 0;
}


// Function Declarations

// Global trap handler (for ALL traps).
void __attribute__((interrupt)) global_trap_handler(void) {

  // read the mcause CSR register (find cause of trap)
  uint32_t mcause = neorv32_cpu_csr_read(CSR_MCAUSE);

  // read the pending interrupt CSR register
  uint32_t src = NEORV32_XIRQ->ESC;

  // check if GPTMR interrupt caused the trap
  if (mcause == GPTMR_TRAP_CODE) {
    
    // clear timer-match interrupt
    neorv32_gptmr_trigger_matched(); 

    // clear the timer interrupt tick
    timer_interrupt_tick = 1;
    
    // read the 64-bit GPIO input port
    gpio_inputs = neorv32_gpio_port_get();

    // get the encoder pulse counter (lower 32-bits)
    motor_encoder_counter_gpio_lower = gpio_inputs & 0xFFFFFFFF;
    
    // determine encoder pulses in the last millisecond
    // absolute as the hardware counter increments on each encoder edge. (direction is not required)
    new_encoder_pulses_count = abs(motor_encoder_counter_gpio_lower - last_encoder_pulses_count);                                                

    // calculate the actual motor RPM
    motor_actual_rpm = ( (new_encoder_pulses_count * 60000) / ENCODER_PPR);

    // store the last encoder pulse counter
    last_encoder_pulses_count = motor_encoder_counter_gpio_lower;

    // only process if PI speed control is enabled (i.e. motor is running)
    if (motor_speed_control_enable == 1){
      motor_control_pi(motor_setpoint_rpm, motor_actual_rpm);
    }

    // finally get the remaining GPIO upper 32-bit inputs (these are updated every millisecond)
    control_inputs_gpio_upper = (gpio_inputs >> 32) & 0xFFFFFFFF;
  }

   // check if an XIRQ trigger caused the trap
  else if (mcause == 0x80000018) { 
  
    // motor setpoint encoder CH A rising edge
    if (src == NEORV32_PCB_SETPOINT_ENCODER_CHA_RISING_XIRQ){  

      // if the motor setpoint encoder CH B is low, increment motor setpoint RPM by 50
      if (neorv32_gpio_pin_get(35) == 0){

        // only increase speed if within acceptable range
        if ( (motor_setpoint_rpm + 50) <= MOTOR_SETPOINT_MAX){
          motor_setpoint_rpm += 50;
        }
      }

      // otherwise, decrement motor setpoint RPM by 50
      else {

        // only decrease speed if within acceptable range
        if ( (motor_setpoint_rpm - 50) >= MOTOR_SETPOINT_MIN){
          motor_setpoint_rpm -= 50;
        }
      }
    }
  }
  
  // check if trap is caused by an exception
  else if (((mcause >> 31) == 0) && (mcause != TRAP_CODE_I_ACCESS)) {
    
    // read the mepc CSR register
    uint32_t rte_mepc = neorv32_cpu_csr_read(CSR_MEPC);

    // default: faulting instruction is uncompressed so increment PC by 4
    rte_mepc += 4; 

    // update return address from trap handler
    neorv32_cpu_csr_write(CSR_MEPC, rte_mepc);
  }

  // clear the currently pending XIRQ interrupt
  NEORV32_XIRQ->EIP = ~(1 << src);

  // acknowledge the current XIRQ interrupt
  NEORV32_XIRQ->ESC = 0;
}


// return either 0 or 1 depending on the input bit value
uint8_t get_input_bit(uint32_t input_data, uint8_t bit_num){
  uint8_t bit_val = (input_data >> bit_num) & 1;
  return bit_val;
}


// compute the BCD value of each 4-digits from a decimal speed input
void decimal_to_bcd(int decimal_input, int*thousands, int*hundreds, int*tens, int*ones){
  int sub_result = 0;
  int sub_result_carry_forward = 0;

  int thousands_temp = 0;
  int hundreds_temp = 0;
  int tens_temp = 0;
  int ones_temp = 0;
  
  //Compute thousands value
  if (decimal_input == 0){
    *thousands = thousands_temp; 
    *hundreds = hundreds_temp; 
    *tens = tens_temp; 
    *ones = ones_temp; 
  }

  else if(decimal_input < 1000){
    sub_result_carry_forward = decimal_input;
  }

  else{
    sub_result = decimal_input;

        while (sub_result >= 0){
          sub_result = sub_result - 1000;

            if (sub_result >= 0){
                sub_result_carry_forward = sub_result;
                thousands_temp += 1;
            }
        }
      } 
  
  //Compute hundreds value
  if (sub_result_carry_forward >= 100){
    sub_result = sub_result_carry_forward;

    while (sub_result >= 0){
            sub_result = sub_result - 100;

            if (sub_result >= 0){
                sub_result_carry_forward = sub_result;
                hundreds_temp += 1;
            }
    }
  }

  //Compute tens value
  if (sub_result_carry_forward >= 10){
    sub_result = sub_result_carry_forward;

    while (sub_result >= 0){
            sub_result = sub_result - 10;

            if (sub_result >= 0){
                sub_result_carry_forward = sub_result;
                tens_temp += 1;
            }
    }
  }

  //Compute ones value
  if (sub_result_carry_forward >= 1){
    sub_result = sub_result_carry_forward;

    while (sub_result >= 0){
            sub_result = sub_result - 1;

            if (sub_result >= 0){
              ones_temp += 1;
            }
    }
  }
  *thousands = thousands_temp; 
  *hundreds = hundreds_temp; 
  *tens = tens_temp; 
  *ones = ones_temp;
}


void motor_control_pi(int setpoint, int current_speed){

    // calcaulte motor actual speed error
    float error = (float)setpoint - (float)current_speed;

    // calculate integral
    pi_integral += error * (PI_UPDATE_PERIOD_MS / 1000.0);

    // check that the integral is within min and max ranges (to prevent wind up) 
    if (pi_integral < MIN_INTEGRAL) {
        pi_integral = MIN_INTEGRAL;
    }
    if (pi_integral > MAX_INTEGRAL) {
        pi_integral = MAX_INTEGRAL;
    }

    // calculate PI output
    float pi_output = (Kp * error) + (Ki * pi_integral);

    // and limit within min and max ranges
    if (pi_output < MIN_RPM_ERROR) {
        pi_output = MIN_RPM_ERROR;
    }
    if (pi_output > MAX_RPM_ERROR) {
        pi_output = MAX_RPM_ERROR;
    }

    // compute the PWM duty cycle to update the H-bridge motor driver control signal
    int pi_duty_cycle = ((pi_output - MIN_RPM_ERROR) * (PWM_MAX_DUTY_CYCLE - PWM_MIN_DUTY_CYCLE)) / (MAX_RPM_ERROR - MIN_RPM_ERROR) + PWM_MIN_DUTY_CYCLE;

    // call function to update PWM duty cycle
    set_pwm_duty_cycle(pi_duty_cycle);
}


// update the PWM signal with the computed duty cycle
void set_pwm_duty_cycle(int duty_cycle) {

    // limit duty cycle to within min and max ranges
    if (duty_cycle < PWM_MIN_DUTY_CYCLE) {
        duty_cycle = PWM_MIN_DUTY_CYCLE;
    }
    if (duty_cycle > PWM_MAX_DUTY_CYCLE) {
        duty_cycle = PWM_MAX_DUTY_CYCLE;
    }
    
    // set the PWM duty cycle output to within min and max ranges
    neorv32_pwm_set(0, duty_cycle);
}