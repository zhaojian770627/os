section header vstart=0		;定义用户程序头部段
	program_length 	dd	program_end ;定义程序总长度[0x00]

	;; 用户程序的入口点
	code_entry	dw	start ;偏移地址[0x04]
			dd	section.code_1.start ;段地址[0x06]

	;; 段重定位表项个数
	realloc_tbl_len	dw	(header_end - code_1_segment)/4 ;[0x0a]

	;; 段重定位表
	code_1_segment	dd	section.code_1.start ;[0x0c]
	code_2_segment	dd	section.code_2.start ;[0x10]
	data_1_segment	dd	section.data_1.start ;[0x14]
	data_2_segment	dd	section.data_2.start ;[0x18]
	stack_segment	dd	section.stack.start  ;[0x1c]

header_end:

	;; ================================================================
section code_1 align=16 vstart=0 ;定义代码段1(16字节对齐)
put_string:			 ;显示串(0结尾).
	;; 输入:DS:BX=串地址
	mov	cl,[bx]
	or	cl,cl
	jz	.exit
	call	put_char
	inc	bx		;下一个字符
	jmp	put_string

.exit:
	ret
;;; ===========================================================================
put_char:			;显示一个字读
	;; 输入;cl=字符ascii
	push	ax
	push	bx
	push	cx
	push	dx
	push 	ds
	push	es

	;; 以下取当前光标位置
	mov	dx,0x3d4
	mov	al,0x0e
	out	dx,al
	mov	dx,0x3d5
	in	al,dx		;高8位
	mov	ah,al

	mov	dx,0x3d4
	mov	al,0x0f
	out	dx,al
	mov	dx,0x3d5
	in	al,dx		;低8位
	mov	bx,ax		;BX=代表光标位置的16位数

	cmp	cl,0x0d		;回车符
	jnz	.put_0a		;不是，是黄行符?
	mov	ax,bx
	mov	bl,80
	div	bl
	mul	bl
	mov	bx,ax
	jmp	.set_cursor
.put_0a:
	cmp	cl,0x0a		;换行符
	jnz	.put_other	;不是 正常显示字符
	add	bx,80
	jmp	.roll_screen

.put_other:			;正常显示字符
	mov	ax,0xb800
	mov	es,ax
	shl	bx,1
	mov	[es:bx],cl

	shr	bx,1
	add	bx,1
.roll_screen:
	cmp	bx,2000		;光标超出屏幕:滚屏
	jl	.set_cursor

	mov	ax,0xb800
	mov	ds,ax
	mov	es,ax
	cld
	mov	si,0xa0
	mov	di,0x00
	mov	cx,1920
	rep	movsw
	mov	bx,3840		;清楚屏幕最底一场
	mov	cx,80
.cls:
	mov	word[es:bx],0x0720
	add	bx,2
	loop	.cls

	mov	bx,1920

.set_cursor:
	mov	dx,0x3d4
	mov	al,0x0e
	out	dx,al
	mov	dx,0x3d5
	mov	al,bh
	out	dx,al
	mov	dx,0x3d4
	mov	al,0x0f
	out	dx,al
	mov	dx,0x3d5
	mov	al,bl
	out 	dx,al

	pop	es
	pop	ds
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	ret
;;;================================================================
start:
	;; 初始执行时，DS和ES指向用户程序头部段
	mov	ax,[stack_segment] ;设置到用户程序自己的堆栈
	mov	ss,ax
	mov	sp,stack_end

	mov	ax,[data_1_segment]
	mov	ds,ax

	mov	bx,msg0
	call	put_string

	push	word[es:code_2_segment]
	mov	ax,begin
	push	ax

	retf

continue:
	mov	ax,[es:data_2_segment]
	mov	ds,ax

	mov	bx,msg1
	call	put_string

	halt

section code_2 align=16 vstart=0
begin:
	push	word[es:code_1_segment]
	mov	ax,continue
	push	ax

	retf

;;; ==========================================================================
section data_1 align=16 vstart=0
         msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         db 0x0d,0x0a,0x0d,0x0a
         db '  Example code for calculate 1+2+...+1000:',0x0d,0x0a,0x0d,0x0a
         db '     xor dx,dx',0x0d,0x0a
         db '     xor ax,ax',0x0d,0x0a
         db '     xor cx,cx',0x0d,0x0a
         db '  @@:',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     add ax,cx',0x0d,0x0a
         db '     adc dx,0',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     cmp cx,1000',0x0d,0x0a
         db '     jle @@',0x0d,0x0a
         db '     ... ...(Some other codes)',0x0d,0x0a,0x0d,0x0a
         db 0
;;; ===========================================================================
section data_2 align=16 vstart=0
	 msg1 db '  The above contents is written by LeeChung. '
         db '2011-05-06'
         db 0
;;; ===============================================
section stack align=16 vstart=0
	resb	256 
stack_end:
;;; ========================================================================
section trail align=16
program_end:	