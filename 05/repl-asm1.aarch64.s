	.text
	.globl _start
_start:
	mov x0, 1
	adr x1, prompt
	mov x2, len
	bl p4w_write
	ldr x1, =input
	
	mov x15, input_len / 8
ini0:	cbz x15, end0
	str xzr, [x1], 8
	sub x15, x15, 1
	b ini0

end0:	
	
	mov x0, xzr
	#adr x1, input
	mov x2, input_len
	bl p4w_read

#	mov x15, input_len / 8
#loop:	cbz x15, continue
#	str xzr, [x1], 8
#	sub x15, x15, 1
#	b loop

#continue:	
	#--------------------
#	mov x0, 1
#	ldr x1, =input
#	mov x2, input_len
#	bl p4w_write

	#-----------------------
	


	
	mov x2, x0
	mov x0, 1
	bl p4w_write
	
	
	ldrb w2, [x1]
	cmp w2, 113
	beq done

	
	b _start

done:	
	mov x0, xzr 
	bl p4w_exit
	

prompt:
        .asciz "$ "
	len = . - prompt
	

.data

input:
	.fill 1024
input_end = . - 1
input_len = 1024
	
