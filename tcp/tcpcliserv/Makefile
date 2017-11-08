#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= tcpserv01 tcpserv02 tcpserv03 tcpcli01
all:$(EXEF)
tcpserv01:tcpserv01.o $(OBJECTS) str_echo.o
tcpserv02:tcpserv02.o $(OBJECTS) str_echo.o sigchldwait.o signal.o
tcpserv03:tcpserv03.o $(OBJECTS) str_echo.o sigchldwait.o signal.o
tcpcli01:tcpcli01.o $(OBJECTS) str_cli.o readline.o

clean:
	$(RM) *.o *.d $(EXEF)