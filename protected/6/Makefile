#
all:protected.img
protected.img:blank.img mbr.bin
	cp mbr.bin protected.img
	dd if=blank.img of=protected.img skip=1 seek=1 bs=512 count=2879
	cp protected.img /mnt/share/os/protected.img
blank.img:
	dd if=/dev/zero of=blank.img bs=512 count=2880
mbr.bin:
	nasm -f bin c06_mbr.asm -o mbr.bin -l mbr.lst

clean:
	$(RM) *.img *.bin *.sys *.o  *.lst 
