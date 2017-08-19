         ;代码清单13-2
         ;文件名：c13_core.asm
         ;文件说明：保护模式微型核心程序 
         ;创建日期：2011-10-26 12:11

         ;以下常量定义部分。内核的大部分内容都应当固定 
         core_code_seg_sel     equ  0x38    ;内核代码段选择子
         core_data_seg_sel     equ  0x30    ;内核数据段选择子 
         sys_routine_seg_sel   equ  0x28    ;系统公共例程代码段的选择子 
         video_ram_seg_sel     equ  0x20    ;视频显示缓冲区的段选择子
         core_stack_seg_sel    equ  0x18    ;内核堆栈段选择子
         mem_0_4_gb_seg_sel    equ  0x08    ;整个0-4GB内存的段的选择子

;-------------------------------------------------------------------------------
         ;以下是系统核心的头部，用于加载核心程序 
         core_length      dd core_end       ;核心程序总长度#00

         sys_routine_seg  dd section.sys_routine.start
                                            ;系统公用例程段位置#04

         core_data_seg    dd section.core_data.start
                                            ;核心数据段位置#08

         core_code_seg    dd section.core_code.start
                                            ;核心代码段位置#0c


         core_entry       dd start          ;核心代码段入口点#10
                          dw core_code_seg_sel

;===============================================================================
         [bits 32]
;===============================================================================
SECTION sys_routine vstart=0                ;系统公共例程代码段 
;-------------------------------------------------------------------------------
         ;字符串显示例程
put_string:                                 ;显示0终止的字符串并移动光标 
                                            ;输入：DS:EBX=串地址
         push ecx
  .getc:
         mov cl,[ebx]
         or cl,cl
         jz .exit
         call put_char
         inc ebx
         jmp .getc

  .exit:
         pop ecx
         retf                               ;段间返回

;-------------------------------------------------------------------------------
put_char:                                   ;在当前光标处显示一个字符,并推进
                                            ;光标。仅用于段内调用 
                                            ;输入：CL=字符ASCII码 
         pushad

         ;以下取当前光标位置
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         inc dx                             ;0x3d5
         in al,dx                           ;高字
         mov ah,al

         dec dx                             ;0x3d4
         mov al,0x0f
         out dx,al
         inc dx                             ;0x3d5
         in al,dx                           ;低字
         mov bx,ax                          ;BX=代表光标位置的16位数

         cmp cl,0x0d                        ;回车符？
         jnz .put_0a
         mov ax,bx
         mov bl,80
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

  .put_0a:
         cmp cl,0x0a                        ;换行符？
         jnz .put_other
         add bx,80
         jmp .roll_screen

  .put_other:                               ;正常显示字符
         push es
         mov eax,video_ram_seg_sel          ;0xb8000段的选择子
         mov es,eax
         shl bx,1
         mov [es:bx],cl
         pop es

         ;以下将光标位置推进一个字符
         shr bx,1
         inc bx

  .roll_screen:
         cmp bx,2000                        ;光标超出屏幕？滚屏
         jl .set_cursor

         push ds
         push es
         mov eax,video_ram_seg_sel
         mov ds,eax
         mov es,eax
         cld
         mov esi,0xa0                       ;小心！32位模式下movsb/w/d 
         mov edi,0x00                       ;使用的是esi/edi/ecx 
         mov ecx,1920
         rep movsd
         mov bx,3840                        ;清除屏幕最底一行
         mov ecx,80                         ;32位程序应该使用ECX
  .cls:
         mov word[es:bx],0x0720
         add bx,2
         loop .cls

         pop es
         pop ds

         mov bx,1920

  .set_cursor:
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         inc dx                             ;0x3d5
         mov al,bh
         out dx,al
         dec dx                             ;0x3d4
         mov al,0x0f
         out dx,al
         inc dx                             ;0x3d5
         mov al,bl
         out dx,al

         popad
         ret                                

