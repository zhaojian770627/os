#include <unistd.h>
#include <stdlib.h>
#include <curses.h>

int main()
{
  WINDOW *new_window_ptr;
  WINDOW *popup_window_ptr;
  int x_loop;
  int y_loop;
  char a_letter='a';

  initscr();
  move(5,5);
  printw("%s","Testing multiple windows");
  refresh();

  for(y_loop=0;y_loop<LINES-1;y_loop++){
    for(x_loop=0;x_loop<COLS-1;x_loop++){
      mvwaddch(stdscr,y_loop,x_loop,a_letter);
      a_letter++;
      if(a_letter>'z')
	a_letter='a';
    }
  }
  refresh();
  sleep(2);

  endwin();
  exit(EXIT_SUCCESS);
}
