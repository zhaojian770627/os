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

	mov	ax,[cs:phy_base] ;计算用于加载用户程序的逻辑段地址
	mov	dx,[cs:phy_base+0x02]
	mov	bx,16
	div	bx
	mov	ds,ax		;令DS和ES指向该段以进行操作
	mov	es,ax

	;; 以下读取程序的起始部分
	xor	di,di
	mov	si,app_floppy_start ;程序在硬盘上的起始逻辑扇区号
	xor	bx,bx		    ;加载到DS:0x0000处
	call	read_floppy_disk_0

	;; 以下判断整个程序有多大
	mov	dx,[2]		;
	mov	ax,[0]
	mov	bx,512		;512字节每扇区
	div	bx
	cmp	dx,0		
	jnz	@1		;未除近，因此结果比实际扇区少1
	dec	ax		;已经读了一个扇区,扇区总数减1
@1:
	cmp	ax,0		;考虑实际长度小于等于512个字节的情况
	jz	direct

	;; 读取剩余的扇区
	push	ds		;以下要用到并改变DS寄存器

	mov	cx,ax		;循环次数
@2:
	mov	ax,ds
	add	ax,0x20		;得到下一个以512字节为边界的段地址
	mov	ds,ax

	xor	bx,bx		;每次读时，偏移地址始终为0x0000
	inc	si		;下一个逻辑扇区
	mov	byte[_errno],0
	call	read_floppy_disk_0
	cmp	byte[_errno],0
	jne	error
	loop 	@2		;循环读，直到读完整个功能程序

	pop	ds

	;; 计算入口点代码段基址
direct:
	jmp 	$		;暂时结束

;;; ======================================================
read_floppy_disk_0:		;从软盘读取一个逻辑扇区
	push 	ax
	push	bx
	push	cx
	push	dx
	push	si

	;;运算柱面 
	mov	ax,_readsecs
	add	ax,_startsec
	mov	bx,0x12
	div	bx
	cmp 	dx,0
	jz	no_remained
	inc	ax
no_remained:	
	mov	[_cyls],ax
	
	mov	ch,0		;注面
	mov	dh,0		;磁头0
	mov	cl,_startsec	;起始扇区
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

	
	mov	ax,es
	add	ax,0x0020
	mov	es,ax		
	add	cl,1
	add	cl,18
	jbe	readloop	;如果cl<=18,则跳至readlloop
	mov	cl,1
	add	dh,1
	cmp	dh,2
	jb	readloop
	mov	dh,0
	add	ch,1
	cmp	ch,_cyls
	jb	readloop
	jmp	rexit
err:	
	mov	byte[_errno],1
rexit:
	
	push 	si
	push	dx
	push	cx
	push	bx
	push	ax
	ret

error:
	mov 	si,msg
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
msg:
	db	0x0a,0x0a
	db	"load error"
	db	0x0a
	db	0

	
;;; =========================================================
	phy_base	dd	0x10000 ;用户程序被加载的物理起始地址
	times 510 - ($-$$) db 0
	db 	0x55,0xaa