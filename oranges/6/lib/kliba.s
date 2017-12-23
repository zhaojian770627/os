
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                              klib.asm
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                                                       Forrest Yu, 2005
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%include "sconst.inc"

extern disp_pos
	
[SECTION .text]

; 导出函数
global	disp_str
global	disp_color_str
global  put_string
global	out_byte
global	in_byte
global	enable_irq
global	disable_irq
	
; ========================================================================
;                  void disp_str(char * info);
; ========================================================================
disp_str:
	push	ebp
	mov	ebp, esp

	mov	esi, [ebp + 8]	; pszInfo
	mov	edi, [disp_pos]
	mov	ah, 0Fh
.1:
	lodsb
	test	al, al
	jz	.2
	cmp	al, 0Ah	; 是回车吗?
	jnz	.3
	push	eax
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	eax
	jmp	.1
.3:
	mov	[gs:edi], ax
	add	edi, 2
	jmp	.1

.2:
	mov	[disp_pos], edi

	pop	ebp
	ret
; ========================================================================
;                  void disp_color_str(char * info, int color);
; ========================================================================
disp_color_str:
	push	ebp
	mov	ebp, esp

	mov	esi, [ebp + 8]	; pszInfo
	mov	edi, [disp_pos]
	mov	ah, [ebp + 12]	; color
.1:
	lodsb
	test	al, al
	jz	.2
	cmp	al, 0Ah	; 是回车吗?
	jnz	.3
	push	eax
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	eax
	jmp	.1
.3:
	mov	[gs:edi], ax
	add	edi, 2
	jmp	.1

.2:
	mov	[disp_pos], edi

	pop	ebp
	ret
	
; ========================================================================
;                  void out_byte(u16 port, u8 value);
; ========================================================================
out_byte:
	mov	edx, [esp + 4]		; port
	mov	al, [esp + 4 + 4]	; value
	out	dx, al
	nop	; 一点延迟
	nop
	ret

; ========================================================================
;                  u8 in_byte(u16 port);
; ========================================================================
in_byte:
	mov	edx, [esp + 4]		; port
	xor	eax, eax
	in	al, dx
	nop	; 一点延迟
	nop
	ret

;===================================================================
         ;字符串显示例程
put_string:                                 ;显示0终止的字符串并移动光标 
                                            ;输入：DS:EBX=串地址
	push	ebp
	mov	ebp,esp

	push 	ebx
	push	ecx

	mov	ebx,[ebp+8]
	
	cli			;硬件操作期间，关中断
.getc:
        mov 	cl,[ebx]
        test	cl,cl
        jz 	.exit
        call 	put_char
        inc 	ebx
        jmp 	.getc

.exit:
	sti			;硬件操作完毕，开放中断
	
        pop 	ecx
	pop	ebx
	pop	ebp
	
        ret                               ;段间返回

;--------------------------------------------------------------------
put_char:                                   ;在当前光标处显示一个字符,并推进
                                            ;光标。仅用于段内调用 
                                            ;输入：CL=字符ASCII码 
        pushad

        ;以下取当前光标位置
        mov 	dx,0x3d4
        mov 	al,0x0e
        out 	dx,al
        inc 	dx                             ;0x3d5
        in 	al,dx                           ;高字
        mov 	ah,al

        dec 	dx                             ;0x3d4
        mov 	al,0x0f
        out 	dx,al
        inc 	dx                             ;0x3d5
        in 	al,dx                           ;低字
        mov 	bx,ax                          ;BX=代表光标位置的16位数
	and	ebx,0x0000ffff		    ;准备使用32位寻址方式访问显存
	
        cmp 	cl,0x0d                        ;回车符？
        jnz 	.put_0a
	
        mov 	ax,bx
        mov 	bl,80
        div 	bl
        mul 	bl
        mov 	bx,ax
        jmp 	.set_cursor

