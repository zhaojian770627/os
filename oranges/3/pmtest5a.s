%include "pm.inc"
	org	0100h
	jmp	LABEL_BEGIN
	[SECTION .gdt]
	;; GDT
	;; Section			base addr	Limit		Attr
	;; Blank Desc
LABEL_GDT:		Descriptor	0,		0,		0
LABEL_DESC_NORMAL:	Descriptor	0,		0ffffh,		DA_DRW
LABEL_DESC_CODE32:	Descriptor	0,		SegCode32Len-1,	DA_C+DA_32
LABEL_DESC_CODE16:	Descriptor	0,		0ffffh,		DA_C
LABEL_DESC_CODE_DEST:	Descriptor	0,		SegCodeDestLen-1,	DA_C+DA_32
LABEL_DESC_CODE_RING3:	Descriptor 	0,		SegCodeRing3Len-1,	DA_C+DA_32+DA_DPL3
LABEL_DESC_DATA:	Descriptor	0,		DataLen-1,	DA_DRW
LABEL_DESC_STACK:	Descriptor	0,		TopOfStack,	DA_DRWA+DA_32
LABEL_DESC_STACK3:	Descriptor 	0,		TopOfStack3,	DA_DRWA+DA_32+DA_DPL3 ;32位
LABEL_DESC_LDT:		Descriptor	0h,		LDTLen-1,	DA_LDT

LABEL_DESC_VIDEO:	Descriptor	0B8000h,	0ffffh,		DA_DRW+DA_DPL3

	;; Gate				Target Selector		offset	DCount	Attribute
LABEL_CALL_GATE_TEST:	Gate		SelectorCodeDest,	0,	0,	DA_386CGate+DA_DPL0
	
	;; GDT End

	GdtLen	equ	$-LABEL_GDT ;GDT length
	GdtPtr	dw	GdtLen-1    ;GDT Limit
		dd	0
	;; GDT selector
	SelectorNormal	equ	LABEL_DESC_NORMAL - LABEL_GDT
	SelectorCode32	equ	LABEL_DESC_CODE32 - LABEL_GDT
	SelectorCode16	equ	LABEL_DESC_CODE16 - LABEL_GDT
	SelectorCodeDest equ	LABEL_DESC_CODE_DEST-LABEL_GDT
	SelectorCodeRing3 equ	LABEL_DESC_CODE_RING3 - LABEL_GDT+SA_RPL3
	SelectorData	equ	LABEL_DESC_DATA	- LABEL_GDT
	SelectorStack	equ	LABEL_DESC_STACK - LABEL_GDT
	SelectorStack3	equ	LABEL_DESC_STACK3 - LABEL_GDT + SA_RPL3
	SelectorLDT 	equ 	LABEL_DESC_LDT - LABEL_GDT
	SelectorVideo	equ	LABEL_DESC_VIDEO - LABEL_GDT


	;; Gate Selector
	SelectorCallGateTest equ LABEL_CALL_GATE_TEST - LABEL_GDT
	
	;; End of [Section .gdt]

	[SECTION .data1]	;data section
	ALIGN 32
	[BITS 32]
LABEL_DATA:
	SPValueInRealMode	dw	0
	;; string
PMMessage:	db	"In Protect Mode now.^-^",0 ;diplay in protected
	OffsetPMMessage	equ	PMMessage - $$
StrTest:	db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ",0
	OffsetStrTest	equ	StrTest - $$
	DataLen	equ	$ - LABEL_DATA
	;; End of [SECTION .data]

	;; global stack sector
	[SECTION .gs]
	ALIGN	32
	[BITS	32]
LABEL_STACK:
	times 	512 db	0

	TopOfStack	equ	$ - LABEL_STACK -1
	;; End of [SECTION .gs]
	

	;; 堆栈段ring3
	[SECTION .s3]
	ALIGN	32
	[BITS	32]
LABEL_STACK3:
	times	512 db 0
	TopOfStack3 equ  $ - LABEL_STACK3-1
	;; END of [SECTION .s3]

	
	[SECTION .s16]
	[BITS 16]
