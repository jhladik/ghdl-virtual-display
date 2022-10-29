#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <X11/Xlib.h>

Display *d;
int s;
Window w;
Colormap scm;
GC gc;
Pixmap pixmap;
XEvent e;

static uint xres;
static uint yres;

void sim_init(uint32_t width, uint32_t height) {
  xres = width;
  yres = height;
  
  d = XOpenDisplay(NULL);
  if (d == NULL) {
     fprintf(stderr, "Cannot open display.\n");
     exit(EXIT_FAILURE);
  }
  
  s = DefaultScreen(d);
  w = XCreateSimpleWindow(d, RootWindow(d, s), 0, 0, xres, yres, 0, BlackPixel(d, s), BlackPixel(d, s));
  XSelectInput(d, w, ExposureMask | KeyPressMask);
  XMapWindow(d, w);
  XFlush(d);

  gc = DefaultGC(d, s);
  scm = DefaultColormap(d, DefaultScreen(d));

  while (1) {
    XNextEvent(d, &e);
    if (e.type == Expose) { break; }
  }
}

void save_screenshot(int32_t *ptr, uint32_t width, uint32_t height, int id) {
  assert(ptr != NULL);
  pixmap = XCreatePixmap(d, w, width, height, DefaultDepth(d, DefaultScreen(d)));
  int x_pos = (xres-width)/2;
  int y_pos = (yres-height)/2;
  int x, y;
  int p = 0;
  uint32_t *q = ptr;
  for( y=0 ; y < height ; y++ ) {
    for( x=0 ; x < width ; x++ ) {
      int k = *q++;
      if (p != k) {
        XSetForeground(d, gc, k);
        p = k;
      }
      XDrawPoint(d, pixmap, gc, x, y);
    }
  }
  XCopyArea(d, pixmap, w, gc, 0, 0, width, height, x_pos, y_pos);
  XFreePixmap(d, pixmap);
}

void sim_cleanup(void) {
  printf("Press any key to exit the X window.\n");
  while (1) {
    XNextEvent(d, &e);
      if (e.type == KeyPress)
        break;
  }
  XCloseDisplay(d);
}
