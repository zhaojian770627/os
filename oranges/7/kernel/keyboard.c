#include "../include/type.h"
#include "../include/const.h"
#include "../include/protect.h"
#include "../include/proto.h"
#include "../include/string.h"
#include "../include/proc.h"
#include "../include/global.h"

PUBLIC void keyboard_handler(int irq)
{
  //  put_string("*");

  u8 scan_code = in_byte(0x60);
  put_int(scan_code);
}

PUBLIC void init_keyboard()
{
  put_irq_handler(KEYBOARD_IRQ,keyboard_handler);
  enable_irq(KEYBOARD_IRQ);
}