LABEL_BEGIN:
	mov 	ax,cs
	mov 	ds,ax
	mov 	es,ax
	mov 	ss,ax
	mov 	sp,0100h

	mov	[LABEL_GO_BACK_TO_REAL+3],ax
	mov	[SPValueInRealMode],sp

	;; Init 16bit Code desc
	mov	ax,cs
	movzx	eax,ax
	shl	eax,4
	add	eax,LABEL_SEG_CODE16
	mov	word[LABEL_DESC_CODE16+2],ax
	shr	eax,16
	mov	byte[LABEL_DESC_CODE16+4],al
	mov	byte[LABEL_DESC_CODE16+7],ah
	
	;; Init 32bit section descriptor
	xor	eax,eax
	mov 	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_CODE32
	mov	word[LABEL_DESC_CODE32+2],ax
	shr 	eax,16
	mov	byte[LABEL_DESC_CODE32+4],al
	mov	byte[LABEL_DESC_CODE32+7],ah

	;; Init Test Call Get Code Seg Discrip
	xor 	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_CODE_DEST
	mov 	word[LABEL_DESC_CODE_DEST+2],ax
	shr 	eax,16
	mov	byte[LABEL_DESC_CODE_DEST+4],al
	mov	byte[LABEL_DESC_CODE_DEST+7],ah

	;; Init Data section descriptor
	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_DATA
	mov	word[LABEL_DESC_DATA+2],ax
	shr	eax,16
	mov	byte[LABEL_DESC_DATA+4],al
	mov	byte[LABEL_DESC_DATA+7],ah

	;; Init stack section descriptor
	xor 	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_STACK
	mov	word[LABEL_DESC_STACK+2],ax
	shr	eax,16
	mov	byte[LABEL_DESC_STACK+4],al
	mov	byte[LABEL_DESC_STACK+7],ah

	;; Init stack3 section descriptor
	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add 	eax,LABEL_STACK3
	mov	word[LABEL_DESC_STACK3+2],ax
	shr	eax,16
	mov	byte[LABEL_DESC_STACK3+4],al
	mov	byte[LABEL_DESC_STACK3+7],ah

	;; Init LDT Pos in GDT
	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_LDT
	mov	word[LABEL_DESC_LDT+2],ax
	shr	eax,16
	mov	byte[LABEL_DESC_LDT+4],al
	mov	byte[LABEL_DESC_LDT+7],ah

	;; Init descrptor in LDT
	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_CODE_A
	mov	word[LABEL_LDT_DESC_CODEA+2],ax
	shr	eax,16
	mov	byte[LABEL_LDT_DESC_CODEA+4],al
	mov	byte[LABEL_LDT_DESC_CODEA+7],ah

	;; 初始化Ring3描述符
	xor 	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_CODE_RING3
	mov	word[LABEL_DESC_CODE_RING3+2],ax
	shr	eax,16
	mov	byte[LABEL_DESC_CODE_RING3+4],al
	mov	byte[LABEL_DESC_CODE_RING3+7],ah
	
	;; prepare load GDTR
	xor	eax,eax
	mov	ax,ds
	shl 	eax,4
	add	eax,LABEL_GDT	;eax<-gdt base addr
	mov 	dword[GdtPtr+2],eax ;[GdtPtr+2]<-gdt base addr

	;; Load GDTR
	lgdt	[GdtPtr]

	;; turn off interupt
	cli

	;; open addr bus A20
	in 	al,92h
	or 	al,00000010b
	out	92h,al

	;; prepare switch protect mode
	mov 	eax,cr0
	or	eax,1
	mov	cr0,eax

	;; in protect mode
	jmp	dword SelectorCode32:0
	;; End of [SECTION .s16]

LABEL_REAL_ENTRY:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ss,ax

	mov	sp,[SPValueInRealMode]

	in 	al,92h
	and 	al,11111101b
	out	92h,al
	sti

	mov	ax,4c00h
	int 	21h
	
	[SECTION .s32]		;32bit code
	[BITS	32]
