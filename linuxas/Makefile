#
EXEF=exit
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
clean:
	$(RM) $(EXEF)  *.o *.lst *.bin
