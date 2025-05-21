	.text
	.globl _start
	# Has to be defined before being used
	.equ input_len, 1024
_start:
	# Show prompt
	li  a7, 64 # SYS_WRITE
	li  a0, 1  # stdout
	la  a1, prompt
	li  a2, 2
	ecall

	# read user inout
	li a7, 63 # SYS_READ
	li a0, 0
	la a1, input
	li a2, input_len
	ecall

	# echo user input
	li a7, 64
	li a0, 1
	ecall

	# check command
	lb t0, 0(a1)
	li t1, 113
	beq t0, t1, done

	
	#repeat
	j _start
done:	
	li a7, 94 # SYS_EXIT
	ecall
	
prompt:
        .asciz "$ "
	len = . - prompt
	

.data

input:
	.fill 1024
	input_end = . - 1
	

	
