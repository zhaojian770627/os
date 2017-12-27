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


  TASK* p_task=task_table;
  PROCESS* p_proc=proc_table;
  char* p_task_stack=task_stack+STACK_SIZE_TOTAL;
  u16 selector_ldt=SELECTOR_LDT_FIRST;
  int i;

  for(i=0;i<NR_TASKS;i++){
    strcpy(p_proc->p_name,p_task->name); /* name of the process */
    p_proc->pid=i;			 /* pid */
    p_proc->ldt_sel=selector_ldt;

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

    p_proc->regs.eip= (u32)p_task->initial_eip;
    p_proc->regs.esp= (u32)p_task_stack;
    p_proc->regs.eflags = 0x1202;	// IF=1, IOPL=1, bit 2 is always 1.
    
    p_task_stack-=p_task->stacksize;
    p_proc++;
    p_task++;
    selector_ldt+=1<<3;
  }

  k_reenter = 0;
  ticks=0;

  p_proc_ready=proc_table;

  put_irq_handler(CLOCK_IRQ,clock_handler);
  enable_irq(CLOCK_IRQ);

  restart();

  while(1){
  }
}

void TestA()
{
  int i=0;
  while(1){
    put_string("A");
    put_int(get_ticks());
    put_string(".");
    delay(1000);
  }
}

void TestB()
{
  int i=0;
  while(1){
    put_string("B");
    put_int(i++);
    put_string(".");
    delay(1000);
  }
}

void TestC()
{
  int i=0x1000;
  while(1){
    put_string("C");
    put_int(i++);
    put_string(".");
    delay(1000);
  }
}
