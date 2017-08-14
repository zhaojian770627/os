#本章开始使用虚拟硬盘 虚拟硬盘采用固定100M VHD固定格式 用VirtualBOX创建，默认位置为 ~/imgs/org.vhd 
#此虚拟硬盘每个磁道17个扇区，因为目前为止编写的程序都不超过17个扇区，所以采用直接写的方式，如果以后程序大了
#在开发专用工具
all:disk
disk:mbr.bin core.bin c14.bin
	cp ~/imgs/org.vhd disk.vhd
	dd if=mbr.bin of=disk.vhd  bs=512 count=1 conv=notrunc
	dd if=core.bin of=disk.vhd  bs=512 seek=1 conv=notrunc
	dd if=c14.bin of=disk.vhd  bs=512 seek=50 conv=notrunc
	cp disk.vhd ~/imgs
mbr.bin:
	nasm -f bin mbr.asm -o mbr.bin -l mbr.lst
core.bin:
	nasm -f bin core.asm -o core.bin -l core.lst
c14.bin:
	nasm -f bin c14.asm -o c14.bin -l c14.lst
clean:
	$(RM) *.vhd *.bin *.sys *.o  *.lst *.txt
