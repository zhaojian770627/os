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
LABEL_DESC_PAGE_TBL:	Descriptor	PageTblBase,	4096*8-1,		DA_DRW|DA_LIMIT_4K ;Page Tables
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
	;; 实模式下使用这些符号
	;; 字符串
	SPValueInRealMode	dw	0
	;; string
_szPMMessage:	db	"In Protect Mode now.^-^",0ah,0ah,0 ;diplay in protected
_szMemChkTitle:	db "BaseAddrL BaseAddrH LengthLow LengthHith   Type",0ah,0
_szRAMSize:	db 	"RAM size:",0
_szReturn:	db	0ah,0
	;; 变量
_dwMCRNumber:	dd	0	;Memory Check Result
_dwDispPos:	dd	(80*6+0)*2 ;屏幕第6行，第0列
_dwMemSize:	dd	0

_ARDStruct:			;Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		dd	0

_MemChkBuf:	times	256 db 0
	
	;; 保护模式下使用这些符号
	szPMMessage	equ	_szPMMessage - $$
	szMemChkTitle	equ 	_szMemChkTitle - $$
	szRAMSize	equ 	_szRAMSize - $$
	szReturn	equ	_szReturn - $$
	dwDispPos	equ	_dwDispPos - $$
	dwMemSize	equ	_dwMemSize - $$ 
	dwMCRNumber	equ	_dwMCRNumber - $$
	ARDStruct	equ	_ARDStruct - $$
		dwBaseAddrLow	equ	_dwBaseAddrLow - $$
		dwBaseAddrHigh	equ	_dwBaseAddrHigh - $$
		dwLengthLow	equ	_dwLengthLow - $$
		dwLengthHigh	equ 	_dwLengthHigh - $$
		dwType		equ	_dwType - $$
	MemChkBuf	equ	_MemChkBuf - $$
	
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

	;; 得到内存数
	mov	ebx,0
	mov	di,_MemChkBuf
.loop:
	mov	eax,0e820h
	mov	ecx,20
	mov	edx,0534d4150h
	int 	15h
	jc 	LABEL_MEM_CHK_FAIL
	add	di,20
	inc	dword [_dwMCRNumber]
	cmp	ebx,0
	jne	.loop
	jmp	LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov	dword[_dwMCRNumber],0
LABEL_MEM_CHK_OK:
	

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
	mov	ax,SelectorData
	mov	ds,ax		;Data selector

	mov	es,ax

	mov 	ax,SelectorVideo
	mov	gs,ax

	mov	ax,SelectorStack
	mov	ss,ax		 ;Stack section selector

	mov	esp,TopOfStack

	;; 下面显示一个字符串
	push	szPMMessage	
	call	DispStr
	add	esp,4

	push	szMemChkTitle	
	call	DispStr
	add	esp,4

	call 	DispMemSize	;显示内存信息

	call 	SetupPaging	;启动分页基址
	
	jmp	SelectorCode16:0

	;; 启动分页机制-------------------------------------------
SetupPaging:
	;; 根据内存大小计算应初始化多少PDE以及多少页表
	xor	edx,edx
	mov	eax,[dwMemSize]
	mov	ebx,400000h	;400000h=4M=4096*1024,一个页表对应的内存大小
	div	ebx
	mov	ecx,eax		;此时ecx为页表的个数，也即PDE应该的个数
	test	edx,edx
	jz	.no_remainder
	inc	ecx		;如果余数不为0，就需要增加一个页表
.no_remainder:
	push	ecx		;暂存页表个数

	;; 为简化处理，所有线性地址对应相等的物理地址

	;; 首先初始化页目录
	mov	ax,SelectorPageDir ;此段首地址为PageDirBase
	mov	es,ax
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
	pop	eax		;页表个数
	mov	ebx,1024	;每个页表1024个PTE
	mul	ebx
	mov	ecx,eax		;PTE个数=页表个数*1024
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


DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov	esi,MemChkBuf
	mov	ecx,[dwMCRNumber]
.loop:
	mov	edx,5
	mov	edi,ARDStruct
.1:
	push	dword[esi]
	call	DispInt
	pop	eax
	stosd
	add	esi,4
	dec	edx
	cmp	edx,0
	jnz	.1
	call 	DispReturn
	cmp	dword[dwType],1
	jne	.2
	mov	eax,[dwBaseAddrLow]
	add	eax,[dwLengthLow]
	cmp	eax,[dwMemSize]
	jb	.2
	mov	[dwMemSize],eax
.2:
	loop	.loop

	call 	DispReturn
	push	szRAMSize
	call	DispStr
	add	esp,4

	push	dword[dwMemSize]
	call	DispInt
	add	esp,4

	pop	ecx
	pop	edi
	pop	esi
	ret
	
%include "lib.inc"
	
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