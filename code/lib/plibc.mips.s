	.global p4w_exit
	.global p4w_write
	.global p4w_read
	.global p4w_close
	.global p4w_open
	
	
p4w_write:
	li $2, 4004
	j do_syscall

p4w_exit:
	li $2, 4001
	j do_syscall

p4w_read:	
	li $2, 4003
	syscall
	jr $31

p4w_close:
	li $2, 4006
	j do_syscall

p4w_open:
	li $2, 4005
	j do_syscall

do_syscall:
	syscall
	jr $31
