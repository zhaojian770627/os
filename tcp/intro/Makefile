#
GPATH=../lib 
VPATH=../lib 
CFLAGS+=-g
OBJECTS=error.o
EXEF:= daytimetcpcli
all:$(EXEF)
daytimetcpcli:daytimetcpcli.o $(OBJECTS) 

error.o:error.c

clean:
	$(RM) *.o *.d $(EXEF)