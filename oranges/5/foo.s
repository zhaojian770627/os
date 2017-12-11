extern choose			;int choose(int a,int b)

[section .data]			;数据在此
	num1st	dd	3
	num2nd	dd	4
	
[section .text]			;代码在此
global	_start			;必须导出_start这个入口，以便让链接器识别
global myprint		;

_start:
	push	dword[num2nd]	;
	push	dword[num1st]	; choose(num1st,num2nd)
	call	choose
	add	esp,8

	mov	ebx,0
	mov	eax,1		;sys_exit
	int 	0x80

myprint:
	mov	edx,[esp+8]	;len
	mov	ecx,[esp+4]	;msg
	mov	ebx,1
	mov	eax,4		;sys_write
	int	0x80
	ret