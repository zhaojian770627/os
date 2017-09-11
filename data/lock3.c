#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

const char *test_file="/tmp/test_lock";

int main()
{
  int file_desc;
  int byte_count;
  char *byte_to_write="A";
  struct flock region_1;
  struct flock region_2;
  int res;

  file_desc=open(test_file,O_RDWR|O_CREAT,0666);
  if(!file_desc){
    fprintf(stderr,"Unable to open %s for ead/write\n",test_file);
    exit(EXIT_FAILURE);
  }
  for(byte_count=0;byte_count<100;byte_count++){
    write(file_desc,byte_to_write,1);
  }
