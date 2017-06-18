#
all:protected.img
protected.img:blank.img mbr.bin c09.bin
	cp blank.img protected.img
	dd if=mbr.bin of=protected.img  bs=512 count=1 conv=notrunc
	dd if=c09.bin of=protected.img  bs=512 seek=1 conv=notrunc
	cp protected.img ~/imgs
blank.img:
	dd if=/dev/zero of=blank.img bs=512 count=2880
mbr.bin:
	nasm -f bin mbr.asm -o mbr.bin -l mbr.lst
c09.bin:
	#nasm -f bin c09.asm -o c09.bin -l c09.lst
	nasm -f bin c09_2.asm -o c09.bin -l c09.lst
clean:
	$(RM) *.img *.bin *.sys *.o  *.lst *.txt
