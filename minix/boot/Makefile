#
EXEF:=installboot
all:$(EXEF)
asm:blank.img masterboot.bin
	cp blank.img m.img
	dd if=masterboot.bin of=m.img  bs=512 count=1 conv=notrunc
	cp m.img ~/imgs
blank.img:
	dd if=/dev/zero of=blank.img bs=512 count=2880
masterboot.bin:
	nasm -f bin masterboot.s -o masterboot.bin
installboot:
	gcc -g -m32 -o installboot installboot.c
clean:
	$(RM) *.o *.d $(EXEF) *.img *.bin *.sys *.o  *.lst *.txt *.bin