.put_0a:
        cmp 	cl,0x0a                        ;换行符？
        jnz 	.put_other
        add 	bx,80
        jmp 	.roll_screen

.put_other:                               ;正常显示字符
	shl	bx,1
	mov	[gs:ebx],cl ;在光标位置处显示字符
	
        ;以下将光标位置推进一个字符
        shr 	bx,1
        inc 	bx

.roll_screen:
        cmp 	bx,2000                        ;光标超出屏幕？滚屏
        jl 	.set_cursor
		
        cld
	push	ds
	push	es
	
	push 	gs
	pop 	ds
	push	gs
	pop	es
	mov 	esi,0x0a0                 ;小心！32位模式下movsb/w/d 
	mov	edi,0x000		       ;使用的是esi/edi/ecx
        mov 	ecx,1920
        rep 	movsd

	pop	es
	pop	ds
	
        mov 	bx,3840                        ;清除屏幕最底一行
        mov 	ecx,80                         ;32位程序应该使用ECX
.cls:
        mov 	word[gs:ebx],0x0720
        add 	bx,2
        loop 	.cls

        mov 	bx,1920

.set_cursor:
        mov 	dx,0x3d4
        mov 	al,0x0e
        out 	dx,al
        inc 	dx                             ;0x3d5
        mov 	al,bh
        out 	dx,al
        dec 	dx                             ;0x3d4
        mov 	al,0x0f
        out 	dx,al
        inc 	dx                             ;0x3d5
        mov 	al,bl
        out 	dx,al

        popad
        ret

; ========================================================================
;                  void disable_irq(int irq);
; ========================================================================
; Disable an interrupt request line by setting an 8259 bit.
; Equivalent code:
;	if(irq < 8)
;		out_byte(INT_M_CTLMASK, in_byte(INT_M_CTLMASK) | (1 << irq));
;	else
;		out_byte(INT_S_CTLMASK, in_byte(INT_S_CTLMASK) | (1 << irq));
disable_irq:
        mov     ecx, [esp + 4]          ; irq
        pushf
        cli
        mov     ah, 1
        rol     ah, cl                  ; ah = (1 << (irq % 8))
        cmp     cl, 8
        jae     disable_8               ; disable irq >= 8 at the slave 8259
disable_0:
        in      al, INT_M_CTLMASK
        test    al, ah
        jnz     dis_already             ; already disabled?
        or      al, ah
        out     INT_M_CTLMASK, al       ; set bit at master 8259
        popf
        mov     eax, 1                  ; disabled by this function
        ret
disable_8:
        in      al, INT_S_CTLMASK
        test    al, ah
        jnz     dis_already             ; already disabled?
        or      al, ah
        out     INT_S_CTLMASK, al       ; set bit at slave 8259
        popf
        mov     eax, 1                  ; disabled by this function
        ret
dis_already:
        popf
        xor     eax, eax                ; already disabled
        ret

; ========================================================================
;                  void enable_irq(int irq);
; ========================================================================
; Enable an interrupt request line by clearing an 8259 bit.
; Equivalent code:
;       if(irq < 8)
;               out_byte(INT_M_CTLMASK, in_byte(INT_M_CTLMASK) & ~(1 << irq));
;       else
;               out_byte(INT_S_CTLMASK, in_byte(INT_S_CTLMASK) & ~(1 << irq));
;
enable_irq:
        mov     ecx, [esp + 4]          ; irq
        pushf
        cli
        mov     ah, ~1
        rol     ah, cl                  ; ah = ~(1 << (irq % 8))
        cmp     cl, 8
        jae     enable_8                ; enable irq >= 8 at the slave 8259
enable_0:
        in      al, INT_M_CTLMASK
        and     al, ah
        out     INT_M_CTLMASK, al       ; clear bit at master 8259
        popf
        ret
enable_8:
        in      al, INT_S_CTLMASK
        and     al, ah
        out     INT_S_CTLMASK, al       ; clear bit at slave 8259
        popf
        ret