#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= tcpserv01 tcpserv02 tcpserv03 tcpserv04 tcpcli01 tcpcli04 tcpcli01rst tcpservselect01 tcpservpoll01
all:$(EXEF)
tcpserv01:tcpserv01.o $(OBJECTS) str_echo.o
tcpserv02:tcpserv02.o $(OBJECTS) str_echo.o sigchldwait.o signal.o
tcpserv03:tcpserv03.o $(OBJECTS) str_echo.o sigchldwait.o signal.o
tcpserv04:tcpserv04.o $(OBJECTS) str_echo.o sigchldwaitpid.o signal.o
tcpcli01:tcpcli01.o $(OBJECTS) str_cli.o readline.o
tcpcli04:tcpcli04.o $(OBJECTS) str_cli.o readline.o
tcpcli01rst:tcpcli01rst.o $(OBJECTS) str_cli1.o readline.o
tcpservselect01:tcpservselect01.o $(OBJECTS)
tcpservpoll01:tcpservpoll01.o $(OBJECTS)

clean:
	$(RM) *.o *.d $(EXEF)