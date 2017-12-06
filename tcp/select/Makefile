#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= tcpcli01 tcpcli02
all:$(EXEF)
tcpcli01:tcpcli01.o $(OBJECTS) strcliselect01.o readline.o
tcpcli02:tcpcli02.o $(OBJECTS) strcliselect02.o

clean:
	$(RM) *.o *.d $(EXEF)