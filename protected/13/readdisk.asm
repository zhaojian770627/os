	;; 从软盘读取逻辑扇区
	;; EAX=起始扇区号
	;; ECX=读取扇区数	
	;; ES:EBX=目标缓冲区地址
read_floppy_disk:		;从软盘读取一个逻辑扇区
	push	dx
	push	si
	push	di

	push	cx	
	push 	bx
	
	xor 	di,di

	dec	ax
	xor	dx,dx
	mov	bx,0x12
	div	bx

	mov	cl,dl		;扇区
	inc	cl

	xor	dx,dx

	mov	bx,0x2
	div	bx

	mov	ch,al		;柱面
	mov	dh,dl		;磁头0

	pop	bx
readloop:
	mov	si,0		;记录失败次数的寄存器
retry:
	mov	ah,0x02		;ah=0x02 读入磁盘
	mov	al,1		;一个扇区
	mov	dl,0x00		;A驱动器
	int	0x13
	jnc	next		;No error
	inc	si
	cmp	si,5
	jae	err
	mov	ah,0x00
	mov	dl,0x00
	int 	0x13
	jmp	retry
next:
	inc	di
	pop	ax
	cmp	di,ax
	push	ax
	je	rexit
	add	bx,0x0200
	add	cl,1
	cmp	cl,18
	jbe	readloop
	mov	cl,1
	add	dh,1
	cmp	dh,2
	jb	readloop
	mov	dh,0
	add	ch,1
	jmp	readloop
err:
	pop	cx
	mov	cx,1
rexit:
	pop	di
	pop	si
	pop	dx

	ret
