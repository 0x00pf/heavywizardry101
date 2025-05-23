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
	#ldr %r5,=input_end
	add %r5, %r4, $input_len

	mov %r6, %r0
	mov %r7, %r0
	mov %r3, %r0
ini0:
	cmp %r4, %r5
	stmltia %r4!, {%r0, %r3, %r6, %r7}
	blt ini0
end0:	

	mov %r0, $1
	ldr %r1, =input
	mov %r2, #input_len
	
	bl p4w_write

	
	eor %r0, %r0 
	ldr %r1, =input
	mov %r2, #input_len
	bl p4w_read


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
	
