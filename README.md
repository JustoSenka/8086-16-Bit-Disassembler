# 8086 16-Bit Disassembler
8086 16-Bit Disassembler written in Assembly

Disassembler for 16-Bit 8086 Intel CPU byte code while it itself was written in 16-Bit MASM/TASM assembler language. Does not recognize all opcodes, supports MOV PUSH POP ADD INC SUB DEC CMP MUL DIV CALL RET JMP LOOP INT and most of Jumps.

![Left: Disassembled code --- Right: Original Code](https://github.com/JustoSenka/8086-16-Bit-Disassembler/blob/master/pics/disasm2.png?raw=true)

## How to run

**Does not run on any modern 64 or 32 bit OS**

That being said, runs well on 16 bit OS, like Dos. With windows, it can run on DOSBox or other 8086 Emulators, like Emu8086.

Program expects 2 command line arguments to be passed. 

- First One: Source file path which should be disassembled.
- Second One: Destination filep path where disassembled code should be written.

Example: `disasm sourceFile.com destinationFile.txt`

## How to compile

Can be easily compiled with:

- Emu8086: Open source file and press run. Runs on modern systems
- Tasm 1.4: Included in the source. Running `Tasm\Tasm disasm` command will compile source to obj, and `Tasm\tlink disasm` will link to create executable.

Tasm and Tlink should be run from DOSBox as well.

## Source Code

Uploading just now, but originally it was written in late 2014. Source Code is released under MIT license. It can be used freely however you want, although, there are some bugs and it doesn't support all instructions as it was written as part of learning process. Storing source code here to preserve it for future generations as it could be used for a learning material to something the world has already passed and forgotten.. 8086
