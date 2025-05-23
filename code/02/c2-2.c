#include <unistd.h>

#ifdef MIPS
void __start (void)
#else
void _start (void)
#endif
{
	register int a = 10;
	register int b = 20;
	a +=b;

	_exit (a);
}
