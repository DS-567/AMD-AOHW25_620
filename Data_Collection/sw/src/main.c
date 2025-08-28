
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include "platform.h"
#include "xil_printf.h"
#include "xuartlite.h"
#include "string.h"
#include "sleep.h"
#include "xparameters.h"

#define UARTLITE_DEVICE_ID		XPAR_UARTLITE_0_DEVICE_ID

// constant lookup table
static const char *Reg_Index_Names_Strings[] = {
    "Bit 1 Fault 1 Time",  "Bit 1 Fault 2 Time",   "Bit 1 Fault 3 Time",     "Bit 2 Fault 1 Time",  "Bit 2 Fault 2 Time",   "Bit 2 Fault 3 Time",
	"Bit 3 Fault 1 Time",  "Bit 3 Fault 2 Time",   "Bit 3 Fault 3 Time",     "Bit 4 Fault 1 Time",  "Bit 4 Fault 2 Time",   "Bit 4 Fault 3 Time",
	"Bit 5 Fault 1 Time",  "Bit 5 Fault 2 Time",   "Bit 5 Fault 3 Time",     "Bit 6 Fault 1 Time",  "Bit 6 Fault 2 Time",   "Bit 6 Fault 3 Time",
	"Bit 7 Fault 1 Time",  "Bit 7 Fault 2 Time",   "Bit 7 Fault 3 Time",     "Bit 8 Fault 1 Time",  "Bit 8 Fault 2 Time",   "Bit 8 Fault 3 Time",
	"Bit 9 Fault 1 Time",  "Bit 9 Fault 2 Time",   "Bit 9 Fault 3 Time",     "Bit 10 Fault 1 Time", "Bit 10 Fault 2 Time",  "Bit 10 Fault 3 Time",
	"Bit 1 Fault 1 Type",  "Bit 1 Fault 2 Type",   "Bit 1 Fault 3 Type",     "Bit 2 Fault 1 Type",  "Bit 2 Fault 2 Type",   "Bit 2 Fault 3 Type",
	"Bit 3 Fault 1 Type",  "Bit 3 Fault 2 Type",   "Bit 3 Fault 3 Type",     "Bit 4 Fault 1 Type",  "Bit 4 Fault 2 Type",   "Bit 4 Fault 3 Type",
	"Bit 5 Fault 1 Type",  "Bit 5 Fault 2 Type",   "Bit 5 Fault 3 Type",     "Bit 6 Fault 1 Type",  "Bit 6 Fault 2 Type",   "Bit 6 Fault 3 Type",
	"Bit 7 Fault 1 Type",  "Bit 7 Fault 2 Type",   "Bit 7 Fault 3 Type",     "Bit 8 Fault 1 Type",  "Bit 8 Fault 2 Type",   "Bit 8 Fault 3 Type",
	"Bit 9 Fault 1 Type",  "Bit 9 Fault 2 Type",   "Bit 9 Fault 3 Type",     "Bit 10 Fault 1 Type", "Bit 10 Fault 2 Type",  "Bit 10 Fault 3 Type",
	"Stuck at Hold Time",  "Bit Flip Hold Time",   "Fault Injection Enable", "Application Run Time"	};

// constant lookup table
static const char *Type_Reg_Value_Strings[] = { "No Fault", "Stuck at 0", "Stuck at 1", "Bit Flip" };

// constant lookup table
static const char *Fault_Inj_Reg_Value_Strings[] = { "Fault Injection Disabled", "Fault Injection Enabled" };

// constant lookup table
static const char *Execute_States_Decode_Strings[] = {"DISPATCH", "TRAP_ENTER", "TRAP_EXIT", "RESTART", "FENCE", "SLEEP", "EXECUTE",
													  "ALU_WAIT", "BRANCH", "BRANCHED", "SYSTEM", "MEM_REQ", "MEM_WAIT" };

// array to store the result data from the C application executed on Neorv32 (64 elements)
int Result_Data_Read_from_Hardware_RAM[64] = {0};


// FUNCTION PROTOTYPES
int UartLiteSelfTestExample(u16 DeviceId);

void PrintMainMenu();
void PrintSetupMenu();
void PrintFlushMenu();
void PrintShowMenu();
void PrintStatusMenu();
void PrintTestMenu();
void PrintRunMenu();
void PrintSetupBitsMenu(u8 bit_index);
void PrintStuckatHoldTimeMenu();
void PrintBitFlipHoldTimeMenu();
void PrintFaultInjEnMenu();
void PrintTimeMenu(u8 bit_index, u8 fault_index);
void PrintTypeMenu(u8 bit_index, u8 fault_index);
void PrintRunTimeMenu();
void ReadTestRegs();
void ReadBitsRegs(u8 bit_num);
void PrintSpareMenu();
void PrintRunAutoMenu();

int GetAddressDecode(u8 bit_index, u8 fault_index, bool type_or_time_flag);
void SendDatatoReg(int data, int address);
u32 ReadDatafromReg(int address);
void ReadResultDatafromRAM();
void CheckRegWrite(int data, int address);
void ReadAllRegs();
void FlushallRegs();
void TestDesign();
void ShowActiveFaults();
int ReadlogicSignals();
int ReadProgramCounterData();
int ReadInstructionRegisterData();
int ReadExecuteStatesData();
int ReadBranchTakenData();
int ReadMCAUSEData();
int ReadMEPCData();
int ReadRS1Data();
int ReadALUCompStatusData();
int ReadCtrlBus1Data();
int ReadCtrlBus2Data();
int ReadMTVECData();
void TestResultDatafromRAM();
bool CheckResultDatainRAMisZero();
void ResetResultDatainRAM();
void StartApplicationRun();
bool FlushallBitsRegs();
void ResetResultDataArray();
const char* DecodeExecuteStatestoString(int array_index);

XUartLite UartLite;		 /* Instance of the UartLite device */

int *AXI_REG_O_WRITE_TO_SETUP_REGS;			// pointer to AXI slave reg 0, used to write data to setup regs
int *AXI_REG_1_READ_FROM_SETUP_REGS;		// pointer to AXI slave reg 1, used to read data from setup regs
int *AXI_REG_2_UB_TO_LOGIC_SIGNALS;			// pointer to AXI slave reg 2, used to write data to hardware logic
int *AXI_REG_3_LOGIC_TO_UB_SIGNALS;			// pointer to AXI slave reg 3, used to read data from hardware logic
int *AXI_REG_4_READ_RESULT_DATA;			// pointer to AXI slave reg 4, used to read result data from hardware logic
int *AXI_REG_5_READ_PC_DATA;				// pointer to AXI slave reg 5, used to read PC data from hardware logic
int *AXI_REG_6_READ_IR_DATA;				// pointer to AXI slave reg 6, used to read IR data from hardware logic
int *AXI_REG_7_READ_EXECUTE_STATES_DATA;	// pointer to AXI slave reg 7, used to read execute state data from hardware logic
int *AXI_REG_8_READ_BRANCH_TAKEN_DATA;		// pointer to AXI slave reg 8, used to read branch taken data from hardware logic
int *AXI_REG_9_READ_MCAUSE_DATA;			// pointer to AXI slave reg 9, used to read MCAUSE data from hardware logic
int *AXI_REG_10_READ_MEPC_DATA; 			// pointer to AXI slave reg 10, used to read MEPC data from hardware logic
int *AXI_REG_11_READ_RS1_DATA; 				// pointer to AXI slave reg 11, used to read RS1 data out from hardware logic
int *AXI_REG_12_READ_ALU_CMP_STATUS_DATA;	// pointer to AXI slave reg 12, used to read ALU comparator status data from hardware logic
int *AXI_REG_13_READ_CTRL_BUS_1_DATA;		// pointer to AXI slave reg 13, used to read control bus 1 data from hardware logic
int *AXI_REG_14_READ_CTRL_BUS_2_DATA;		// pointer to AXI slave reg 14, used to read control bus 2 data from hardware logic
int *AXI_REG_15_MTVEC_DATA;					// pointer to AXI slave reg 15, used to read MTVEC data from hardware logic


// Start of auto fault parameters setup area

// Fibonacci Series (45 values) = 1
// Bubble Sort (25 values) = 2
// Matrix Multiplication (16 values) = 3
// Heap Sort (20 values) = 4
// any other input value will not run!

// C application select (see above comment)
int application_run_num = 4;

// length of time to run each application for
int auto_application_run_time = 17000;

// enable fault injection
int auto_faults_enabled = 1;

// length of time to hold a stuck at fault (permanent)
int auto_stuck_at_hold_time = 17000;

// not used anymore!
int auto_bit_flip_hold_time = 0;	// not used anymore!


// fault type and time setup
// No Fault = 0   |   Stuck at 0 = 1   |   Stuck at 1 = 2   |   Bit Flip = 3  (whether temporary or permanent depends on the stuck at hold time set above!)

int auto_fault_type_1 = 0;
int auto_fault_time_1 = 0;

int auto_fault_type_2 = 0;
int auto_fault_time_2 = 0;

int auto_fault_type_3 = 0;
int auto_fault_time_3 = 0;

int auto_fault_type_4 = 0;
int auto_fault_time_4 = 0;

int auto_fault_type_5 = 0;
int auto_fault_time_5 = 0;

int auto_fault_type_6 = 0;
int auto_fault_time_6 = 0;

int auto_fault_type_7 = 0;
int auto_fault_time_7 = 0;

int auto_fault_type_8 = 0;
int auto_fault_time_8 = 0;

int auto_fault_type_9 = 0;
int auto_fault_time_9 = 0;

int auto_fault_type_10 = 0;
int auto_fault_time_10 = 0;

// how many fault to inject per bit
int auto_num_faults_per_bit = 10;

// order of fault injection
int auto_start_bit = 1;
int auto_end_bit = 10;

// End of auto fault parameters setup area


