#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main(){
  printf("Running ps with execlp\n");
  execlp("ps","ps","-ax",NULL);
  printf("Done.\n");
  exit(0);
}
