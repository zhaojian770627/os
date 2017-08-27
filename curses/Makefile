#
EXEF:=hello moveadd ipmode multiw1 subscl keypad color pad curses
all:$(EXEF)
curses:curses.o -lncurses
pad:pad.o -lncurses
color:color.o -lncurses
keypad:keypad.o -lncurses
subscl:subscl.o -lncurses
multiw1:multiw1.o -lncurses
moveadd:moveadd.o -lncurses
hello:hello.o -lncurses
ipmode:ipmode.o -lncurses
clean:
	$(RM) *.o *.d $(EXEF)