// declare ???
bool auto_mode_selected = 0;
bool flush_bits_regs_flag = false;
bool check_type_parameters = 0;
bool check_bit_parameters = 0;

int main()
{
	//initialise platform resources
    init_platform();

    // ensure UART is available
	int UART_Status;

	UART_Status = UartLiteSelfTestExample(UARTLITE_DEVICE_ID);
	if (UART_Status != XST_SUCCESS) {
		xil_printf("Uartlite Setup Failed!\r\n");
	}
	else{
		xil_printf("Uartlite Setup Successful!\r\n");
		xil_printf("\n");
	}

	// Set up a simple FSM of states
	enum state_machine { MAIN_MENU, SETUP, FLUSH, SHOW, STATUS, RUN_MANUAL, RUN_AUTO, SPARE, SETUP_REGS, TEST_REGS, TYPE_REG_SETUP, TIME_REG_SETUP, FAULT_INJ_EN_SETUP,
						 STUCK_AT_HOLD_SETUP, BIT_FLIP_HOLD_SETUP, APP_RUN_TIME };

	// current state variable (initialise to main menu)
	enum state_machine state = MAIN_MENU;

	// AXI slave register addresses
	AXI_REG_O_WRITE_TO_SETUP_REGS   	= XPAR_NV32_IP1_0_S00_AXI_BASEADDR;
	AXI_REG_1_READ_FROM_SETUP_REGS  	= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 4;
	AXI_REG_2_UB_TO_LOGIC_SIGNALS   	= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 8;
	AXI_REG_3_LOGIC_TO_UB_SIGNALS  	 	= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 12;
	AXI_REG_4_READ_RESULT_DATA 			= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 16;
	AXI_REG_5_READ_PC_DATA 				= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 20;
	AXI_REG_6_READ_IR_DATA 				= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 24;
	AXI_REG_7_READ_EXECUTE_STATES_DATA	= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 28;
	AXI_REG_8_READ_BRANCH_TAKEN_DATA 	= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 32;
	AXI_REG_9_READ_MCAUSE_DATA 			= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 36;
	AXI_REG_10_READ_MEPC_DATA 			= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 40;
	AXI_REG_11_READ_RS1_DATA 			= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 44;
	AXI_REG_12_READ_ALU_CMP_STATUS_DATA	= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 48;
	AXI_REG_13_READ_CTRL_BUS_1_DATA		= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 52;
	AXI_REG_14_READ_CTRL_BUS_2_DATA		= XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 56;
	AXI_REG_15_MTVEC_DATA               = XPAR_NV32_IP1_0_S00_AXI_BASEADDR + 60;

	// receive buffer
	char text[20];

	// first test the setup register can be written too and read from successfully
	TestDesign();
	// flush the registers to initialise for the user
	FlushallRegs();

	// print default main menu
	PrintMainMenu();

	// declare variables ad initialise with default values
	int setup_reg_select = 1;		//default value
	int fault_num_select = 1;		//default value
	bool type_or_time_flag = 0;		//default value
	bool RAM_has_been_read = 0;
	int address = 0;
	int data = 0;

	// declare Neorv32 data read variables
	int print_line_counter = 0;
	int read;
	int read_1;
	int PC_data_read = 0;
	int IR_data_read = 0;
	int execute_states_data_read = 0;
	int branch_taken_data_read = 0;
	int mcause_data_read = 0;
	int mepc_data_read = 0;
	int RS1_data_read = 0;
	int alu_comp_status_data_read = 0;
	int ctrl_bus_1_data_read = 0;
	int ctrl_bus_2_data_read = 0;
	int mtvec_data_read = 0;

	int result_data_nums = 0;

	// initialise default state
	state = MAIN_MENU;

	while(1){

			// main FSM switch statement
			switch (state) {

			case MAIN_MENU: 								// main menu

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "1\r\n") == 0){			// trigger: key 1 entered
			    	state = SETUP;							// next state
			    	PrintSetupMenu();						// print setup menu
			   		}

			    else if (strcmp(text, "2\r\n") == 0){		// trigger: key 2 entered
			    	state = FLUSH;							// next state
			    	PrintFlushMenu();						// print flush menu
			    	}

			    else if (strcmp(text, "3\r\n") == 0){		// trigger: key 3 entered
			    	state = SHOW;							// next state
			    	PrintShowMenu();						// print show menu
			   		}

			    else if (strcmp(text, "4\r\n") == 0){		// trigger: key 4 entered
			    	state = STATUS;							// next state
			    	PrintStatusMenu();						// print status menu
			   		}

			    else if (strcmp(text, "5\r\n") == 0){		// trigger: key 5 entered
			    	state = TEST_REGS;						// next state
			    	PrintTestMenu();						// print test menu
			   		}

			    else if (strcmp(text, "6\r\n") == 0){		// trigger: key 6 entered
			    	state = SPARE;							// next state
			    	PrintSpareMenu();						// print spare menu
			   		}

			    else if (strcmp(text, "7\r\n") == 0){		// trigger: key 7 entered
			    	state = RUN_MANUAL;						// next state
			    	PrintRunMenu();							// print run menu
			   		}

			    else if (strcmp(text, "8\r\n") == 0){		// trigger: key 8 entered
			    	state = RUN_AUTO;						// next state
			    	auto_mode_selected = 1;					// auto mode flag set to stop printing during auto runs
			    	PrintRunAutoMenu();						// print run auto menu
			    }

				break;

	    	case SETUP: 									// setup

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
			    	state = MAIN_MENU;						// next state
					PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
			    	state = MAIN_MENU;			     		// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "0\r\n") == 0){		// trigger: key 0 entered
	    			flush_bits_regs_flag = FlushallBitsRegs();

	    			if (flush_bits_regs_flag == 1){
	    				xil_printf("Error Flushing Bits Registers!\n");
	    				flush_bits_regs_flag = 0;
	    			}
	    			else{
	    				xil_printf("Bits Registers Flushed!\n");
	    			}
			    }

			    else if (strcmp(text, "1\r\n") == 0){		// trigger: key 1 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 1;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			   		}

			    else if (strcmp(text, "2\r\n") == 0){		// trigger: key 2 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 2;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			    	}

			    else if (strcmp(text, "3\r\n") == 0){		// trigger: key 3 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 3;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			   		}

			    else if (strcmp(text, "4\r\n") == 0){		// trigger: key 4 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 4;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			    	}

			    else if (strcmp(text, "5\r\n") == 0){		// trigger: key 5 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 5;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			    	}

			    else if (strcmp(text, "6\r\n") == 0){		// trigger: key 6 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 6;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			    	}

			    else if (strcmp(text, "7\r\n") == 0){		// trigger: key 7 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 7;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			    	}

			    else if (strcmp(text, "8\r\n") == 0){		// trigger: key 8 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 8;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			    	}

			    else if (strcmp(text, "9\r\n") == 0){		// trigger: key 9 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 9;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			    	}

			    else if (strcmp(text, "10\r\n") == 0){		// trigger: key 10 entered
			    	state = SETUP_REGS;						// next state
			    	setup_reg_select = 10;
			    	PrintSetupBitsMenu(setup_reg_select);	// print bit setup menu
			    	}

			    else if (strcmp(text, "11\r\n") == 0){		// trigger: key 11 entered
			    	state = STUCK_AT_HOLD_SETUP;			// next state
			    	setup_reg_select = 11;
			    	PrintStuckatHoldTimeMenu();				// print stuck at hold time setup menu
			   		}

			    else if (strcmp(text, "12\r\n") == 0){		// trigger: key 12 entered
			    	state = BIT_FLIP_HOLD_SETUP;			// next state
			    	setup_reg_select = 12;
			    	PrintBitFlipHoldTimeMenu();				// print bit flip hold time setup menu
			   		}

			    else if (strcmp(text, "13\r\n") == 0){		// trigger: key 13 entered
			    	state = FAULT_INJ_EN_SETUP;				// next state
			    	setup_reg_select = 13;
			    	PrintFaultInjEnMenu();				    // print fault injection enable register setup menu
			   		}

			    else if (strcmp(text, "14\r\n") == 0){		// trigger: key 14 entered
			    	state = APP_RUN_TIME;					// next state
			    	setup_reg_select = 14;
			    	PrintRunTimeMenu();				 	   // print time menu
			   		}

	    		break;

	    	case SETUP_REGS: 								// setup

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();  						// print main menu
			   		}

			    else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
			    	state = SETUP;			     			// next state
			    	PrintSetupMenu();						// print setup menu
			   		}

			    else if (strcmp(text, "1\r\n") == 0){		// trigger: key 1 entered
			    	state = TYPE_REG_SETUP;					// next state
			    	fault_num_select = 1;
			    	type_or_time_flag = 0;
			    	PrintTypeMenu(setup_reg_select, fault_num_select);
			   		}

			    else if (strcmp(text, "2\r\n") == 0){		// trigger: key 2 entered
			    	state = TYPE_REG_SETUP;					// next state
			    	fault_num_select = 2;
			    	type_or_time_flag = 0;
			    	PrintTypeMenu(setup_reg_select, fault_num_select);
			   		}

			    else if (strcmp(text, "3\r\n") == 0){		// trigger: key 3 entered
			    	state = TYPE_REG_SETUP;					// next state
			    	fault_num_select = 3;
			    	type_or_time_flag = 0;
			    	PrintTypeMenu(setup_reg_select, fault_num_select);
			   		}

			    else if (strcmp(text, "4\r\n") == 0){		// trigger: key 4 entered
			    	state = TIME_REG_SETUP;					// next state
			    	fault_num_select = 1;
			    	type_or_time_flag = 1;
			    	PrintTimeMenu(setup_reg_select, fault_num_select);
			   		}

			    else if (strcmp(text, "5\r\n") == 0){		// trigger: key 5 entered
			    	state = TIME_REG_SETUP;					// next state
			    	fault_num_select = 2;
			    	type_or_time_flag = 1;
			    	PrintTimeMenu(setup_reg_select, fault_num_select);
			   		}

			    else if (strcmp(text, "6\r\n") == 0){		// trigger: key 6 entered
			    	state = TIME_REG_SETUP;					// next state
			    	fault_num_select = 3;
			    	type_or_time_flag = 1;
			    	PrintTimeMenu(setup_reg_select, fault_num_select);
			   		}

	    		break;

	    	case TYPE_REG_SETUP: 								// setup

	    		fgets(text, sizeof(text), stdin);		    	// wait for user input

	    			if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
	    				state = MAIN_MENU;				    	// next state
	    				PrintMainMenu();  						// print main menu
	    			}

	    			else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
	    				state = SETUP_REGS;			   			// next state
	    				PrintSetupBitsMenu(setup_reg_select);	// print setup menu
	    			}

				    else if (strcmp(text, "0\r\n") == 0){		// trigger: key 0 entered : no fault
				    	data = 0;
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				   		SendDatatoReg(data, address);
				   		CheckRegWrite(data, address);
				   		}


				    else if (strcmp(text, "1\r\n") == 0){		// trigger: key 1 entered : stuck at zero
				    	data = 1;
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				   		SendDatatoReg(data, address);
				   		CheckRegWrite(data, address);
				   		}

				    else if (strcmp(text, "2\r\n") == 0){		// trigger: key 2 entered : stuck at one
				    	data = 2;
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				   		SendDatatoReg(data, address);
				   		CheckRegWrite(data, address);
				   		}


				    else if (strcmp(text, "3\r\n") == 0){		// trigger: key 3 entered : bit flip
				    	data = 3;
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				   		SendDatatoReg(data, address);
				   		CheckRegWrite(data, address);
				   		}
	    			break;

	    	case TIME_REG_SETUP: 								// setup

	    		fgets(text, sizeof(text), stdin);		    	// wait for user input

	    			if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
	    				state = MAIN_MENU;				   		// next state
	    				PrintMainMenu();  						// print main menu
	    			}

	    			else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
	    				state = SETUP_REGS;			   			// next state
	    				PrintSetupBitsMenu(setup_reg_select);	// print setup menu
	    			}

				    else if (atoi(text) > 65535){
				    	xil_printf("Number bigger than 16-bit register size!\n");
				    }

	    			else if (atoi(text) == 0){					// input is not a number (could be zero though!)

	    				if (strcmp(text, "0\r\n") == 0){		// trigger: key 0 entered
	    					address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
	    					SendDatatoReg(atoi(text), address);
	    					CheckRegWrite(atoi(text), address);
	    				}

	    				else{
		    				xil_printf("Non-number input!\n");
	    				}
	    			}

	    			else{
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				    	SendDatatoReg(atoi(text), address);
				    	CheckRegWrite(atoi(text), address);
				    }

	    			break;

	    	case STUCK_AT_HOLD_SETUP: 							// setup

	    		fgets(text, sizeof(text), stdin);		    	// wait for user input

	    			if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
	    				state = MAIN_MENU;				   		// next state
	    				PrintMainMenu();  						// print main menu
	    			}

	    			else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
	    				state = SETUP;			   				// next state
	    				PrintSetupMenu();						// print setup menu
	    			}

				    else if (atoi(text) > 65535){
				    	xil_printf("Number bigger than 16-bit register size!\n");
				    }

	    			else if (atoi(text) == 0){					// input is not a number (could be zero though!)

	    				if (strcmp(text, "0\r\n") == 0){		// trigger: key 0 entered
	    					address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
	    					SendDatatoReg(atoi(text), address);
	    					CheckRegWrite(atoi(text), address);
	    				}

	    				else{
		    				xil_printf("Non-number input!\n");
	    					}
	    				}

	    			else{
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				    	SendDatatoReg(atoi(text), address);
				    	CheckRegWrite(atoi(text), address);
				    }

	    			break;

	    	case BIT_FLIP_HOLD_SETUP: 							// setup

	    		fgets(text, sizeof(text), stdin);		    	// wait for user input

	    			if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
	    				state = MAIN_MENU;				   		// next state
	    				PrintMainMenu();  						// print main menu
	    			}

	    			else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
	    				state = SETUP;			   		     	// next state
	    				PrintSetupMenu();						// print setup menu
	    			}

				    else if (atoi(text) > 800){
				    	xil_printf("Software limit set at 800!\n");
				    }

	    			else if (atoi(text) == 0){					// input is not a number (could be zero though!)

	    				if (strcmp(text, "0\r\n") == 0){		// trigger: key 0 entered
	    					address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
	    					SendDatatoReg(atoi(text), address);
	    					CheckRegWrite(atoi(text), address);
	    				}

	    				else{
		    				xil_printf("Non-number input!\n");
	    					}
	    				}

	    			else{
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				    	SendDatatoReg(atoi(text), address);
				    	CheckRegWrite(atoi(text), address);
				    }

	    			break;

	    	case FAULT_INJ_EN_SETUP: 						// setup

	    		fgets(text, sizeof(text), stdin);		    // wait for user input

	    			if (strcmp(text, "m\r\n") == 0){		// trigger: key m entered
	    				state = MAIN_MENU;				    	// next state
	    				PrintMainMenu();  					// print main menu
	    			}

	    			else if (strcmp(text, "b\r\n") == 0){	// trigger: key b entered
	    				state = SETUP;			     		// next state
	    				PrintSetupMenu();					// print setup menu
	    			}

				    else if (strcmp(text, "0\r\n") == 0){		// trigger: key 0 entered : fault injection disabled
				    	data = 0;
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				   		SendDatatoReg(data, address);
				   		CheckRegWrite(data, address);
				   		}


				    else if (strcmp(text, "1\r\n") == 0){		// trigger: key 1 entered : fault injection enabled
				    	data = 1;
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				   		SendDatatoReg(data, address);
				   		CheckRegWrite(data, address);
				   		}

	    			break;

	    	case APP_RUN_TIME: 									// setup

	    		fgets(text, sizeof(text), stdin);		    	// wait for user input

	    			if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
	    				state = MAIN_MENU;				   		// next state
	    				PrintMainMenu();  						// print main menu
	    			}

	    			else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
	    				state = SETUP;			   				// next state
	    				PrintSetupMenu();						// print setup menu
	    			}

	    			// range checks
				    else if (atoi(text) > 65535){
				    	xil_printf("Number bigger than 16-bit register size!\n");
				    }

	    			else if (atoi(text) == 0){					// input is not a number (could be zero though!)

	    				if (strcmp(text, "0\r\n") == 0){		// trigger: key 0 entered
	    					address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
	    					SendDatatoReg(atoi(text), address);
	    					CheckRegWrite(atoi(text), address);
	    				}

	    				else{
		    				xil_printf("Non-number input!\n");
	    					}
	    				}

	    			else{
				    	address = GetAddressDecode(setup_reg_select, fault_num_select ,type_or_time_flag);
				    	SendDatatoReg(atoi(text), address);
				    	CheckRegWrite(atoi(text), address);
				    }

	    			break;

	    	case FLUSH: 								     // setup

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "1\r\n") == 0){		// trigger: key 0 entered
			    	FlushallRegs();					      	// flush registers function
			   		}
	    		break;

	    	case SHOW: 										// setup

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "1\r\n") == 0){		// trigger: key 1 entered

			    xil_printf("Any Active Faults (non-zero registers) are shown below:\n");
			    xil_printf("\n");

			    ShowActiveFaults();							// function that prints any active faults
			    PrintShowMenu();							// print show menu
			    }

	    		break;

	    	case STATUS: 									// setup

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "a\r\n") == 0){		// trigger: key a entered
			    	ReadAllRegs();							// function to read all registers and print their values
			    	PrintStatusMenu();						// print status menu again
			    	}

			    else if (strcmp(text, "t\r\n") == 0){		// trigger: key t entered
			    	ReadTestRegs();
			    	PrintStatusMenu();						// print status menu again
			    	}

			    else if ( (!atoi(text) == 0) & (atoi(text) < 11) ){
			    	ReadBitsRegs(atoi(text));
			    	PrintStatusMenu();						// print status menu again
			    	}

			    else{
			    	xil_printf("Invalid Input!\n");
			    }

	    		break;

	    	case TEST_REGS: 							    // setup

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "1\r\n") == 0){		// trigger: key 1 entered
			    	TestDesign();	  			    	    // function to test the design
			    }

	    		break;

	    	case SPARE: 					     			// setup

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   	}

			    else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   	}

	    		break;

	    	case RUN_MANUAL: 						     	// setup

		    	fgets(text, sizeof(text), stdin);		    // wait for user input

			    if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
			    	state = MAIN_MENU;				     	// next state
			    	PrintMainMenu();						// print main menu
			   		}

			    else if (strcmp(text, "1\r\n") == 0){		// trigger: key 1 entered

			    	read = ReadDatafromReg(63);				// read the application run time register
			    	read_1 = ReadlogicSignals();    		// read the hardware to uB signals

			    	// range checks - cannot be zero
			    	if (read == 0){
			    		xil_printf("\n");
			    		xil_printf("Error: Application run time is set to 0!\r");
			    		xil_printf("Set a value greater than zero to run application!\n\r");
			    	}

			    	// range checks - cannot be greater than 32,000
			    	else if (read > 32000){
			    		xil_printf("\n");
			    		xil_printf("Error: Application run time is set greater than 32,000!\r");
			    		xil_printf("32,000 DUT data values is the number of max values allowed to write to the FIFO!\r");
			    		xil_printf("Set a value less than 32,000 to run application!\n\r");
			    	}

			    	// if hardware is not ready for some reason, do not start
			    	else if ( (read_1 & 0x2) != 0x2){
			    		xil_printf("\n");
			    		xil_printf("Error: Hardware is not in ready state! Cannot start application until hardware is ready!\r");
			    	}

			    	// otherwise start data collection
			    	else{

			    		// send the application run time to terminal
			    		xil_printf("Application Run Time = %d\n", read);

			    		// reset the RAM result data before starting
			    		ResetResultDatainRAM();

			    		// reset the array that stores the result data from RAM for next run
		    			ResetResultDataArray();

		    			// initialise the terminal line count
		    			print_line_counter = 0;

		    			// determine which C application is being executed on Neorv32 for the expected length of result data
		    			if (application_run_num == 1){			// Fibonacci series
		    				result_data_nums = 45;
		    			}

		    			else if (application_run_num == 2){		// Bubble sort
		    				result_data_nums = 25;
		    			}

		    			else if (application_run_num == 3){		// Matrix multiplication
		    				result_data_nums = 16;
		    			}

		    			else if (application_run_num == 4){		// Heap sort
		    				result_data_nums = 20;
		    			}

		    			// range check
		    			else{
		    				xil_printf("Error! Invalid application number entered!\r");
		    				xil_printf("Application number must either 1, 2, 3, or 4!\r");
		    				break;
		    			}

		    			// toggle the start command in the RTL IP to begin running Neorv32 and logging data
						StartApplicationRun();

						// manual data collection loop
				    	while(1){

				    		// read the hardware to uB signals
				    		read = ReadlogicSignals();

				    		//hardware logic to uB signals:
				    		//bit 0 = FSM 2 has new PC data in register to read (use bitmask 0x1)
				    		//bit 1 = FSM 1 and 2 are ready to run (use bitmask 0x2)
				    		//bit 2 = FSM 1 and 2 error (use bitmask 0x4)
				    		//bit 3 = FSM 1 result data in RAM is ready to read (use bitmask 0x8)
				    		//all other bits should read as zeros

				    		//uB to hardware logic signals:
				    		//bit 0 = start running application (write 0x1)
				    		//bit 1 = uB has read PC data in register (write 0x2)
				    		//bit 2 = uB has read result data in RAM (write 0x4)
				    		//bit 3 = uB reset result data in RAM (write 0x8)

				    		// just break out as this should not normally happen - print warning message!
				    		if ( (read & 0x4) == 0x4){					// hardware is in an error state
				    			xil_printf("Hardware Error! Do not use Data!\n");
				    			break;
				    		}

				    		// wait until the Neorv32 result data is available in the result data RAM
				    		else if( (read & 0x8) == 0x8){				// DUT result data ready to read in RAM

				    			// read result data and store in array
				    			ReadResultDatafromRAM();			    // reads the RAM

				    			// send the result data to the terminal
				    			for(int i=0; i<result_data_nums; i++){				// print the RAM data that has just been read
				    			xil_printf("RAM_result_data_%02d= %u\n", i, Result_Data_Read_from_Hardware_RAM[i]);
				    			}

				    			// inform the hardware that result data has been read (toggle bit)
				    			RAM_has_been_read = 1;
				    			*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x4;	// sets the result data in RAM has been read bit uB bit in hardware logic
				    			usleep(1);
				    			*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x0;	// clears the result data in RAM has been read bit uB bit in hardware logic
				    		}

				    		// the RTL IP will begin issuing the data from the FIFO buffer
				    		else if( (RAM_has_been_read == 1) && ((read & 0x1) == 0x1) ){	// RAM has been read and new PC data is available in register
					    			PC_data_read = ReadProgramCounterData();				// reads the PC AXI register
					    			IR_data_read = ReadInstructionRegisterData();			// reads the IR AXI register
					    			execute_states_data_read  = ReadExecuteStatesData();	// reads the executes states AXI register
					    			branch_taken_data_read    = ReadBranchTakenData();		// reads the branch taken AXI register
					    			mcause_data_read          = ReadMCAUSEData();			// reads the MCAUSE AXI register
									mepc_data_read            = ReadMEPCData();				// reads the mepc AXI register
									RS1_data_read		      = ReadRS1Data();      		// reads the RS1 AXI register
									alu_comp_status_data_read = ReadALUCompStatusData();	// reads the alu comparator status AXI register
									ctrl_bus_1_data_read	  = ReadCtrlBus1Data();			// reads the control bus 1 AXI register
									ctrl_bus_2_data_read	  = ReadCtrlBus2Data();			// reads the control bus 2 AXI register
									mtvec_data_read    		  = ReadMTVECData();			// reads the mtvec AXI register

									// send all RISC-V instruction data to terminal for that clock cycle
					    			xil_printf("%05d PC= %08x IR= %08x RS1= %08x Branch_taken= %01u ALU_comparator_status= %01u MEPC= %08x MCAUSE= %02u MTVEC= %08x Ctrl_bus_1= %08x Ctrl_bus_2= %08x CPU_state= %s\n", print_line_counter, PC_data_read, IR_data_read, RS1_data_read, branch_taken_data_read, alu_comp_status_data_read, mepc_data_read, mcause_data_read, mtvec_data_read, ctrl_bus_1_data_read, ctrl_bus_2_data_read, DecodeExecuteStatestoString(execute_states_data_read));

					    			// increment the terminal line count
					    			print_line_counter += 1;

					    		// inform the RTL IP that the data has been read (toggle bit)
				    			*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x2;		// sets the reg data has been read bit uB bit in hardware logic
				    			usleep(1);
				    			*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x0;		// clears the reg data has been read bit uB bit in hardware logic
				    		}

				    		// Once RTL IP back to idle state, application run is complete.
				    		else if( (read & 0x2) == 0x2){					// both FSM 1 and 2 are back in ready state i.e. finished their tasks

				    			// reset the result data RAM in RTL IP for next clear run
				    			ResetResultDatainRAM();						// reset the data in RAM back to all zeros
				    			RAM_has_been_read = 0;
				    			break;
				    		}
				    	}
			    	}
			   	}

			    break;

	    		case RUN_AUTO: 		// setup

	    			// ensure that the user has configured a valid application number

	    			if (application_run_num == 1){			// Fibonacci series
	    				result_data_nums = 45;
	    			}

	    			else if (application_run_num == 2){		// Bubble sort
	    				result_data_nums = 25;
	    			}

	    			else if (application_run_num == 3){		// Matrix multiplication
	    				result_data_nums = 16;
	    			}

	    			else if (application_run_num == 4){		// Heap sort
	    				result_data_nums = 20;
	    			}

	    			// range check
	    			else{
	    				xil_printf("Error! Invalid application number entered!\r");
	    				xil_printf("Application number must either 1, 2 or 3!\r");
	    				break;
	    			}


	    			// ensure that the user has configured valid fault types

	    			check_type_parameters = 0;

	    			if ( (auto_fault_type_1 < 0) | (auto_fault_type_1 > 3) ){			// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_2 < 0) | (auto_fault_type_2 > 3) ){		// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_3 < 0) | (auto_fault_type_3 > 3) ){		// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_4 < 0) | (auto_fault_type_4 > 3) ){		// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_5 < 0) | (auto_fault_type_5 > 3) ){		// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_6 < 0) | (auto_fault_type_6 > 3) ){		// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_7 < 0) | (auto_fault_type_7 > 3) ){		// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_8 < 0) | (auto_fault_type_8 > 3) ){		// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_9 < 0) | (auto_fault_type_9 > 3) ){		// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}
	    			else if ( (auto_fault_type_10 < 0) | (auto_fault_type_10  > 3) ){	// check that fault type parameters are between 0 and 3
	    				check_type_parameters = 1;
	    			}

	    			// ensure that the user has configured a valid number of faults per bit (between 1 and 10)

	    			check_bit_parameters = 0;

	    			if ( (auto_num_faults_per_bit <= 0) | (auto_num_faults_per_bit > 10) ){		// check that fault numbers per bit parameter is between 1 and 10
	    				check_bit_parameters = 1;
	    			}

	    			else if ( (auto_start_bit <= 0) | (auto_start_bit > 10) ){	// check that fault start bit parameter is between 1 and 10
	    				check_bit_parameters = 1;
	    			}

	    			else if ( (auto_end_bit <= 0) | (auto_end_bit > 10) ){		// check that fault end bit parameter is between 1 and 10
	    				check_bit_parameters = 1;
	    			}


	    			// otherwise, wait for the user command to start or abort auto data collection

	    			fgets(text, sizeof(text), stdin);		    // wait for user input

	    			if (strcmp(text, "m\r\n") == 0){			// trigger: key m entered
	    				FlushallRegs();							// flush all registers in case a manual run is performed next
	    				state = MAIN_MENU;				     	// next state
	    				auto_mode_selected = 0;
	    				PrintMainMenu();						// print main menu
	    			}

	    			else if (strcmp(text, "b\r\n") == 0){		// trigger: key b entered
	    				FlushallRegs();							// flush all registers in case a manual run is performed next
	    				state = MAIN_MENU;				     	// next state
	    				auto_mode_selected = 0;
	    				PrintMainMenu();						// print main menu
	    			}

	    			// if key 1 is pressed, auto run is started!
	    			else if (strcmp(text, "1\r\n") == 0){				// trigger: key 1 entered

	    				SendDatatoReg(auto_stuck_at_hold_time, 60);		// write to the stuck at hold time register
	    				CheckRegWrite(auto_stuck_at_hold_time, 60);		// check the write to the stuck at hold time register

	    				SendDatatoReg(auto_bit_flip_hold_time, 61);		// write to the application run time register
	    				CheckRegWrite(auto_bit_flip_hold_time, 61);		// check the write to the application run time register

	    				SendDatatoReg(auto_faults_enabled, 62);			// write to the application run time register
	    				CheckRegWrite(auto_faults_enabled, 62);			// check the write to the application run time register

	    				SendDatatoReg(auto_application_run_time, 63);	// write to the application run time register
	    				CheckRegWrite(auto_application_run_time, 63);	// check the write to the application run time register

				    	read = ReadDatafromReg(63);				// read the application run time register
				    	read_1 = ReadlogicSignals();    		// read the hardware to uB signals

				    	// range checks
	    				if (check_type_parameters == 1){
	    					xil_printf("Error: Auto fault type input parameters are set incorrectly\n");
	    					break;
	    				}

				    	// range checks
	    				if (check_bit_parameters == 1){
	    					xil_printf("Error: Auto fault bit number input parameters are set incorrectly\n");
	    					break;
	    				}

	    				// range checks
	    				if (read == 0){
				    		xil_printf("\n");
				    		xil_printf("Error: Application run time is set to 0!\r");
				    		xil_printf("Set a value greater than zero to run application!\n\r");
				    		break;
				    	}

	    				// range checks
				    	else if (read > 32000){
				    		xil_printf("\n");
				    		xil_printf("Error: Application run time is set greater than 32,000!\r");
				    		xil_printf("32,000 DUT data values is the number of max values allowed to write to the FIFO!\r");
				    		xil_printf("Set a value less than 32,000 to run application!\n\r");
				    		break;
				    	}

	    				// ensure RTL IP is in the ready state
				    	else if ( (read_1 & 0x2) != 0x2){
				    		xil_printf("\n");
				    		xil_printf("Error: Hardware is not in ready state! Cannot start application until hardware is ready!\r");
				    		break;
				    	}

	    				// ensure RTL IP is not in hardware state
				    	else if ( (read_1 & 0x4) == 0x4){		// hardware is in an error state
	    					xil_printf("Hardware Error! Cannot start application while hardware is in error state!\r");
	    					break;
	    				}

	    				// data collection is safe to begin!
				    	else{

				    		int auto_run_bit_counter = auto_start_bit;
				    		int auto_run_fault_counter = 1;

				    		int auto_run_fault_type_buffer = 0;
				    		int auto_run_fault_time_buffer = 0;

				    		bool auto_run_started = false;

				    		// reset the array that stores the result data from RAM for next run
			    			ResetResultDataArray();

			    			// reset the terminal line count
			    			print_line_counter = 0;

					    	while(1){

					    		if (auto_run_started == false){

					    			if (auto_run_bit_counter < 11){
					    				read_1 = ReadDatafromReg(63);						// read the application run time register
					    				xil_printf("Application Run Time = %d\n", read_1);	// print the application run time register

					    				xil_printf("Bit %d Fault %d\n", auto_run_bit_counter, auto_run_fault_counter);	// print the bit fault info

					    				read_1 = ReadDatafromReg(62);						// read the fault injection enable register
					    				xil_printf("Fault Injection Enabled = %s\n", Fault_Inj_Reg_Value_Strings[read_1]);	// print the fault injection enable register string
								    }

					    			flush_bits_regs_flag = FlushallBitsRegs();

					    			// sanity check
					    			if (flush_bits_regs_flag == 1){
					    				xil_printf("Error Flushing Registers Between Application Runs!\n");
					    				xil_printf("Auto Data Gathering failed!\n");
					    				break;
					    			}

					    			// initialise the fault setup buffers
						    		if (auto_run_fault_counter == 1){
						    			auto_run_fault_type_buffer = auto_fault_type_1;
						    			auto_run_fault_time_buffer = auto_fault_time_1;
						    		}

						    		if (auto_run_fault_counter == 2){
						    			auto_run_fault_type_buffer = auto_fault_type_2;
						    			auto_run_fault_time_buffer = auto_fault_time_2;
						    		}

						    		if (auto_run_fault_counter == 3){
						    			auto_run_fault_type_buffer = auto_fault_type_3;
						    			auto_run_fault_time_buffer = auto_fault_time_3;
						    		}

						    		if (auto_run_fault_counter == 4){
						    			auto_run_fault_type_buffer = auto_fault_type_4;
						    			auto_run_fault_time_buffer = auto_fault_time_4;
						    		}

						    		if (auto_run_fault_counter == 5){
						    			auto_run_fault_type_buffer = auto_fault_type_5;
						    			auto_run_fault_time_buffer = auto_fault_time_5;
						    		}

						    		if (auto_run_fault_counter == 6){
						    			auto_run_fault_type_buffer = auto_fault_type_6;
						    			auto_run_fault_time_buffer = auto_fault_time_6;
						    		}

						    		if (auto_run_fault_counter == 7){
						    			auto_run_fault_type_buffer = auto_fault_type_7;
						    			auto_run_fault_time_buffer = auto_fault_time_7;
						    		}

						    		if (auto_run_fault_counter == 8){
						    			auto_run_fault_type_buffer = auto_fault_type_8;
						    			auto_run_fault_time_buffer = auto_fault_time_8;
						    		}

						    		if (auto_run_fault_counter == 9){
						    			auto_run_fault_type_buffer = auto_fault_type_9;
						    			auto_run_fault_time_buffer = auto_fault_time_9;
						    		}

						    		if (auto_run_fault_counter == 10){
						    			auto_run_fault_type_buffer = auto_fault_type_10;
						    			auto_run_fault_time_buffer = auto_fault_time_10;
						    		}

						    		if (auto_run_bit_counter == 1){
										SendDatatoReg(auto_run_fault_type_buffer, 30);		// write to bit 1 fault type register
										CheckRegWrite(auto_run_fault_type_buffer, 30);		// check the write to bit 1 fault type register
										SendDatatoReg(auto_run_fault_time_buffer, 0);		// write to bit 1 fault time register
										CheckRegWrite(auto_run_fault_time_buffer, 0);		// check the write to bit 1 fault time register
										StartApplicationRun();
										auto_run_started = true;
					    			}

					    			if (auto_run_bit_counter == 2){
					    				SendDatatoReg(auto_run_fault_type_buffer, 33);		// write to bit 2 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 33);		// check the write to bit 2 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 3);		// write to bit 2 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 3);		// check the write to bit 2 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		if (auto_run_bit_counter == 3){
					    				SendDatatoReg(auto_run_fault_type_buffer, 36);		// write to bit 3 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 36);		// check the write to bit 3 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 6);		// write to bit 3 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 6);		// check the write to bit 3 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		if (auto_run_bit_counter == 4){
					    				SendDatatoReg(auto_run_fault_type_buffer, 39);		// write to bit 4 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 39);		// check the write to bit 4 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 9);		// write to bit 4 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 9);		// check the write to bit 4 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		if (auto_run_bit_counter == 5){
					    				SendDatatoReg(auto_run_fault_type_buffer, 42);		// write to bit 5 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 42);		// check the write to bit 5 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 12);		// write to bit 5 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 12);		// check the write to bit 5 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		if (auto_run_bit_counter == 6){
					    				SendDatatoReg(auto_run_fault_type_buffer, 45);		// write to bit 6 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 45);		// check the write to bit 6 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 15);		// write to bit 6 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 15);		// check the write to bit 6 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		if (auto_run_bit_counter == 7){
					    				SendDatatoReg(auto_run_fault_type_buffer, 48);		// write to bit 7 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 48);		// check the write to bit 7 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 18);		// write to bit 7 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 18);		// check the write to bit 7 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		if (auto_run_bit_counter == 8){
					    				SendDatatoReg(auto_run_fault_type_buffer, 51);		// write to bit 8 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 51);		// check the write to bit 8 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 21);		// write to bit 8 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 21);		// check the write to bit 8 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		if (auto_run_bit_counter == 9){
					    				SendDatatoReg(auto_run_fault_type_buffer, 54);		// write to bit 9 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 54);		// check the write to bit 9 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 24);		// write to bit 9 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 24);		// check the write to bit 9 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		if (auto_run_bit_counter == 10){
					    				SendDatatoReg(auto_run_fault_type_buffer, 57);		// write to bit 10 fault type register
					    				CheckRegWrite(auto_run_fault_type_buffer, 57);		// check the write to bit 10 fault type register
					    				SendDatatoReg(auto_run_fault_time_buffer, 27);		// write to bit 10 fault time register
					    				CheckRegWrite(auto_run_fault_time_buffer, 27);		// check the write to bit 10 fault time register
					    				StartApplicationRun();
					    				auto_run_started = true;
						    		}

						    		else if (auto_run_bit_counter == 11){

						    			flush_bits_regs_flag = FlushallBitsRegs();

						    			if (flush_bits_regs_flag == 1){
						    				xil_printf("Error Flushing Registers Between Application Runs!\n");
						    				xil_printf("Auto Data Gathering failed!\n");
						    				break;
						    			}

						    			xil_printf("End of Dataset!\n");
						    			break;
						    		}

						    		xil_printf("Fault Type = %s\n", Type_Reg_Value_Strings[auto_run_fault_type_buffer]);	//print the fault type for this run

						    		if ( (auto_run_fault_type_buffer == 1) | (auto_run_fault_type_buffer == 2) ){
						    			xil_printf("Fault Hold Time = %d\n", auto_stuck_at_hold_time);	//print the stuck at hold time for this run
						    		}

						    		else if (auto_run_fault_type_buffer == 3){
						    			xil_printf("Fault Hold Time = %d\n", auto_bit_flip_hold_time);	//print the bit hold time for this run (not used anymore)
						    		}

						    		xil_printf("Fault Start Time = %d\n", auto_run_fault_time_buffer);		//print the fault start time for this run
					    		}

					    		read = ReadlogicSignals();			// read the hardware to uB signal

					    		//hardware logic to uB signals:
					    		//bit 0 = FSM 2 has new PC data in register to read (use bitmask 0x1)
					    		//bit 1 = FSM 1 and 2 are ready to run (use bitmask 0x2)
					    		//bit 2 = FSM 1 and 2 error (use bitmask 0x4)
					    		//bit 3 = FSM 1 result data in RAM is ready to read (use bitmask 0x8)
					    		//all other bits should read as zeros

					    		//uB to hardware logic signals:
					    		//bit 0 = start running application (write 0x1)
					    		//bit 1 = uB has read PC data in register (write 0x2)
					    		//bit 2 = uB has read result data in RAM (write 0x4)
					    		//bit 3 = uB reset result data in RAM (write 0x8)

					    		if ( (read & 0x4) == 0x4){					// hardware is in an error state
					    			xil_printf("Hardware Error! Data Gathering Aborted!\n");
					    			break;
					    		}

					    		else if( (read & 0x8) == 0x8){				// DUT result data ready to read in RAM

					    			ReadResultDatafromRAM();				// read result data from RAM

					    			for(int i=0; i<result_data_nums; i++){	// print the RAM data on one line that has just been read
					    				xil_printf("RAM_result_data_%02d= %u\n", i, Result_Data_Read_from_Hardware_RAM[i]);
					    			}

					    			RAM_has_been_read = 1;
					    			*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x4;	// sets the result data in RAM has been read bit uB bit in hardware logic
					    			usleep(1);
					    			*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x0;	// clears the result data in RAM has been read bit uB bit in hardware logic
					    		}

					    		// the RTL IP will begin issuing the data from the FIFO buffer
					    		else if( (RAM_has_been_read == 1) && ((read & 0x1) == 0x1) ){	// RAM has been read and new data is available in register
					    			PC_data_read = ReadProgramCounterData();				// reads the PC AXI register
					    			IR_data_read = ReadInstructionRegisterData();			// reads the IR AXI register
					    			execute_states_data_read  = ReadExecuteStatesData();	// reads the executes states AXI register
					    			branch_taken_data_read    = ReadBranchTakenData();		// reads the branch taken AXI register
					    			mcause_data_read          = ReadMCAUSEData();			// reads the MCAUSE AXI register
					    			mepc_data_read            = ReadMEPCData();				// reads the mepc AXI register
					    			RS1_data_read		      = ReadRS1Data();      		// reads the RS1 AXI register
					    			alu_comp_status_data_read = ReadALUCompStatusData();	// reads the alu comparator status AXI register
					    			ctrl_bus_1_data_read	  = ReadCtrlBus1Data();			// reads the control bus 1 AXI register
					    			ctrl_bus_2_data_read	  = ReadCtrlBus2Data();			// reads the control bus 2 AXI register
									mtvec_data_read    		  = ReadMTVECData();			// reads the mtvec AXI register

									// send all RISC-V instruction data to terminal for that clock cycle
					    			xil_printf("%05d PC= %08x IR= %08x RS1= %08x Branch_taken= %01u ALU_comparator_status= %01u MEPC= %08x MCAUSE= %02u MTVEC= %08x Ctrl_bus_1= %08x Ctrl_bus_2= %08x CPU_state= %s\n", print_line_counter, PC_data_read, IR_data_read, RS1_data_read, branch_taken_data_read, alu_comp_status_data_read, mepc_data_read, mcause_data_read, mtvec_data_read, ctrl_bus_1_data_read, ctrl_bus_2_data_read, DecodeExecuteStatestoString(execute_states_data_read));

									print_line_counter += 1;

					    			*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x2;		// sets the reg data has been read bit uB bit in hardware logic
					    			usleep(1);
					    			*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x0;		// clears the reg data has been read bit uB bit in hardware logic
					    		}

					    		else if( (read & 0x2) == 0x2){					// both FSM 1 and 2 are back in ready state i.e. finished their tasks

					    			ResetResultDatainRAM();						// reset the data in RAM back to all zeros
					    			ResetResultDataArray();						// reset the array that stores the result data from RAM for next run

					    			RAM_has_been_read = 0;


					    			if (auto_run_fault_counter == auto_num_faults_per_bit){
					    				auto_run_fault_counter = 1;

					    				if (auto_run_bit_counter == auto_end_bit){
					    					auto_run_bit_counter = 11;
					    				}
					    				else{
					    					if(auto_start_bit < auto_end_bit){
					    						auto_run_bit_counter += 1;
					    					}
					    					else{
					    						auto_run_bit_counter -= 1;
					    					}
					    				}

					    			}
					    			else{
					    				auto_run_fault_counter += 1;
					    			}

					    			auto_run_started = false;
					    		}
					    	}
				    	}
	    			}
	    			break;

	}
}

	// clean up platform resources (never reached)
    cleanup_platform();
    return 0;
}


