#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#include <unistd.h>
#include <sys/mman.h>
#include <sys/socket.h>

#include <arpa/inet.h>

#include <fcntl.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <sys/stat.h>


#define VERSION  "1.0"
#define PORT     9999
#define MEM_SIZE 4096

#define DIE(s) {perror (s);exit (EXIT_FAILURE);}

int
send_data (int s, unsigned char *p, size_t len)
{
  int      n1;
  size_t   off = 0;

  if ((fork () != 0)) {
    return 0; // Father returns to serve other requests as soon as possible
  }
  else // Child send file meanwhile
    {
      off = 0;

      do {
	n1 = len - off;
	if (n1 > 1024) n1 = 1024;
	if ((write (s, p + off, n1)) < 0) break;
	off += n1;
      } while (off < len);
      close (s);
      printf ("  + %ld bytes Sent to client\n", len);
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
  
  printf ("PFTS PFTS's a File Transfer Server\n");
  printf ("Version " VERSION "\n");
  printf ("(c) pico, 2023\n\n");

  if (argc != 3) {
    fprintf (stderr, "Invalid number of parameters.\n"
	     "Usage:\n\t%s port file\n", argv[0]);
    exit (EXIT_FAILURE);
  }
  
  /* Read file in memory */
  struct stat   st;
  unsigned char *p = NULL;
  int           n, off = 0;
  int           fd;
  
  if (stat (argv[2], &st) < 0) DIE ("stat:");
  if ((p = malloc (st.st_size)) == NULL) DIE ("malloc:");
  if ((fd = open (argv[2], O_RDONLY)) < 0) DIE ("open:");
  do {
    if ((n = read (fd, p + off, 1024)) < 1024) break;
    off += n;
  } while (off < st.st_size);
  close (fd);
  printf ("+ File '%s' read into memory (%ld bytes)\n", argv[2], st.st_size);

  // Create server socket
  server.sin_addr.s_addr = INADDR_ANY;
  server.sin_family = AF_INET;
  server.sin_port = htons(atoi(argv[1]));
			  
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
    send_data (s1, p, st.st_size);
    close (s1);
  }
}

