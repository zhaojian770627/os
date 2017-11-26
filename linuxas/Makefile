#
EXEF=exit maximum power factor toupper write-records read-records
all:$(EXEF)
#hello:
#	nasm -f elf64 hello.s -o hello.o
#	ld -s hello.o -o hello
#foobar:
#	nasm -f elf foo.s -o foo.o
#	gcc -m32 -c -o bar.o bar.c
#	ld -m elf_i386 -s -o foobar foo.o bar.o
exit:
	as -g exit.s -o exit.o
	ld exit.o -o exit
maximum:
	as -g maximum.s -o maximum.o
	ld maximum.o -o maximum
power:
	as --32 -g power.s -o power.o
	ld -m elf_i386 power.o -o power
factor:
	as --32 -g factor.s -o factor.o
	ld -m elf_i386 factor.o -o factor
toupper:
	as --32 -g toupper.s -o toupper.o
	ld -m elf_i386 toupper.o -o toupper
write-records:
	as --32 -g write-records.s -o write-records.o
	as --32 -g write-record.s -o write-record.o
	ld -m elf_i386 write-records.o write-record.o -o write-records
read-records:
	as --32 -g read-record.s -o read-record.o
	as --32 -g count-chars.s -o count-chars.o
	as --32 -g write-newline.s -o write-newline.o
	as --32 -g read-records.s -o read-records.o
	ld -m elf_i386 read-record.o count-chars.o write-newline.o read-records.o -o read-records
clean:
	$(RM) $(EXEF)  *.o *.lst *.bin
