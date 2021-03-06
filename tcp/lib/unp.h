#ifndef	__unp_h
#define	__unp_h

#include "config.h"	/* configuration options for current OS */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <sys/sysctl.h>
#include <time.h>

#include <netinet/in.h>	/* sockaddr_in{} and other Internet defns */
#include <arpa/inet.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h> 
#include <netdb.h>
#include <sys/wait.h>
#include <poll.h>
#include <sys/un.h>		/* for Unix domain sockets */

/* Define some port number that can be used for our examples */
#define	SERV_PORT		 9877			/* TCP and UDP */
#define	UNIXSTR_PATH	"/tmp/unix.str"	/* Unix domain stream */
#define	UNIXDG_PATH	"/tmp/unix.dg"	/* Unix domain datagram */

/* Miscellaneous constants */
#define	MAXLINE		4096	/* max text line length */
#define BUFFSIZE	8192	/* buffer size for reads and writes */

/* Following could be derived from SOMAXCONN in <sys/socket.h>, but many
   kernels still #define it as 5, while actually supporting many more */
#define	LISTENQ		1024	/* 2nd argument to listen() */

/* Following shortens all the typecasts of pointer arguments: */
#define	SA	struct sockaddr

typedef	void	Sigfunc(int);	/* for signal handlers */

Sigfunc *Signal(int, Sigfunc *);

#define	min(a,b)	((a) < (b) ? (a) : (b))
#define	max(a,b)	((a) > (b) ? (a) : (b))

ssize_t	 Read_fd(int, void *, size_t, int *);
ssize_t	 write_fd(int, void *, size_t, int);
ssize_t	 Read(int, void *, size_t);
ssize_t	 Readline(int, void *, size_t);
ssize_t	 writen(int, const void *, size_t);
void	 Sysctl(int *, u_int, void *, size_t *, void *, size_t);

int	 daemon_init(const char *, int);
void	 str_echo(int);
void	 str_cli(FILE *, int);
void	 dg_echo(int, SA *, socklen_t);
void	 dg_cli(FILE *, int, const SA *, socklen_t);

/* prototypes for our stdio wrapper functions: see {Sec errors} */
pid_t	 Fork(void);
void	 Fclose(FILE *);
FILE	*Fdopen(int, const char *);
char	*Fgets(char *, int, FILE *);
FILE	*Fopen(const char *, const char *);
void	 Fputs(const char *, FILE *);
int	 Ioctl(int, int, void *);

void	*Malloc(size_t);

const char *Inet_ntop(int, const void *, char *, size_t);
void  Inet_pton(int, const char *, void *);
char	*sock_ntop_host(const SA *, socklen_t);
char	*Sock_ntop_host(const SA *, socklen_t);

int	 Socket(int, int, int);
void	 Connect(int, const SA *, socklen_t);
void	 Bind(int, const SA *, socklen_t);
void	 Listen(int, int);
int	 Accept(int, SA *, socklen_t *);
void	 Write(int, void *, size_t);
void	 Close(int);
void	 Shutdown(int, int);
void	 Getsockname(int, SA *, socklen_t *);
void	 Getpeername(int, SA *, socklen_t *);
int	 Tcp_listen(const char *, const char *, socklen_t *);
int	 Tcp_connect(const char *, const char *);
int	 Udp_client(const char *, const char *, SA **, socklen_t *);
int	 Udp_server(const char *, const char *, socklen_t *);

pid_t	 Waitpid(pid_t, int *, int);
void	 Socketpair(int, int, int, int *);
void	 Writen(int, void *, size_t);
int	 Select(int, fd_set *, fd_set *, fd_set *, struct timeval *);
int	 Poll(struct pollfd *, unsigned long, int);
void	 Sendto(int, const void *, size_t, int, const SA *, socklen_t);
ssize_t	 Recvfrom(int, void *, size_t, int, SA *, socklen_t *);
char	*Sock_ntop(const SA *, socklen_t);
void	 Setsockopt(int, int, int, const void *, socklen_t);

void	 err_dump(const char *, ...);
void	 err_msg(const char *, ...);
void	 err_quit(const char *, ...);
void	 err_ret(const char *, ...);
void	 err_sys(const char *, ...);
#endif	/* __unp_h */
