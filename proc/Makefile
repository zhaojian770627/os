#
CFLAGS+=-g
EXEF:=system0 pexec fork
all:$(EXEF)
fork:fork.o
pexec:pexec.o
system0:system0.o
clean:
	$(RM) *.o *.d $(EXEF)