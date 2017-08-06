#include <unistd.h>
#include <stdlib.h>
#include <curses.h>

#define NUM_NAMES 14

int main()
{
  WINDOW *sub_window_ptr;
  int x_loop;
  int y_loop;
  int counter;
  char a_letter='A';

  initscr();

  for(y_loop=0;y_loop<LINES-1;y_loop++){
    for(x_loop=0;x_loop<COLS-1;x_loop++){
      mvwaddch(stdscr,y_loop,x_loop,a_letter);
      a_letter++;
      if(a_letter>'z')
	a_letter='a';
    }
  }

  sub_window_ptr=subwin(stdscr,10,20,10,10);
  scrollok(sub_window_ptr,1);
  touchwin(stdscr);
  refresh();
  sleep(5);

  werase(sub_window_ptr);
  mvwprintw(sub_window_ptr,2,0,"%s",
	    "This window will now scroll as now scroll");
  wrefresh(sub_window_ptr);
  sleep(5);

  for(counter=0;counter<10;counter++){
    wprintw(sub_window_ptr,"%s ","This text is both wrapping and scrolling.");
    wrefresh(sub_window_ptr);
    sleep(1);
  }

  delwin(sub_window_ptr);

  touchwin(stdscr);
  refresh();
  sleep(5);

  endwin();
  exit(EXIT_SUCCESS);
}
