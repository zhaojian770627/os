#
GPATH=../lib  
VPATH=../lib
CFLAGS+=-g
OBJECTS=error.o wrapsock.o wrapunix.o wraplib.o
EXEF:= daytimetcpcli daytimetcpsrv daytimetcpsrv1 byteorder
all:$(EXEF)
byteorder:byteorder.o
daytimetcpsrv:daytimetcpsrv.o $(OBJECTS)
daytimetcpsrv1:daytimetcpsrv1.o  $(OBJECTS)
daytimetcpcli:daytimetcpcli.o $(OBJECTS) 
wrapsock:wrapsock.c
error.o:error.c
wrapunix.o:wrapunix.c
wraplib.o:wraplib.c

clean:
	$(RM) *.o *.d $(EXEF)