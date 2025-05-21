#include <stdio.h>
#include <unistd.h>

int unlock_juicy = 0;

void juicy () {
  puts (">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  puts ("This is the juicy stuff");
  puts (">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
}


void auth () {
  char buf[16];
  long i, *p;

  /* New added lines to dump the stack before user input*/
  /* We also print the addresses of buf and juicy */
  printf ("<juicy> function at: %p\n", juicy);
  printf ("<buf>            at: %p\n", buf);
  i = 6 * 8;
  p = (long *)buf + 6;
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  /* Program continues normally */

  puts ("Enter the key:");
  gets (buf); /* New added lines to dump the stack after user input*/
  i = 6 * 8;
  p = (long *)buf + 6;
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);
  printf ("<%p> [%+03d] : 0x%016llx\n", p--, i -=8, (long)*p);  
  /* Program continues normally */
  if (buf[0] == '0') unlock_juicy = 1;
  return;
}

int main (int argc, char *argv[]) {
  puts ("Juicy Data Server\n(c) GBC Inc., 2024\n");

  printf ("Return address   at: %p\n", &&return_addr);
  auth ();
return_addr:
  if (unlock_juicy == 1) juicy (); else puts (":(. Bad Luck. Keep Trying");
}

