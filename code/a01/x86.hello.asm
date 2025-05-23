	global _start
_start: mov 	rax, 1
	mov 	rdi, 1
	lea 	rsi, [rel msg]
	mov  	rdx, 13
	syscall
	
	;; Exit program
	mov 	rax, 0x3c 
	mov 	rdi, 0
	syscall
	
msg:
db 'Hello World!',0x0a
