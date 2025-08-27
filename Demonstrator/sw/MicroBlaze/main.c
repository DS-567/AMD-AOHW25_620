
#include "xparameters.h"
#include "xstatus.h"
#include "xuartlite_l.h"
#include "xil_printf.h"
#include "platform.h"
#include <string.h>
#include "sleep.h"
#include <stdbool.h>
#include <stdlib.h>

// UARTlite and 256-byte buffer
#define UARTLITE_BASEADDR XPAR_UARTLITE_0_BASEADDR
#define BUFFER_SIZE 256

// bit positions of Python GUI buttons
#define NEORV32_PYTHON_MOTOR_STOP_BUTTON 0
#define NEORV32_PYTHON_MOTOR_START_BUTTON 1
#define NEORV32_PYTHON_MOTOR_DIRECTION_BUTTON 2
#define NEORV32_PYTHON_MOTOR_INCREASE_SPEEED_BUTTON 3
#define NEORV32_PYTHON_MOTOR_DECREASE_SPEEED_BUTTON 4
#define NEORV32_PYTHON_MOTOR_CONFIRM_SPEED_SETPOINT_BUTTON 5

// bit positions of Python GUI PC bit fault type buttons
#define PC_BIT_1_FAULT_TYPE_BUTTON 0
#define PC_BIT_2_FAULT_TYPE_BUTTON 1
#define PC_BIT_3_FAULT_TYPE_BUTTON 2
#define PC_BIT_4_FAULT_TYPE_BUTTON 3
#define PC_BIT_5_FAULT_TYPE_BUTTON 4
#define PC_BIT_6_FAULT_TYPE_BUTTON 5
#define PC_BIT_7_FAULT_TYPE_BUTTON 6
#define PC_BIT_8_FAULT_TYPE_BUTTON 7
#define PC_BIT_9_FAULT_TYPE_BUTTON 8
#define PC_BIT_10_FAULT_TYPE_BUTTON 9

// bit positions of Python GUI fault command buttons
#define INJECT_FAULTS_BUTTON 10
#define CLEAR_FAULTS_BUTTON 11
#define CLEAR_ALL_FAULTS_BUTTON 12

// bit position of Python Neorv32 reset switch
#define NEORV32_RESET_BUTTON 13

// bit position of Neorv32 trap triggered
#define NEORV32_TRAP_TRIGGERED 14

// default value (4000)
#define DEFAULT_FIFO_WRITE_CYCLES 4000

// constant lookup table to decode Neorv32 execute FSM states
static const char *Execute_States_Decode_Strings[] = {"DISPATCH", "TRAP_ENTER", "TRAP_EXIT", "RESTART", "FENCE", "SLEEP", "EXECUTE",
													  "ALU_WAIT", "BRANCH", "BRANCHED", "SYSTEM", "MEM_REQ", "MEM_WAIT"};

// FUNCTION PROTOTYPES
int parse_motor_setpoint_speed(const char *message);

int Read_Neorv32_Buttons_AXI_Reg();
void Write_Neorv32_Buttons_AXI_Reg();
int Read_Python_GUI_Control_AXI_Reg();
void Write_Python_GUI_Control_AXI_Reg();
void Write_Motor_Speed_Setpoint_AXI_Reg(int data);

int Reg_Set_Bit(int reg_data, int bit);
int Reg_Clear_Bit(int reg_data, int bit);
int Reg_Get_Bit(int reg_data, int bit);

int Read_Motor_Speeds_AXI_Reg();
int Read_PC_Bit_Fault_Type_Counters_AXI_Reg();
int Read_Other_Data_AXI_Reg();
int Read_Watchdog_Signals_AXI_Reg();
void Write_Watchdog_Signals_AXI_Reg();

int Read_NEORV32_IR_Data_AXI_Reg();
int Read_NEORV32_PC_Data_AXI_Reg();
int Read_NEORV32_Execute_States_Data_AXI_Reg();
int Read_NEORV32_RS1_Reg_Data_AXI_Reg();
int Read_NEORV32_MTVEC_Data_AXI_Reg();
int Read_NEORV32_MEPC_Data_AXI_Reg();
int Read_Features_Data_AXI_Reg();
int Read_NEORV32_MCAUSE_Data_AXI_Reg();

void Write_FIFO_Write_Cycles_AXI_Reg(int data);
int Read_FIFO_Write_Cycles_AXI_Reg();
int Parse_FIFO_Write_Cycles(const char *message);

const char* DecodeExecuteStatestoString(int array_index);

int Read_SNN_Input_Neuron_2_to_0_Spikes_AXI_Reg();
int Read_SNN_Input_Neuron_5_to_3_Spikes_AXI_Reg();
int Read_SNN_Input_Neuron_8_to_6_Spikes_AXI_Reg();
int Read_SNN_Input_Neuron_11_to_9_Spikes_AXI_Reg();
int Read_SNN_Input_Neuron_14_to_12_Spikes_AXI_Reg();
int Read_SNN_Input_Neuron_15_Spikes_AXI_Reg();

