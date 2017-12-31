#
# Programs,flags,etc
ASM		= nasm
ASMFLAGS 	=-I include/

# This Program
TARGET		= boot.bin loader.bin

# All Phony Targets
.PHONY:everything clean all

# Default starting position
everything:$(TARGET)

boot.bin:boot.s include/load.inc include/fat12hdr.inc
	$(ASM) $(ASMFLAGS) -o $@ $<
loader.bin:loader.s include/load.inc include/fat12hdr.inc include/pm.inc
	$(ASM) $(ASMFLAGS) -o $@ $<
clean:
	$(RM) -f $(TARGET)
