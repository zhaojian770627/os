#
GPATH=../lib 
VPATH=../lib 
CFLAGS+=-g
OBJECTS=error.o wrapsock.o wrapunix.o
EXEF:= daytimetcpcli daytimetcpsrv
all:$(EXEF)
daytimetcpsrv:daytimetcpsrv.o $(OBJECTS)
daytimetcpcli:daytimetcpcli.o $(OBJECTS) 
wrapsock:wrapsock.c
error.o:error.c
wrapunix:wrapunix.c

clean:
	$(RM) *.o *.d $(EXEF)