	org	07c00h
	mov 	ax,cs
	mov 	ds,ax
	mov	es,ax
	call	DispStr		;Display 
	jmp	$		;un loop
DispStr:
	mov	ax,BootMessage
	mov	bp,ax		;ES:BP= string address
	mov	cx,16		;CX= string length
	mov	ax,01301h	;AH=13,AL=01h
	mov	bx,000ch	;Page 0(BH=0) background black font red
	mov	dl,0
	int 	10h
	ret
BootMessage:
	db	"Hello, OS World!"
	times	510-($-$$)	db	0
	dw	0xaa55