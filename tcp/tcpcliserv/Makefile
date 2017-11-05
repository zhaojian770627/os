#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o
EXEF:= tcpserv01
all:$(EXEF)
tcpserv01:tcpserv01.o $(OBJECTS) str_echo.o
error.o:error.c
writen.o:writen.c
wrapunix.o:wrapunix.c
wrapsock.o:wrapsock.c
str_echo.o:str_echo.c

clean:
	$(RM) *.o *.d $(EXEF)