LABEL_SEG_CODE32:
	mov	ax,SelectorData
	mov	ds,ax		;Data selector
	mov 	ax,SelectorVideo
	mov	gs,ax

	mov	ax,SelectorStack
	mov	ss,ax		 ;Stack section selector

	mov	esp,TopOfStack

	;; Display a string
	
	mov	ah,0ch		 ;red on black
	xor	esi,esi
	xor	edi,edi
	mov	esi,OffsetPMMessage ;source
	mov	edi,(80*10+0)*2	    ;
	cld

.1:
	lodsb
	test	al,al
	jz	.2
	mov	[gs:edi],ax
	add	edi,2
	jmp	.1

	 
.2:	  			;;DIsplay over
	call 	DispReturn

	push 	SelectorStack3
	push	TopOfStack3
	push	SelectorCodeRing3
	push	0
	retf
	
	;; Test call get,will print 'c'
	call 	SelectorCallGateTest:0
	
	;; Load LDT
	mov	ax,SelectorLDT
	lldt	ax

	;; jmp local task
	jmp	SelectorLDTCodeA:0

	;; ---------------------------------------
DispReturn:
	push 	eax
	push	ebx
	mov	eax,edi
	mov	bl,160
	div	bl
	and 	eax,0ffh
	inc	eax
	mov	bl,160
	mul	bl
	mov	edi,eax
	pop 	ebx
	pop	eax

	ret
	;; DispReturn End

	SegCode32Len	equ	$-LABEL_SEG_CODE32
	;; END of [SECTION .32]

	[SECTION .sdest]	;Call Get Seg
	[BITS 32]
LABEL_SEG_CODE_DEST:	
	;; jmp	$
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	edi,(80*12+0)*2
	mov	ah,0ch
	mov	al,'C'
	mov	[gs:edi],ax

	retf

	SegCodeDestLen	equ	$-LABEL_SEG_CODE_DEST
	;; END of [SECTION .sdest]
	
	;; 16 Bit Code seg,jmp from 32 bit,switch real mode
	[SECTION .s16code]
	ALIGN 32
	[BITS 16]
LABEL_SEG_CODE16:	
	mov	ax,SelectorNormal
	mov	ds,ax
	mov	es,ax
	mov	fs,ax
	mov	gs,ax
	mov	ss,ax

	mov	eax,cr0
	and 	al,11111110b
	mov	cr0,eax

LABEL_GO_BACK_TO_REAL:
	jmp	0:LABEL_REAL_ENTRY

	Code16Len	equ $-LABEL_SEG_CODE16
	;; End of [SECTION .s16code]

	;; LDT
	[SECTION .ldt]
	ALIGN	32
LABEL_LDT:

LABEL_LDT_DESC_CODEA:	Descriptor 	0,CodeALen-1,DA_C+DA_32 ;Code,32 bit
	
	LDTLen	equ	$-LABEL_LDT

	;; LDT Selector
	SelectorLDTCodeA equ LABEL_LDT_DESC_CODEA -LABEL_LDT+SA_TIL
	;; END of [SECTION .ldt]

	;; CodeA (LDT,32 bit]
	[SECTION .la]
	ALIGN 32
	[BITS 32]
LABEL_CODE_A:
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	edi,(80*13+0)*2
	mov	ah,0ch
	mov	al,'L'
	mov	[gs:edi],ax	

	jmp	SelectorCode16:0
	CodeALen	equ	$-LABEL_CODE_A
	;; END of [SECTION .la]

	;; CodeRing3
	[SECTION .ring3]
	ALIGN	32
	[BITS	32]
LABEL_CODE_RING3:
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	edi,(80*14+0)*2
	mov	ah,0ch
	mov	al,'3'
	mov	[gs:edi],ax

	jmp	$
	SegCodeRing3Len	equ $ - LABEL_CODE_RING3
	;; END of [SECTION .ring3]