	.global p4w_exit
	.global p4w_write
	.global p4w_read
	.global p4w_openat
	.global p42_close
	
p4w_write:
	li a7, 64
	j do_syscall


p4w_read:	
	li a7, 63
	j do_syscall

p4w_close:
	li a7, 57
	j do_syscall

p4w_open:
	li a7, 56
	j do_syscall
	
p4w_exit:
	li a7, 94


do_syscall:
	ecall
	ret   # jalr x0, x1, 0
	
