#
all:protected.img
protected.img:blank.img mbr.bin
	cp blank.img protected.img
	dd if=mbr.bin of=protected.img  bs=512 count=1 conv=notrunc
	#cp protected.img /mnt/share/os/protected.img
blank.img:
	dd if=/dev/zero of=blank.img bs=512 count=2880
mbr.bin:
	nasm -f bin mbr.asm -o mbr.bin -l mbr.lst

clean:
	$(RM) *.img *.bin *.sys *.o  *.lst 
