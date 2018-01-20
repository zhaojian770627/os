#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o sock_ntop.o signal.o
EXEF:= hostent daytimetcpcli1
all:$(EXEF)
hostent:hostent.o $(OBJECTS)
daytimetcpcli1:daytimetcpcli1.o $(OBJECTS)
clean:
	$(RM) *.o *.d $(EXEF)