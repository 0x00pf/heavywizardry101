#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <fcntl.h>

unsigned char mem[1024];
int           rip;
int           ebx, ebp;

int sctw2k_status () {
  printf ("EBX: 0x%x\n", ebx);
  printf ("EBP: 0x%x\n", ebp);
  printf ("RIP: 0x%x\n", rip);
  puts ("--------------------------");
  for (int i = 0; i < 16; i++) {
    printf ("ADDR-0x%0x | %02x |", 15-i, mem[15-i]);
    if (15 - i == rip) puts (" <= RIP"); else puts ("");
  }
}

int main (int argc, char *argv[]) {
  char          buffer[1024], *p;
  int           fd, l;
  
  printf ("SCTW-2000 Emulator\n");
  if (argc != 2) {
    fprintf (stderr, "Invalid number of parameters:\nUsage: %s input.bin\n",
	     argv[0]);
    exit (EXIT_FAILURE);
  }
  memset (mem, 0, 1024);
  rip = ebx = ebp = 0;
  // Read program in memory
  if ((fd = open (argv[1], O_RDONLY)) < 0) {
    perror ("open:");
    exit (EXIT_FAILURE);
  }
  if (read(fd, mem, 1024) < 0) {
    perror ("read:");
    exit (EXIT_FAILURE);
  }
  close (fd);
  
  while (1) {
    sctw2k_status ();
  skip_status:    
    printf ("%s", "> ");
    if (fgets (buffer, 1024, stdin) == NULL) break;
    buffer[strlen(buffer) - 1] = 0;
    if (buffer[0] == 'q') exit (EXIT_SUCCESS);
    if (buffer[0] == '?') {
      puts ("------------------------------------");
      puts ("? : Shows this help");
      puts ("q : Quits program");
      puts ("s : Instruction execution");
      puts ("------------------------------------");
      goto skip_status;
    }
    if (buffer[0] == 's') {
      if      (mem[rip] == 0x90) {rip++;continue;}
      else if (mem[rip] == 0xff) exit (EXIT_SUCCESS);
      else if (mem[rip] == 0xbb) ebx = mem[++rip];
      else if (mem[rip] == 0xbd) ebp = mem[++rip];
      else if (mem[rip] == 0x01) {
	rip++;
	if      (mem[rip] == 0xea) ebp += ebx;
	else if (mem[rip] == 0xeb) ebx += ebp;
      }
      rip++;
    }
  }
  
}
