%include "pm.inc"

	PageDirBase	equ	200000h ;页目录开始地址:2M
	PageTblBase	equ	201000h ;页表开始地址:2M+4K

	org	0100h
	jmp	LABEL_BEGIN
	[SECTION .gdt]
	;; GDT
	;; Section			base addr	Limit		Attr
	;; Blank Desc
LABEL_GDT:		Descriptor	0,		0,		0
LABEL_DESC_NORMAL:	Descriptor	0,		0ffffh,		DA_DRW
LABEL_DESC_PAGE_DIR:	Descriptor	PageDirBase,	4095,		DA_DRW ;Page Directory
LABEL_DESC_PAGE_TBL:	Descriptor	PageTblBase,	1023,		DA_DRW|DA_LIMIT_4K ;Page Tables
LABEL_DESC_CODE32:	Descriptor	0,		SegCode32Len-1,	DA_C+DA_32
LABEL_DESC_CODE16:	Descriptor	0,		0ffffh,		DA_C
LABEL_DESC_DATA:	Descriptor	0,		DataLen-1,	DA_DRW
LABEL_DESC_STACK:	Descriptor	0,		TopOfStack,	DA_DRWA+DA_32
LABEL_DESC_VIDEO:	Descriptor	0B8000h,	0ffffh,		DA_DRW
	;; GDT End

	GdtLen	equ	$-LABEL_GDT ;GDT length
	GdtPtr	dw	GdtLen-1    ;GDT Limit
		dd	0
	;; GDT selector
	SelectorNormal	equ	LABEL_DESC_NORMAL - LABEL_GDT
	SelectorPageDir	equ	LABEL_DESC_PAGE_DIR - LABEL_GDT
	SelectorPageTbl	equ	LABEL_DESC_PAGE_TBL - LABEL_GDT
	SelectorCode32	equ	LABEL_DESC_CODE32 - LABEL_GDT
	SelectorCode16	equ	LABEL_DESC_CODE16 - LABEL_GDT
	SelectorData	equ	LABEL_DESC_DATA	- LABEL_GDT
	SelectorStack	equ	LABEL_DESC_STACK - LABEL_GDT
	SelectorVideo	equ	LABEL_DESC_VIDEO - LABEL_GDT
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
	call 	SetupPaging
	
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
	;; Stop
	jmp	SelectorCode16:0

	;; 启动分页机制-------------------------------------------
SetupPaging:
	;; 为简化处理，所有线性地址对应相等的物理地址

	;; 首先初始化页目录
	mov	ax,SelectorPageDir ;此段首地址为PageDirBase
	mov	es,ax
	mov	ecx,1024	;共1K个表项
	xor	edi,edi
	xor	eax,eax
	mov	eax,PageTblBase|PG_P|PG_USU|PG_RWW
.1:
	stosd
	add	eax,4096	;为了简化，所有页表在内存中是连续的
	loop	.1

	;; 再初始化所有页表(1K个，4M内存空间)
	mov	ax,SelectorPageTbl ;此段首地址为PageTblBase
	mov	es,ax
	mov	ecx,1024*1024	;共1M个表项，也即有1M个页
	xor	edi,edi
	xor	eax,eax
	mov	eax,PG_P|PG_USU|PG_RWW
.2:
	stosd
	add 	eax,4096	;每一页指向4K的空间
	loop	.2

	mov	eax,PageDirBase
	mov	cr3,eax
	mov	eax,cr0
	or 	eax,80000000h
	mov	cr0,eax
	jmp	short .3
.3:
	nop

	ret
	
	;; 分页机制启动完毕--------------------------------------

	SegCode32Len	equ	$-LABEL_SEG_CODE32
	;; END of [SECTION .32]

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
	and 	eax,7ffffffeh	;PE=0,PG=0
	mov	cr0,eax

LABEL_GO_BACK_TO_REAL:
	jmp	0:LABEL_REAL_ENTRY

	Code16Len	equ $-LABEL_SEG_CODE16
	;; End of [SECTION .s16code]