#
CFLAGS+=-g
EXEF:=system0 pexec fork wait
all:$(EXEF)
wait:wait.o
fork:fork.o
pexec:pexec.o
system0:system0.o
clean:
	$(RM) *.o *.d $(EXEF)