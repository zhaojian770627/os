	;; 软盘主引导扇区代码
	core_base_address equ 0x00040000 ;常数,内核加载的起始内存地址
	core_start_sector equ 0x00000001 ;常数,内核的起始逻辑扇区号

	mov	ax,cs
	mov	ss,ax
	mov	sp,0x7c00

	;; 计算GDT所在的逻辑段地址
	mov	edx,[cs:pgdt+0x7c00+0x02] ;GDT的32位物理地址
	xor	edx,edx
	mov	ebx,16
	div	ebx		;分解成16位逻辑地址

	mov	ds,eax		;令DS指向该段以进行操作
	mov	ebx,edx		;段内起始偏移地址

	;; 跳过0#描述符的槽位
	;; 创建1#描述符,这是一个数据段，对应0~4GB的线性地址空间
	mov	dword[ebx+0x08],0x0000ffff ;基地址为0，段界限位0xffff
	mov	dword[ebx+0x0c],0x00cf9200 ;粒度位4KB，存储器段描述符

	;; 创建保护模式下初始代码段描述符
	mov	dword[ebx+0x10],0x7c0001ff ;基地址为0x00007c00，段界限位0x1ff
	mov	dword[ebx+0x14],0x00489800 ;粒度位1个字节，代码段描述符

	;; 创建保护模式下堆栈段描述符
	mov	dword[ebx+0x18],0x7c00fffe ;基地址为0x00007c00，段界限位0xffffe
	mov	dword[ebx+0x1c],0x00cf9600 ;粒度为4KB

	
	mov	dword[ebx+0x20],0x80007fff ;基地址为0x000B8000,界限位0x07fff
	mov	dword[ebx+0x24],0x0040920b ;粒度为字节

	;; 初始化描述符表寄存器GDTR
	mov	word[cs:pgdt+0x7c00],39 ;描述符的界限

	lgdt	[cs:pgdt+0x7c00]

	in	al,0x92		;南桥芯片内的端口
	or	al,0000_0010B	
	out	0x92,al		;打开A20

	cli			;中断机制尚未工作

	mov	eax,cr0
	or	eax,1
	mov	cr0,eax		;设置PE位

	;; 以下进入保护模式......
	jmp	dword 0x0010:flush ;16位描述符选择子:32位偏移

	[bits 32]
flush:
	mov	eax,0x0008	;加载数据段(0..4GB)选择子
	mov	ds,eax
	mov	es,eax		;读扇区用
	
	mov	eax,0x0018	;加载堆栈段选择子
	mov	ss,eax
	xor	esp,esp

	;; 以下加载系统核心程序
	mov	edi,core_base_address

	mov	eax,core_start_sector
	mov	ebx,edi		;起始部分
	call 	read_floppy_disk ;以下读取程序的起始部分(一个扇区)

	;; 以下判断整个程序多大
	mov	eax,[edi]	;核心程序尺寸
	xor	edx,edx
	mov	ecx,512		;512字节每扇区
	div	ecx

	or 	edx,edx
	jnz	@1		;未除尽，因此结果比实际扇区数少1
	dec	eax		;已经读了一个扇区，扇区总数减1
@1:
	or	eax,eax		;考虑实际长度<=512个字节的情况
	jz	setup		;EAX=0?

	;; 读取剩余的扇区
	mov	ecx,eax
	mov	eax,core_start_sector
	inc	eax		;从下一个逻辑扇区接着读

	call	read_floppy_disk
setup:
	hlt
;;; ------------------------------------------------------------------
%include "readdisk.asm"
;;; -------------------------------------------------------------------
	pgdt	dw	0
		dd	0x00007e00 ;GDT的物理地址
;;; -------------------------------------------------------------------
	times	510-($-$$) db 0
			   db 0x55,0xaa