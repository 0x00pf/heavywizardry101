BITS 64
        org 0x400000
ehdr:                                   ; Elf64_Ehdr
        db      0x7F, "ELF", 2, 1, 1, 0 ; 0x00: e_ident
        times 8 db      0               ; 0x09: e_ident(PADDING)
        dw      2                       ; 0x10: e_type
        dw      0x3e                    ; 0x12: e_machine
        dd      1                       ; 0x14: e_version
        dq      _start                  ; 0x18: e_entry
        dq      phdr - $$               ; 0x20: e_phoff
        dq      0                       ; 0x28: e_shoff
        dd      0                       ; 0x30: e_flags
        dw      ehdrsize                ; 0x34: e_ehsize
        dw      phdrsize                ; 0x36: e_phentsize
        dw      1                       ; 0x38: e_phnum
        dw      0                       ; 0x3a: e_shentsize
        dw      0                       ; 0x3c: e_shnum
        dw      0                       ; 0x3e: e_shstrndx
	ehdrsize      equ     $ - ehdr  ;   Header Size

phdr:                                   ; Elf64_Phdr
        dd      1                       ; 0x00: p_type (PT_LOAD)
        dd      5                       ; 0x04: p_flags (PF_R | PF_X)
        dq      0                       ; 0x08: p_offset
        dq      $$                      ; 0x10: p_vaddr
        dq      $$                      ; 0x18: p_paddr
        dq      filesize                ; 0x20: p_filesz
        dq      filesize                ; 0x28: p_memsz
        dq      0x1000                  ; 0x30: p_align

	phdrsize      equ     $ - phdr

	
_start: mov 	rax, 1
	mov 	rdi, 1
	lea 	rsi, [rel msg]
	mov  	rdx, 13
	syscall
	
	;; Exit program
	mov 	rax, 0x3c 
	mov 	rdi, 0
	syscall
	
msg:
	db 'Hello World!',0x0a
	
filesize equ $ - $$
