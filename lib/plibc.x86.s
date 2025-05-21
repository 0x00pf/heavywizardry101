	.global p4w_exit
	.global p4w_write
	.global p4w_read	
	.global p4w_close
	.global p4w_open
	
p4w_write:
	mov $0x01, %eax
	syscall
	ret

p4w_read:
	mov $0x00, %eax
	syscall
	ret
	
p4w_open:
	mov $0x02, %eax
	syscall
	ret
	
p4w_close:
	mov $0x03, %eax
	syscall
	ret

p4w_exit:
	mov $0x3c, %eax
	syscall
	ret

