#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= unixbind unixstrserv01 unixstrcli01 unixdgserv01 unixdgcli01 mycat openfile
all:$(EXEF)
unixbind:unixbind.o $(OBJECTS)
unixstrserv01:unixstrserv01.c $(OBJECTS) sigchldwaitpid.c signal.c str_echo.c
unixstrcli01:unixstrcli01.c $(OBJECTS) str_cli.o readline.o
unixdgserv01:unixdgserv01.c $(OBJECTS) dg_echo.o
unixdgcli01:unixdgcli01.c $(OBJECTS) dg_cli.o
openfile:openfile.c $(OBJECTS) write_fd.o
mycat:mycat.c $(OBJECTS) myopen.o read_fd.o
clean:
	$(RM) *.o *.d $(EXEF)