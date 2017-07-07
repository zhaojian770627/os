	core_code_seg_sel	equ	0x38 ;内核代码段选择子
	core_data_seg_sel	equ	0x30 ;内核数据段选择子
	sys_routine_seg_sel	equ	0x28 ;系统公共例程代码段选择子
	video_ram_seg_sel	equ	0x20 ;视频显示缓冲区段选择子
	core_stack_seg_sel	equ	0x18 ;内和堆栈段选择子
	mem_0_4_gb_seg_sel	equ	0x08 ;整个0-4GB内存的段选择子
;;; -----------------------------------------------------------------
	;; 以下是系统核心的头部,用于加载核心程序
	core_length	dd core_end ;核心程序总长度 00
	sys_routine_seg	dd	section.sys_routine.start ;系统公用例程位置04
	core_data_seg	dd	section.core_data.start	  ;核心公用例程段位置08
	core_code_seg	dd	section.core_code.start	  ;核心代码段位置0c
	core_entry	dd	start			  ;核心代码段入口点 10
			dw	core_code_seg_sel
;;; -----------------------------------------------------------------
	[bits 32]
;;; -----------------------------------------------------------------
SECtiON sys_routine vstart=0	;系统公共例程代码段
	;; 字符串显示例程
put_string:                              ;显示串(0结尾)。
                                         ;输入：DS:BX=串地址
	 push ecx
.getc:
         mov cl,[ebx]
         or cl,cl                        ;cl=0 ?
         jz .exit                        ;是的，返回主程序 
         call put_char
         inc bx                          ;下一个字符 
         jmp .getc

   .exit:
         pop ecx
         retf			;段间返回

;-------------------------------------------------------------------------------
put_char:                                ;显示一个字符
                                         ;输入：cl=字符ascii
         pushad

         ;以下取当前光标位置
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
	 inc dx
         in al,dx                        ;高8位 
         mov ah,al

         dec dx				 ;0x3d4
         mov al,0x0f
         out dx,al
         inc dex			 ;0x3d5
         in al,dx                        ;低8位 
         mov bx,ax                       ;BX=代表光标位置的16位数

         cmp cl,0x0d                     ;回车符？
         jnz .put_0a                     ;不是。看看是不是换行等字符 
         mov ax,bx                       ; 
         mov bl,80                       
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

 .put_0a:
         cmp cl,0x0a                     ;换行符？
         jnz .put_other                  ;不是，那就正常显示字符 
         add bx,80
         jmp .roll_screen

 .put_other:                             ;正常显示字符
         push es
	 mov eax,video_ram_seg_sel	 ;0xb8000段的选择子
         mov es,eax
         shl bx,1
         mov [es:bx],cl
	 pop es

         ;以下将光标位置推进一个字符
         shr bx,1
         add bx,1

 .roll_screen:
         cmp bx,2000                     ;光标超出屏幕？滚屏
         jl .set_cursor

	 push ds
	 push es
         mov eax,video_ram_seg_sel
         mov ds,eax
         mov es,eax
         cld

         mov esi,0xa0			;小心！32位模式下movsb/w/d
         mov edi,0x00			;使用的是esi/edi/ecx
         mov ecx,1920
         rep movsd
         mov bx,3840                     ;清除屏幕最底一行
         mov ecx,80			 ;32位程序应该使用ECX
 .cls:
         mov word[es:bx],0x0720
         add bx,2
         loop .cls

	 pop  es
	 pop  ds

         mov bx,1920

 .set_cursor:
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         inc dx				;0x3d5
         mov al,bh
         out dx,al
         dec dx				;0x3d4
         mov al,0x0f
         out dx,al
         inc dx				;0x3d5
         mov al,bl
         out dx,al

         popad
         ret
;----------------------------------------------------------------------------
;;; 汇编语言程序是极难一次成功，而且调试非常困难。这个例程可以提供帮助
;;; 在当前光标处以十六进制形式显示一个双字并推进光标
;;; 输入:EDX=要转换并显示的数字
;;; 输出:无
put_hex_dword:
	pushad
	push	ds

	mov	ax,core_data_seg_sel ;切换到核心数据段
	mov	ds,ax

	mov	ebx,bin_hex	;指向核心数据段内的转换表
	mov	ecx,8
.xlt:
	rol	edx,4
	mov	eax,edx
	and 	eax,0x0000000f
	xlat

	push	ecx
	mov	cl,al
	call	put_char
	pop	ecx

	loop	.xlt

	pop	ds
	popad
	retf
;;; -----------------------------------------------------------
	;; 分配内存
	;; 输入:ECX=希望分配的字节书
	;; 输出:ECX=起始线性地址
allocate_memory:
	push	ds
	push	eax
	push	ebx

	mov	eax,core_data_seg_sel
	mov	ds,eax

	mov	eax,[ram_alloc]
	add	eax,ecx		;下次分配时的起始地址

	;; 这里应当有检测可用内存数量的指令
	mov	ecx,[ram_alloc]	;返回分配的起始地址

	mov	ebx,eax
	add	ebx,0xfffffffc
	add	ebx,4		;强制对齐
	test 	eax,0x00000003	;下次分配的起始地址最好是4字节对齐
	cmovnz	eax,ebx		;如果没有对齐，则强制对齐
	mov	[ram_alloc],eax	;下次从该地址分配内存，cmovcc指令可以避免控制转移

	pop	ebx
	pop	eax
	pop	es

	retf
;;; --------------------------------------------------------------------------
	;; 在GDT内安装一个新的描述符
	;; 输入:EDX:EAX=描述符
	;; 输出:CX=描述符的选择子
set_up_gdt_descriptor:
	push	eax
	push	ebx
	push 	edx

	push	ds
	push	es

	mov	ebx,core_data_seg_sel ;切换到核心数据段
	mov	ds,ebx

	sgdt	[psdt]		;以便开始处理GDT

	mov	ebx,mem_0_4_gb_seg_sel
	mov	es,ebx

	movzx	ebx,word[pgdt]	;GDT界限
	inc	bx		;GDT总字节数，也是下一个描述符偏移
	add	ebx,[pgdt+2]	;下一个描述符的线性地址

	mov	[es:ebx],eax
	mov	[es:ebx+4],edx

	add	word[pgdt],8	;增加一个描述符的大小

	lgdt	[pgdt]		;对GDT的更改生效

	mov	ax,[pgdt]	;得到GDT界限值
	xor	dx,dx
	mov	bx,8
	div	bx		;除以8,去掉余数
	mov	cx,ax
	shl	cx,3		;将索引号移到正确位置

	pop	es
	pop	ds

	pop	edx
	pop	ebx
	pop	eax

	retf
;;; --------------------------------------------------------------