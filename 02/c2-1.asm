	global _start
_start:
	mov rdi, 10
	mov rbx, 20
	add rdi,rbx
	mov rax, 0x3c
	syscall
