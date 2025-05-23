
.text
.globl __start
__start:
	dli $v0, 5057
        dla $a0, msg
        dli $a1, 0
        dli $a2, 0

        syscall

msg:
        .asciz "/bin/sh"
