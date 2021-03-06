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
start:
	mov	ax,[stack_segment]
	mov	ss,ax
	mov	sp,ss_pointer
	mov	ax,[data_segment]
	mov	ds,ax

	mov	cx,msg_end - message
	mov	bx,message
.putc:
	mov	ah,0x0e
	mov	al,[bx]
	int 	0x10
	inc	bx
	loop	.putc
.reps:
	mov	ah,0x00
	int 	0x16
	mov	ah,0x0e
	mov	bl,0x07
	int 	0x10

	jmp	.reps
;;; ==================================================================
SECTION data align=16 vstart=0

	message	db 'Hello,frient!',0x0d,0x0a
		db 'This simple procedure used to demonstrate '
		db 'the BIOS interrupt.',0x0d,0x0a
		db 'Please press the keys on the keyboard ->'
	msg_end:	

;;; ===============================================
section stack align=16 vstart=0
	resb	256
ss_pointer:	
stack_end:
;;; ========================================================================
section trail align=16
program_end:	