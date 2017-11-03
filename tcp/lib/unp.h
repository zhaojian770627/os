#ifndef	__unp_h
#define	__unp_h

#include "config.h"	/* configuration options for current OS */

#include <sys/types.h>
#include <sys/socket.h>

#include <time.h>

#include <netinet/in.h>	/* sockaddr_in{} and other Internet defns */
#include <arpa/inet.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Miscellaneous constants */
#define	MAXLINE		4096	/* max text line length *

/* Following could be derived from SOMAXCONN in <sys/socket.h>, but many
   kernels still #define it as 5, while actually supporting many more */
#define	LISTENQ		1024	/* 2nd argument to listen() */

/* Following shortens all the typecasts of pointer arguments: */
#define	SA	struct sockaddr

const char *Inet_ntop(int, const void *, char *, size_t);

int	 Socket(int, int, int);
void	 Bind(int, const SA *, socklen_t);
void	 Listen(int, int);
int	 Accept(int, SA *, socklen_t *);
void	 Write(int, void *, size_t);
void	 Close(int);

void	 err_dump(const char *, ...);
void	 err_msg(const char *, ...);
void	 err_quit(const char *, ...);
void	 err_ret(const char *, ...);
void	 err_sys(const char *, ...);
#endif	/* __unp_h */
