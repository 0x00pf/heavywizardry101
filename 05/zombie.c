#include <unistd.h>
#include <stdio.h>

int main () {
  char input[1024];
  int  i, id, ddos = 0;

  // Register with C2
  id = -1;
  // setbuf(stdout, NULL);
  write (1, "R\n", 2);
  write (2, "START\n", 6);
  while (1) {
    for (i = 0; i < 1024; i++) input[i] = 0;
read_input:
    read (0, input, 1024);
process:
    if (input[0] == 'q') return 0;
    if (input[0] == 'r' && id == -1) { // Register
      write (2, "+ Registered!\n ", 14);
      id=input[1] - '0';
    } else if (input[0] == 'd') {
      if ((input[1] - '0' != id) && (input[1] != '*')) continue;
      input[0] = 'D';
      input[1] = id + '0';
      input[2] = '\n';
      if (!ddos) write (2, "C:Starting DDOS\n", 16);
      ddos = 1;
      write (1, input, 3);
    }
    else if (input[0] == 's') {
      if ((input[1] - '0' != id) && (input[1] != '*')) continue;
      input[0] = 'S';
      input[1] = id + '0';
      input[2] = '\n';
      if (ddos) write (2, "C:Stopping DDOS\n", 16);
      ddos = 0;
      write (1, input, 3);
    }
  }
}
