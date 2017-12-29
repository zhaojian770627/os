
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                               clock.c
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                                    Forrest Yu, 2005
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#include "../include/type.h"
#include "../include/const.h"
#include "../include/protect.h"
#include "../include/proto.h"
#include "../include/string.h"
#include "../include/proc.h"
#include "../include/global.h"


/*======================================================================*
                           clock_handler
 *======================================================================*/
PUBLIC void clock_handler(int irq)
{
  ticks++;
  p_proc_ready->ticks--;

  if(k_reenter!=0){
    return;
  }

  schedule();
}

/* 
   mill_delay
 */
PUBLIC void milli_delay(int milli_sec)
{
  int t=get_ticks();
  while(((get_ticks()-t)*1000/HZ)<milli_sec){}
}