;-------------------------------------------------------------------------------
read_hard_disk_0:                           ;从硬盘读取一个逻辑扇区
                                            ;EAX=逻辑扇区号
                                            ;DS:EBX=目标缓冲区地址
                                            ;返回：EBX=EBX+512
         push eax 
         push ecx
         push edx
      
         push eax
         
         mov dx,0x1f2
         mov al,1
         out dx,al                          ;读取的扇区数

         inc dx                             ;0x1f3
         pop eax
         out dx,al                          ;LBA地址7~0

         inc dx                             ;0x1f4
         mov cl,8
         shr eax,cl
         out dx,al                          ;LBA地址15~8

         inc dx                             ;0x1f5
         shr eax,cl
         out dx,al                          ;LBA地址23~16

         inc dx                             ;0x1f6
         shr eax,cl
         or al,0xe0                         ;第一硬盘  LBA地址27~24
         out dx,al

         inc dx                             ;0x1f7
         mov al,0x20                        ;读命令
         out dx,al

  .waits:
         in al,dx
         and al,0x88
         cmp al,0x08
         jnz .waits                         ;不忙，且硬盘已准备好数据传输 

         mov ecx,256                        ;总共要读取的字数
         mov dx,0x1f0
  .readw:
         in ax,dx
         mov [ebx],ax
         add ebx,2
         loop .readw

         pop edx
         pop ecx
         pop eax
      
         retf                               ;段间返回 

;-------------------------------------------------------------------------------
;汇编语言程序是极难一次成功，而且调试非常困难。这个例程可以提供帮助 
put_hex_dword:                              ;在当前光标处以十六进制形式显示
                                            ;一个双字并推进光标 
                                            ;输入：EDX=要转换并显示的数字
                                            ;输出：无
         pushad
         push ds
      
         mov ax,core_data_seg_sel           ;切换到核心数据段 
         mov ds,ax
      
         mov ebx,bin_hex                    ;指向核心数据段内的转换表
         mov ecx,8
  .xlt:    
         rol edx,4
         mov eax,edx
         and eax,0x0000000f
         xlat
      
         push ecx
         mov cl,al                           
         call put_char
         pop ecx
       
         loop .xlt
      
         pop ds
         popad
         retf
      
;-------------------------------------------------------------------------------
allocate_memory:                            ;分配内存
                                            ;输入：ECX=希望分配的字节数
                                            ;输出：ECX=起始线性地址 
         push ds
         push eax
         push ebx
      
         mov eax,core_data_seg_sel
         mov ds,eax
      
         mov eax,[ram_alloc]
         add eax,ecx                        ;下一次分配时的起始地址
      
         ;这里应当有检测可用内存数量的指令
          
         mov ecx,[ram_alloc]                ;返回分配的起始地址

         mov ebx,eax
         and ebx,0xfffffffc
         add ebx,4                          ;强制对齐 
         test eax,0x00000003                ;下次分配的起始地址最好是4字节对齐
         cmovnz eax,ebx                     ;如果没有对齐，则强制对齐 
         mov [ram_alloc],eax                ;下次从该地址分配内存
                                            ;cmovcc指令可以避免控制转移 
         pop ebx
         pop eax
         pop ds

         retf

;-------------------------------------------------------------------------------
set_up_gdt_descriptor:                      ;在GDT内安装一个新的描述符
                                            ;输入：EDX:EAX=描述符 
                                            ;输出：CX=描述符的选择子
         push eax
         push ebx
         push edx
      
         push ds
         push es
      
         mov ebx,core_data_seg_sel          ;切换到核心数据段
         mov ds,ebx

         sgdt [pgdt]                        ;以便开始处理GDT

         mov ebx,mem_0_4_gb_seg_sel
         mov es,ebx

         movzx ebx,word [pgdt]              ;GDT界限 
         inc bx                             ;GDT总字节数，也是下一个描述符偏移 
         add ebx,[pgdt+2]                   ;下一个描述符的线性地址 
      
         mov [es:ebx],eax
         mov [es:ebx+4],edx
      
         add word [pgdt],8                  ;增加一个描述符的大小   
      
         lgdt [pgdt]                        ;对GDT的更改生效 
       
         mov ax,[pgdt]                      ;得到GDT界限值
         xor dx,dx
         mov bx,8
         div bx                             ;除以8，去掉余数
         mov cx,ax                          
         shl cx,3                           ;将索引号移到正确位置 

         pop es
         pop ds

         pop edx
         pop ebx
         pop eax
      
         retf 
;-------------------------------------------------------------------------------
make_seg_descriptor:                        ;构造存储器和系统的段描述符
                                            ;输入：EAX=线性基地址
                                            ;      EBX=段界限
                                            ;      ECX=属性。各属性位都在原始
                                            ;          位置，无关的位清零 
                                            ;返回：EDX:EAX=描述符
         mov edx,eax
         shl eax,16
         or ax,bx                           ;描述符前32位(EAX)构造完毕

         and edx,0xffff0000                 ;清除基地址中无关的位
         rol edx,8
         bswap edx                          ;装配基址的31~24和23~16  (80486+)

         xor bx,bx
         or edx,ebx                         ;装配段界限的高4位

         or edx,ecx                         ;装配属性

         retf
