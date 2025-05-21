	.global _exit
	
_exit:
	mov r7, #1
	swi 0
