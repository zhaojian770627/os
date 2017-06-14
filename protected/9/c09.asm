section header vstart=0		;定义用户程序头部段
	program_length 	dd	program_end ;定义程序总长度[0x00]

	;; 用户程序的入口点
	code_entry	dw	start ;偏移地址[0x04]
			dd	section.code_1.start ;段地址[0x06]

	;; 段重定位表项个数
	realloc_tbl_len	dw	(header_end - code_1_segment)/4 ;[0x0a]

	;; 段重定位表
	code_1_segment	dd	section.code_1.start ;[0x0c]
	data_1_segment	dd	section.data_1.start ;[0x10]
	stack_segment	dd	section.stack.start  ;[0x14]

header_end:

	;; ================================================================
section code_1 align=16 vstart=0 ;定义代码段1(16字节对齐)

;;;================================================================
start:
	halt
;;; ==========================================================================
section data_1 align=16 vstart=0

;;; ===============================================
section stack align=16 vstart=0
	resb	256 
stack_end:
;;; ========================================================================
section trail align=16
program_end:	