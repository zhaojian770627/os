#include "../include/type.h"
#include "../include/const.h"
#include "../include/protect.h"
#include "../include/tty.h"
#include "../include/console.h"
#include "../include/proto.h"
#include "../include/string.h"
#include "../include/proc.h"
#include "../include/global.h"


/* 
   schedule
 */
PUBLIC void schedule()
{
  PROCESS* p;
  int greatest_ticks=0;

  while(!greatest_ticks){
    for(p=proc_table;p<proc_table+NR_TASKS;p++){
      if(p->ticks>greatest_ticks){
	greatest_ticks=p->ticks;
	p_proc_ready=p;
      }
    }
    if(!greatest_ticks){
      for(p=proc_table;p<proc_table+NR_TASKS;p++){
	p->ticks=p->priority;
      }
    }
  }
}

/*======================================================================*
                           sys_get_ticks
 *======================================================================*/
PUBLIC int sys_get_ticks()
{
	return ticks;
}
