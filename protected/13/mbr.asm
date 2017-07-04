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

	

	