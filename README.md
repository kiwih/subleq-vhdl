# subleq-vhdl

This is an implementation of the subleq [One Instruction Set Computer](https://en.wikipedia.org/wiki/One_instruction_set_computer).

It is written in VHDL as a single-cycle, harvard architecture machine.

It synthesizes correctly on Quartus 11 for the Cyclone EP1C3T144C8. The top level file is subleq.vhd.

The processor features some memory mapped components - two two-digit seven-segment displays, although one of the displays is not currently enabled (instead the PC is output instead).
The 4 seven segment displays are in matrix form, so they require a driver to scan the different digits continuously (using persistance of vision).

Currently, the processor runs the following program:
 0. Write FF to the first seven seg display, continue
 1. (nop) Jump to 2
 2. Subtract 1 from seven seg display, if now 0, go to 4, else continue
 3. (nop) Jump to 2
 4. (nop) Jump to 0.

The reasons for the nops is so that each decrement of the digit takes 2 instructions, making a nice smooth down-counter.

This program is encoded as follows:
```
INSTRUCTIONS	
0 => x"01F001",
1 => x"000002",
2 => x"02F004",
3 => x"000002",
4 => x"000000",
```

```
DATA
0 => 0
1 => -FF (in 2's compliment)
2 => 1
```
