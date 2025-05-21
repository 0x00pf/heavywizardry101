section .text
	global _start

_start:
	mov rax, 0x3b
	lea rdi, [rel cmd]
	xor rsi, rsi
	xor rdx,rdx
	syscall

cmd: db '/bin/sh',0

