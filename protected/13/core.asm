	core_code_seg_sel	equ	0x38 ;内核代码段选择子
	core_data_seg_sel	equ	0x30 ;内核数据段选择子
	sys_routine_seg_sel	equ	0x28 ;系统公共例程代码段选择子
	video_ram_seg_sel	equ	0x20 ;视频显示缓冲区段选择子
	core_stack_seg_sel	equ	0x18 ;内和堆栈段选择子
	mem_0_4_gb_seg_sel	equ	0x08 ;整个0-4GB内存的段选择子
;;; -----------------------------------------------------------------
	;; 以下是系统核心的头部,用于加载核心程序
	core_length	dd core_end ;核心程序总长度 00
	sys_routine_seg	dd	section.sys_routine.start ;系统公用例程位置04
	core_data_seg	dd	section.core_data.start	  ;核心公用例程段位置08
	core_code_seg	dd	section.core_code.start	  ;核心代码段位置0c
	core_entry	dd	start			  ;核心代码段入口点 10
			dw	core_code_seg_sel
;;; -----------------------------------------------------------------
	[bits 32]
;;; -----------------------------------------------------------------
SECtiON sys_routine vstart=0	;系统公共例程代码段
	