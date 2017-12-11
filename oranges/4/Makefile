#
all:pig.img
pig.img:blank.img boot.bin loader.bin
	cp blank.img pig.img
	dd if=boot.bin of=pig.img  bs=512 count=1 conv=notrunc
	#dd if=c09.bin of=pig.img  bs=512 seek=1 conv=notrunc
	cp pig.img ~/imgs
blank.img:
	dd if=/dev/zero of=blank.img bs=512 count=2880
boot.bin:
	nasm -f bin boot.s -o boot.bin -l boot.lst
loader.bin:
	nasm -f bin loader.s -o loader.bin -l loader.lst
clean:
	$(RM) *.img *.bin *.sys *.o  *.lst *.txt
