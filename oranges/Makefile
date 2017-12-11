#
all:boot.img
boot.img:blank.img boot.bin
	cp boot.bin boot.img
	dd if=blank.img of=boot.img skip=1 seek=1 bs=512 count=2879
	cp boot.img /mnt/share/os/boot.img
blank.img:
	dd if=/dev/zero of=blank.img bs=512 count=2880
boot.bin:
	nasm -f bin boot.asm -o boot.bin -l boot.lst
clean:
	$(RM) *.img *.bin *.sys *.o  *.lst *.txt