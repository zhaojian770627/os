all:disk
disk:mbr.bin core.bin c171.bin c172.bin
#c16.bin
	cp ~/imgs/org.vhd disk.vhd
	dd if=mbr.bin of=disk.vhd  bs=512 count=1 conv=notrunc
	dd if=core.bin of=disk.vhd  bs=512 seek=1 conv=notrunc
	dd if=c171.bin of=disk.vhd  bs=512 seek=50 conv=notrunc
	dd if=c172.bin of=disk.vhd  bs=512 seek=100 conv=notrunc
	cp disk.vhd ~/imgs
mbr.bin:
	nasm -f bin mbr.asm -o mbr.bin -l mbr.lst
core.bin:
	nasm -f bin core.asm -o core.bin -l core.lst
c171.bin:
	nasm -f bin c171.asm -o c171.bin -l c172.lst
c172.bin:
	nasm -f bin c172.asm -o c172.bin -l c172.lst
clean:
	$(RM) *.vhd *.bin *.sys *.o  *.lst *.txt
