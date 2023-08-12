/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xgpio_l.h"
#include "xil_printf.h"

/************************** Constant Definitions *****************************/

#define DELAY_MAX_VALUE	 100


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/


/************************** Variable Definitions *****************************/


/*****************************************************************************/
/**
* @main for AT24C256 test
*
* @return	Always 0
*
* @note
* The main function is returning an integer to prevent compiler warnings.
*
******************************************************************************/
int main(void)
{
	u32 Data, Addr=0u, Value=0x11;
	volatile int Delay;


	while (1) {

		Xil_Out32(XPAR_AXI_LITE_SLV_0_BASEADDR + Addr, Value);

		for (Delay = 0; Delay < DELAY_MAX_VALUE; Delay++);

		Data = Xil_In32(XPAR_AXI_LITE_SLV_0_BASEADDR + Addr);

		Addr += 4;
		Value++;

		for (Delay = 0; Delay < DELAY_MAX_VALUE; Delay++);
	}

}

