	global _start
_start: mov rax, 1
	; SYS_write = 1
	mov rdi, 1
	; fd = 1
	lea rsi, [rel msg] ; buf = msg
	mov rdx, 14
	; count = 13 (the number of bytes to write)
	syscall ; (SYS_write = rax(1), fd = rdi (1), buf = rsi (msg), count = rdx (13))
	;; Exit program
	mov rax, 0x3c ; SYS_exit = 0x3c
	mov rdi, 0
	; status = 0
	syscall ; (SYS_exit = rax (0x3c), status = rdi (0))
msg:
db 'Hello, world!',0x0a