int Read_SNN_Hidden_Neuron_2_to_0_Spikes_AXI_Reg();
int Read_SNN_Hidden_Neuron_5_to_3_Spikes_AXI_Reg();
int Read_SNN_Hidden_Neuron_8_to_6_Spikes_AXI_Reg();
int Read_SNN_Hidden_Neuron_11_to_9_Spikes_AXI_Reg();
int Read_SNN_Hidden_Neuron_14_to_12_Spikes_AXI_Reg();
int Read_SNN_Hidden_Neuron_17_to_15_Spikes_AXI_Reg();
int Read_SNN_Hidden_Neuron_19_to_18_Spikes_AXI_Reg();

int Read_SNN_Output_Neuron_1_to_0_Spikes_AXI_Reg();


// write from uB to the RTL IP hardware axi slave registers
int *AXI_REG_O;				// pointer to AXI slave reg 0, neorv32 buttons from Python GUI
int *AXI_REG_1;				// pointer to AXI slave reg 1, motor setpoint speed from Python GUI
int *AXI_REG_2;				// pointer to AXI slave reg 2, Python GUI fault command buttons from Python GUI

// read into uB from the RTL hardware axi slave registers
int *AXI_REG_3;				// pointer to AXI slave reg 3, motor setpoint and actual speeds to Python GUI
int *AXI_REG_4;				// pointer to AXI slave reg 4, PC bit fault type counters to Python GUI
int *AXI_REG_5;				// pointer to AXI slave reg 5, other data signals from Python GUI

// watchdog hardware axi slave registers
int *AXI_REG_6;				// pointer to AXI slave reg 6, handshake signals from uB to watchdog FSM
int *AXI_REG_7;				// pointer to AXI slave reg 7, watchdog signals to uB from watchdog FSM

// read into uB from the RTL hardware axi slave register
int *AXI_REG_8;				// pointer to AXI slave reg 8, Neorv32 IR
int *AXI_REG_9;				// pointer to AXI slave reg 9, Neorv32 PC
int *AXI_REG_10;			// pointer to AXI slave reg 10, Neorv32 Execute FSM states
int *AXI_REG_11;			// pointer to AXI slave reg 11, Neorv32 RS1
int *AXI_REG_12;			// pointer to AXI slave reg 12, Neorv32 MTVEC
int *AXI_REG_13;			// pointer to AXI slave reg 13, Neorv32 MEPC

// read into uB from the RTL hardware axi slave register
int *AXI_REG_14;			// pointer to AXI slave reg 14, watchdog extracted features to uB

// read into uB from the RTL hardware axi slave register
int *AXI_REG_15;			// pointer to AXI slave reg 15, Neorv32 MCAUSE

// fifo write cycles data axi slave register
int *AXI_REG_16;			// pointer to AXI slave reg 16, FIFO write cycles from Python GUI to RTL IP
int *AXI_REG_17;			// pointer to AXI slave reg 17, FIFO write cycles to Python GUI from RTL IP

// read snn spike shift registers axi slave registers
int *AXI_REG_18;			// pointer to AXI slave reg 18, input neurons 0 to 2
int *AXI_REG_19;			// pointer to AXI slave reg 19, input neurons 3 to 5
int *AXI_REG_20;			// pointer to AXI slave reg 20, input neurons 6 to 8
int *AXI_REG_21;			// pointer to AXI slave reg 21, input neurons 9 to 11
int *AXI_REG_22;			// pointer to AXI slave reg 22, input neurons 12 to 14
int *AXI_REG_23;			// pointer to AXI slave reg 23, input neuron 15
int *AXI_REG_24;			// pointer to AXI slave reg 24, hidden neurons 0 to 2
int *AXI_REG_25;			// pointer to AXI slave reg 25, hidden neurons 3 to 5
int *AXI_REG_26;			// pointer to AXI slave reg 26, hidden neurons 6 to 8
int *AXI_REG_27;			// pointer to AXI slave reg 27, hidden neurons 9 to 11
int *AXI_REG_28;			// pointer to AXI slave reg 28, hidden neurons 12 to 14
int *AXI_REG_29;			// pointer to AXI slave reg 29, hidden neurons 15 to 17
int *AXI_REG_30;			// pointer to AXI slave reg 30, hidden neurons 18 and 19
int *AXI_REG_31;			// pointer to AXI slave reg 31, output neurons 0 and 1

// data read from the RTL IP
int motor_speeds_to_uB;
int pc_bit_fault_type_counters_to_uB;
int other_data_to_uB;
int watchdog_signals_to_uB;

// RISC-V instruction data from Neorv32
int ir_data_to_uB;
int pc_data_to_uB;
int execute_states_data_to_uB;
int rs1_reg_data_to_uB;
int mtvec_data_to_uB;
int mepc_data_to_uB;
int mcause_data_to_uB;

