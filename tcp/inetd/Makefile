#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= daytimetcpsrv2 daytimetcpsrv3
all:$(EXEF)
daytimetcpsrv2:daytimetcpsrv2.o $(OBJECTS) daemon_init.o tcp_listen.o signal.o sock_ntop.o
daytimetcpsrv3:daytimetcpsrv3.o $(OBJECTS) daemon_inetd.o sock_ntop.o

clean:
	$(RM) *.o *.d $(EXEF)