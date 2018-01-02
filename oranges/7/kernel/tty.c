
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                               tty.c
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
#include "../include/keyboard.h"


/*======================================================================*
                           task_tty
 *======================================================================*/
PUBLIC void task_tty()
{
  while (1) {
    keyboard_read();
  }
}
