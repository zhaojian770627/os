#
CFLAGS+=-g
EXEF:=gltest
all:$(EXEF)
gltest:
	gcc -I/usr/include -L/usr/local/lib -L/usr/X11R6/lib gltest.c -o gltest -lglut -lGLU -lGL -lX11 -lXext  -lXi -lm
clean:
	$(RM) *.o *.d $(EXEF)