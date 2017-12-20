/* include checkopts1 */
/* *INDENT-OFF* */
#include	"../lib/unp.h"
#include	<netinet/tcp.h>		/* for TCP_xxx defines */

union val {
  int				i_val;
  long				l_val;
  struct linger		linger_val;
  struct timeval	timeval_val;
} val;

static char	*sock_str_flag(union val *, int);
static char	*sock_str_int(union val *, int);
static char	*sock_str_linger(union val *, int);
static char	*sock_str_timeval(union val *, int);

struct sock_opts {
  const char	   *opt_str;
  int		opt_level;
  int		opt_name;
  char   *(*opt_val_str)(union val *, int);
} sock_opts[] = {
  { "SO_BROADCAST",		SOL_SOCKET,	SO_BROADCAST,	sock_str_flag }
};


  /* *INDENT-ON* */
  /* end checkopts1 */

  /* include checkopts2 */
int
main(int argc, char **argv)
{
  int		   	fd;
  socklen_t		len;
  struct sock_opts	*ptr;

  for (ptr = sock_opts; ptr->opt_str != NULL; ptr++) {
  }
  exit(0);
}


/* include checkopts3 */
static char	strres[128];

static char	*
sock_str_flag(union val *ptr, int len)
{
  /* *INDENT-OFF* */
  if (len != sizeof(int))
    snprintf(strres, sizeof(strres), "size (%d) not sizeof(int)", len);
  else
    snprintf(strres, sizeof(strres),
	     "%s", (ptr->i_val == 0) ? "off" : "on");
  return(strres);
  /* *INDENT-ON* */
}
