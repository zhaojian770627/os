#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= udpserv01 udpcli01
all:$(EXEF)
udpserv01:udpserv01.o $(OBJECTS) dg_echo.o
udpcli01:udpcli01.o $(OBJECTS) dg_cli.o
udpcli02:udpcli02.o $(OBJECTS) dgcliaddr.o
clean:
	$(RM) *.o *.d $(EXEF)