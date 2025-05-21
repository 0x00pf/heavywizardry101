
.text
.globl __start
__start: li $2, 4011

        la $4, msg
        li $5, 0
        li $6, 0

        syscall
msg:
        .asciz "/bin/sh"
