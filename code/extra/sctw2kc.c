#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>


int main (int argc, char *argv[]) {
  char          buffer[1024], *p;
  unsigned char mem[8];
  int           l;

  while (1) {
    memset (buffer, 0, 1024);
    memset (mem, 0, 8);
    //if (read (0, buffer, 1024) <= 0) break;
    if (fgets (buffer, 1024, stdin) == NULL) break;
    buffer[strlen(buffer) - 1] = 0;
    p = buffer;
    l = 0;
    fprintf (stderr, "1: Input: '%s'\n", buffer);
    while (*p == ' ' || *p == '\t') p++;
    fprintf (stderr, "2: Trimmed Input: '%s'\n", p);
    if      (!strncasecmp (p, "NOP", 3))  mem[l++] = 0x90;
    else if (!strncasecmp (p, "HALT", 4)) mem[l++] = 0xFF;
    else if (!strncasecmp (p, "MOV", 3)) {
      p+=3;
      while (*p == ' ' || *p == '\t') p++;
      if      (!strncasecmp (p, "EBX", 3)) mem[l++] = 0xbb;
      else if (!strncasecmp (p, "EBP", 3)) mem[l++] = 0xbd;
      p+=3;
      while (*p == ' ' || *p == '\t' || *p == ',') p++;
      int val = strtold (p, NULL);
      mem[l++] = (unsigned char)(val & 0xff);
    } else if (!strncasecmp (p, "ADD", 3)) {
      mem[l++] = 0x01;
      p+=3;
      while (*p == ' ' || *p == '\t') p++;
      if      (!strncasecmp (p, "EBX", 3)) mem[l++] = 0xeb;
      else if (!strncasecmp (p, "EBP", 3)) mem[l++] = 0xea;      
    }
    write (1, mem, l);
  }
  
}
