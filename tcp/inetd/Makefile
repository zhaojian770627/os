#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= daytimetcpsrv2
all:$(EXEF)
daytimetcpsrv2:daytimetcpsrv2.o $(OBJECTS) daemon_init.o tcp_listen.o signal.o sock_ntop.o

clean:
	$(RM) *.o *.d $(EXEF)