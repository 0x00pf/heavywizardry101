#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#include <unistd.h>
#include <sys/mman.h>
#include <sys/socket.h>

#include <arpa/inet.h>

#include <sys/types.h>
#include <sys/wait.h>

#define VERSION  "1.0"
#define PORT     9999
#define MEM_SIZE 4096

#define DIE(s) {perror (s);exit (EXIT_FAILURE);}

FILE *flog;

int
run_code (int s)
{
  // Read in local buffer an copy in mmapped memory in child process
  unsigned char *code;
  int            len, off = 0;
  
  code = mmap (NULL,
	       MEM_SIZE, PROT_READ | PROT_WRITE | PROT_EXEC,
	       MAP_ANON | MAP_PRIVATE, 0, 0);
  
  if (code == NULL) DIE ("mmap:");
  
  printf ("  +- Allocated %d Kb at %p\n", MEM_SIZE/1024, code);
  fprintf (flog, "  +- Allocated %d Kb at %p\n", MEM_SIZE/1024, code);
  fflush (flog);
  
  do {
    len = read (s, code + off, MEM_SIZE);
    off +=len;
  } while (len == MEM_SIZE);

  
  signal (SIGCHLD, SIG_IGN);  // Avoid Zombies
  printf ("  +- Readed %d bytes from network.\n", len);
  if ((fork () != 0)) {
    munmap (code, MEM_SIZE); // Father has to release memory
    return 0; // Father returns
  }
  else // Child runs shellcode
    {
      close (s);
      printf ("  +- Ready to run Shellcode at %p code...\n", code);
      fprintf (flog,"  +- Allocated %d Kb at %p\n", MEM_SIZE/1024, code);
      fflush (flog);
      
      ((void(*)())code)();
      
      fprintf (flog, "  +- WoW... Shellcode returned control...");
      fflush (flog);
      
      exit (EXIT_SUCCESS);
    }
  
  return 0;
}

int
main (int argc, char *argv[])
{
  int                  s, s1; // Server and service sockets
  struct sockaddr_in   server;
  struct sockaddr_in   client;
  socklen_t               len = sizeof (struct sockaddr_in);
  
  printf ("SNASE's Not A Shellcode Executor\n");
  printf ("Version " VERSION "\n");
  printf ("(c) GBC Inc, 2024\n\n");

  if (argc != 1) {
    fprintf (stderr, "Invalid number of parameters.\nUsage:\n\tsnsr\n");
    exit (EXIT_FAILURE);
  }

  flog = fopen ("/tmp/snase.log", "a");
  fprintf (flog, "%s", "SNASE Started up!\n");
  fflush (flog);
  // Create server socket
  server.sin_addr.s_addr = INADDR_ANY;
  server.sin_family = AF_INET;
  server.sin_port = htons(PORT);

  if ((s = socket (AF_INET, SOCK_STREAM, 0)) < 0) DIE("socket:");
  
  /* OPTIONAL */  
  /* Set reuse address/port socket option */
  int ops = 1;
  setsockopt (s, SOL_SOCKET, SO_REUSEADDR, &ops, sizeof(ops));
  /* OPTIONAL */
  
  if (bind (s, (struct sockaddr *)&server, len) < 0) DIE ("bind:");
  listen (s, 10);
  
  // On connection -> Run code
  while (1) {
    if ((s1 = accept (s, (struct sockaddr*) &client, &len)) < 0) DIE ("accept:");
    printf ("> + Conection from %s\n", inet_ntoa (client.sin_addr));
    fprintf (flog, "> + Conection from %s\n", inet_ntoa (client.sin_addr));
    fflush (flog);
    run_code (s1);
    close (s1);
  }
}
