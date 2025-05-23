#include <unistd.h>

const char *prompt="$ \0";

int main () {
  char input[1024];
  int  i;
  
  while (1) {
    write (1, "$ ", 2); // Write Prompt
init_buffer:
    for (i = 0; i < 1024; i++) input[i] = 0;
read_input:
    read (0, input, 1024);
process:
    if (input[0] == 'q') return 0;
    if (input[0] == 'd') {
      write (1, "Running command D\n", 18);
    } else if (input[0] == 'w') {
      write (1, "Running command W\n", 18);
    } else
      write (1, "Unknown Command\n",17);
  }
}
