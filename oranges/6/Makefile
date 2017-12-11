# Entry point of Orange's
ENTRYPOINT	=0x30400

# Offset of entry point in kernel file
ENTRYOFFSET	=0x400

# Programs,flags,etc
ASM		= nasm
DASM		= ndisasm
CC		= gcc
LD		= ld
ASMBFLAGS	= -I boot/include/
ASMKFLAGS	= -I include/ -f elf
CFLAGS		= -I include/ -c -m32 -fno-stack-protector
LDFLAGS		= -s -m elf_i386 -Ttext $(ENTRYPOINT)
DASMFLAGS	= -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

# This Program
ORANGESBOOT	= boot/boot.bin boot/loader.bin
ORANGESKERNEL	= kernel.bin
OBJS		= kernel/kernel.o kernel/start.o kernel/i8259.o kernel/global.o lib/kliba.o lib/string.o lib/klib.o kernel/protect.o
DASMOUTPUT	= kernel.bin.asm

# ALL Phony Targets
.PHONY:everything final image clean realclean disasm all buildimg

# Default starting position
everything:$(ORANGESBOOT) $(ORANGESKERNEL)

all:realclean everything

final:all clean

image:final buildimg

clean:
	$(RM) $(OBJS) 
realclean:
	$(RM) $(OBJS) $(ORANGESBOOT) $(ORANGESKERNEL) *.img
disasm:
	$(DASM) $(DASMFLAGS) $(ORANGESKERNEL) > $(DASMOUTPUT)

buildimg:
	dd if=/dev/zero of=blank.img bs=512 count=2880
	cp blank.img pig.img
	dd if=boot/boot.bin of=pig.img  bs=512 count=1 conv=notrunc
	cp pig.img ~/imgs
	sudo mount -o loop ~/imgs/pig.img /mnt/floppy/
	sudo cp -fv boot/loader.bin /mnt/floppy/
	sudo cp -fv kernel.bin /mnt/floppy/
	sudo umount /mnt/floppy
boot/boot.bin:boot/boot.s boot/include/load.inc boot/include/fat12hdr.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<
boot/loader.bin:boot/loader.s boot/include/load.inc boot/include/fat12hdr.inc boot/include/pm.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<
$(ORANGESKERNEL):$(OBJS)
	$(LD) $(LDFLAGS) -o $(ORANGESKERNEL) $(OBJS)
kernel/kernel.o:kernel/kernel.s
	$(ASM) $(ASMKFLAGS) -o $@ $<
kernel/klib.o:
	$(CC) $(CFLAGS) -o $@ $<
kernel/protect.o : kernel/protect.c
	$(CC) $(CFLAGS) -o $@ $<
kernel/i8259.o : kernel/i8259.c include/type.h include/const.h include/protect.h include/proto.h
	$(CC) $(CFLAGS) -o $@ $<
kernel/global.o : kernel/global.c
	$(CC) $(CFLAGS) -o $@ $<
kernel/start.o:kernel/start.c include/type.h include/const.h include/protect.h include/proto.h include/string.h
	$(CC) $(CFLAGS) -o $@ $<
lib/kliba.o:lib/kliba.s
	$(ASM) $(ASMKFLAGS) -o $@ $<
lib/string.o:lib/string.s
	$(ASM) $(ASMKFLAGS) -o $@ $<