;;;------------------------------------------------------------
	;; 构造门的描述符（调用门等）
	;; 输入:EAX=门代码在段内偏移地址
	;;      BX=门代码所在段的选择子
	;;      CX=段类型及属性等（各属性
	;; 位都在原始位置)
	;; 返回:EDX:EAX=完整的描述符
make_gate_descriptor:
	push	ebx
	push	ecx

	mov	edx,eax
	and 	edx,0xffff0000	;得到偏移地址高16位
	or	dx,cx		;组装属性部分到EDX
	and	eax,0f0000ffff	;得到偏移地址低16位
	shl	ebx,16
	or	eax,ebx		;组装段选择子部分

	pop	ecx
	pop	ebx

	retf
	
sys_routine_end:	
	
;===============================================================================
SECTION core_data vstart=0                  ;系统核心的数据段
;-------------------------------------------------------------------------------
         pgdt             dw  0             ;用于设置和修改GDT 
                          dd  0

         ram_alloc        dd  0x00100000    ;下次分配内存时的起始地址

         ;符号地址检索表
         salt:
         salt_1           db  '@PrintString'
                     times 256-($-salt_1) db 0
                          dd  put_string
                          dw  sys_routine_seg_sel

         salt_2           db  '@ReadDiskData'
                     times 256-($-salt_2) db 0
                          dd  read_hard_disk_0
                          dw  sys_routine_seg_sel

         salt_3           db  '@PrintDwordAsHexString'
                     times 256-($-salt_3) db 0
                          dd  put_hex_dword
                          dw  sys_routine_seg_sel

         salt_4           db  '@TerminateProgram'
                     times 256-($-salt_4) db 0
                          dd  return_point
                          dw  core_code_seg_sel

         salt_item_len   equ $-salt_4
         salt_items      equ ($-salt)/salt_item_len

         message_1        db  '  If you seen this message,that means we '
                          db  'are now in protect mode,and the system '
                          db  'core is loaded,and the video display '
                          db  'routine works perfectly.',0x0d,0x0a,0

         message_2        db  '  System wide CALL-GATE mounted.',0x0d,0x0a,0

	 message_3	  db  0x0d,0x0a,'  Loading user program...',0
	
         do_status        db  'Done.',0x0d,0x0a,0
         
         message_6        db  0x0d,0x0a,0x0d,0x0a,0x0d,0x0a
                          db  '  User program terminated,control returned.',0

         bin_hex          db '0123456789ABCDEF'
                                            ;put_hex_dword子过程用的查找表 
         core_buf   times 2048 db 0         ;内核用的缓冲区

         esp_pointer      dd 0              ;内核用来临时保存自己的栈指针     

         cpu_brnd0        db 0x0d,0x0a,'  ',0
         cpu_brand  times 52 db 0
         cpu_brnd1        db 0x0d,0x0a,0x0d,0x0a,0

	;; 任务控制块链
	tcb_chain	dd 0
code_data_end:	

;===============================================================================
SECTION core_code vstart=0
;-------------------------------------------------------------------------------
	;; 在LDT内安装一个新的描述符
	;; 输入:EDX:EAX=描述符
	;;         EBX=TCB基地址
	;; 输出:cx=描述符的选择子
fill_descriptor_in_ldt:
	push 	eax
	push	edx
	push	edi
	push	ds

	mov	ecx,mem_0_4_gb_seg_sel
	mov	ds,ecx

	mov	edi,[ebx+0x0c]	;获得LDT基地址

	xor	ecx,ecx
	mov	cx,[ebx+0x0a]	;获得LDT界限
	inc	cx		;LDT的总字节数，即新描述符偏移地址
	mov	[edi+ecx+0x00],eax ;安装描述符
	mov	[edi+ecx+0x04],edx

	add	cx,8
	dec	cx		;得到新的LDT界限值

	mov	[ebx+0x0a],cx	;更新LDT界限值到TCB

	mov	ax,cx
	xor	dx,dx
	mov	cx,8
	div	cx

	mov	cx,ax
	shl	cx,3		;左移三位，并且
	or	cx,0000_0000_0000_0100B ;使TI位=1，指向LDT，最后使RPL=00

	pop	ds
	pop	edi
	pop	edx
	pop	eax

	ret
;;; ----------------------------------------------------------------------
	;; 加载并重定位用户程序
	;; 输入:PUSH 逻辑扇区号
	;;     PUSH 任务控制块基地址
	;; 输出:无
