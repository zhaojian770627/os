#include <stdio.h>  
#include <stdlib.h>  
#include <unistd.h>  
#include <X11/keysymdef.h>  
#include <X11/Xlib.h>  
   
int main(int argc, char *argv[])  
{  
       
  Display* display;  
  display = XOpenDisplay(":0");  
       
  if (NULL == display){  
    fprintf(stderr, "连接不上X Server %s\n", "zj:0");  
    exit(-1);  
  }  

  printf("%s\n",XDisplayName((char*)display));
  
  int screen_num;  
  int screen_width;  
  int screen_height;  
  Window root_window;  
       
  unsigned long white_pixel;  
  unsigned long black_pixel;  
       
  screen_num = DefaultScreen(display);  
       
  screen_width = DisplayWidth(display, screen_num);  
  screen_height = DisplayHeight(display, screen_num);  
           
  puts("测试输出:");  
  printf("句柄:%x宽度:%d高度:%d\n",  
	 screen_num, screen_width, screen_height);  
           
  root_window = RootWindow(display, screen_num);  
  white_pixel = WhitePixel(display, screen_num);  
  black_pixel = BlackPixel(display, screen_num);  
       
  Window win;  
  int win_width;  
  int win_height;  
  int win_x;  
  int win_y;       
  int win_border_width;  
  int win_border_height;  
           
  int width;  
  int height;  
       
  win_x = win_y = win_border_width= win_border_height = 0;
  win_width = DisplayWidth(display, screen_num);  
  win_height = DisplayHeight(display, screen_num);  
       
  width = (win_width / 3);  
  height = (win_height / 3);  
  win_border_width = 2;  
       
  /*创建一个窗口*/       
  win = XCreateSimpleWindow(  
			    display,  
			    RootWindow(display, screen_num),  
			    win_x, win_y,  
			    width, height,  
			    win_border_width, win_border_height,  
			    WhitePixel(display, screen_num)  
			      );  
  /*注册事件*/  
  /* XSelectInput(display, win, ExposureMask); */  
  /*ExposureMask在头文件"X.h"中被定义，如果我们想注册更多的事件类型，我们可以使用逻辑"or"*/  
       
  XSelectInput(display, win,  
	       ExposureMask | ButtonPressMask |  
	       ButtonReleaseMask | ButtonPress |  
	       ButtonRelease | EnterWindowMask |  
	       LeaveWindowMask | EnterNotify |  
	       LeaveNotify  
	       );  
  /*鼠标的进入和离开 Enter Leave和GTK很像.*/  
       
  XMapWindow(display, win);  
       
  /*画笔*/  
  GC gc;  
  XGCValues values;  
  unsigned long valuemask = 0;  
  /* XGCValues values = CapButt | JoinBevel; */  
  /* unsigned long valuemask = GCCapStyle | GCJoinStyle; */  
  gc = XCreateGC(display, win, valuemask, &values);  
  XSync(display, False);  
  if (gc < 0)  
    {  
      fprintf(stderr, "XCreateGC:\n");  
    }  
  /*画画.*/  
       
  XSetBackground(display, gc, WhitePixel(display, screen_num));/*设置背景颜色*/  
  XSetForeground(display, gc, BlackPixel(display, screen_num));/*设置前景色*/  
  unsigned int line_width = 2;  
  int line_style = LineSolid;  
  int cap_style = CapButt;  
  int join_style = JoinBevel;  
   
  XSetLineAttributes(display, gc,  
		     line_width, line_style, cap_style, join_style);  
  XSetFillStyle(display, gc, FillSolid);  
       
   
  /* sleep(14); */  
  XEvent an_event;  
  /*事件循环*/  
  while (1)  
    {  
      XNextEvent(display, &an_event);  
      /*这里就是判断所有事件*/  
   
           
      switch(an_event.type)  
	{  
                 
	case KeyPress:  
	  printf("键盘被按下");  
	  break;  
	case Expose: /*重绘*/  
	  if(an_event.xexpose.count > 0)       
	    {  
	      break;  
	    }  
	  XDrawLine(display, win, gc, 0, 100, 400, 100);  
	  XDrawPoint(display, win, gc, 5, 5);  
	  XDrawRectangle(display, win, gc, 120, 150, 50, 60);       
	  XFillRectangle(display, win, gc, 60, 150, 50, 60);  
	  /*刷新*/  
	  XFlush(display);  
	  printf("正在重绘事件\n");  
	  break;  
	case ButtonPress: /*按下事件*/  
	  /* int x; */  
	  /* int y; */  
	  /* x = an_event.xbutton.x; */  
	  /* y = an_event.xbutton.window; */                 
	  switch(an_event.xbutton.button){  
	  case Button1:  
	    XDrawRectangle(display, win, gc, 120, 150, 50, 60);       
	    puts("鼠标左键按下");  
	    break;  
	  case Button2:       
	    puts("button2...");  
	    break;  
	  default:  
	    break;  
	  }  
	}                 
           
    }  
  /*关闭X服务器连接*/  
  XCloseDisplay(display);  
  return 0;  
}  
