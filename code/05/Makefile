all: repl-asm repl-asm1 repl-asm2 repl-asm3 repl-asm.arm repl-asm1.arm repl-asm2.arm repl-asm3.arm \
     repl-asm.mips repl-asm1.mips repl-asm2.mips repl-asm.arm64 repl-asm1.arm64 repl-asm2.arm64

DEBUG=-F dwarf -g 

LIBS=../lib/plibc-x86.o
LIBS_ARM=../lib/plibc.arm.o
LIBS_ARM64=../lib/plibc.arm64.o
LIBS_MIPS=../lib/plibc.mips.o

repl-asm: repl-asm.o $(LIBS)
	ld -o $@ $^

repl-asm1: repl-asm1.o $(LIBS)
	ld -o $@ $^

repl-asm2: repl-asm2.o $(LIBS)
	ld -o $@ $^

repl-asm3: repl-asm3.o $(LIBS)
	ld -o $@ $^

repl-asm.arm: repl-asm.arm.o $(LIBS_ARM)
	arm-linux-gnueabi-ld -o $@  $^

repl-asm.arm.o: repl-asm.arm.s
	arm-linux-gnueabi-as -o $@ $^

repl-asm1.arm: repl-asm1.arm.o $(LIBS_ARM)
	arm-linux-gnueabi-ld -o $@  $^

repl-asm1.arm.o: repl-asm1.arm.s
	arm-linux-gnueabi-as -o $@ $^

repl-asm2.arm: repl-asm2.arm.o $(LIBS_ARM)
	arm-linux-gnueabi-ld -o $@  $^

repl-asm2.arm.o: repl-asm2.arm.s
	arm-linux-gnueabi-as -o $@ $^

repl-asm3.arm.o: repl-asm3.arm.s
	arm-linux-gnueabi-as -o $@ $^

repl-asm3.arm: repl-asm3.arm.o $(LIBS_ARM)
	arm-linux-gnueabi-ld -o $@ $^

repl-asm.mips.o: repl-asm.mips.s
	mips-linux-gnu-as -o $@ $^

repl-asm.mips: repl-asm.mips.o $(LIBS_MIPS)
	mips-linux-gnu-ld -o $@ $^

repl-asm1.mips.o: repl-asm1.mips.s
	mips-linux-gnu-as -o $@ $^

repl-asm1.mips: repl-asm1.mips.o $(LIBS_MIPS)
	mips-linux-gnu-ld -o $@ $^

repl-asm2.mips.o: repl-asm2.mips.s
	mips-linux-gnu-as -o $@ $^

repl-asm2.mips: repl-asm2.mips.o $(LIBS_MIPS)
	mips-linux-gnu-ld -o $@ $^

repl-asm.arm64: repl-asm.arm64.o $(LIBS_ARM64)
	aarch64-linux-gnu-ld -o $@  $^

repl-asm.arm64.o: repl-asm.arm64.s
	aarch64-linux-gnu-as -o $@ $^

repl-asm1.arm64: repl-asm1.arm64.o $(LIBS_ARM64)
	aarch64-linux-gnu-ld -o $@  $^

repl-asm1.arm64.o: repl-asm1.arm64.s
	aarch64-linux-gnu-as -o $@ $^

repl-asm2.arm64: repl-asm2.arm64.o $(LIBS_ARM64)
	aarch64-linux-gnu-ld -o $@  $^

repl-asm2.arm64.o: repl-asm2.arm64.s
	aarch64-linux-gnu-as -o $@ $^

%.o: %.asm
	nasm -f elf64 ${DEBUG} -o $@ $<

.PHONY:
clean:
	rm repl-asm repl-asm1 repl-asm2 repl-asm3 repl-asm.arm repl-asm1.arm repl-asm2.arm repl-asm3.arm \
	   repl-asm.mips repl-asm1.mips repl-asm.arm64 repl-asm1.arm64 repl-asm2.arm64