load_relocate_program:                     
	pushad
	
         push ds
         push es

	 mov ebp,esp		;为访问通过堆栈传递的参数做准备
	
         mov ecx,core_data_seg_sel
         mov es,ecx

	 mov esi,[ebp+11*4]	;从堆栈中取得TCB的基地址

	;; 以下申请创建LDT所需要的内存
	mov 	ecx,160		;允许安装20个LDT描述符
	call 	sys_routine_seg_sel:allocate_memory
	mov 	[es:esi+0x0c],ecx ;登记LDT基地址到TCB中
	mov	word[es:esi+0x0a],0xffff ;登记LDT初始的界限到TCB中

	;; 以下开始加载用户程序
	mov	eax,core_data_seg_sel
	mov	ds,eax		;切换DS到内核数据段

	mov	eax,[ebp+12*4]	;从堆栈中取出用户程序起始扇区号
	mov	ebx,core_buf	;读取程序头部数据
        call 	sys_routine_seg_sel:read_hard_disk_0

         ;以下判断整个程序有多大
         mov eax,[core_buf]                 ;程序尺寸
         mov ebx,eax
         and ebx,0xfffffe00                 ;使之512字节对齐（能被512整除的数， 
         add ebx,512                        ;低9位都为0 
         test eax,0x000001ff                ;程序的大小正好是512的倍数吗? 
         cmovnz eax,ebx                     ;不是。使用凑整的结果 
      
         mov ecx,eax                        ;实际需要申请的内存数量
         call sys_routine_seg_sel:allocate_memory
	mov	[es:esi+0x06],ecx 	;登记程序加载基地址到TCB中

	mov ebx,ecx                        ;ebx -> 申请到的内存首地址
         push ebx                           ;保存该首地址 
         xor edx,edx
         mov ecx,512
         div ecx
         mov ecx,eax                        ;总扇区数 
      
         mov eax,mem_0_4_gb_seg_sel         ;切换DS到0-4GB的段
         mov ds,eax

         mov eax,esi                        ;起始扇区号 
  .b1:
         call sys_routine_seg_sel:read_hard_disk_0
         inc eax
         loop .b1                           ;循环读，直到读完整个用户程序

	mov	edi,[es:esi+0x06]	;获得程序加载基地址
         ;建立程序头部段描述符
         mov eax,edi                        ;程序头部起始线性地址
         mov ebx,[edi+0x04]                 ;段长度
         dec ebx                            ;段界限 
         mov ecx,0x0040f200                 ;字节粒度的数据段描述符,特权级3
         call sys_routine_seg_sel:make_seg_descriptor

	;; 安装头部段描述符到LDT中
	mov	ebx,esi		;TCB的基地址
	call	fill_descriptor_in_ldt
	
	or	cx,0000_0000_0000_0110B ;设置选择子的特权级为3
	mov	[es:esi+0x44],cx	;登记程序头部段选择子到TCB
	mov	[edi+0x04],cx		;和头部内
	
         ;建立程序代码段描述符
         mov eax,edi
         add eax,[edi+0x14]                 ;代码起始线性地址
         mov ebx,[edi+0x18]                 ;段长度
         dec ebx                            ;段界限
         mov ecx,0x0040f800                 ;字节粒度的代码段描述符,特权级3
         call sys_routine_seg_sel:make_seg_descriptor
	 mov 	ebx,esi		;TCB的基地址
	 call 	fill_descriptor_in_ldt
	 or	cx,0000_0000_0000_0011B ;设置选择子的特权级为3
	 mov 	[edi+0x14],cx		;登记代码段选择子到头部

         ;建立程序数据段描述符
         mov eax,edi
         add eax,[edi+0x1c]                 ;数据段起始线性地址
         mov ebx,[edi+0x20]                 ;段长度
         dec ebx                            ;段界限
         mov ecx,0x0040f200                 ;字节粒度的数据段描述符，特权级3
         call sys_routine_seg_sel:make_seg_descriptor
	 mov	ebx,esi		;TCB的基地址
	 call	fill_descriptor_in_ldt
	 or	cx,0000_0000_0000_0011B ;设置选择子的特权级3
         mov 	[edi+0x1c],cx

         ;建立程序堆栈段描述符
         mov ecx,[edi+0x0c]                 ;4KB的倍率 
         mov ebx,0x000fffff
         sub ebx,ecx                        ;得到段界限
         mov eax,4096
	 mul ecx
	 mov ecx,eax                        ;准备为堆栈分配内存 
         call sys_routine_seg_sel:allocate_memory
         add eax,ecx                        ;得到堆栈的高端物理地址 
         mov ecx,0x00c09600                 ;4KB粒度的堆栈段描述符
         call sys_routine_seg_sel:make_seg_descriptor
         mov	ebx,esi		;TCB的基地址
	 call	fill_descriptor_in_ldt
	 or	cx,0000_0000_0000_0011B ;设置选择子的特权级为3
	 mov	[edi+0x08],cx		;登记堆栈段选择到头部
	
         ;重定位SALT
         mov eax,mem_0_4_gb_seg_sel ;头部段描述付已安装，但还没有生效
         mov es,eax		    ;只能通过4GB段访问用户程序头部
	
         mov eax,core_data_seg_sel
         mov ds,eax
      
         cld

         mov ecx,[es:0x24]                  ;用户程序的SALT条目数
         mov edi,0x28                       ;用户程序内的SALT位于头部内0x2c处
  .b2: 
         push ecx
         push edi
      
         mov ecx,salt_items
         mov esi,salt
  .b3:
         push edi
         push esi
         push ecx

         mov ecx,64                         ;检索表中，每条目的比较次数 
         repe cmpsd                         ;每次比较4字节 
         jnz .b4
         mov eax,[esi]                      ;若匹配，esi恰好指向其后的地址数据
         mov [es:edi-256],eax               ;将字符串改写成偏移地址 
         mov ax,[esi+4]
	 or  ax,0000000000000011B ;用用户程序自己的特权级使用调用门 RPL=3
	
	 mov [es:edi-252],ax                ;回填调用门选择子
  .b4:
      
         pop ecx
         pop esi
         add esi,salt_item_len
         pop edi                            ;从头比较 
         loop .b3
      
         pop edi
         add edi,256
         pop ecx
         loop .b2

	 mov esi,[ebp+11*4]	;从堆栈中取得TC的基地址

	;; 创建0特权级堆栈
	mov	ecx,4096
	mov	eax,ecx		;为生成堆栈高端地址做准备
	mov	[es:esi+0x1a],ecx
	shr	dword[es:esi+0x1a],12 ;登记0特权级堆栈尺寸到TCB
	call	sys_routine_seg_sel:allocate_memory
	add	eax,ecx		;堆栈必须使用高端地址为基地址
	mov	[es:esi+0x1e],eax ;登记0特权级堆栈基地址到TCB
	mov	ebx,0xffffe	  ;段长度
	mov	ecx,0x00c09600	  ;4KB粒度，读写，特权级0
	call	sys_routine_seg_sel:make_seg_descriptor
	mov	ebx,esi		;TCB的基地址
	call	fill_descriptor_in_ldt
	;; or	cx,0000_0000_0000_0000 ;设置选择子的特权级为0
	mov	[es:esi+0x22],cx ;登记0特权级堆栈选择子到TCB
	mov	dword[es:esi+0x24],0 ;登记0特权级堆栈初始ESP到TCP

	;; 创建1特权级堆栈
	mov	ecx,4096
	mov	eax,ecx		;为生成堆栈高端地址做准备
	mov	[es:esi+0x28],ecx
	shr	[es:esi+0x28],12 ;登记1特权级堆栈尺寸到TCB
	call	sys_routine_seg_sel:allocate_memory
	add	eax,ecx		;堆栈必须使用高端地址为基地址
	mov	[es:esi+0x2c],eax ;登记1特权级堆栈基地址到TCB
	mov	ebx,0xffffe	  ;段长度
	mov	ecx,0x00c0b600	  ;4KB粒度，读写，特权级1
	call	sys_routine_seg_sel:make_seg_descriptor
	mov	ebx,esi		;TCB的基地址
	call	fill_descriptor_in_ldt
	or	cx,0000_0000_0000_0001 ;设置选择子的特权级为1
	mov	[es:esi+0x30],cx ;登记0特权级堆栈选择子到TCB
	mov	dword[es:esi+0x32],0 ;登记1特权级堆栈初始ESP到TCP
	 

	;; 创建2特权级堆栈
	mov	ecx,4096
	mov	eax,ecx		;为生成堆栈高端地址做准备
	mov	[es:esi+0x36],ecx
	shr	[es:esi+0x36],12 ;登记1特权级堆栈尺寸到TCB
	call	sys_routine_seg_sel:allocate_memory
	add	eax,ecx		;堆栈必须使用高端地址为基地址
	;; ???
	mov	[es:esi+0x3a],eax ;登记2特权级堆栈基地址到TCB
	mov	ebx,0xffffe	  ;段长度
	mov	ecx,0x00c0d600	  ;4KB粒度，读写，特权级2
	call	sys_routine_seg_sel:make_seg_descriptor
	mov	ebx,esi		;TCB的基地址
	call	fill_descriptor_in_ldt
	or	cx,0000_0000_0000_0010 ;设置选择子的特权级为1
	mov	[es:esi+0x3e],cx ;登记0特权级堆栈选择子到TCB
	mov	dword[es:esi+0x40],0 ;登记1特权级堆栈初始ESP到TCP

	;; 在GDT中登记LDT描述符
	mov	eax,[es:esi+0x0c] ;LDT的起始线性地址
	movzx	ebx,word[es:esi+0x0a] ;LDT段界限
	mov	ecx,0x00408200	      ;LDT描述符，特权级0
	call	sys_routine_seg_sel:make_seg_descriptor
	call	sys_routine_seg_sel:set_up_gdt_descriptor
	mov	[es:esi+0x10],cx ;登记LDT选择子到TCB中

	;; 创建用户程序的TSS

	
         mov ax,[es:0x04]

         pop es                             ;恢复到调用此过程前的es段 
         pop ds                             ;恢复到调用此过程前的ds段
      
         pop edi
         pop esi
         pop edx
         pop ecx
         pop ebx
      
         ret
      
