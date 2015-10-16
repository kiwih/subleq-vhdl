# subleq-vhdl

This is an implementation of the subleq [One Instruction Set Computer](https://en.wikipedia.org/wiki/One_instruction_set_computer).

It is written in VHDL as a single-cycle, harvard architecture machine.

It synthesizes correctly on Quartus 11 for the Cyclone EP1C3T144C8. The top level file is subleq.vhd.

The processor features some memory mapped components - two two-digit seven-segment displays, although one of the displays is not currently enabled (instead the PC is output instead).
The 4 seven segment displays are in matrix form, so they require a driver to scan the different digits continuously (using persistance of vision).

##How does subleq work?

Subleq executes the pseudo-code
Given addresses a,b,c, where [a] is the data at address a:
 1. [b] = [b] - [a]
 2. if [b] - [a] <= goto c 

##Currently encoded program

Currently, the processor runs the following program:
 0. Write F to the first seven seg display, continue
 1. (nop) Jump to 2
 2. Subtract 1 from seven seg display, if now 0, go to 4, else continue
 3. (nop) Jump to 2
 4. (nop) Jump to 0.

The reasons for the nops is so that each decrement of the digit takes 2 instructions, making a nice smooth down-counter.


This program is encoded as follows (7segment display is located at F0 in data memory):
```
INSTRUCTIONS     A   B   C     EXPLAIN?
0 => x"01F001"   01  F0  01    Write [F0] - [01] (0 - -F) into [F0]. This !<= 0 so C is ignored (but I leave it as 01 anyway)
1 => x"000002"   00  00  02    Write [00] - [00] (0 - 0) into [00]. This <=0 so GOTO 2. Acts as GOTO instruction.
2 => x"02F004"   02  F0  04    Write [F0] - [02] into [F0] (subtract 1 from F0). If res <=0 GOTO 4, else, continue
3 => x"000002"   00  00  02    GOTO 2
4 => x"000000"   00  00  00    GOTO 4
```

```
DATA
0 => 0
1 => -F (in 2's compliment)
2 => 1
```
