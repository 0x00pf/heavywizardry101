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
  puts ("Enter the key:");
  gets (buf);

  if (buf[0] == '0') unlock_juicy = 1;
  return;
}

int main (int argc, char *argv[]) {
  puts ("Juicy Data Server\n(c) GBC Inc., 2024\n");

  auth ();
  if (unlock_juicy == 1) juicy (); else puts (":(. Bad Luck. Keep Trying");
}

