;;; 编译链接方法
;;; nasm -f elf64 hello.s -o hello.o
;;; ld -s hello.o -o hello
;;; ./hello
;;; https://www.cnblogs.com/lxq20135309/p/5551658.html
[section .data]			;数据在此
	strHello	db	"Hello,world!",0ah
	STRLEN		equ	$-strHello

[section .text]			;代码在此
global	_start			;必须导出_start这个入口，以便让链接器识别

_start:
	mov	edx,STRLEN
	mov	ecx,strHello
	mov	ebx,1
	mov	eax,4		;sys_write
	int 	0x80		;系统调用
	mov	ebx,0
	mov	eax,1		;sys_exit
	int 	0x80		;系统调用
	