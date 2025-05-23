#include <unistd.h>
int main (void)
{
register int a = 10;
register int b = 20;
a = a + b;
_exit (a);
}
