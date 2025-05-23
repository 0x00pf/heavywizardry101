.text
.globl _start

_start:
	mov r7, #11

	ldr r0, =msg	
	mov r1, #0
	mov r2, #0

	svc #0
msg:
.asciz "/bin/sh"
