/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xparameters_ps.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xscugic.h"

//#include <stdio.h>
//#include "platform.h"
//#include "xil_printf.h"

static int glb_s2mm_done = 0;
static int glb_mm2s_done = 0;
static int glb_rtl_irq = 0;
//XAxiDma myDma;
XScuGic IntcInst;

static void s2mm_isr(void* CallbackRef);
static void mm2s_isr(void* CallbackRef);
static void rtl_isr(void* CallbackRef);

int main()
{
    init_platform();
    print("Hello World\n\r");

    const int LEN = 10;
    u32 a[LEN];
    u32 b[LEN];
    u32 status;

    for (u32 i = 0; i<LEN; i ++){
    	a[i] = i+10;
    }

    xil_printf("Hello dma!\n");

    // Step 1: init DMA, without interrupt
    XAxiDma_Config *myDmaConfig;	// a struct with config data, intersection with dma struct
    XAxiDma myDma;		// a struct with DMA instance data variables, & hardware type

    myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);	// takes in base addr, return a pointer to config, only 1 dma in this application!
    status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);

    if(status != XST_SUCCESS){
    	xil_printf("DMA initialization failed\n");
    	return -1;
    }
   	xil_printf("DMA initialization success..\n");

   	// Step 2: init dma intr controller
	XScuGic_Config *IntcConfig;

	IntcConfig =  XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}
	status = XScuGic_CfgInitialize(&IntcInst, IntcConfig, IntcConfig->CpuBaseAddress);
	if (status != XST_SUCCESS) {
			return XST_FAILURE;
	}
	// set trigger priority: dma send and rcv
	XScuGic_SetPriorityTriggerType(&IntcInst, XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR, 0xA0, 0x3);	// priority level, triggered by edge
	XScuGic_SetPriorityTriggerType(&IntcInst, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR, 0xA8, 0x3);
	XScuGic_SetPriorityTriggerType(&IntcInst, XPS_FPGA2_INT_ID, 0xAB, 0x03);

	status = XScuGic_Connect(&IntcInst, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR, (Xil_InterruptHandler)s2mm_isr, 0);
	if (status != XST_SUCCESS){
		xil_printf("ERROR! Failed to connect s2mm_isr to the interrupt controller.\r\n", status);
		return -1;
	}
	status = XScuGic_Connect(&IntcInst, XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR, (Xil_InterruptHandler)mm2s_isr, 0);
	if (status != XST_SUCCESS){
		xil_printf("ERROR! Failed to connect mm2s_isr to the interrupt controller.\r\n", status);
		return -1;
	}
	status = XScuGic_Connect(&IntcInst, XPS_FPGA2_INT_ID, (Xil_InterruptHandler)rtl_isr, 0);
	if (status != XST_SUCCESS){
		xil_printf("ERROR! Failed to connect mm2s_isr to the interrupt controller.\r\n", status);
		return -1;
	}

	XScuGic_Enable(&IntcInst, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);
	XScuGic_Enable(&IntcInst, XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR);
	XScuGic_Enable(&IntcInst, XPS_FPGA2_INT_ID);

	// Initialize exception table and register the interrupt controller handler with exception table
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, (void *)&IntcInst);

	// Enable non-critical exceptions
	Xil_ExceptionEnable();

	//XAxiDma_IntrDisable(&myDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrEnable(&myDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);

	//XAxiDma_IntrDisable(&myDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(&myDma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DMA_TO_DEVICE);

   	// Step 3: flush data and record the transaction.
   	Xil_DCacheFlushRange((u32)a, LEN*sizeof(u32));	// force transfer to ddr, starting addr & length

   	status = XAxiDma_SimpleTransfer(&myDma, (u32)b, LEN*sizeof(u32),XAXIDMA_DEVICE_TO_DMA);	// initialize rcv first
   	status = XAxiDma_SimpleTransfer(&myDma, (u32)a, LEN*sizeof(u32),XAXIDMA_DMA_TO_DEVICE);   //typecasting in C/C++
   	// simple tranfer is non_blocking, just configure the dma registers and return!
   	if(status != XST_SUCCESS){
   		print("DMA transfer initialization failed\n");
   		return -1;
   	}
   	//sleep(1);

   	while (!glb_mm2s_done | !glb_s2mm_done);

   	XGpio irq2rtl;
   	XGpio_Initialize(&irq2rtl, XPAR_AXI_GPIO_0_DEVICE_ID);
   	XGpio_SetDataDirection(&irq2rtl, 1, 0x0);
   	XGpio_DiscreteWrite(&irq2rtl, 1, 0xFFFFFFFF);

   	while (!glb_rtl_irq);

   	for (u32 i = 0; i<LEN; i ++){
   	    xil_printf("%0x\n", b[i]);
   	}
   	//sleep(1);

    cleanup_platform();
    return 0;
}

static void s2mm_isr(void* CallbackRef){
	XScuGic_Disable(&IntcInst, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);
	xil_printf("s2mm finished!\n");
	glb_s2mm_done = 1;
	XScuGic_Enable(&IntcInst, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);
}

static void mm2s_isr(void* CallbackRef){
	XScuGic_Disable(&IntcInst, XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR);
	xil_printf("mm2s finished!\n");
	glb_mm2s_done = 1;
	XScuGic_Enable(&IntcInst, XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR);
	//XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);
}

static void rtl_isr(void* CallbackRef){
	XScuGic_Disable(&IntcInst, XPS_FPGA2_INT_ID);
	xil_printf("Bang!\n");
	glb_rtl_irq = 1;
	XScuGic_Enable(&IntcInst, XPS_FPGA2_INT_ID);
}

