#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o sock_ntop.o signal.o
EXEF:= hostent daytimetcpcli1 daytimetcpcli daytimetcpsrv1 daytimetcpsrv2
all:$(EXEF)
hostent:hostent.o $(OBJECTS)
daytimetcpcli1:daytimetcpcli1.o $(OBJECTS)
daytimetcpcli:daytimetcpcli.o $(OBJECTS) tcp_connect.o sock_ntop_host.o
daytimetcpsrv1:daytimetcpsrv1.o $(OBJECTS) tcp_listen.o
daytimetcpsrv2:daytimetcpsrv2.o $(OBJECTS) tcp_listen.o
clean:
	$(RM) *.o *.d $(EXEF)