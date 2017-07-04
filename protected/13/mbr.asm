	;; 软盘主引导扇区代码
	core_base_address equ 0x00040000 ;常数,内核加载的起始内存地址
	core_start_sector equ 0x00000001 ;常数,内核的起始逻辑扇区号

	mov	ax,cs
	mov	ss,ax
	mov	sp,0x7c00

	;; 计算GDT所在的逻辑段地址
	mov	edx,[cs:pgdt+0x7c00+0x02] ;GDT的32位物理地址
	xor	edx,edx
	mov	ebx,16
	div	ebx		;分解成16位逻辑地址

	mov	ds,eax		;令DS指向该段以进行操作
	mov	ebx,edx		;段内起始偏移地址

	;; 跳过0#描述符的槽位
	;; 创建1#描述符,这是一个数据段，对应0~4GB的线性地址空间
	mov	dword[ebx+0x08],0x0000ffff ;基地址为0，段界限位0xffff
	mov	dword[ebx+0x0c],0x00cf9200 ;粒度位4KB，存储器段描述符

	;; 创建保护模式下初始代码段描述符
	mov	dword[ebx+0x10],0x7c0001ff ;基地址为0x00007c00，段界限位0x1ff
	mov	dword[ebx+0x14],0x00489800 ;粒度位1个字节，代码段描述符

	;; 创建保护模式下堆栈段描述符
	mov	dword[ebx+0x18],0x7c00fffe ;基地址为0x00007c00，段界限位0xffffe
	mov	dword[ebx+0x1c],0x00cf9600 ;粒度为4KB

	
	mov	dword[ebx+0x20],0x80007fff ;基地址为0x000B8000,界限位0x07fff
	mov	dword[ebx+0x24],0x0040920b ;粒度为字节