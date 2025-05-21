	.global p4w_exit
	.global p4w_write
	.global p4w_read
	.global p4w_close
	.global p4w_openat
	
	
p4w_write:
	mov x8, 0x40
	svc 0
	br x30

p4w_read:
	mov x8 ,0x3f
	svc 0
	ret

p4w_exit:
	mov x8 , 0x5d
	svc 0
	ret

p4w_openat:
	# Appears as openat in the syscall table
	mov x8 , 0x38
	svc 0
	ret
	
p4w_close:
	mov x8 , 0x39
	svc 0
	ret

	
