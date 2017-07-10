#
EXEF:=hello moveadd
all:$(EXEF)
moveadd:moveadd.o -lncurses
hello:hello.o -lncurses
clean:
	$(RM) *.o *.d $(EXEF)