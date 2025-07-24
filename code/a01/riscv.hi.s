	.global _start
ehdr:                                      # 0x00 : Elf64_Ehdr
        .byte      0x7F, 0x45, 0x4c, 0x46  # 0x00 : e_ident(MAGIC)
				.byte      2, 1, 1, 0              # 0x04 : e_ident(CLASS, ENDIANESS, VERSION,ABI,ABI VERSION)
        .fill      8, 1, 0                 # 0x09 : e_ident(PADDING)
        .short     3                       # 0x10 : e_type (ET_DYN)
        .short     0xf3                    # 0x12 : e_machine
        .long      1                       # 0x14 : e_version 1
        .quad      elfdata                  # 0x18 : e_entry: .text at 0x10000 78 is the offset to _start
        .quad      ehdrsize                # 0x20 : e_phoff
        .quad      0                       # 0x28 : e_shoff
        .long      0                       # 0x30 : e_flags (RISC-V 0x4 floating-point)
        .short     ehdrsize                # 0x34 : e_ehsize
        .short     phdrsize                # 0x36: e_phentsize
        .short     1                       # 0x38: e_phnum
        .short     0                       # 0x3a: e_shentsize
        .short     0                       # 0x3C: e_shnum
        .short     0                       # 0x3e:  e_shstrndx
				.equ  		ehdrsize,   . - ehdr         # Header Size

phdr:                                      # Elf64_Phdr
        .long      1                       # 0x00:  p_type (PT_LOAD)
        .long      5                       # 0x04: flags )(PF_R | PF_X)
        .quad      0                       # 0x08: p_offset
        .quad      0                  # 0x10: p_vaddr
				.quad      0                  # 0x18: p_paddr

	
        .quad      filesize                # 0x20: p_filesz
        .quad      filesize                # 0x28: p_memsz
        .quad      0x1000                  # 0x30: p_align
				.equ 		phdrsize ,  . - phdr          # Size of Program Header entry
				.equ 		elfdata, . - ehdr
	
# Regular code starts here....
	#-----------------------------------------------
_start:	  
	li a7, 64 
	li a0, 1
	la a1,msg
	li a2, 13
	ecall 

	li a0,42
	li a7,93
	ecall
msg:
	.asciz "Hello World!\n"
#-----------------------------------------------
# Regular code ends here
#-----------------------------------------------
	.equ filesize, . - ehdr        # Calculate filesize
