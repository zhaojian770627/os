	;; 软盘主引导扇区代码(加载程序)

	app_floppy_start equ 100 ;声明常熟(用户程序起始逻辑扇区号)

section mbr align=16 vstart=0x7c00
	jmp	start
	;; 设置堆栈段和栈指针
	
	_errno		db	0	;出错标记
	_startsec	dd	0	;起始扇区
	_readsecs	dd	0	;读取扇区数
	_cyls		dd	0	;柱面数
	
start:	
	mov	ax,0
	mov	ss,ax
	mov	sp,ax

	mov	ax,cs
	mov	ds,ax

	mov	ax,[cs:phy_base] ;计算用于加载用户程序的逻辑段地址
	mov	dx,[cs:phy_base+0x02]
	mov	bx,16
	div	bx
	mov	es,ax

	;; 以下读取程序的起始部分
	xor	bx,bx		    ;加载到DS:0x0000处

	mov    	byte[cs:_startsec],0x2	;第2个扇区
	mov 	byte[cs:_readsecs],0x1	;读取一个
	call	read_floppy_disk_0
	;; 以下判断整个程序有多大
	push 	es
	pop	ds
	
	mov	dx,[2]		;
	mov	ax,[0]
	mov	bx,0x200	;每扇区512字节
	div	bx
	cmp	dx,0
	jnz	@1
	dec	ax
@1:
	cmp	ax,0
	jz	direct

	;; 读取剩余的扇区，
	mov	byte[cs:_startsec],0x3 ;第三个扇区
	mov	word[cs:_readsecs],ax
	mov 	ax,es
	add	ax,0x20
	mov	es,ax
	call	read_floppy_disk_0
	
	;; 计算入口点代码段基址
direct:
	;; 计算入口点代码段基址
	;;
	mov	dx,[0x08]	;ds 为用户程序所加载到地址，一直没有变过
	mov	ax,[0x06]
	call	calc_segment_base
	mov	[0x06],ax	;回填修正后的入口代码段基址

	;; 开始处理段重定位表
	mov	cx,[0x0a]	;需要重定位的项目数量
	mov	bx,0x0c		;重定位表首地址

realloc:
	mov	dx,[bx+0x02]	;32位地址的高16位
	mov	ax,[bx]
	call	calc_segment_base
	mov	[bx],ax		;回填段的基址
	add	bx,4		;下一个重定位项
	loop	realloc

	;; 还原es,和ds一样,用户程序用的着
	push	ds
	pop	es

	jmp	far[0x04]

;;; ======================================================
read_floppy_disk_0:		;从软盘读取一个逻辑扇区
	push 	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di

	xor 	di,di

	mov	ax,[cs:_startsec]
	dec	ax
	xor	dx,dx
	mov	bx,0x12
	div	bx

	mov	cl,dl		;扇区
	inc	cl

	xor 	dx,dx
	
	mov	bx,0x2
	div	bx

	mov	ch,al		;注面
	mov	dh,dl		;磁头0
readloop:	
	mov	si,0		;记录失败次数的寄存器
retry:	
	mov	ah,0x02		;ah=0x02:读入磁盘
	mov	al,1		;1个扇区
	mov	bx,0
	mov	dl,0x00		;A驱动器
	int 	0x13		;调用磁盘BIOS
	jnc	next		;没出错时跳转到next
	add	si,1		;si加1
	cmp	si,5		;比较si与5
	jae	err		;si>=5时,跳转到error
	mov	ah,0x00
	mov	dl,0x00		;A驱动器
	int	0x13		;重置驱动器
	jmp	retry

next:
	;; 需要比较总扇区数
	inc	di
	cmp	di,[cs:_readsecs]
	je	rexit	
	mov	ax,es
	add	ax,0x0020
	mov	es,ax		
	add	cl,1
	cmp	cl,18
	jbe	readloop	;如果cl<=18,则跳至readlloop
	mov	cl,1
	add	dh,1
	cmp	dh,2
	jb	readloop
	mov	dh,0
	add	ch,1
	jmp	readloop
err:	
	mov	byte[cs:_errno],1
rexit:
	pop	di
	pop 	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
;;; ------------------------------------------------------
calc_segment_base:		;计算16位段地址
	;; 输入:DX:AX=32位物理地址
	;; 返回:AX=16位段基地址
	push 	dx
	add	ax,[cs:phy_base]
	add	dx,[cs:phy_base+0x02]
	shr	ax,4
	ror	dx,4
	and 	dx,0xf000
	or	ax,dx

	pop	dx
	ret
;;; -----------------------------------------------------
	
loadok:
	mov	si,okmsg
	jmp	putloop
error:
	mov 	si,errmsg
putloop:
	mov 	al,[si]
	add	si,1
	cmp	al,0
	je	fin
	mov 	ah,0x0e
	mov	bx,15
	int	0x10
	jmp	putloop
fin:
	hlt
	jmp	fin
okmsg:
	db	0x0a,0x0a
	db	"load ok"
	db	0x0a
	db	0
errmsg:
	db	0x0a,0x0a
	db	"load error"
	db	0x0a
	db	0

	
;;; =========================================================
	phy_base	dd	0x10000 ;用户程序被加载的物理起始地址
	times 510 - ($-$$) db 0
	db 	0x55,0xaa