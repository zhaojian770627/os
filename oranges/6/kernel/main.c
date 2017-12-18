#include "../include/type.h"
#include "../include/const.h"
#include "../include/protect.h"
#include "../include/proto.h"
#include "../include/string.h"
#include "../include/proc.h"
#include "../include/global.h"

PUBLIC int kernel_main()
{
  put_string("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\r");
  put_string("-----\"kernel_main\" begins-------\r\n");

  PROCESS* p_proc=proc_table;

  p_proc->ldt_sel=SELECTOR_LDT_FIRST;
  memcpy(&p_proc->ldts[0],&gdt[SELECTOR_KERNEL_CS>>3],sizeof(DESCRIPTOR));
  p_proc->ldts[0].attr1=DA_C|PRIVILEGE_TASK<<5; /* change the DPL */
  memcpy(&p_proc->ldts[1],&gdt[SELECTOR_KERNEL_DS>>3],sizeof(DESCRIPTOR));
  p_proc->ldts[1].attr1=DA_DRW|PRIVILEGE_TASK<<5; /* change the DPL */

  p_proc->regs.cs= (0 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
  p_proc->regs.ds= (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
  p_proc->regs.es= (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
  p_proc->regs.fs= (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
  p_proc->regs.ss= (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
  p_proc->regs.gs= (SELECTOR_KERNEL_GS & SA_RPL_MASK) | RPL_TASK;
  p_proc->regs.eip= (u32)TestA;
  p_proc->regs.esp= (u32) task_stack + STACK_SIZE_TOTAL;
  p_proc->regs.eflags = 0x1202;	// IF=1, IOPL=1, bit 2 is always 1.

  p_proc_ready=proc_table;
  restart();
  while(1){
  }
}

void TestA()
{
  int i=0;
  while(i<20){
    put_string("A");
    put_int(i++);
    put_string(".");
    delay(1000);
  }
  stop();
}
