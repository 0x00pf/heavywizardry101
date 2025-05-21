	global _start
_start: mov rax, 1         ; SYS_write = 1
	mov rdi, 1         ; fd = 1
	lea rsi, [rel msg] ; buf = msg
	mov rdx, 13        ; count = 13 (the number of bytes to write)
	syscall
	;; Exit program
	mov rax, 0x3c      ; SYS_exit = 0x3c
	mov rdi, 0         ; status = 0
	syscall
msg:
db 'Hello World!',0x0a