///	FUNCTION BODIES


int UartLiteSelfTestExample(u16 DeviceId)
{
	int Status;

	// Initialise the UartLite driver so that it is ready to use.
	Status = XUartLite_Initialize(&UartLite, DeviceId);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	 // Perform a self-test to ensure that the hardware was built correctly.
	Status = XUartLite_SelfTest(&UartLite);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


void PrintMainMenu()
{
	//MAIN MENU
	xil_printf("--------------------------------\n\r");
	xil_printf("          Current Page:\r");
	xil_printf("            Main Menu\n\r");
	xil_printf("--------------------------------\n\r");
	xil_printf("\n");
	xil_printf("Options: 1 - Setup Individual Registers\r");
	xil_printf("         2 - Flush all Setup Registers\r");
	xil_printf("         3 - Show any Active Faults\r");
	xil_printf("         4 - Status of Registers\r");
	xil_printf("         5 - Test Setup Registers\r");
	xil_printf("         6 - Spare (Not Used)\r");
	xil_printf("         7 - Manual Run Application\r");
	xil_printf("         8 - Auto Run Application\r");
	xil_printf("\n");
}


void PrintSetupMenu()
{
	//SETUP
    xil_printf("--------------------------------\n\r");
    xil_printf("         Current Page:\r");
    xil_printf("   Setup Individual Registers\n\r");
    xil_printf("--------------------------------\n\r");
   	xil_printf("\n");
   	xil_printf("Options: m -  Main Menu\r");
   	xil_printf("         b -  Back to Main Menu\r");
   	xil_printf("         0  - Flush Bits Registers\r");
   	xil_printf("         1 -  Bit 1\r");
   	xil_printf("         2 -  Bit 2\r");
    xil_printf("         3 -  Bit 3\r");
   	xil_printf("         4 -  Bit 4\r");
   	xil_printf("         5 -  Bit 5\r");
   	xil_printf("         6 -  Bit 6\r");
   	xil_printf("         7 -  Bit 7\r");
    xil_printf("         8 -  Bit 8\r");
   	xil_printf("         9 -  Bit 9\r");
   	xil_printf("         10 - Bit 10\r");
   	xil_printf("         11 - Stuck at Hold Time\r");
   	xil_printf("         12 - Bit Flip Hold Time\r");
   	xil_printf("         13 - Enable Fault Injection\r");
   	xil_printf("         14 - Application Run Time\r");
   	xil_printf("\n");
}


void PrintFlushMenu()
{
	//FLUSH
    xil_printf("--------------------------------\n\r");
   	xil_printf("         Current Page:\r");
   	xil_printf("      Flush Setup Registers\n\r");
   	xil_printf("--------------------------------\n\r");
   	xil_printf("Enter a Register Index:\n\r");
    xil_printf("Options: m - Main Menu\n\r");
   	xil_printf("         b - Back to Main Menu\r");
   	xil_printf("         1 - Flush all Registers\n\r");
   	xil_printf("\n");
}


void PrintShowMenu()
{
	//SHOW
    xil_printf("--------------------------------\n\r");
    xil_printf("         Current Page:\r");
    xil_printf("       Show Active Faults\n\r");
    xil_printf("--------------------------------\n\r");
    xil_printf("Options: m - Main Menu\r");
    xil_printf("         b - Back to Main Menu\r");
    xil_printf("         1 - Show any Active Faults\n\r");
    xil_printf("\n");
}


void PrintStatusMenu()
{
	//STATUS
    xil_printf("--------------------------------\n\r");
    xil_printf("         Current Page:\r");
    xil_printf("        Parameters Status\n\r");
    xil_printf("--------------------------------\n\r");
    xil_printf("Options: m  - Main Menu\r");
    xil_printf("         b  - Back to Main Menu\r");
    xil_printf("         a  - Read all Registers\r");
    xil_printf("         t  - Read Test Setup Registers\r");
    xil_printf("         1  - Read Bit 1  Registers\r");
    xil_printf("         2  - Read Bit 2  Registers\r");
    xil_printf("         3  - Read Bit 3  Registers\r");
    xil_printf("         4  - Read Bit 4  Registers\r");
    xil_printf("         5  - Read Bit 5  Registers\r");
    xil_printf("         6  - Read Bit 6  Registers\r");
    xil_printf("         7  - Read Bit 7  Registers\r");
    xil_printf("         8  - Read Bit 8  Registers\r");
    xil_printf("         9  - Read Bit 9  Registers\r");
    xil_printf("         10 - Read Bit 10 Registers\n\r");
   	xil_printf("\n");
}


void PrintTestMenu(){
	//TEST
    xil_printf("--------------------------------\n\r");
   	xil_printf("         Current Page:\r");
   	xil_printf("             Test\n\r");
   	xil_printf("--------------------------------\n\r");
   	xil_printf("This tests the design by writing a random value to each register,\n");
    xil_printf("and then comparing each value by reading back\n\r");
   	xil_printf("Options: m - Main Menu\r");
   	xil_printf("         b - Back to Main Menu\r");
   	xil_printf("         1 - Run Test\n\r");
   	xil_printf("\n");
}


void PrintRunMenu()
{
	//RUN
	int temp = 0;
	temp = ReadlogicSignals();

    xil_printf("--------------------------------\n\r");
    xil_printf("         Current Page:\r");
    xil_printf("    Manual Run Application\n\r");
    xil_printf("--------------------------------\n\r");

    xil_printf("Hardware Conditions:\n\r");

    if (temp == 2){
    	xil_printf("Hardware Status: Ready\r");
    }
    else{
    	xil_printf("Hardware Status: Not Ready!\r");
    }

    if (temp == 4){
    	xil_printf("Hardware Error Status: Error!\n\r");
    }
    else{
    	xil_printf("Hardware Error Status: No Error\n\r");
    }

    if (temp == 1){
    	xil_printf("New Data in Reg: Yes\n\r");
    }
    else{
    	xil_printf("New Data in Reg: No\n\r");
    }

    xil_printf("\n\r");
    xil_printf("Application Run Conditions:\n\r");
    ReadTestRegs();
    ShowActiveFaults();

    xil_printf("Options: m - Main Menu\r");
   	xil_printf("         b - Back to Main Menu\r");
   	xil_printf("         1 - Run Application and Log Data\n\r");
   	xil_printf("\n");
   	xil_printf("Before starting application run, clear the terminal screen and start capturing it to a file!\r");
   	xil_printf("After dataset has been printed, be sure to stop capturing terminal screen to file to save it!\n\r");
   	xil_printf("\n");
}


void PrintRunAutoMenu()
{
    xil_printf("--------------------------------\n\r");
    xil_printf("         Current Page:\r");
    xil_printf("     Auto Run Application\n\r");
    xil_printf("--------------------------------\n\r");

    xil_printf("Options: m - Main Menu\r");
    xil_printf("         b - Back to Main Menu\r");
    xil_printf("         1 - Start Auto Data Gathering\n\r");
}


void PrintSetupBitsMenu(u8 bit_index)
{
	//SETUP - BITS 1 TO 10
	xil_printf("--------------------------------\n\r");
	xil_printf("         Current Page:\r");
	xil_printf("         Setup - Bit %d \n\r", bit_index);
	xil_printf("--------------------------------\n\r");
	xil_printf("Options: m - Main Menu\r");
	xil_printf("         b - Back to Setup Individual Registers\r");
	xil_printf("         1 - Fault 1 Type\r");
	xil_printf("         2 - Fault 2 Type\r");
	xil_printf("         3 - Fault 3 Type\r");
	xil_printf("         4 - Fault 1 Time\r");
	xil_printf("         5 - Fault 2 Time\r");
	xil_printf("         6 - Fault 3 Time\r");
	xil_printf("\n");
}


void PrintStuckatHoldTimeMenu()
{
	//SETUP - STUCK AT HOLD TIME
    xil_printf("--------------------------------\n\r");
    xil_printf("         Current Page:\r");
    xil_printf("    Setup - Stuck at Hold Time\n\r");
   	xil_printf("--------------------------------\n\r");
   	xil_printf("\n");
   	xil_printf("Enter a Time:\n");
    xil_printf("\n");
   	xil_printf("Options: m - Main Menu\r");
   	xil_printf("         b - Back to Setup Individual Registers\r");
   	xil_printf("\n");
}


void PrintBitFlipHoldTimeMenu()
{
	//SETUP - BIT FLIP HOLD TIME
    xil_printf("--------------------------------\n\r");
   	xil_printf("         Current Page:\r");
   	xil_printf("    Setup - Bit Flip Hold Time\n\r");
   	xil_printf("--------------------------------\n\r");
   	xil_printf("\n");
    xil_printf("Enter a Time:\n");
   	xil_printf("\n");
   	xil_printf("Options: m - Main Menu\n\r");
   	xil_printf("         b - Back to Setup Individual Registers\r");
    xil_printf("\n");
}


void PrintFaultInjEnMenu()
{
	//SETUP - ENABLE FAULT INJECTION
    xil_printf("--------------------------------\n\r");
   	xil_printf("         Current Page:\r");
   	xil_printf(" Setup - Enable Fault Injection\n\r");
   	xil_printf("--------------------------------\n\r");
   	xil_printf("\n");
    xil_printf("Enable/Disable Fault Injection:\n");
   	xil_printf("\n");
   	xil_printf("Options: m - Main Menu\r");
   	xil_printf("         b - Back to Setup Individual Registers\r");
   	xil_printf("         0 - Disable Fault Injection\r");
   	xil_printf("         1 - Enable Fault Injection\r");
   	xil_printf("\n");
}


void PrintTypeMenu(u8 bit_index, u8 fault_index)
{
	//SETUP - FAULT TYPES
    xil_printf("--------------------------------\n\r");
    xil_printf("         Current Page:\r");
    xil_printf("    Setup - Fault %d Type\n\r", fault_index);
    xil_printf("--------------------------------\n\r");
    xil_printf("\n");
    xil_printf("Select which fault type:\n");
    xil_printf("\n");
    xil_printf("Options: m - Main Menu\r");
    xil_printf("Options: b - Back to Setup - Bit %d\r", bit_index);
    xil_printf("         0 - No Fault\r");
   	xil_printf("         1 - Stuck at Zero\r");
   	xil_printf("         2 - Stuck at One\r");
   	xil_printf("         3 - Bit Flip\r");
   	xil_printf("\n");
}


void PrintTimeMenu(u8 bit_index, u8 fault_index)
{
	//SETUP - FAULT TIMES
    xil_printf("--------------------------------\n\r");
   	xil_printf("         Current Page:\r");
   	xil_printf("    Setup - Fault %d Time\n\r", fault_index);
   	xil_printf("--------------------------------\n\r");
   	xil_printf("\n");
   	xil_printf("Enter a fault Time:\n");
   	xil_printf("\n");
   	xil_printf("Options: m - Main Menu\r");
   	xil_printf("Options: b - Back to Setup - Bit %d\r", bit_index);
   	xil_printf("\n");
}


void PrintRunTimeMenu()
{
	//SETUP - RUN TIME
    xil_printf("--------------------------------\n\r");
   	xil_printf("         Current Page:\r");
   	xil_printf("  Setup - Application Run Time\n\r");
   	xil_printf("--------------------------------\n\r");
   	xil_printf("\n");
   	xil_printf("Enter a Time:\n");
   	xil_printf("\n");
   	xil_printf("Options: m - Main Menu\r");
   	xil_printf("Options: b - Back to Setup\r");
   	xil_printf("\n");
}


void PrintSpareMenu()
{
	//RESULT DATA REGISTERS
    xil_printf("--------------------------------\n\r");
    xil_printf("         Current Page:\r");
    xil_printf("            Spare\n\r");
    xil_printf("--------------------------------\n\r");
    xil_printf("Options: m - Main Menu\r");
   	xil_printf("         b - Back to Main Menu\n\r");
   	xil_printf("\n");
}


void SendDatatoReg(int data, int address)
{
	u32 GPIO_out_temp = 0;
	GPIO_out_temp = address;
	GPIO_out_temp = (GPIO_out_temp << 16);
	GPIO_out_temp |= (0xffff & data);
	GPIO_out_temp = GPIO_out_temp | 0x400000;
	*AXI_REG_O_WRITE_TO_SETUP_REGS = GPIO_out_temp;
	usleep(100);
	GPIO_out_temp = GPIO_out_temp & 0x3FFFFF;
	*AXI_REG_O_WRITE_TO_SETUP_REGS = GPIO_out_temp;
}


u32 ReadDatafromReg(int address)
{
	u32 temp = 0;
	temp = address;
	temp = (temp << 16);
	*AXI_REG_O_WRITE_TO_SETUP_REGS = temp;
	usleep(100);
	temp = *AXI_REG_1_READ_FROM_SETUP_REGS;
	return temp;
}


void ReadResultDatafromRAM()
{
	for (int i=0; i<64; i++){
		u32 temp = 0;
		temp = i;
		temp = (temp << 16);
		*AXI_REG_O_WRITE_TO_SETUP_REGS = temp;
		usleep(1);
		Result_Data_Read_from_Hardware_RAM[i] = *AXI_REG_4_READ_RESULT_DATA;
	}
}


void ResetResultDatainRAM()
{
	bool zero_flag = false;

	*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x8;	// sets the reset the result data in RAM bit in hardware logic
	usleep(1);
	*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x0;	// clears the reset the result data in RAM bit in hardware logic

	zero_flag = CheckResultDatainRAMisZero();

	if (zero_flag == 1){
		xil_printf("Error! RAM is non all zeros after reset!\n");
	}
}


bool CheckResultDatainRAMisZero()
{
	bool zero_flag = false;

	for (int i=0; i<64; i++){
		u32 temp = 0;
		temp = i;
		temp = (temp << 16);
		*AXI_REG_O_WRITE_TO_SETUP_REGS = temp;
		usleep(1);
		temp = *AXI_REG_4_READ_RESULT_DATA;

		if (temp != 0){
			zero_flag = 1;
			break;
		}
	}
	return zero_flag;
}


void ReadAllRegs()
{
	u32 temp1 = 0;
	u32 temp2 = 0;
	u8 loop;

	temp1 = ReadDatafromReg(63);
	xil_printf("%s : %d\n", Reg_Index_Names_Strings[63], temp1);

	temp1 = ReadDatafromReg(62);
	xil_printf("%s : %s\n", Reg_Index_Names_Strings[62], Fault_Inj_Reg_Value_Strings[temp1]);
	xil_printf("\n");

	temp1 = ReadDatafromReg(60);
	xil_printf("%s : %d\n", Reg_Index_Names_Strings[60], temp1);

	temp1 = ReadDatafromReg(61);
	xil_printf("%s : %d\n", Reg_Index_Names_Strings[61], temp1);

	xil_printf("\n");

	temp1 = 0;

	for(loop=0; loop<30; loop++){

		temp1 = ReadDatafromReg(loop + 30);
		temp2 = ReadDatafromReg(loop);

		xil_printf("%s : %s  ", Reg_Index_Names_Strings[loop + 30], Type_Reg_Value_Strings[temp1]);
		xil_printf("   %s : %d\n", Reg_Index_Names_Strings[loop], temp2);

		usleep(50000);

	}
	xil_printf("\n");
}


void CheckRegWrite(int data, int address)
{
	u32 temp = 0;
	temp = ReadDatafromReg(address);

	if(data != temp){
		xil_printf("Error writing to register! Data read doesn't match data written!\n");
		xil_printf("Troubleshooting required!\n");
	}

	else if(auto_mode_selected == 0){
		xil_printf("Write Successful!\n");
	}
}


void FlushallRegs()
{
	u8 flush_loop;
	u32 out_temp = 0;
	u8 check_loop;
	u32 check;
	bool flag = 0;

	for(flush_loop=0; flush_loop<64; flush_loop++){
		out_temp = (flush_loop << 16);
		out_temp |= (0xffff & 0);
		out_temp = out_temp | 0x400000;
		*AXI_REG_O_WRITE_TO_SETUP_REGS = out_temp;
		usleep(100);
		out_temp = out_temp & 0x3FFFFF;
		*AXI_REG_O_WRITE_TO_SETUP_REGS = out_temp;
	}

	for(check_loop=0; check_loop<64; check_loop++){
		check = ReadDatafromReg(check_loop);
		if(check != 0){
			flag = 1;
			xil_printf("Error Flushing Registers!\n");
		}
	}

	if(flag == 0){
		xil_printf("Register Flush Complete!\n");
		xil_printf("\n");
	}
}


bool FlushallBitsRegs()
{
	u32 out_temp = 0;
	u8 check_loop;
	u32 check;
	bool flag = 0;

	for(u8 flush_loop=0; flush_loop<60; flush_loop++){
		out_temp = (flush_loop << 16);
		out_temp |= (0xffff & 0);
		out_temp = out_temp | 0x400000;
		*AXI_REG_O_WRITE_TO_SETUP_REGS = out_temp;
		usleep(100);
		out_temp = out_temp & 0x3FFFFF;
		*AXI_REG_O_WRITE_TO_SETUP_REGS = out_temp;
	}

	for(check_loop=0; check_loop<60; check_loop++){
		check = ReadDatafromReg(check_loop);
		if(check != 0){
			flag = 1;
			xil_printf("Error Flushing Registers!\n");
		}
	}

return flag;

}


void TestDesign()
{
	int loop_addr;
	int rand_data;
	int rand_data_store[62] = {0};
	int read;
	bool check_flag = 0;

	// random value write loop
	for(loop_addr=0; loop_addr<64; loop_addr++){

		// if else statements ensures to write the correct size random values to the next register in loop
		if (loop_addr < 30){
			rand_data = rand() % 65535;
		}
		else if ( (loop_addr >= 30) && (loop_addr < 60) ){
			rand_data = rand() % 4;
		}
		else if (loop_addr == 60){
			rand_data = rand() % 65535;
		}
		else if (loop_addr == 61){
			rand_data = rand() % 32;
		}
		else if (loop_addr == 63){
			rand_data = rand() % 65535;
		}
		else{
			rand_data = rand() % 2;
		}

	rand_data_store[loop_addr] = rand_data;
	SendDatatoReg(rand_data_store[loop_addr], loop_addr);
	}

	// test loop
	for(loop_addr=0; loop_addr<63; loop_addr++){
		read = ReadDatafromReg(loop_addr);

		if(read != rand_data_store[loop_addr]){
			check_flag = 1;
			break;
		}
	}
	if(check_flag == 1){
		xil_printf("Test Design Failed!\n");
	}
	else{
		xil_printf("Test Design Successful!\n");
	}
}


int GetAddressDecode(u8 reg_index, u8 fault_index, bool type_or_time_flag){

	int type_temp = 30;
	int time_temp = 0;
	int address_out = 0;

	int reg_index_loop;
	int fault_num_loop;

	if (reg_index == 0 || reg_index > 14){
		xil_printf("GetAddressDecode function error return : reg_index is out of range!\n");
		xil_printf("GetAddressDecode function error return : reg_index causing error is : %d\n", reg_index);
	}

	else if (fault_index == 0 || fault_index > 3){
		xil_printf("GetAddressDecode function error return : fault_index input is out of range!\n");
		xil_printf("GetAddressDecode function error return : fault_index causing error is : %d\n", fault_index);
	}

	else{

		if (reg_index == 11){
			address_out = 60;
		}

		else if (reg_index == 12){
			address_out = 61;
		}

		else if (reg_index == 13){
			address_out = 62;
		}

		else if (reg_index == 14){
			address_out = 63;
		}

		else{

			for (reg_index_loop=1; reg_index_loop<11; reg_index_loop++){

				if (reg_index == reg_index_loop){

					if (reg_index_loop == 1){
						time_temp = time_temp;
						type_temp = type_temp;
						break;
					}

						else{
							time_temp += 3 * (reg_index_loop - 1);
							type_temp += 3 * (reg_index_loop - 1);
							break;
							}
				}
			}

			for (fault_num_loop=1; fault_num_loop<4; fault_num_loop++){

				if (fault_index == fault_num_loop){
					time_temp = (time_temp + fault_num_loop) - 1;
					type_temp = (type_temp + fault_num_loop) - 1;
					break;
				}
			}

				if (type_or_time_flag == 0){
					address_out = type_temp;
				}

				else if (type_or_time_flag == 1){
					address_out = time_temp;
				}
			}
	}
		// IT OK TO STILL RETURN ADDRESS OUT WHICH WILL BE ZERO WHICH IS A VALID ADDRESS? IS A PRINT ERROR MESSAGE ENOUGH OR SHOULD THE CODE
	   ///////////////////  BLOCK SOMETHING ELSE OR RETURN AN ERROR THAT CAN BE USED TO NOT DO A WRITE?
	return address_out;
}


void ShowActiveFaults()
{
	u32 temp1 = 0;
	u32 temp2 = 0;
	u8 loop;
	bool any_faults_flag = 0;

	for(loop=0; loop<30; loop++){

		temp1 = ReadDatafromReg(loop + 30);
		temp2 = ReadDatafromReg(loop);

		if (temp1 != 0 || temp2 != 0){
		xil_printf("%s : %s  ", Reg_Index_Names_Strings[loop + 30], Type_Reg_Value_Strings[temp1]);
		xil_printf("   %s : %d\n", Reg_Index_Names_Strings[loop], temp2);
		any_faults_flag = 1;
		}

		usleep(5000);
	}
	xil_printf("\n");

	if (any_faults_flag == 0){
		xil_printf("No Faults Active\n");
		xil_printf("\n");
	}
}


void ReadTestRegs()
{
	u32 temp = 0;

	temp = ReadDatafromReg(63);
	xil_printf("%s : %d\n", Reg_Index_Names_Strings[63], temp);

	temp = ReadDatafromReg(62);
	xil_printf("%s : %s\n", Reg_Index_Names_Strings[62], Fault_Inj_Reg_Value_Strings[temp]);
	xil_printf("\n");

	temp = ReadDatafromReg(60);
	xil_printf("%s : %d\n", Reg_Index_Names_Strings[60], temp);

	temp = ReadDatafromReg(61);
	xil_printf("%s : %d\n", Reg_Index_Names_Strings[61], temp);

	xil_printf("\n");
}


void ReadBitsRegs(u8 bit_num)
{
	u32 temp1 = 0;
	u32 temp2 = 0;
	u8 loop;

	int offset = (bit_num - 1) * 3;

	for(loop=0; loop<3; loop++){
		temp1 = ReadDatafromReg(loop + 30 + offset);
		temp2 = ReadDatafromReg(loop + offset);
		xil_printf("%s : %s   ", Reg_Index_Names_Strings[(loop + 30) + offset], Type_Reg_Value_Strings[temp1]);
		xil_printf("   %s : %d\n", Reg_Index_Names_Strings[loop + offset], temp2);
	}
	xil_printf("\n");
}


int ReadlogicSignals()
{
	int temp = 0;
	temp = *AXI_REG_3_LOGIC_TO_UB_SIGNALS;
	return temp;
}


int ReadProgramCounterData()
{
	int temp = 0;
	temp = *AXI_REG_5_READ_PC_DATA;
	return temp;
}


int ReadInstructionRegisterData()
{
	int temp = 0;
	temp = *AXI_REG_6_READ_IR_DATA;
	return temp;
}


int ReadExecuteStatesData()
{
	int temp = 0;
	temp = *AXI_REG_7_READ_EXECUTE_STATES_DATA;
	return temp;
}


int ReadBranchTakenData()
{
	int temp = 0;
	temp = *AXI_REG_8_READ_BRANCH_TAKEN_DATA;
	return temp;
}


int ReadMCAUSEData()
{
	int temp = 0;
	temp = *AXI_REG_9_READ_MCAUSE_DATA;
	return temp;
}


int ReadMEPCData()
{
	int temp = 0;
	temp = *AXI_REG_10_READ_MEPC_DATA;
	return temp;
}


int ReadRS1Data()
{
	int temp = 0;
	temp = *AXI_REG_11_READ_RS1_DATA;
	return temp;
}


int ReadALUCompStatusData()
{
	int temp = 0;
	temp = *AXI_REG_12_READ_ALU_CMP_STATUS_DATA;
	return temp;
}


int ReadCtrlBus1Data()
{
	int temp = 0;
	temp = *AXI_REG_13_READ_CTRL_BUS_1_DATA;
	return temp;
}


int ReadCtrlBus2Data()
{
	int temp = 0;
	temp = *AXI_REG_14_READ_CTRL_BUS_2_DATA;
	return temp;
}


int ReadMTVECData()
{
	int temp = 0;
	temp = *AXI_REG_15_MTVEC_DATA;
	return temp;
}


void StartApplicationRun()
{
	*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x1;	// sends start command bit in hardware logic
	usleep(1);
	*AXI_REG_2_UB_TO_LOGIC_SIGNALS = 0x0;	// clears start command bit in hardware logic
}


void ResetResultDataArray()
{
	for (int i=0; i<64; i++){
		Result_Data_Read_from_Hardware_RAM[i] = 0;
	}
}


const char* DecodeExecuteStatestoString(int array_index)
{
	return Execute_States_Decode_Strings[array_index];
}


