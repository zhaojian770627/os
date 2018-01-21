#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o sock_ntop.o signal.o
EXEF:= hostent daytimetcpcli1 daytimetcpcli daytimetcpsrv1 daytimetcpsrv2 daytimeudpsrv2
all:$(EXEF)
hostent:hostent.o $(OBJECTS)
daytimetcpcli1:daytimetcpcli1.o $(OBJECTS)
daytimeudpcli1:daytimeudpcli1.o $(OBJECTS) udp_client.o
daytimetcpcli:daytimetcpcli.o $(OBJECTS) tcp_connect.o sock_ntop_host.o
daytimetcpsrv1:daytimetcpsrv1.o $(OBJECTS) tcp_listen.o
daytimetcpsrv2:daytimetcpsrv2.o $(OBJECTS) tcp_listen.o
daytimeudpsrv2:daytimeudpsrv2.o $(OBJECTS) udp_server.o
clean:
	$(RM) *.o *.d $(EXEF)