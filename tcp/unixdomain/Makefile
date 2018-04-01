#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= unixbind unixstrserv01 unixstrcli01
all:$(EXEF)
unixbind:unixbind.o $(OBJECTS)
unixstrserv01:unixstrserv01.c $(OBJECTS) sigchldwaitpid.c signal.c str_echo.c
unixstrcli01:unixstrcli01.c $(OBJECTS) str_cli.o readline.o
clean:
	$(RM) *.o *.d $(EXEF)