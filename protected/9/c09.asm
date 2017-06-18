section header vstart=0		;定义用户程序头部段
	program_length 	dd	program_end ;定义程序总长度[0x00]

	;; 用户程序的入口点
	code_entry	dw	start ;偏移地址[0x04]
			dd	section.code.start ;段地址[0x06]

	;; 段重定位表项个数
	realloc_tbl_len	dw	(header_end - code_segment)/4 ;[0x0a]

	;; 段重定位表
	code_segment	dd	section.code.start ;[0x0c]
	data_segment	dd	section.data.start ;[0x10]
	stack_segment	dd	section.stack.start  ;[0x14]

header_end:

	;; ================================================================
section code align=16 vstart=0 ;定义代码段1(16字节对齐)
new_int_0x70:
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
.w0:
	mov	al,0x0a		;阻断NMI。当然，通常不必要的
	or	al,0x80
	out	0x70,al
	in	al,0x71		;读寄存器A
	test	al,0x80		;测试第7位UIP
	jnz	.w0		;以上代码对于更新周期结束中断来说是不必要的

	xor	al,al
	or	al,0x80
	out	0x70,al
	in	al,0x71		;读RTC秒
	push	ax

	mov	al,2
	or	al,0x80
	out	0x70,al
	in	al,0x71		;读分
	push	ax

	mov	al,4
	or	al,0x80
	out	0x70,al
	in	al,0x71		;时
	push	ax

	mov	al,0x0c		;寄存器C的索引.且开放NMI
	out	0x70,al
	in	al,0x71		;读下RTC的寄存器C,否则只发生一次中断，此处不考虑闹钟和周期性中断的情况

	mov	ax,0xb800
	mov	es,ax

	pop	ax
	call	bcd_to_ascii
	mov	bx,12*168+36*2	;从屏幕的12行36列开始显示

	mov	[es:bx],ah
	mov	[es:bx+2],al	;显示两位小时数字

	mov	al,':'
	mov	[es:bx+4],al	;显示分割符
	not	byte[es:bx+5]	;反转显示属性

	pop	ax
	call 	bcd_to_ascii
	mov	[es:bx+6],ah
	mov	[es:bx+8],al	;显示两位分钟数字

	mov	al,':'
	mov	[es:bx+10],al	;显示分割符
	not 	byte[es:bx+11]	;反转显示属性

	pop	ax
	call 	bcd_to_ascii
	mov	[es:bx+12],ah
	mov	[es:bx+14],al	;显示两位秒数字

	mov	al,0x20		;中断结束命令
	out	0xa0,al		;向从片发送
	out	0x20,al		;向主片发送
	
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	iret
;;; ---------------------------------------------------------------
	;; BCD妈转ASCII
	;; Input:AL=bcd妈
	;; Output:AX=ascii
bcd_to_ascii:
	mov	ah,al		;分解成两个数字
	and	al,0x0f		;仅保留低4位
	add	al,0x30		;转换成ASCII

	shr	ah,4		;逻辑右移4位
	and 	ah,0x0f
	add	ah,0x30

	ret
		
;;;--------------------------------------------------------------
%include "lib.inc"
start:
	mov	ax,[stack_segment]
	mov	ss,ax
	mov	sp,ss_pointer
	mov	ax,[data_segment]
	mov	ds,ax

	mov	bx,init_msg	;显示初始信息
	call	put_string

	mov	bx,inst_msg	;显示安装信息
	call	put_string

	mov	al,0x70
	mov	bl,4
	mul	bl
	mov	bx,ax		;计算0x70号中断在IVT中的偏移

	cli			;防止改动期间发生新的0x70号中断

	push	es
	mov	ax,0x0000
	mov	es,ax
	mov	word[es:bx],new_int_0x70 ;偏移地址
	mov	word[es:bx+2],cs	 ;段地址
	pop	es

	mov	al,0x0b		;RTC寄存器B
	or	al,0x80		;阻断NMI
	out	0x70,al
	mov	al,0x12		;设置寄存器B，禁止周期性中断，
	out	0x71,al		;新结束后中断，BCD码，24小时制

	mov	al,0x0c
	out 	0x70
	in	al,0x71		;读RTC寄存器C，复位未决的中断状态


	in	al,0xa1		;读8259从片的IMR寄存器
	and 	al,0xfe		;清除bit 0(次位连接RTC)
	out	0xa1,al		;写回此寄存器

	sti

	mov	bx,done_msg	;显示安装完成信息
	call	put_string

	mov	bx,tips_msg	;显示提示信息
	call	put_string

	mov	cx,0xb800
	mov	ds,cx
	mov	byte[12*160+33*2],'0' ;屏幕第12行，35列
.idle:
	hlt			;使CPU进入低功耗状态,直到用中断唤醒
	not	byte[12*160+33*2+1] ;反转显示属性
	jmp	.idle
	
;;; ==========================================================================
section data align=16 vstart=0
	init_msg	db 'Starting...',0x0d,0x0a,0
	inst_msg	db 'Installing a new interrupt 70H...',0
	done_msg	db 'Done.',0x0d,0x0a,0
	tips_msg	db 'Clock is now working.',0
	
;;; ===============================================
section stack align=16 vstart=0
	resb	256
ss_pointer:	
stack_end:
;;; ========================================================================
section trail align=16
program_end:	