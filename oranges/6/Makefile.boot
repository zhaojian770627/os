#
# Programs,flags,etc
ASM		= nasm
ASMFLAGS 	=-I boot/include/

# This Program
PIGTARGET		= boot/boot.bin boot/loader.bin

# All Phony Targets
.PHONY:everything clean all

# Default starting position
everything:$(PIGTARGET)

all:clean everything

boot/boot.bin:boot/boot.s boot/include/load.inc boot/include/fat12hdr.inc
	$(ASM) $(ASMFLAGS) -o $@ $<
boot/loader.bin:boot/loader.s boot/include/load.inc boot/include/fat12hdr.inc boot/include/pm.inc
	$(ASM) $(ASMFLAGS) -o $@ $<
clean:
	$(RM) -f $(PIGTARGET)
