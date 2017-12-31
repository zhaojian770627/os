	LOADOFF	   equ	0x7C00	;0x0000:LOADOFF is where this code is loaded 
	BUFFER	   equ	0x0600	;First free memory 
	PART_TABLE equ	   446	;Location of partition table within this code
	PENTRYSIZE equ	    16	;Size of one partition table entry
	MAGIC	   equ	   510	;Location of the AA55 magic number


	bootind	   equ	     0
	sysind	   equ	     4
	lowsec	   equ	     8
[SECTION .text vstart=0x7c00]
master:
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	cli
	mov	ss, ax			;ds = es = ss = Vector segment
	mov	sp, LOADOFF
	sti
	;; Copy this code to safety, then jump to it.
	mov	si,sp
	push	si
	mov	di,BUFFER
	mov	cx,256
	cld
	rep	movsw
	jmp	0:(BUFFER+(migrate-$$))
migrate:
	call	print
	db	'hello',0
	hlt
	jmp	migrate
;;; Find the active partition
findactive:
	test	dl,dl
	jns	nextdisk
nextdisk:	
	jmp 	migrate

;;; Print a message
print:
	pop	si
prnext:
	lodsb
	test	al,al
	jz 	prdone
	mov	ah,0x0e
	mov	bx,0x1
	int	0x10
	jmp	prnext
prdone:
	jmp	[si]
;;; ========================================================
	times	510-($-$$) db 0
			   db 0x55,0xaa