
.text
.globl _start
_start:
	li a7, 221 # SYS_EXECVE
        la a0, cmd
        li a1, 0
        li a2, 0

        ecall

cmd:
        .asciz "/bin/sh"