;-------------------------------------------------------------------------------
start:
         mov ecx,core_data_seg_sel           ;使ds指向核心数据段 
         mov ds,ecx

         mov ebx,message_1
         call sys_routine_seg_sel:put_string
                                         
         ;显示处理器品牌信息 
         mov eax,0x80000002
         cpuid
         mov [cpu_brand + 0x00],eax
         mov [cpu_brand + 0x04],ebx
         mov [cpu_brand + 0x08],ecx
         mov [cpu_brand + 0x0c],edx
      
         mov eax,0x80000003
         cpuid
         mov [cpu_brand + 0x10],eax
         mov [cpu_brand + 0x14],ebx
         mov [cpu_brand + 0x18],ecx
         mov [cpu_brand + 0x1c],edx

         mov eax,0x80000004
         cpuid
         mov [cpu_brand + 0x20],eax
         mov [cpu_brand + 0x24],ebx
         mov [cpu_brand + 0x28],ecx
         mov [cpu_brand + 0x2c],edx

         mov ebx,cpu_brnd0
         call sys_routine_seg_sel:put_string
         mov ebx,cpu_brand
         call sys_routine_seg_sel:put_string
         mov ebx,cpu_brnd1
         call sys_routine_seg_sel:put_string

	;; 以下开始安装为整个系统服务的调用门。特权级之间的控制转移必须使用门
	mov	edi,salt	;C-SALT表的起始地址
	mov	ecx,salt_items	;C-SALT表的条目数量
