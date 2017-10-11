#ifndef	__unp_h
#define	__unp_h

#include "config.h"	/* configuration options for current OS */

#include <sys/types.h>
#include <sys/socket.h>

#include <netinet/in.h>	/* sockaddr_in{} and other Internet defns */
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Miscellaneous constants */
#define	MAXLINE		4096	/* max text line length *

/* Following shortens all the typecasts of pointer arguments: */
#define	SA	struct sockaddr

void	 err_dump(const char *, ...);
void	 err_msg(const char *, ...);
void	 err_quit(const char *, ...);
void	 err_ret(const char *, ...);
void	 err_sys(const char *, ...);
#endif	/* __unp_h */