// extracted features
int features_data_to_uB = 0;

// array of bytes to store the last 10 PC bit fault type counters
uint8_t pc_bit_fault_type_counters_last[10] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
uint8_t other_data_to_uB_last[10] = {2, 2, 2, 2, 2, 2, 2, 2, 2, 2};

// motor setpoint and actual speed
int motor_setpoint_speed_from_uB = 0;
int motor_setpoint_speed_last = 0;
int motor_actual_speed_last = 0;

// instruction info enabled
uint8_t instruction_info_enabled = 0;
uint8_t instruction_info_enabled_last = 0;

// instruction counters
uint16_t instructions_monitored = 0;
uint16_t instructions_no_faults_monitored = 0;
uint16_t instructions_faults_monitored = 0;

// FIFO write cycles
uint16_t fifo_write_cycles_from_uB = 0;
uint16_t fifo_write_cycles_from_uB_last = 0;

// spike plot enabled
uint8_t spike_plot_enabled = 0;
uint8_t spike_plot_enabled_last = 0;

int main(void) {

	//initialise platform resources
    init_platform();

    // AXI slave register addresses
	AXI_REG_O   = XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR;
	AXI_REG_1  	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 4;
	AXI_REG_2   = XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 8;
	AXI_REG_3  	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 12;
	AXI_REG_4	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 16;
	AXI_REG_5	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 20;
	AXI_REG_6	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 24;
	AXI_REG_7	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 28;
	AXI_REG_8	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 32;
	AXI_REG_9	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 36;
	AXI_REG_10	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 40;
	AXI_REG_11	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 44;
	AXI_REG_12	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 48;
	AXI_REG_13	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 52;
	AXI_REG_14	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 56;
	AXI_REG_15	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 60;
	AXI_REG_16	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 64;
	AXI_REG_17	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 68;
	AXI_REG_18	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 72;
	AXI_REG_19	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 76;
	AXI_REG_20	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 80;
	AXI_REG_21	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 84;
	AXI_REG_22	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 88;
	AXI_REG_23	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 92;
	AXI_REG_24	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 96;
	AXI_REG_25	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 100;
	AXI_REG_26	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 104;
	AXI_REG_27	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 108;
	AXI_REG_28	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 112;
	AXI_REG_29	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 116;
	AXI_REG_30	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 120;
	AXI_REG_31	= XPAR_ISCAS_DEMO_IP1_0_S00_AXI_BASEADDR + 124;

	// UART receive buffer
	char recieve_buffer[BUFFER_SIZE];
    int num_received_bytes = 0;
    u8 recieve_byte = 0;

    uint8_t pc_bit_fault_type_counter_temp;
    uint8_t shift_num;
    uint8_t other_data_temp;

    int read_data_temp = 0;
    int watchdog_ready = 0;
    int watchdog_done = 0;

    // initilise the FIFO write cycles register in RTL IP
    Write_FIFO_Write_Cycles_AXI_Reg(DEFAULT_FIFO_WRITE_CYCLES);

    while (1) {

    	// start of read UART data from Python GUI

    	// check for a byte received
        if (XUartLite_IsReceiveEmpty(UARTLITE_BASEADDR) == 0) {
        	recieve_byte = XUartLite_ReadReg(UARTLITE_BASEADDR, XUL_RX_FIFO_OFFSET);

        	// ensure the buffer is not full (256 bytes)
            if (num_received_bytes < BUFFER_SIZE) {
            	recieve_buffer[num_received_bytes++] = recieve_byte;
            }

            // check for end of a UART message to process
            if (recieve_byte == '\n' || num_received_bytes == BUFFER_SIZE) {
            	recieve_buffer[num_received_bytes] = '\0';

            	// uncomment for debugging
            	//xil_printf("uB receive buffer: %s\n\r", recieve_buffer);


            	// if-else decision tree to compare known commands (could do with more efficient approach)

            	// motor stop button pressed on GUI
            	if (strcmp(recieve_buffer, "motor_stop_p\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// set AXI bit
            		read_data_temp = Reg_Set_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_STOP_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor stop button released on GUI
            	else if (strcmp(recieve_buffer, "motor_stop_r\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// clear AXI bit
            		read_data_temp = Reg_Clear_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_STOP_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor start button pressed on GUI
            	else if (strcmp(recieve_buffer, "motor_start_p\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// set AXI bit
            		read_data_temp = Reg_Set_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_START_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor start button released on GUI
            	else if (strcmp(recieve_buffer, "motor_start_r\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// clear AXI bit
            		read_data_temp = Reg_Clear_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_START_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor change direction button pressed on GUI
            	else if (strcmp(recieve_buffer, "motor_dir_p\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// set AXI bit
            		read_data_temp = Reg_Set_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_DIRECTION_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor change direction button released on GUI
            	else if (strcmp(recieve_buffer, "motor_dir_r\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// clear AXI bit
            		read_data_temp = Reg_Clear_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_DIRECTION_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor increase setpoint speed button pressed on GUI
            	else if (strcmp(recieve_buffer, "motor_speed_inc_p\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// set AXI bit
            		read_data_temp = Reg_Set_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_INCREASE_SPEEED_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor increase setpoint speed button released on GUI
            	else if (strcmp(recieve_buffer, "motor_speed_inc_r\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// clear AXI bit
            		read_data_temp = Reg_Clear_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_INCREASE_SPEEED_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor decrease setpoint speed button pressed on GUI
            	else if (strcmp(recieve_buffer, "motor_speed_dec_p\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// set AXI bit
            		read_data_temp = Reg_Set_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_DECREASE_SPEEED_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor decrease setpoint speed button released on GUI
            	else if (strcmp(recieve_buffer, "motor_speed_dec_r\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// clear AXI bit
            		read_data_temp = Reg_Clear_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_DECREASE_SPEEED_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor enter setpoint speed button pressed on GUI (confirm)
            	else if (strcmp(recieve_buffer, "motor_setpoint_conf_p\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// set AXI bit
            		read_data_temp = Reg_Set_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_CONFIRM_SPEED_SETPOINT_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor enter setpoint speed button released on GUI (confirm)
            	else if (strcmp(recieve_buffer, "motor_setpoint_conf_r\n") == 0){
            		read_data_temp = Read_Neorv32_Buttons_AXI_Reg();
            		// clear AXI bit
            		read_data_temp = Reg_Clear_Bit(read_data_temp, NEORV32_PYTHON_MOTOR_CONFIRM_SPEED_SETPOINT_BUTTON);
            		Write_Neorv32_Buttons_AXI_Reg(read_data_temp);
            	}

            	// motor setpoint speed message from GUI
            	else if (strncmp(recieve_buffer, "motor_setpoint_", 15) == 0) {
            		// parse speed and write to AXI reg
            		Write_Motor_Speed_Setpoint_AXI_Reg(parse_motor_setpoint_speed(recieve_buffer));
            	}


            	// PC bit fault type buttons pressed and released on GUI (bits 1 to 10)
            	// set / clear AXI bits

            	else if (strcmp(recieve_buffer, "pc_bit_1_p\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_1_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_1_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_1_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_2_p\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_2_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_2_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_2_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_3_p\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
                	read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_3_FAULT_TYPE_BUTTON);
                	Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_3_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_3_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_4_p\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
                	read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_4_FAULT_TYPE_BUTTON);
                	Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_4_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_4_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_5_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
                    read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_5_FAULT_TYPE_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_5_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_5_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_6_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
                    read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_6_FAULT_TYPE_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_6_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_6_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_7_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
                    read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_7_FAULT_TYPE_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_7_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_7_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_8_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
                    read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_8_FAULT_TYPE_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_8_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_8_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_9_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
                    read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_9_FAULT_TYPE_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_9_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_9_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_10_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
                    read_data_temp = Reg_Set_Bit(read_data_temp, PC_BIT_10_FAULT_TYPE_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	else if (strcmp(recieve_buffer, "pc_bit_10_r\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		read_data_temp = Reg_Clear_Bit(read_data_temp, PC_BIT_10_FAULT_TYPE_BUTTON);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// inject faults button pressed on GUI
            	else if (strcmp(recieve_buffer, "flts_inj_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
               		// set AXI bit
                    read_data_temp = Reg_Set_Bit(read_data_temp, INJECT_FAULTS_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// inject faults button released on GUI
            	else if (strcmp(recieve_buffer, "flts_inj_r\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
               		// clear AXI bit
                    read_data_temp = Reg_Clear_Bit(read_data_temp, INJECT_FAULTS_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// clear faults button pressed on GUI
            	else if (strcmp(recieve_buffer, "flts_clr_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
               		// set AXI bit
                    read_data_temp = Reg_Set_Bit(read_data_temp, CLEAR_FAULTS_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// clear faults button released on GUI
            	else if (strcmp(recieve_buffer, "flts_clr_r\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
               		// clear AXI bit
                    read_data_temp = Reg_Clear_Bit(read_data_temp, CLEAR_FAULTS_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// clear all fault setups button pressed on GUI
            	else if (strcmp(recieve_buffer, "flts_clr_all_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
               		// set AXI bit
                    read_data_temp = Reg_Set_Bit(read_data_temp, CLEAR_ALL_FAULTS_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// clear all fault setups button released on GUI
            	else if (strcmp(recieve_buffer, "flts_clr_all_r\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
               		// clear AXI bit
                    read_data_temp = Reg_Clear_Bit(read_data_temp, CLEAR_ALL_FAULTS_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// Neor32 reset switch activated on GUI
            	else if (strcmp(recieve_buffer, "nv32_rst_p\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
               		// set AXI bit
                    read_data_temp = Reg_Set_Bit(read_data_temp, NEORV32_RESET_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// Neor32 reset switch de-activated on GUI
            	else if (strcmp(recieve_buffer, "nv32_rst_r\n") == 0){
               		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
               		// clear AXI bit
                    read_data_temp = Reg_Clear_Bit(read_data_temp, NEORV32_RESET_BUTTON);
                    Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// trap detected
            	else if (strcmp(recieve_buffer, "trap_trig_1\n") == 0){
            		read_data_temp = Read_Python_GUI_Control_AXI_Reg();
            		// set AXI bit
            		read_data_temp = Reg_Set_Bit(read_data_temp, NEORV32_TRAP_TRIGGERED);
            		Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// no trap detected
            	else if (strcmp(recieve_buffer, "trap_trig_0\n") == 0){
					read_data_temp = Read_Python_GUI_Control_AXI_Reg();
					// clear AXI bit
					read_data_temp = Reg_Clear_Bit(read_data_temp, NEORV32_TRAP_TRIGGERED);
					Write_Python_GUI_Control_AXI_Reg(read_data_temp);
            	}

            	// instruction info enable button pressed on GUI
            	else if (strcmp(recieve_buffer, "instr_info_en_p\n") == 0){
            		// check current state and invert
            		if (instruction_info_enabled == 0){
            			instruction_info_enabled = 1;
              		}
            		else{
            			instruction_info_enabled = 0;
            		}
            	}

            	// spike plot enable button pressed on GUI
            	else if (strcmp(recieve_buffer, "spike_plt_en_p\n") == 0){
            		// check current state and invert
					if (spike_plot_enabled == 0){
						spike_plot_enabled = 1;
					}
					else{
						spike_plot_enabled = 0;
            		}
            	}

            	// FIFO write cycles message from GUI
            	else if (strncmp(recieve_buffer, "fifo_wr_cyc_", 12) == 0) {
            		Write_FIFO_Write_Cycles_AXI_Reg(Parse_FIFO_Write_Cycles(recieve_buffer));
            	}

                num_received_bytes = 0;
            }
        }

        // end of read UART data from Python GUI



        // start of send data from uB to Python GUI


        // instruction info enable button
        // if change in button state, update the GUI
        if (instruction_info_enabled_last != instruction_info_enabled){
        	xil_printf("instr_info_en_%d\n\r", instruction_info_enabled);
        }
        // update the button state
        instruction_info_enabled_last = instruction_info_enabled;


        // spike plot enable button
        // if change in button state, update the GUI
        if (spike_plot_enabled_last != spike_plot_enabled){
        	xil_printf("spike_plot_en_%d\n\r", spike_plot_enabled);
        }
        // update the button state
        spike_plot_enabled_last = spike_plot_enabled;


        // FIFO write cycles
        // if change in FIFO write cycles, update the GUI
        fifo_write_cycles_from_uB = Read_FIFO_Write_Cycles_AXI_Reg();
        // if changed, update the GUI
        if (fifo_write_cycles_from_uB_last != fifo_write_cycles_from_uB){
        	xil_printf("fifo_wr_cycles_%d\n\r", fifo_write_cycles_from_uB);
        }
        // update the FIFO write cycles
        fifo_write_cycles_from_uB_last = fifo_write_cycles_from_uB;



        // read the PC bit fault type counters AXI register
        pc_bit_fault_type_counters_to_uB = Read_PC_Bit_Fault_Type_Counters_AXI_Reg();

        shift_num = 0;

        // loop through each 2-bit counter
        for (uint8_t i=0; i<10; i++){

        	// shift to lower 2 bits of temp variable and bitmask
        	pc_bit_fault_type_counter_temp = (pc_bit_fault_type_counters_to_uB >> shift_num) & 0x3;

        	// if change in fault type counters, update the GUI
        	if (pc_bit_fault_type_counter_temp != pc_bit_fault_type_counters_last[i]){
        		xil_printf("pc_bit_cnts_%d_%d\n\r", i+1, pc_bit_fault_type_counter_temp);
        	}

        	// update the fault type counters
        	pc_bit_fault_type_counters_last[i] = pc_bit_fault_type_counter_temp;
        	shift_num += 2;
        }



        // read the motor speeds AXI register
        motor_speeds_to_uB = Read_Motor_Speeds_AXI_Reg();

        // extract the two 16-bit values
        uint32_t motor_actual_speed_temp = motor_speeds_to_uB & 0xFFFF;
        uint32_t motor_setpoint_speed_temp = (motor_speeds_to_uB >> 16) & 0xFFFF;

        // if change in motor actual speed, update the GUI
        if (motor_actual_speed_temp != motor_actual_speed_last){
    		xil_printf("motor_actual_%d\n\r", motor_actual_speed_temp);
        }

        // if change in motor setpoint speed, update the GUI
        if (motor_setpoint_speed_temp != motor_setpoint_speed_last){
        	xil_printf("motor_setpoint_%d\n\r", motor_setpoint_speed_temp);
        }

        // update the motor speeds
        motor_actual_speed_last = motor_actual_speed_temp;
        motor_setpoint_speed_last = motor_setpoint_speed_temp;



        // read the other data AXI register
        other_data_to_uB = Read_Other_Data_AXI_Reg();

        // loop through all 10 bits
        for (uint8_t i=0; i<10; i++){

        	// shift to each bit and bitmask
        	other_data_temp = (other_data_to_uB >> i) & 0x1;

        	if (other_data_temp != other_data_to_uB_last[i]){

        		// motor running status
        		if (i == 0){
        			xil_printf("motor_run_%d\n\r", other_data_temp);
        		}

        		// motor forward indicator
        		else if (i == 1){
        			xil_printf("motor_for_%d\n\r", other_data_temp);
        		}

        		// motor reverse indicator
        		else if (i == 2){
        			xil_printf("motor_rev_%d\n\r", other_data_temp);
        		}

        		// faults active indicator
        		else if (i == 3){
        			xil_printf("flts_active_%d\n\r", other_data_temp);
        		}

        		// Neorv32 reset indicator
        		else if (i == 4){
        			xil_printf("nv32_rst_%d\n\r", other_data_temp);
        		}

        		// watchdog enabled indicator
        		else if (i == 5){
        			xil_printf("wd_en_%d\n\r", other_data_temp);
        		}

        		// watchdog count of instructions classified as no faults
        		else if (i == 6){
        			xil_printf("wd_no_flts_det_%d\n\r", other_data_temp);
        		}

        		// watchdog count of instructions classified as faults
        		else if (i == 7){
        			xil_printf("wd_flts_det_%d\n\r", other_data_temp);
        		}

        		// system error indicator
        		else if (i == 8){
        			xil_printf("system_err_%d\n\r", other_data_temp);
        		}

        		// trap triggered indicator
        		else if (i == 9){
        			xil_printf("trap_trig_led_%d\n\r", other_data_temp);
        		}

        	}

        	// update the data
        	other_data_to_uB_last[i] = other_data_temp;
        }


        // end of send data from uB to Python GUI



        // start of read the watchdog signals (smart watchdog monitoring loop)

        // read the watchdog FSM status bits
        watchdog_signals_to_uB = Read_Watchdog_Signals_AXI_Reg();

        watchdog_ready = Reg_Get_Bit(watchdog_signals_to_uB, 0);
        watchdog_done = Reg_Get_Bit(watchdog_signals_to_uB, 1);

        // check for watchdog ready bit low (signifies start of monitoring instruction data)
        if ( (watchdog_ready == 0) && (watchdog_done == 0) ){

        	// inform GUI to expect instruction monitoring message
        	xil_printf("start\n\r");

        	// initialise instruction counters
        	instructions_monitored = 0;
        	instructions_no_faults_monitored = 0;
        	instructions_faults_monitored = 0;

        	// while the watchdog done bit is not asserted (still busy),
        	// enter this loop until watchdog processing all RISC-V instruction data
        	while (Reg_Get_Bit(watchdog_signals_to_uB, 1) == 0){

        		// read the watchdog FSM status bits again
        		watchdog_signals_to_uB = Read_Watchdog_Signals_AXI_Reg();

				// check if the neorv32 instruction data is ready to read
				if (Reg_Get_Bit(watchdog_signals_to_uB, 5) == 1){

					// if instruction info is enabled, it needs to be read from the RTL IP AXI registers
					if (instruction_info_enabled == 1){

						// read Neorv32 instruction data
						ir_data_to_uB = Read_NEORV32_IR_Data_AXI_Reg();
						pc_data_to_uB = Read_NEORV32_PC_Data_AXI_Reg();
						execute_states_data_to_uB = Read_NEORV32_Execute_States_Data_AXI_Reg();
						rs1_reg_data_to_uB = Read_NEORV32_RS1_Reg_Data_AXI_Reg();
						mtvec_data_to_uB = Read_NEORV32_MTVEC_Data_AXI_Reg();
						mepc_data_to_uB = Read_NEORV32_MEPC_Data_AXI_Reg();
						mcause_data_to_uB = Read_NEORV32_MCAUSE_Data_AXI_Reg();

						// send Neorv32 instruction data to Python GUI
						xil_printf("IR= %08x PC= %08x RS1= %08x MTVEC= %08x MEPC= %08x MCAUSE= %02x CPU_state= %s\n\r", ir_data_to_uB, pc_data_to_uB, rs1_reg_data_to_uB, mtvec_data_to_uB, mepc_data_to_uB, mcause_data_to_uB, DecodeExecuteStatestoString(execute_states_data_to_uB));
					}

					// inform watchdog FSM that the uB has read the neorv32 data (effectively toggle bit)
					Write_Watchdog_Signals_AXI_Reg(2);
					Write_Watchdog_Signals_AXI_Reg(0);
				}


				// check if the watchdog SNN inference class is ready to read (bit is set)
				else if (Reg_Get_Bit(watchdog_signals_to_uB, 2) == 1){

					// read the extracted 16 features
					features_data_to_uB = Read_Features_Data_AXI_Reg();

					// increment the instructions monitored count
					instructions_monitored += 1;

					// check if the SNN class is 0
					if (Reg_Get_Bit(watchdog_signals_to_uB, 3) == 1){

						// send class 0 and features if instruction info is enabled
						if (instruction_info_enabled == 1){
							xil_printf("snn_c0_features_%d\n\r", features_data_to_uB);
						}

						// increment the no faults instructions monitored count
						else{
							instructions_no_faults_monitored += 1;
						}
					}

					// check if the SNN class is 1
					else if (Reg_Get_Bit(watchdog_signals_to_uB, 4) == 1){

						// send class 1 and features if instruction info is enabled
						if (instruction_info_enabled == 1){
							xil_printf("snn_c1_features_%d\n\r", features_data_to_uB);
						}

						// increment the faults instructions monitored count
						else{
							instructions_faults_monitored += 1;
						}
					}

					// if instruction info and spike plot are both enabled
					if (spike_plot_enabled == 1 && instruction_info_enabled == 1){

						// read all the SNN spiking activity from the watchdog (shift registers)

						// input layer spikes
						xil_printf("snn_in_2_0_spikes_%d\n\r", Read_SNN_Input_Neuron_2_to_0_Spikes_AXI_Reg());
						xil_printf("snn_in_5_3_spikes_%d\n\r", Read_SNN_Input_Neuron_5_to_3_Spikes_AXI_Reg());
						xil_printf("snn_in_8_6_spikes_%d\n\r", Read_SNN_Input_Neuron_8_to_6_Spikes_AXI_Reg());
						xil_printf("snn_in_11_9_spikes_%d\n\r", Read_SNN_Input_Neuron_11_to_9_Spikes_AXI_Reg());
						xil_printf("snn_in_14_12_spikes_%d\n\r", Read_SNN_Input_Neuron_14_to_12_Spikes_AXI_Reg());
						xil_printf("snn_in_15_spikes_%d\n\r", Read_SNN_Input_Neuron_15_Spikes_AXI_Reg());

						// hidden layer spikes
						xil_printf("snn_hid_2_0_spikes_%d\n\r", Read_SNN_Hidden_Neuron_2_to_0_Spikes_AXI_Reg());
						xil_printf("snn_hid_5_3_spikes_%d\n\r", Read_SNN_Hidden_Neuron_5_to_3_Spikes_AXI_Reg());
						xil_printf("snn_hid_8_6_spikes_%d\n\r", Read_SNN_Hidden_Neuron_8_to_6_Spikes_AXI_Reg());
						xil_printf("snn_hid_11_9_spikes_%d\n\r", Read_SNN_Hidden_Neuron_11_to_9_Spikes_AXI_Reg());
						xil_printf("snn_hid_14_12_spikes_%d\n\r", Read_SNN_Hidden_Neuron_14_to_12_Spikes_AXI_Reg());
						xil_printf("snn_hid_17_15_spikes_%d\n\r", Read_SNN_Hidden_Neuron_17_to_15_Spikes_AXI_Reg());
						xil_printf("snn_hid_19_18_spikes_%d\n\r", Read_SNN_Hidden_Neuron_19_to_18_Spikes_AXI_Reg());

						// output layer spikes
						xil_printf("snn_out_1_0_spikes_%d\n\r", Read_SNN_Output_Neuron_1_to_0_Spikes_AXI_Reg());
					}


						// inform watchdog FSM that the uB has read the snn class data (effectively toggle bit)
						Write_Watchdog_Signals_AXI_Reg(1);
						Write_Watchdog_Signals_AXI_Reg(0);

						// re-send the RISC-V instruction data for the start of the next instruction (current and last PC / IR etc)
						if (instruction_info_enabled == 1){
							xil_printf("IR= %08x PC= %08x RS1= %08x MTVEC= %08x MEPC= %08x MCAUSE= %02x CPU_state= %s\n\r", ir_data_to_uB, pc_data_to_uB, rs1_reg_data_to_uB, mtvec_data_to_uB, mepc_data_to_uB, mcause_data_to_uB, DecodeExecuteStatestoString(execute_states_data_to_uB));
						}

				}

        	}

        	// break out of while loop when watchdog is finally done, to here
        	// if instruction info is disabled, just print the instruction counts
        	if (instruction_info_enabled == 0){
				xil_printf("instr_count_%d\n\r", instructions_monitored);
				xil_printf("instr_nf_count_%d\n\r", instructions_no_faults_monitored);
				xil_printf("instr_f_count_%d\n\r", instructions_faults_monitored);
        	}

        	// inform GUI that instruction monitoring is complete message
        	xil_printf("done\n\r");

        }

        // end of read the watchdog signals (smart watchdog monitoring loop)

    }

    // clean up platform resources (never reached)
    cleanup_platform();
    return 0;
}




// FUNCTION BODIES

int parse_motor_setpoint_speed(const char *message) {
    const char *prefix = "motor_setpoint_";
    size_t prefix_length = strlen(prefix);

    // if message starts with "motor_setpoint_speed_"
    if (strncmp(message, prefix, prefix_length) == 0) {
        // get setpoint speed
        const char *speed_str = message + prefix_length;

        // return the converted string as integer
        int setpoint_speed_int = atoi(speed_str);
        return setpoint_speed_int;
    }
    return 0;
}


int Read_Neorv32_Buttons_AXI_Reg(){
	int reg_data = 0;
	reg_data = *AXI_REG_O;
	return reg_data;
}


void Write_Neorv32_Buttons_AXI_Reg(int data){
	*AXI_REG_O = data;
}


int Read_Python_GUI_Control_AXI_Reg(){
	int reg_data = 0;
	reg_data = *AXI_REG_2;
	return reg_data;
}


void Write_Python_GUI_Control_AXI_Reg(int data){
	*AXI_REG_2 = data;
}


void Write_Motor_Speed_Setpoint_AXI_Reg(int data){
	*AXI_REG_1 = data & 0xFFFF;
}


int Reg_Set_Bit(int reg_data, int bit){
	reg_data |= (1 << bit);
	return reg_data;
}


int Reg_Clear_Bit(int reg_data, int bit){
	reg_data &= ~(1 << bit);
	return reg_data;
}


int Reg_Get_Bit(int reg_data, int bit){
	reg_data = (reg_data >> bit) & 1;
	return reg_data;
}


int Read_Motor_Speeds_AXI_Reg(){
	int reg_data = 0;
	reg_data = *AXI_REG_3;
	return reg_data;
}


int Read_PC_Bit_Fault_Type_Counters_AXI_Reg(){
	int reg_data = 0;
	reg_data = *AXI_REG_4;
	return reg_data;
}


int Read_Other_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_5;
	return temp;
}


int Read_Watchdog_Signals_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_7;
	return temp;
}


void Write_Watchdog_Signals_AXI_Reg(int data){
	*AXI_REG_6 = data;
}


int Read_NEORV32_IR_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_8;
	return temp;
}


int Read_NEORV32_PC_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_9;
	return temp;
}


int Read_NEORV32_Execute_States_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_10;
	return temp;
}


int Read_NEORV32_RS1_Reg_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_11;
	return temp;
}


int Read_NEORV32_MTVEC_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_12;
	return temp;
}


int Read_NEORV32_MEPC_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_13;
	return temp;
}


int Read_Features_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_14;
	return temp;
}


const char* DecodeExecuteStatestoString(int array_index){
	return Execute_States_Decode_Strings[array_index];
}


int Read_NEORV32_MCAUSE_Data_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_15;
	return temp;
}


void Write_FIFO_Write_Cycles_AXI_Reg(int data){
	*AXI_REG_16 = data;
}


int Read_FIFO_Write_Cycles_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_17;
	return temp;
}


int Parse_FIFO_Write_Cycles(const char *message) {
    const char *prefix = "fifo_wr_cyc_";
    size_t prefix_length = strlen(prefix);

    // if message starts with "motor_setpoint_speed_"
    if (strncmp(message, prefix, prefix_length) == 0) {
        // get setpoint speed
        const char *fifo_wr_cycles_str = message + prefix_length;

        // return the converted string as integer
        int fifo_wr_cycles = atoi(fifo_wr_cycles_str);
        return fifo_wr_cycles;
    }
    return 0;
}


int Read_SNN_Input_Neuron_2_to_0_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_18;
	return temp;
}


int Read_SNN_Input_Neuron_5_to_3_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_19;
	return temp;
}


int Read_SNN_Input_Neuron_8_to_6_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_20;
	return temp;
}


int Read_SNN_Input_Neuron_11_to_9_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_21;
	return temp;
}


int Read_SNN_Input_Neuron_14_to_12_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_22;
	return temp;
}


int Read_SNN_Input_Neuron_15_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_23;
	return temp;
}


int Read_SNN_Hidden_Neuron_2_to_0_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_24;
	return temp;
}


int Read_SNN_Hidden_Neuron_5_to_3_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_25;
	return temp;
}


int Read_SNN_Hidden_Neuron_8_to_6_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_26;
	return temp;
}


int Read_SNN_Hidden_Neuron_11_to_9_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_27;
	return temp;
}


int Read_SNN_Hidden_Neuron_14_to_12_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_28;
	return temp;
}


int Read_SNN_Hidden_Neuron_17_to_15_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_29;
	return temp;
}


int Read_SNN_Hidden_Neuron_19_to_18_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_30;
	return temp;
}


int Read_SNN_Output_Neuron_1_to_0_Spikes_AXI_Reg(){
	int temp = 0;
	temp = *AXI_REG_31;
	return temp;
}



