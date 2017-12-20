#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o writen.o wrapunix.o wrapsock.o wraplib.o wrapstdio.o
EXEF:= checkopts
all:$(EXEF)
checkopts:checkopts.o $(OBJECTS)

clean:
	$(RM) *.o *.d $(EXEF)