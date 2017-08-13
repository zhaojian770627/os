#本章开始使用虚拟硬盘 虚拟硬盘采用固定100M VHD固定格式 用VirtualBOX创建，默认位置为 ~/imgs/org.vhd 
#此虚拟硬盘每个磁道17个扇区，因为目前为止编写的程序都不超过17个扇区，所以采用直接写的方式，如果以后程序大了
#在开发专用工具
all:disk
disk:mbr.bin 
	cp ~/imgs/org.vhd disk.vhd
	dd if=mbr.bin of=disk.vhd  bs=512 count=1 conv=notrunc
#	dd if=core.bin of=protected.img  bs=512 seek=1 conv=notrunc
#	dd if=c13.bin of=protected.img  bs=512 seek=11 conv=notrunc
	cp disk.vhd ~/imgs
mbr.bin:
	nasm -f bin mbr.asm -o mbr.bin -l mbr.lst
clean:
	$(RM) *.vhd *.bin *.sys *.o  *.lst *.txt
