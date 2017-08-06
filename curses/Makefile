#
EXEF:=hello moveadd ipmode multiw1 subscl
all:$(EXEF)
subscl:subscl.o -lncurses
multiw1:multiw1.o -lncurses
moveadd:moveadd.o -lncurses
hello:hello.o -lncurses
ipmode:ipmode.o -lncurses
clean:
	$(RM) *.o *.d $(EXEF)