#include "../lib/unp.h"

int
main(int argc,char **argv)
{
  int i,maxi,maxfd,listenfd,connfd,sockfd;
  int nready,client[FD_SETSIZE];
  ssize_t n;
  fd_set rset,allset;
  char buf[MAXLINE];
  socklen_t clilen;
  struct sockaddr_in cliaddr,servaddr;

  listenfd=Socket(AF_INET,SOCK_STREAM,0);

  bzero(&servaddr,sizeof(servaddr));
  servaddr.sin_family=AF_INET;
  servaddr.sin_addr.s_addr=htonl(INADDR_ANY);
  servaddr.sin_port=htons(SERV_PORT);

  Bind(listenfd,(SA*)&servaddr,sizeof(servaddr));

  Listen(listenfd,LISTENQ);

  maxfd=listenfd;		/* initialize */
  maxi=-1;			/* index into client[] array */
  for(i=0;i<FD_SETSIZE;i++)
    client[i]=-1;		/* -1 indicates available entry */
  FD_ZERO(&allset);
  FD_SET(listenfd,&allset);
}
