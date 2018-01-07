#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o sock_ntop.o signal.o
EXEF:= udpserv01 udpserv02  udpcli01 udpcli02 udpcli03 udpcli04
all:$(EXEF)
udpserv01:udpserv01.o $(OBJECTS) dg_echo.o
udpserv02:udpserv02.o $(OBJECTS) dgecholoop1.o
udpcli01:udpcli01.o $(OBJECTS) dg_cli.o
udpcli02:udpcli02.o $(OBJECTS) dgcliaddr.o
udpcli03:udpcli03.o $(OBJECTS) dgcliconnect.o
udpcli04:udpcli04.o $(OBJECTS) dgcliloop1.o

clean:
	$(RM) *.o *.d $(EXEF)