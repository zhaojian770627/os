#
all:protected.img
protected.img:blank.img mbr.bin core.bin c13.bin
	cp blank.img protected.img
	dd if=mbr.bin of=protected.img  bs=512 count=1 conv=notrunc
	dd if=core.bin of=protected.img  bs=512 seek=1 conv=notrunc
	dd if=c13.bin of=protected.img  bs=512 seek=10 conv=notrunc
	cp protected.img ~/imgs
blank.img:
	dd if=/dev/zero of=blank.img bs=512 count=2880
mbr.bin:
	nasm -f bin mbr.asm -o mbr.bin -l mbr.lst
core.bin:
	nasm -f bin core.asm -o core.bin -l core.lst
c13.bin:
	nasm -f bin c13.asm -o c13.bin -l c13.lst
clean:
	$(RM) *.img *.bin *.sys *.o  *.lst *.txt
