	org	0100h		;调试状态，做成.COM文件，可调试

	jmp	short LABEL_START ;Start to boot.

%include "fat12hdr.inc"
%include "load.inc"
%include "pm.inc"

; GDT
;                            段基址     段界限, 属性
LABEL_GDT:	    Descriptor 0,            0, 0              ; 空描述符
LABEL_DESC_FLAT_C:  Descriptor 0,      0fffffh, DA_CR|DA_32|DA_LIMIT_4K ;0-4G
LABEL_DESC_FLAT_RW: Descriptor 0,      0fffffh, DA_DRW|DA_32|DA_LIMIT_4K;0-4G
LABEL_DESC_VIDEO:   Descriptor 0B8000h, 0ffffh, DA_DRW|DA_DPL3 ; 显存首地址

GdtLen		equ	$ - LABEL_GDT
GdtPtr		dw	GdtLen - 1				; 段界限
		dd	BaseOfLoaderPhyAddr + LABEL_GDT		; 基地址

; GDT 选择子
SelectorFlatC		equ	LABEL_DESC_FLAT_C	- LABEL_GDT
SelectorFlatRW		equ	LABEL_DESC_FLAT_RW	- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT + SA_RPL3	
BaseOfStack		equ	0100h	; 调试状态下堆栈基地址(栈底, 从这个位置向低地址生长)

LABEL_START:			;从这里开始
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	sp,BaseOfStack

	mov	dh,0		;"Loading "
	call	DispStrRealMode	;显示字符串

	;; 得到内存数
	mov	ebx,0		;ebx=后续值，开始时需为0
	mov	di,_MemChkBuf	;es:di 指向一个地址范围描述符结构
.MemChkLoop:
	mov	eax,0e820h
	mov	ecx,20
	mov	edx,0534d4150h
	int	15h
	jc	.MemChkFail
	add	di,20
	inc	dword[_dwMCRNumber] ;dwMCRNumber=ARDS的个数
	cmp	ebx,0
	jne	.MemChkLoop
	jmp	.MemChkOK
.MemChkFail:
	mov	dword[_dwMCRNumber],0
.MemChkOK:
	
	;; 下面在A盘的根目录寻找KERNEL.BIN
	mov	word[wSectorNo],SectorNoOfRootDirectory
		
	;; 软驱复位
	xor	ah,ah
	xor	dl,dl
	int	13h

LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp	word[wRootDirSizeForLoop],0 ;判断根目录是否已经读完
	jz	LABEL_NO_KERNELBIN	    ;如果读完表示没有找到KERNEL.BIN
	dec	word[wRootDirSizeForLoop]
	mov	ax,BaseOfKernelFile
	mov	es,ax			; es <- BaseOfKernelFile
	mov	bx,OffsetOfKernelFile 	; bx <- OffsetOfKernelFile
	mov	ax,[wSectorNo]		; ax <- Root Directory 中的某扇区号
	mov	cl,1
	call	ReadSector

	mov	si,KernelFileName 	; ds:si -> "KERNEL  BIN"
	mov	di,OffsetOfKernelFile	; es:di -> BaseOfLoader:0100
	cld
	mov	dx,10h
LABEL_SEARCH_FOR_KERNELBIN:
	cmp	dx,0		;循环次数控制
	jz	LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR ;如果已经读完了一个Sector
	dec	dx
	mov	cx,11
LABEL_CMP_FILENAME:
	cmp	cx,0
	jz	LABEL_FILENAME_FOUND ;如果比较了11个字符都相等，表示找到
	dec	cx
	lodsb
	cmp	al,byte[es:di]
	jz	LABEL_GO_ON
	jmp	LABEL_DIFFERENT

LABEL_GO_ON:
	inc	di
	jmp	LABEL_CMP_FILENAME ;继续循环

