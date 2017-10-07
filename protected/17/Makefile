all:disk
disk:mbr.bin core.bin 
#c16.bin
	cp ~/imgs/org.vhd disk.vhd
	dd if=mbr.bin of=disk.vhd  bs=512 count=1 conv=notrunc
	dd if=core.bin of=disk.vhd  bs=512 seek=1 conv=notrunc
#	dd if=c16.bin of=disk.vhd  bs=512 seek=50 conv=notrunc
#	cp disk.vhd ~/imgs
mbr.bin:
	nasm -f bin mbr.asm -o mbr.bin -l mbr.lst
core.bin:
	nasm -f bin core.asm -o core.bin -l core.lst
c16.bin:
	nasm -f bin c16.asm -o c16.bin -l c16.lst
clean:
	$(RM) *.vhd *.bin *.sys *.o  *.lst *.txt
