/* klib.asm */
PUBLIC void	out_byte(u16 port, u8 value);
PUBLIC u8	in_byte(u16 port);
PUBLIC void     disp_int(int input);
PUBLIC void     put_int(int input);
PUBLIC void	disp_str(char * info);
PUBLIC void     put_string(char *info);
PUBLIC void	disp_color_str(char * info, int color);

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
