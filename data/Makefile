#
CFLAGS+=-g
EXEF:=memory1 memory2 memory3 memory4 memory5a  memory5b memory6 lock1 lock2 lock3 lock4
all:$(EXEF)
lock4:lock4.o
lock3:lock3.o
lock2:lock2.o
lock1:lock1.o
memory6:memory6.o
memory5b:memory5b.o
memory5a:memory5a.o
memory1:memory1.o
memory2:memory2.o
memory3:memory3.o
memory4:memory4.o
clean:
	$(RM) *.o *.d $(EXEF)