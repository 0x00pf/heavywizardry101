#include <unistd.h>

int main () {
  char input[1024];
  int  i;
  char zombie[10];
  int  n_zombies = 0;

  for (i = 0; i < 10; zombie[i++] = 0);
  while (1) {

init_buffer:
    for (i = 0; i < 1024; i++) input[i] = 0;
read_input:
    read (0, input, 1024);
process:
    if (input[0] == 'q') return 0;
    if (input[0] == 'R') { // Register
      write (2, "Registering zombie ",20);
      zombie[n_zombies] = 1; // We got a new zombie
      input[0] = 'r';
      input[1] = (n_zombies++) + '0';
      input[2] = '\n';
      write (2, input+1, 2);
      write (1, input, 3);
    } else if (input[0] == 'a') {
      input[0] = 'd';
      write (2, "C2:Starting DDOS\n", 17);
      if (input[1] == '*') {
	for (i = 0; i < 10; i++) {
	  if (zombie[i]) {
	    write (2, "+ Command zombie ",17);
	    write (2, input + 1, 2);
	    write (1, input, 3);
	  }
	}
      } else {
	write (2, "+ Command zombie ",17);
	write (2, input + 1, 2);
	
	write (1, input, 3);
      }
    }
   else if (input[0] == 'D') {
      if (zombie[input[1] - '0']) {
	write (2, "+ Zombie ", 10);
	write (2, &input[1], 1);
	write (2, " DDOsing\n", 9) ;
      }
   } else if (input[0] == 'S') {
      if (zombie[input[1] - '0']) {
	write (2, "+ Zombie ", 10);
	write (2, &input[1], 1);
	write (2, " STOPPING\n", 10) ;
      }
   }
  }
}
