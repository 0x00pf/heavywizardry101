# Simplest Computer in The World 2000

This folder contains a simple assembler and an emulator for the SCTW-2K that you can use to follow along with chapter 1 or to take it as starting point to develop a more sophisticated virtual machine.

# Assembler

The assembler takes the source code from standard input and output the binary to standout. Typical usage is as follows:

```
$ cat file.asm | sctw2kc > file.bin
```

# Emulator
The emulator receives the program to emulate as a parameter and starts in interactive mode. In this mode, the user can enter the following commands:

```
? : Shows this help
q : Quits program
s : Instruction execution

```
The emulator will show the machine state: the values of the registers and a dump oif 16 bytes of memory after each user input. This allows you to execute step by step any SCTW-2k program assembled with the `sctw2kc` program.

