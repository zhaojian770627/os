	;; 软盘主引导扇区代码(加载程序)

	app_floppy_start equ 100 ;声明常熟(用户程序起始逻辑扇区号)

section mbr align=16 vstart=0x7c00
	;; 设置堆栈段和栈指针
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
	;; 计算入口点代码段基址
	