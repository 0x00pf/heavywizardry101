	.global p4w_exit
	.global p4w_write
	.global p4w_read
	.global p4w_close
	.global p4w_open
	
	
p4w_write:
	mov %r7, $0x04
	swi $0
	mov pc, lr
	#bx lr

p4w_read:
	mov %r7 ,$0x03
	swi $0
	bx lr

p4w_exit:
	mov %r7 ,$0x01
	swi $0
	bx lr

p4w_open:
	mov %r7 ,$0x05
	swi $0
	bx lr
	
p4w_close:
	mov %r7 ,$0x06
	swi $0
	bx lr
	
