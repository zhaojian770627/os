#
all:m.img
m.img:blank.img masterboot.bin
	cp blank.img m.img
	dd if=masterboot.bin of=m.img  bs=512 count=1 conv=notrunc
	cp m.img ~/imgs
blank.img:
	dd if=/dev/zero of=blank.img bs=512 count=2880
masterboot.bin:
	as masterboot.s -o masterboot.o
	ld --oformat binary -o masterboot.bin masterboot.o
clean:
	$(RM) *.img *.bin *.sys *.o  *.lst *.txt *.bin