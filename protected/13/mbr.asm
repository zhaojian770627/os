	
	;; 软盘主引导扇区代码
	core_base_address equ 0x00040000 ;常数,内核加载的起始内存地址
	core_start_sector equ 0x00000002 ;常数,内核的起始逻辑扇区号

	user_base_address equ 0x00050000 ;常数，用户程序加载的起始内存地址
	user_start_sector equ 0x0000000b ;常数，用户程序起始逻辑扇区号 11扇区

	mov	ax,cs
	mov	ss,ax
	
	mov	sp,0x7c00

	mov     ax,0x7c00+init_msg
	call    dispstr

	;; 在实模式下加载核心程序，进入保护模式下，就不能调用BIOS代码，以现有的知识能力
	mov	ax,[cs:phy_base+0x7c00]
	mov	dx,[cs:phy_base+0x7c00+0x02]
	mov	bx,16
	div	bx
	mov	es,ax
	push	es
	push	es
	
	;; 以下加载系统核心程序
	mov	eax,core_start_sector
	mov	ebx,0		;起始部分
	mov	ecx,1		;1个扇区
	call 	read_floppy_disk ;以下读取程序的起始部分(一个扇区)

	;; 以下判断整个程序多大
	pop	ds
	mov	dx,[2]	;核心程序尺寸
	mov	ax,[0]
	push	bx		;bx保存着上次读取到的地址，所以要保存
	mov	bx,0x200		;512字节每扇区
	div	bx
	pop	bx

	cmp 	dx,0
	jnz	@1		;未除尽，因此结果比实际扇区数少1
	dec	eax		;已经读了一个扇区，扇区总数减1
@1:
	or	eax,eax		;考虑实际长度<=512个字节的情况
	jz	@2		;EAX=0?

	;; 读取剩余的扇区
	mov	ecx,eax
	mov	eax,core_start_sector
	inc	eax		;从下一个逻辑扇区接着读

	call	read_floppy_disk
@2:
	;; 加载用户程序
	mov	ax,[cs:phy_user+0x7c00]
	mov	dx,[cs:phy_user+0x7c00+0x02]
	mov	bx,16
	div	bx
	mov	es,ax
	push	es
		
	;; 以下加载系统核心程序
	mov	eax,user_start_sector
	mov	ebx,0		;起始部分
	mov	ecx,1		;1个扇区
	call 	read_floppy_disk ;以下读取程序的起始部分(一个扇区)

	;; 以下判断整个程序多大
	pop	ds
	mov	dx,[2]	;核心程序尺寸
	mov	ax,[0]
	push	bx
	mov	bx,0x200		;512字节每扇区
	div	bx
	pop 	bx
	
	cmp 	dx,0
	jnz	@3		;未除尽，因此结果比实际扇区数少1
	dec	eax		;已经读了一个扇区，扇区总数减1
@3:
	or	eax,eax		;考虑实际长度<=512个字节的情况
	jz	@4		;EAX=0?

	;; 读取剩余的扇区
	mov	ecx,eax
	mov	eax,user_start_sector
	inc	eax		;从下一个逻辑扇区接着读

	call	read_floppy_disk
@4:
	;;转移到核心段
	pop	ds
	mov	dx,[0x14]
	mov	ax,[0x12]
	call	calc_segment_base
	mov	[0x12],ax
	;; 跳入内核程序
	jmp 	far [0x10]
;;; ------------------------------------------------------------------
calc_segment_base:		;计算16位段地址
	;; 输入:DX:AX=32位物理地址
	;; 返回:AX=16位段基地址
	push	dx
	add	ax,[cs:phy_base+0x7c00]
	add	dx,[cs:phy_base+0x02+0x7c00]
	shr	ax,4
	ror	dx,4
	and 	dx,0xf000
	or	ax,dx
	pop	dx
	ret
;;; ------------------------------------------------------------------
%include "readdisk.asm"
dispstr:
	mov	bp,ax		;ES:BP= string address
	mov	cx,16		;CX= string length
	mov	ax,01301h	;AH=13,AL=01h
	mov	bx,000ch	;Page 0(BH=0) background black font red
	mov	dl,0
	int 	10h
	ret
;;; ------------------------------------------------------------------
	phy_base dd	0x40000	   ;内核程序加载到的物理地址，对应余于常数core_base_addres
	phy_user dd	0x50000	   ;用户程序的地址，对应于常数，user_start_address
	init_msg	db "Starting..."

;;; -------------------------------------------------------------------
	times	510-($-$$) db 0
			   db 0x55,0xaa