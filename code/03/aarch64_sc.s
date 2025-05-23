.text
.globl _start
_start:
	mov w8, #221
	mov x1, #0
	mov x2, #0
	ldr x0, =msg
	svc #0

msg:
.asciz "/bin/bash"
