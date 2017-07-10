#include <unistd.h>
#include <stdlib.h>
#include <curses.h>
#include <string.h>

int main()
{
  const char witch_one[]=" First Witch  ";
  const char witch_two[]=" Second Witch  ";
  const char *scan_ptr;

  initscr();

  move(5,15);
  attron(A_BOLD);
  printw("%s","Macbeth");
  attroff(A_BOLD);
  refresh();
  sleep(5);

  move(8,15);
  attron(A_DIM);
  printw("%s","Thunder and Lightning");
  attroff(A_DIM);
  refresh();
  sleep(5);

  move(10,10);
  printw("%s","When shall we three meet agin");

  move(11,23);
  printw("%s","In thunder,lightning,or in rain?");

  move(13,10);
  printw("%s","When the hurlyburly's done.");

  move(14,23);
  printw("%s","When the battle's lost and won.");
  refresh();
  sleep(5);

  attron(A_DIM);
  scan_ptr=witch_one+strlen(witch_one);
  while(scan_ptr!=witch_one){
    move(10,10);
    insch(*scan_ptr--);
  }

  scan_ptr=witch_two+strlen(witch_two);
  while(scan_ptr!=witch_two){
    move(13,10);
    insch(*scan_ptr--);
  }

  attroff(A_DIM);
  refresh();
  sleep(5);

  endwin();
  exit(EXIT_SUCCESS);
}
