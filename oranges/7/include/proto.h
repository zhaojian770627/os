/* klib.asm */
PUBLIC void	out_byte(u16 port, u8 value);
PUBLIC u8	in_byte(u16 port);
PUBLIC void     disp_int(int input);
PUBLIC void     put_int(int input);
PUBLIC void	disp_str(char * info);
PUBLIC void     put_string(char *info);
PUBLIC void     put_color_string(char *info,int color);
PUBLIC void	disp_color_str(char * info, int color);
PUBLIC void     enable_irq(u8 value);
PUBLIC void     disable_irq(u8 value);
PUBLIC void     disable_int();
PUBLIC void     enable_int();

PUBLIC void	init_prot();
PUBLIC void	init_8259A();
PUBLIC u32	seg2phys(u16 seg);

PUBLIC void     delay(int time);

/* kernel.asm */
void restart();
void stop();

/* main.c */
void TestA();
void TestB();
void TestC();

/* i8259.c */
PUBLIC void put_irq_handler(int irq, irq_handler handler);
PUBLIC void spurious_irq(int irq);

/* clock.c */
PUBLIC void clock_handler(int irq);
PUBLIC void milli_delay(int milli_sec);
PUBLIC void init_clock();

/* keyboard.c */
PUBLIC void init_keyboard();
PUBLIC void keyboard_read();

/* tty.c */
PUBLIC void task_tty();
PUBLIC void in_process(u32 key);

/* 以下是系统调用相关 */

/* proc.c */
PUBLIC  int     sys_get_ticks();        /* sys_call */
PUBLIC void     schedule();

/* syscall.s */
PUBLIC  void    sys_call();             /* int_handler */
PUBLIC  int     get_ticks();
