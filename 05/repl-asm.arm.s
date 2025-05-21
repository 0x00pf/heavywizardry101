	.text
	.globl _start
_start:
	mov %r0, $1
	ldr %r1, =prompt
	mov %r2, #len
	bl p4w_write

	# Initialise input
	eor %r0, %r0 
	ldr %r4,=input
	mov %r5, $1024
	
ini0:
	cmp %r5, $0
	ble end0
	sub %r5,%r5,$1
	#str %r0, [%r4, %r5]
	str %r0, [%r4], $1

	b ini0
end0:	



	
	# mov %r0, $0
	eor %r0, %r0
	ldr %r1, =input
	mov %r2, #input_len
	bl p4w_read

	mov %r2, %r0
	mov %r0, $1
	bl p4w_write
	
	
	ldrb %r2, [%r1]
	cmp %r2, $113
	beq done

	
	b _start

done:	
	mov %r0, $0
	bl p4w_exit
	

prompt:
        .asciz "$ "
	len = . - prompt
	

.data

input:
	.fill 1024
input_end = . - 1
input_len = 1024
	
