#include "platform.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xparameters_ps.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xscugic.h"
#include <assert.h>

#define printf xil_printf
#define assert_printf(v1, op, v2, optional_debug_info,...) ((v1  op v2) || (printf("ASSERT FAILED: \n CONDITION: "), printf("( " #v1 " " #op " " #v2 " )"), printf(", VALUES: ( %ld %s %ld ), ", (long int)v1, #op, (long int)v2), printf("DEBUG_INFO: " optional_debug_info), printf(" " __VA_ARGS__), printf("\n\n"), assert(v1 op v2), 0))

static int glb_s2mm_done = 0;
static int glb_mm2s_done = 0;
static int glb_rtl_irq   = 0;

XAxiDma my_dma;
XScuGic intr_controller; // Generic interrupt controller
XGpio   gpio_out;
u32     status;

#define TRANSFER_LEN 10
#define TRANSFER_BYTES (TRANSFER_LEN*sizeof(u32))
u32 *a = (u32 *)XPAR_DDR_MEM_BASEADDR;
u32 *b = (u32 *)XPAR_DDR_MEM_BASEADDR + 100;

static void s2mm_isr(void* CallbackRef){
  u32 IrqStatus = XAxiDma_IntrGetIrq(&my_dma, XAXIDMA_DEVICE_TO_DMA);
  XAxiDma_IntrAckIrq(&my_dma, IrqStatus, XAXIDMA_DEVICE_TO_DMA);
  if (!(IrqStatus & XAXIDMA_IRQ_IOC_MASK)) return;
  xil_printf("s2mm finished!\n");
  glb_s2mm_done = 1;
}

static void mm2s_isr(void* CallbackRef){
  u32 IrqStatus = XAxiDma_IntrGetIrq(&my_dma, XAXIDMA_DMA_TO_DEVICE); // Read pending interrupts
  XAxiDma_IntrAckIrq(&my_dma, IrqStatus, XAXIDMA_DMA_TO_DEVICE); // Acknowledge pending interrupts
  if (!(IrqStatus & XAXIDMA_IRQ_IOC_MASK)) return;
  xil_printf("mm2s finished!\n");
  glb_mm2s_done = 1;
}

static void rtl_isr(void* CallbackRef){
  XScuGic_Disable(&intr_controller, XPS_FPGA2_INT_ID);
  xil_printf("RTL raised interrupt!\n");
  glb_rtl_irq = 1;
  XScuGic_Enable(&intr_controller, XPS_FPGA2_INT_ID);
}

static void setup_interrupt(XScuGic *p_intr_controller, u32 intr_id, Xil_InterruptHandler handler_fn, u8 priority){
  XScuGic_SetPriorityTriggerType(p_intr_controller, intr_id, priority, 0x3);            // set priority level, triggered by rising edge
  status = XScuGic_Connect(p_intr_controller, intr_id, handler_fn, 0);    // connect interrupt handler
  assert_printf (status, ==, XST_SUCCESS, "ERROR! Failed to connect mm2s_isr to the interrupt controller.\r\n",);
  XScuGic_Enable(p_intr_controller, intr_id); // enable interrupt
}


int main() {
  init_platform();
  print("Hello World -- Aba\n\r");

  // Initialize Interrupt Controller
  XScuGic_Config *IntcConfig =  XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
  status = XScuGic_CfgInitialize(&intr_controller, IntcConfig, IntcConfig->CpuBaseAddress);
  assert_printf (status, ==, XST_SUCCESS, "Interrupt initialization failed",);
  Xil_ExceptionInit(); // Initialize exception table
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, (void *)&intr_controller);  //register the interrupt controller handler with exception table
  Xil_ExceptionEnable(); // Enable non-critical exceptions


  // Initialize DMA
  status = XAxiDma_CfgInitialize(&my_dma, XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR));
  assert_printf (status, ==, XST_SUCCESS, "DMA initialization failed",);
  // MM2S
  setup_interrupt(&intr_controller, XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR, (Xil_InterruptHandler)mm2s_isr, 0xA0);
  XAxiDma_IntrDisable(&my_dma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DMA_TO_DEVICE);
  XAxiDma_IntrEnable (&my_dma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DMA_TO_DEVICE);
  // S2MM
  setup_interrupt(&intr_controller, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR, (Xil_InterruptHandler)s2mm_isr, 0xA8);
  XAxiDma_IntrDisable(&my_dma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);
  XAxiDma_IntrEnable (&my_dma, XAXIDMA_IRQ_IOC_MASK, XAXIDMA_DEVICE_TO_DMA);


  // RTL Interrupt
  setup_interrupt(&intr_controller, XPS_FPGA2_INT_ID, (Xil_InterruptHandler)rtl_isr , 0xAB);

  // Initialize GPIO
  XGpio_Initialize(&gpio_out, XPAR_AXI_GPIO_0_DEVICE_ID);
  XGpio_SetDataDirection(&gpio_out, 1, 0x0);


  // ------------ DATA TRANSFER ---------------

  for (int t=0; t<100; t++){

    // 1. Prepare input data
    for (u32 i = 0; i<TRANSFER_LEN; i++){
      a[i] = 10*t + i;
      xil_printf("a[%d] = %d\n", i, a[i]);
    }
    Xil_DCacheFlushRange((INTPTR)a, TRANSFER_BYTES);  // force transfer to DDR, starting addr & length
    Xil_DCacheFlushRange((INTPTR)b, TRANSFER_BYTES);

    // 2. Start transfers
    status = XAxiDma_SimpleTransfer(&my_dma, (INTPTR)b, TRANSFER_BYTES, XAXIDMA_DEVICE_TO_DMA);
    status = XAxiDma_SimpleTransfer(&my_dma, (INTPTR)a, TRANSFER_BYTES, XAXIDMA_DMA_TO_DEVICE);

    assert_printf (status, ==, XST_SUCCESS, "DMA transfer initialization failed \r\n",);

    // 3. Wait for interrupt callbacks to set global variables
    while (!glb_mm2s_done | !glb_s2mm_done);
    glb_mm2s_done = 0;
    glb_s2mm_done = 0;

    // 4. Read data
    Xil_DCacheFlushRange((INTPTR)b, TRANSFER_BYTES);
    for (u32 i = 0; i<TRANSFER_LEN; i++) {
      xil_printf("b[%d] = %d\n", i, b[i]);
    }

    // Write GPIO, wait for interrupt to clear the global variable
    XGpio_DiscreteWrite(&gpio_out, 1, 0xFFFFFFFF);
    while (!glb_rtl_irq);
    glb_rtl_irq = 0;
    XGpio_DiscreteWrite(&gpio_out, 1, 0);

    xil_printf("Done transfer: %d/100 \n", t);
  }

  XScuGic_Disconnect(&intr_controller, XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR);
  XScuGic_Disconnect(&intr_controller, XPAR_FABRIC_AXI_DMA_0_MM2S_INTROUT_INTR);

  cleanup_platform();
  return 0;
}