LABEL_DIFFERENT:
	and	di,0ffe0h	;di &=e0 是为了让它指向本条目开头
	add	di,20h		;下一个目录条目
	mov	si,KernelFileName ;
	jmp	LABEL_SEARCH_FOR_KERNELBIN

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add	word[wSectorNo],1
	jmp	LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_KERNELBIN:
	mov	dh,2		;“No KERNEL.”
	call	DispStr		;显示字符串

	%ifdef	_BOOT_DEBUG_
	mov	ax, 4c00h		; `.
	int	21h			; /  没有找到 LOADER.BIN, 回到 DOS
%else
	jmp	$			; 没有找到 LOADER.BIN, 死循环在这里
%endif

LABEL_FILENAME_FOUND:			; 找到 LOADER.BIN 后便来到这里继续
	mov	ax,RootDirSectors
	and	di,0fff0h	; di -> 当前条目的开始 boot.s 为0ffe0，应该效果一样，目录项长度为32为，二进制最后五位总是0 

	push	eax
	mov	eax,[es:di+01ch]
	mov	dword[dwKernelSize],eax ;/ 保存KERNEL.BIN
	pop	eax
	
	add	di,01ah		; di -> 首 Sector
	mov	cx,word[es:di]
	push	cx		;保存此Sector在FAT中的序号
	add	cx,ax
	add	cx,DeltaSectorNo ;cl <- KERNEL.BIN的起始扇区号(0-based)
	mov	ax,BaseOfKernelFile
	mov	es,ax		  ; es <- BaseOfKernelFile
	mov	bx,OffsetOfKernelFile ; bx <- OffsetOfKernelFile
	mov	ax,cx		  ; ax <- Sector 号
LABEL_GOON_LOADING_FILE:
	push	ax
	push	bx
	mov	ah,0eh		; 每读一个扇区就在 "Booting  " 后面打一个点
	mov	al,'.'
	mov	bl,0fh
	int 	10h
	pop	bx
	pop	ax

	mov	cl,1
	call	ReadSector

	pop	ax		;取出此Sector在FAT中的序号
	call	GetFATEntry
	cmp	ax,0fffh
	jz	LABEL_FILE_LOADED
	push	ax		;保存Sector在FAT中的序号
	mov	dx,RootDirSectors
	add	ax,dx
	add	ax,DeltaSectorNo
	add	bx,[BPB_BytsPerSec]
	jmp	LABEL_GOON_LOADING_FILE
LABEL_FILE_LOADED:
	CALL 	KillMotor 	;关闭软驱马达

	;;mov	dh,1		;"Ready."
	;;call	DispStrRealMode

	;; 下面准备跳入保护模式
	;; 加载GDTR
	lgdt	[GdtPtr]

	;; 关中断
	cli

	;; 打开地址线A20
	in	al,92h
	or	al,00000010b
	out	92h,al

	;; 准备切换到保护模式
	mov	eax,cr0
	or	eax,1
	mov	cr0,eax

	;; 真正进入保护模式
	jmp	dword	SelectorFlatC:(BaseOfLoaderPhyAddr+LABEL_PM_START)
;;;==========================================================================
;;; 变量
;Root　Directory占用的扇区数,在循环中会递减至0
wRootDirSizeForLoop	dw	RootDirSectors 
wSectorNo		dw	0 ;要读取的扇区号
bOdd			db	0 ;奇数还是偶数
dwKernelSize		dd	0 ;KERNEL.BIN文件大小
;;; 字符串
KernelFileName		db	"KERNEL  BIN",0
;;; 为简化代码，下面每个字符串的长度均为 MessageLength
; 为简化代码, 下面每个字符串的长度均为 MessageLength
MessageLength		equ	9
LoadMessage:		db	"Loading  "
Message1		db	"Ready.   " ; 9字节, 不够则用空格补齐. 序号 1
Message2		db	"No KERNEL" ; 9字节, 不够则用空格补齐. 序号 2
Message3		db	"FOUND    " ; 9字节, 不够则用空格补齐. 序号 3
;;; ============================================================

;;; -----------------------------------------------------
;;; DispStrRelMode
;;; 	显示一个字符串，函数开始时dh中应该是字符串序号(0-based)

DispStrRealMode:
	mov	ax,MessageLength
	mul	dh
	add	ax,LoadMessage
	mov	bp,ax		;ES:BP=串地址
	mov	ax,ds
	mov	es,ax
	mov	cx,MessageLength
	mov	ax,01301h	;AH=13,AL=01h
	mov	bx,0007h
	mov	dl,0
	int	10h
	ret
	
;;; -----------------------------------------------------------------
;;; 函数名:ReadSector
;;; -------------------------------
;;; 从第ax个Sector开始，将cl个Sector读入es:bx中
ReadSector:
	;; ------------------------------------------------
	;; 由逻辑扇区号求扇区在磁盘中的位置(扇区号->柱面号,起始扇区，磁头号)
	;; 设扇区号为x
	;;			  ┌ 柱面号=y>>1
	;; 	x	   ┌ 商y  ┤
	;; --------------=>┤      └ 磁头号=y&1
	;; 　每磁道扇区数     │
	;;                 └ 余z => 起始扇区号=z+1
	push	bp
	mov	bp,sp
	sub	esp,2		;辟出两个字节的堆栈区域保存要读的扇区数:byte[bp-2]

	mov	byte[bp-2],cl
	push	bx		;保存bx
	mov	bl,[BPB_SecPerTrk] ;bl:除数
	div	bl		   ;y在al中，z在ah中
	inc	ah		   ;z++
	mov	cl,ah		   ;cl<-起始扇区数
	mov	dh,al		   ;dh<-y
	shr	al,1		   ;y>>1(y/BPB_NumHeads
	mov	ch,al		   ;ch<-柱面号
	and	dh,1		   ;dh&1=磁头号
	pop	bx		   ;回复bx
	;; 柱面号，起始扇区，磁头号全部得到
	mov	dl,[BS_DrvNum]	;驱动器号(0 表示Ａ盘)
.GoOnReading:
	mov	ah,2		;读
	mov	al,byte[bp-2]	;读al个扇区
	int	13h
	jc	.GoOnReading	;如果读取错误CF会被置为１，这时就不停地读，直到正确为止

	add	esp,2
	pop	bp

	ret
;;; -----------------------------------------------------------------
;;; 函数名：GetFATEntry
;;; 作用:
;;; 	找到序号为ax的Sector在FAT中的条目，结果放在ax中
;;;  	需要注意的是，中间需要读FAT的扇区到es:bx处，所以函数一开始保存了es和bx
GetFATEntry:
	push	es
	push 	bx
	push	ax
	mov	ax,BaseOfKernelFile
	sub	ax,0100h	;在BaseOfLoader后面留出4K空间用户存放FAT
	mov	es,ax
	pop	ax
	mov	byte[bOdd],0
	mov	bx,3
	mul	bx		;dx:ax=ax*3
	mov	bx,2
	div	bx		;div:ax/2==>ax<-商，dx<-余数
	cmp	dx,0
	jz	LABEL_EVEN
	mov	byte[bOdd],1
LABEL_EVEN:			;偶数
	;; 现在ax中是FATEntry在FAT中的偏移量，下面来计算FATEntry在
	;; 哪个扇区中(FAT占用不止一个扇区)
	xor	dx,dx
	mov	bx,[BPB_BytsPerSec]
	;; dx:ax/BPB/BytePersec
	;; ax<-商(FATEnry所在的扇区相对于FAT的扇区号)
	;; dx<-余数(FATEntry在扇区内的偏移)
	div	bx
	push	dx
	mov	bx,0		;bx<-0 ex:bx=(BaseOfLoader-100):00
	add	ax,SectorNoOfFAT1 ;此句之后的ax就是FATEntry所在的扇区号
	mov	cl,2
	;; 读取FATEntry所在的扇区，一次读两个，避免在边界发生错误
	;; 因为一个FATEntry可能跨越两个扇区
	call	ReadSector
	pop	dx
	add	bx,dx
	mov	ax,[es:bx]
	cmp	byte[bOdd],1
	jnz	LABEL_EVEN_2
	shr	ax,4
LABEL_EVEN_2:
	and 	ax,0fffh
LABEL_GET_FAT_ENTRY_OK:
	pop	bx
	pop	es
	ret
;;; --------------------------------------------------------------------
;;; KillMotor
;;; 	关闭软驱马达		
KillMotor:
	push	dx
	mov	dx,03f2h
	mov	al,0
	out	dx,al
	pop	dx
	ret
	
;;; ======================================================
;;; 从此以后的代码在保护模式下执行
;;; 32位代码段，由实模式跳入
	[SECTION .32]
	ALIGN	32
	[BITS 	32]
LABEL_PM_START:
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	ax,SelectorFlatRW
	mov	ds,ax
	mov	es,ax
	mov	fs,ax
	mov	ss,ax
	mov	esp,TopOfStack

	push	szMemChkTitle
	call	DispStr
	add	esp,4

	call	DispMemInfo
	call	SetupPaging

	call	InitKernel

	;jmp	$

	;***************************************************************
	jmp	SelectorFlatC:KernelEntryPointPhyAddr	; 正式进入内核 *
	;***************************************************************
	
%include "lib.inc"

;;; 显示内存信息---------------------------------------------
DispMemInfo:
	push	esi
	push	edi
	push	ecx

	mov	esi, MemChkBuf
	mov	ecx, [dwMCRNumber];for(int i=0;i<[MCRNumber];i++)//每次得到一个ARDS
.loop:				  ;{
	mov	edx, 5		  ;  for(int j=0;j<5;j++)//每次得到一个ARDS中的成员
	mov	edi, ARDStruct	  ;  {//依次显示:BaseAddrLow,BaseAddrHigh,LengthLow
.1:				  ;               LengthHigh,Type
	push	dword [esi]	  ;
	call	DispInt		  ;    DispInt(MemChkBuf[j*4]); // 显示一个成员
	pop	eax		  ;
	stosd			  ;    ARDStruct[j*4] = MemChkBuf[j*4];
	add	esi, 4		  ;
	dec	edx		  ;
	cmp	edx, 0		  ;
	jnz	.1		  ;  }
	call	DispReturn	  ;  printf("\n");
	cmp	dword [dwType], 1 ;  if(Type == AddressRangeMemory)
	jne	.2		  ;  {
	mov	eax, [dwBaseAddrLow];
	add	eax, [dwLengthLow];
	cmp	eax, [dwMemSize]  ;    if(BaseAddrLow + LengthLow > MemSize)
	jb	.2		  ;
	mov	[dwMemSize], eax  ;    MemSize = BaseAddrLow + LengthLow;
.2:				  ;  }
	loop	.loop		  ;}
				  ;
	call	DispReturn	  ;printf("\n");
	push	szRAMSize	  ;
	call	DispStr		  ;printf("RAM size:");
	add	esp, 4		  ;
				  ;
	push	dword [dwMemSize] ;
	call	DispInt		  ;DispInt(MemSize);
	add	esp, 4		  ;

	pop	ecx
	pop	edi
	pop	esi
	ret

; 启动分页机制 --------------------------------------------------------------
SetupPaging:
	; 根据内存大小计算应初始化多少PDE以及多少页表
	xor	edx, edx
	mov	eax, [dwMemSize]
	mov	ebx, 400000h	; 400000h = 4M = 4096 * 1024, 一个页表对应的内存大小
	div	ebx
	mov	ecx, eax	; 此时 ecx 为页表的个数，也即 PDE 应该的个数
	test	edx, edx
	jz	.no_remainder
	inc	ecx		; 如果余数不为 0 就需增加一个页表
.no_remainder:
	push	ecx		; 暂存页表个数

	; 为简化处理, 所有线性地址对应相等的物理地址. 并且不考虑内存空洞.

	; 首先初始化页目录
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase	; 此段首地址为 PageDirBase
	xor	eax, eax
	mov	eax, PageTblBase | PG_P  | PG_USU | PG_RWW
.1:
	stosd
	add	eax, 4096		; 为了简化, 所有页表在内存中是连续的.
	loop	.1

	; 再初始化所有页表
	pop	eax			; 页表个数
	mov	ebx, 1024		; 每个页表 1024 个 PTE
	mul	ebx
	mov	ecx, eax		; PTE个数 = 页表个数 * 1024
	mov	edi, PageTblBase	; 此段首地址为 PageTblBase
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; 每一页指向 4K 的空间
	loop	.2

	mov	eax, PageDirBase
	mov	cr3, eax
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	jmp	short .3
.3:
	nop

	ret
; 分页机制启动完毕 ----------------------------------------------------------

;;; -------------------------------------------------------------------
;;; InitKernel
;;; 将 KERNEL.BIN的内容经过整理对齐后放到新的位置
;;; 遍历每一个Program Header,根据Program Header中的信息来确定把什么放进内存
;;; 放到什么位置，以及放多少
InitKernel:
	xor	esi,esi
	;; ecx <-pELFHdr->e_phnum
	mov	cx,word[BaseOfKernelFilePhyAddr+2ch] 
	movzx	ecx,cx

	;; esi <- pELEHdr->e_phoff
	mov	esi,[BaseOfKernelFilePhyAddr+1ch]

	;; esi <-OffsetOfKernel+pELEHdr->e_phoff
	add	esi,BaseOfKernelFilePhyAddr

.Begin:
	mov	eax,[esi+0]
	cmp	eax,0		;PT_NULL
	jz	.NoAction
	push	dword[esi+010h]	;size
	mov	eax,[esi+04h]
	add	eax,BaseOfKernelFilePhyAddr
	push	eax		;src
	push	dword[esi+08h]	;dst
	call	MemCpy
	add	esp,12
.NoAction:
	add	esi,020h
	dec	ecx
	jnz	.Begin

	ret
;;; InitKernel-------------------------------------------------
	
; SECTION .data1 之开始 ---------------------------------------------------------------------------------------------
[SECTION .data1]

ALIGN	32

LABEL_DATA:
; 实模式下使用这些符号
; 字符串
_szMemChkTitle:	db "BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0
_szRAMSize:	db "RAM size:", 0
_szReturn:	db 0Ah, 0
;; 变量
_dwMCRNumber:	dd 0	; Memory Check Result
_dwDispPos:	dd (80 * 6 + 0) * 2	; 屏幕第 6 行, 第 0 列。
_dwMemSize:	dd 0
_ARDStruct:	; Address Range Descriptor Structure
  _dwBaseAddrLow:		dd	0
  _dwBaseAddrHigh:		dd	0
  _dwLengthLow:			dd	0
  _dwLengthHigh:		dd	0
  _dwType:			dd	0
_MemChkBuf:	times	256	db	0
;
;; 保护模式下使用这些符号
szMemChkTitle		equ	BaseOfLoaderPhyAddr + _szMemChkTitle
szRAMSize		equ	BaseOfLoaderPhyAddr + _szRAMSize
szReturn		equ	BaseOfLoaderPhyAddr + _szReturn
dwDispPos		equ	BaseOfLoaderPhyAddr + _dwDispPos
dwMemSize		equ	BaseOfLoaderPhyAddr + _dwMemSize
dwMCRNumber		equ	BaseOfLoaderPhyAddr + _dwMCRNumber
ARDStruct		equ	BaseOfLoaderPhyAddr + _ARDStruct
	dwBaseAddrLow	equ	BaseOfLoaderPhyAddr + _dwBaseAddrLow
	dwBaseAddrHigh	equ	BaseOfLoaderPhyAddr + _dwBaseAddrHigh
	dwLengthLow	equ	BaseOfLoaderPhyAddr + _dwLengthLow
	dwLengthHigh	equ	BaseOfLoaderPhyAddr + _dwLengthHigh
	dwType		equ	BaseOfLoaderPhyAddr + _dwType
MemChkBuf		equ	BaseOfLoaderPhyAddr + _MemChkBuf


; 堆栈就在数据段的末尾
StackSpace:	times	1024	db	0
TopOfStack	equ	BaseOfLoaderPhyAddr + $	; 栈顶
; SECTION .data1 之结束 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^