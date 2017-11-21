#
EXEF=exit maximum power factor
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
clean:
	$(RM) $(EXEF)  *.o *.lst *.bin
