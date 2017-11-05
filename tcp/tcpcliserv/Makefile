#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= tcpserv01 tcpcli01
all:$(EXEF)
tcpserv01:tcpserv01.o $(OBJECTS) str_echo.o
tcpcli01:tcpcli01.o $(OBJECTS)

clean:
	$(RM) *.o *.d $(EXEF)