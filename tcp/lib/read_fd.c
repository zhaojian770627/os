#include "unp.h"

ssize_t 
read_fd(int fd,void *ptr,size_t nbytes,int *recvfd)
{
  struct msghdr msg;
  struct iovec iov[1];
  ssize_t n;

#ifdef HAVE_MSGHDR_MSG_CONTROL
  union{
    struct cmsghdr cm;
    char control[CMSG_SPACE(sizeof(int))];
