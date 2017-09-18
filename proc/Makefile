#
CFLAGS+=-g
EXEF:=system0 pexec fork wait thread1
all:$(EXEF)
thread1:thread1.o
wait:wait.o
fork:fork.o
pexec:pexec.o
system0:system0.o
clean:
	$(RM) *.o *.d $(EXEF)