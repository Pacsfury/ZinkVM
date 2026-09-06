# ZinkVM
Developing another simple stack-based virtual machine, this time written in Zig to learn more about VMs and the language.

---

## Operations

0 - NOP - _No operation_

1 - PUSH - _Adds next number at stack_

2 - POP - _Deletes top stack number_

3 - ADD - _Sums two top numbers, pops them and push the result_

4 - SUB - _Subs two top numbers, pops them and push the result_

5 - MUL - _Mulitplies two top numbers, pops them and push the result_

6 - DIV - _Divides two top numbers, pops them and push the result_

7 - DUP - _Duplicates top stack item_

8 - RES - _Prints top stack item_

9 - JMP - _Goes to the next program number_

10 - JIZ - _Goes to the next program number if the top of the stack is 0_

11 - JNZ - _Goes to the next program number if the top of the stack is not 0_

12 - EQU - _Pops the two top items from stack, if they are equal, pushes a 1, of not, a 0_

13 - NEQ - _Pops the two top items from stack, if they are not equal, pushes a 1, of not, a 0_

14 - GRT - _Pops the two top items from stack, if a > b, pushes a 1, of not, a 0_

15 - SMT - _Pops the two top items from stack, if a < b, pushes a 1, of not, a 0_

16 - GRE - _Pops the two top items from stack, if a >= b, pushes a 1, of not, a 0_

17 - SME - _Pops the two top items from stack, if a <= b, pushes a 1, of not, a 0_

18 - LOR - _Logical OR_

19 - LAND - _Logical AND_

20 - LXOR - _Logical XOR_

21 - LNOT - _Logical NOT_

22 - BOR - _Bitwise OR_

23 - BAND - _Bitwise AND_

24 - INC - _Increment stack top_

25 - DEC - _Decrement stack top_

26 - COUT - _Print stack top as Ascii character_

27 - SWAP - _Swap stack[-1] and stack[-2]_

28 - CLS - _Delete the stack_

29 - MOD - _Divides two top numbers, pops them and push the remainder of the division_

30 - SHL - _Left shift_

31 - SHR - _Right shift_

32 - JGT — _Pops two items, goes to the next program number if a > b_

33 - JLT — _Pops two items, goes to the next program number if a < b_

34 - JGE — _Pops two items, goes to the next program number if a >= b_

35 - JLE — _Pops two items, goes to the next program number if a <= b_

36 - SAVE - _Pops address, then value, saves at memory_

37 - LOAD - _Pops address, pushed value from memory_

38 - SPRINT - _Pops a constant pool address, prints the string at that index of constant pool_

## Assembler

_Docs coming soon_

## Examples

### Divide 6 by itself

```
@intFromEnum(operations.push), 0x06, @intFromEnum(operations.dup), @intFromEnum(operations.div), @intFromEnum(operations.res), @intFromEnum(operations.push), 0x00
```

Or

```
0x01, 0x06, 0x07, 0x06, 0x08, 0x01, 0x00
```

So basically, what the program does is: 


| **PUSH** | 6   | **DUPLICATE 6** | **DIVIDE** | **PRINT TOP** | **PUSH** | 0    |
|----------|-----|-----------------|------------|---------------|----------|------|
| 0x01     | 0x06| 0x07            | 0x06       | 0x08          | 0x01     | 0x00 |

We push zero at the end (we could do other operations, like -6) because the VM gets the top of the stack and uses it as the program result. And code 0 means all right.
