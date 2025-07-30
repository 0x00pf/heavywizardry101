#include <unistd.h>
int main ()
{
register void *p = "Hello, world!\n";
write (1, p, 14);
_exit (0);
}
