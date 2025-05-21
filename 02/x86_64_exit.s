	.global _exit
	
_exit:
	mov $0x3c, %eax
	syscall