.b3:
	push	ecx
	mov	eax,[edi+256]	;该条目入口点的32位偏移地址
	mov	bx,[edi+260]	;该条目入口点的段选择子
	;; 特权级3的调用门（3以上的特权级才允许访问)
	;; 0个参数（因为用寄存器传递参数，而没有用到栈）
	mov	cx,1_11_0_1100_000_00000B
	call	sys_routine_seg_sel:make_gate_descriptor
	call	sys_routine_seg_sel:set_up_gdt_descriptor
	mov	[edi+260],cx	;将返回的门描述符选择子回填
	add	edi,salt_item_len ;指向下一个C-SALT条目
	pop	ecx
	loop	.b3

	;; 对门进行测试
	mov	ebx,message_2
	call 	far[salt_1+256]	;通过门显示信息（偏移量将忽略）

	mov	ebx,message_3
	call	sys_routine_seg_sel:put_string ;在内核中调用例程不需要通过门
	
	
	
return_point:                                ;用户程序返回点
         mov eax,core_data_seg_sel           ;使ds指向核心数据段
         mov ds,eax

         mov eax,core_stack_seg_sel          ;切换回内核自己的堆栈
         mov ss,eax 
         mov esp,[esp_pointer]

         mov ebx,message_6
         call sys_routine_seg_sel:put_string

         ;这里可以放置清除用户程序各种描述符的指令
         ;也可以加载并启动其它程序
       
         hlt
            
;===============================================================================
SECTION core_trail
;-------------------------------------------------------------------------------
core_end:
