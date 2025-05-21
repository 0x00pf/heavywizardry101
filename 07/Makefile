all:dropper dropper1 dropper2 dropper3 dropper4 dropper5 \
	dropper6 dropper7 dropper.x86 dropper.arm dropper.mips dropper.riscv

dropper: dropper.c
	${CC} -o $@ $?

dropper4: dropper4.c
	${CC} -o $@ $? -lrt

dropper.x86: dropper.x86.asm
	nasm -f elf64 -o $@.o $?
	ld -o $@ $@.o

dropper.riscv: dropper.riscv.s
	riscv64-linux-gnu-as -o $@.o $?
	riscv64-linux-gnu-ld -o $@ $@.o

dropper.mips: dropper.mips.s
	mips-linux-gnu-as -o $@.o $?
	mips-linux-gnu-ld -o $@ $@.o

dropper.arm: dropper.arm.s
	arm-linux-gnueabi-as -o $@.o $?
	arm-linux-gnueabi-ld -o $@ $@.o
