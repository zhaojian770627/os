
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

/*======================================================================*
				in_process
 *======================================================================*/
PUBLIC void in_process(u32 key)
{
  char output[2] = {'\0', '\0'};

  if (!(key & FLAG_EXT)) {
    output[0] = key & 0xFF;
    put_string(output);
  }
}
