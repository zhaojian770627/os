#
EXEF:=hello moveadd ipmode
all:$(EXEF)
moveadd:moveadd.o -lncurses
hello:hello.o -lncurses
ipmode:ipmode.o -lncurses
clean:
	$(RM) *.o *.d $(EXEF)