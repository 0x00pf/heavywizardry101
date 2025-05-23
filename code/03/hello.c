#include <unistd.h>
int main ()
{
register void *p = "Hello World!\n";
write (1, p, 13);
_exit (0);
}
