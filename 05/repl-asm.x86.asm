	;; Select file
	
        global    _start
	extern    p4w_write
	extern    p4w_read	
	extern    p4w_exit
	
        section   .text
_start:

	;; Show prompt
	mov rdi, 1
	mov rsi, prompt
	mov rdx, prompt_len
	call p4w_write

	;; Read Input
	mov rdi, 0
	mov rsi, input
	mov rdx, 1024
	call p4w_read

	;; Print Input
	mov rdi, 1
	mov rsi, input
	mov rdx, rax
	call p4w_write

	cmp BYTE [input], 'q'
	jz done
	jmp _start
done:	
	;; All done. Exiting
	xor rax, rax
	call p4w_exit
	
	;; --------------------------
	section .data
prompt:	 db "$ ", 0x00
prompt_len EQU $-prompt
input_len EQU 1024
input:	times 1024 db 0

