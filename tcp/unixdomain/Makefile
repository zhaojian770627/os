#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= unixbind unixstrserv01
all:$(EXEF)
unixbind:unixbind.o $(OBJECTS)
unixstrserv01:unixstrserv01.c $(OBJECTS) sigchldwaitpid.c signal.c str_echo.c
clean:
	$(RM) *.o *.d $(EXEF)