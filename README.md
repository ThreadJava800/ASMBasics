# Assembler basics

Here i will put my basic assembler programs.

All this programs are compatible with turbo assembler and DOS. Of course, this technologies are deprecated, by I used them mainly to work with interruptions (it is much harder in modern OS). I will definetely use something more modern in future.

For now I have created a [library](https://github.com/ThreadJava800/ASMBasics/blob/main/LIBA.ASM) that contains functions for getting decimal value from keyboard, for printing registers in different notations (BIN, HEX, DEC) and drawing rectangle on the screen.

In [FIRST.AM](https://github.com/ThreadJava800/ASMBasics/blob/main/EXPLM/FIRST.ASM) you can see basic interruptions.

In [COLORTXT.ASM](https://github.com/ThreadJava800/ASMBasics/blob/main/COLORTXT/COLORTXT.ASM) you can find an example of printing a colored string.

In [CALC.ASM](https://github.com/ThreadJava800/ASMBasics/blob/main/FUNCTION/CALC.ASM) you can find a calculator that adds two decimal numbers (taken from keyboard) and translates this value to HEX, BIN and DEC and prints.

In [RAMKA.ASM](https://github.com/ThreadJava800/ASMBasics/blob/main/RAMKA/RAMKA.ASM) you can see a call of a function that prints rectangle on screen (declared in [LIBA.ASM](https://github.com/ThreadJava800/ASMBasics/blob/main/LIBA.ASM)).

In [FRMBYTXT.ASM](https://github.com/ThreadJava800/ASMBasics/blob/main/RAMKA/FRMBYTXT.ASM) you can see a call of a function that prints rectangle on screen based on text (declared in [LIBA.ASM](https://github.com/ThreadJava800/ASMBasics/blob/main/LIBA.ASM)).

In [INTINT](https://github.com/ThreadJava800/ASMBasics/tree/main/INTINT) you can see my experiments with DOS interruptions. 
The climax of it you can see in [REGVIEW.ASM](https://github.com/ThreadJava800/ASMBasics/blob/main/INTINT/REGVIEW.ASM) - it prints your register in live time (you can switch off/on it with hot key). Specifically I worked with 9th (keyboard) and 8th (chronometer) DOS interruption

Updates coming!
