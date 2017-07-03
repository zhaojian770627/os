	;; 从软盘读取逻辑扇区
	;; EAX=起始扇区号
	;; ECX=读取扇区数	
	;; ES:EBX=目标缓冲区地址
read_floppy_disk:		;从软盘读取一个逻辑扇区
	push	edx
	push	esi
	push	edi

	push	ecx	
	push 	ebx
	
	xor 	edi,edi

	dec	ax
	xor	edx,edx
	mov	bx,0x12
	div	bx

	mov	cl,dl		;扇区
	inc	cl

	xor	dx,dx

	mov	bx,0x2
	div	bx

	mov	ch,al		;柱面
	mov	dh,dl		;磁头0

	pop	ebx
readloop:
	mov	si,0		;记录失败次数的寄存器
retry:
	mov	ah,0x02		;ah=0x02 读入磁盘
	mov	al,1		;一个扇区
	mov	dl,0x00		;A驱动器
	int	0x13h
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
	pop	ecx
	cmp	di,cx
	je	rexit
	push	ecx
	add	ebx,0x0200
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
	pop	ecx
	mov	ecx,1
rexit:
	pop	edi
	pop	esi
	pop	edi

	retf
