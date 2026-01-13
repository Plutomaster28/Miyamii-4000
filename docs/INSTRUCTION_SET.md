# Miyamii-4000 Instruction Set Reference

## Instruction Format

All instructions are either 8-bit (1 byte) or 16-bit (2 bytes).

### Instruction Encoding Format
```
[7:4] - Opcode (operation)
[3:0] - Operand (register, immediate, or condition)
```

## Complete Instruction List

### No Operation
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| NOP | 0000 0000 | No operation | 8 | - |

### Arithmetic Operations
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| ADD r | 1000 rrrr | Add register to accumulator | 8 | CY |
| SUB r | 1001 rrrr | Subtract register from accumulator | 8 | CY |
| INC r | 0110 rrrr | Increment register | 8 | CY |
| IAC | 1111 0010 | Increment accumulator | 8 | CY |
| DAC | 1111 1000 | Decrement accumulator | 8 | CY |
| DAA | 1111 1011 | Decimal adjust accumulator | 8 | CY |

### Logic Operations
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| CMA | 1111 0100 | Complement accumulator | 8 | - |
| CMC | 1111 0011 | Complement carry | 8 | CY |
| STC | 1111 1010 | Set carry | 8 | CY |
| CLC | 1111 0001 | Clear carry | 8 | CY |
| CLB | 1111 0000 | Clear both (accumulator and carry) | 8 | CY |

### Rotate Operations
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| RAL | 1111 0101 | Rotate left through carry | 8 | CY |
| RAR | 1111 0110 | Rotate right through carry | 8 | CY |

### Data Transfer
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| LD r | 1010 rrrr | Load register to accumulator | 8 | - |
| XCH r | 1011 rrrr | Exchange register and accumulator | 8 | - |
| LDM d | 1101 dddd | Load immediate to accumulator | 8 | - |
| TCC | 1111 0111 | Transfer carry to accumulator, clear carry | 8 | CY |
| TCS | 1111 1001 | Transfer carry subtract (acc = 9 + carry) | 8 | CY |

### Register Pair Operations
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| FIM rp,d | 0010 rrr0 dddddddd | Fetch immediate to register pair | 8 | - |
| SRC rp | 0010 rrr1 | Send register control (set RAM address) | 8 | - |
| FIN rp | 0011 rrr0 | Fetch indirect from ROM | 8 | - |
| JIN rp | 0011 rrr1 | Jump indirect | 8 | - |

### Jump and Branch
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| JUN a | 0100 aaaa aaaaaaaa | Jump unconditional (12-bit address) | 8 | - |
| JMS a | 0101 aaaa aaaaaaaa | Jump to subroutine (12-bit address) | 8 | - |
| JCN c,a | 0001 cccc aaaaaaaa | Jump conditional (8-bit address) | 8 | - |
| ISZ r,a | 0111 rrrr aaaaaaaa | Increment and skip if zero | 8 | - |
| BBL d | 1100 dddd | Branch back and load data | 8 | - |

### RAM Operations
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| WRM | 1110 0000 | Write accumulator to RAM main | 8 | - |
| WMP | 1110 0001 | Write accumulator to RAM port | 8 | - |
| WRR | 1110 0010 | Write accumulator to ROM port | 8 | - |
| WR0 | 1110 0100 | Write accumulator to RAM status 0 | 8 | - |
| WR1 | 1110 0101 | Write accumulator to RAM status 1 | 8 | - |
| WR2 | 1110 0110 | Write accumulator to RAM status 2 | 8 | - |
| WR3 | 1110 0111 | Write accumulator to RAM status 3 | 8 | - |
| RDM | 1110 1001 | Read RAM main to accumulator | 8 | - |
| RDR | 1110 1010 | Read ROM port to accumulator | 8 | - |
| RD0 | 1110 1100 | Read RAM status 0 to accumulator | 8 | - |
| RD1 | 1110 1101 | Read RAM status 1 to accumulator | 8 | - |
| RD2 | 1110 1110 | Read RAM status 2 to accumulator | 8 | - |
| RD3 | 1110 1111 | Read RAM status 3 to accumulator | 8 | - |
| SBM | 1110 1000 | Subtract RAM from accumulator | 8 | CY |
| ADM | 1110 1011 | Add RAM to accumulator | 8 | CY |

### Special Operations
| Mnemonic | Opcode | Description | Cycles | Flags |
|----------|--------|-------------|--------|-------|
| KBP | 1111 1100 | Keyboard process (convert bit to decimal) | 8 | - |
| DCL | 1111 1101 | Designate command line (RAM bank select) | 8 | - |

## Condition Codes (for JCN)

The JCN instruction uses a 4-bit condition field (cccc):

```
Bit 0: Invert condition
Bit 1: Test accumulator = 0
Bit 2: Test carry = 1
Bit 3: Test test pin = 0
```

### Common Condition Codes
| Code | Bits | Description |
|------|------|-------------|
| 0000 | 0000 | Never jump (NOP) |
| 0001 | 0001 | Always jump (invert never) |
| 0010 | 0010 | Jump if accumulator = 0 |
| 0011 | 0011 | Jump if accumulator ≠ 0 |
| 0100 | 0100 | Jump if carry = 1 |
| 0101 | 0101 | Jump if carry = 0 |
| 0110 | 0110 | Jump if accumulator = 0 OR carry = 1 |
| 1000 | 1000 | Jump if test = 0 |
| 1001 | 1001 | Jump if test = 1 |

## Register Addressing

### Individual Registers (0-15)
```
0000 - Register 0
0001 - Register 1
...
1111 - Register 15
```

### Register Pairs (0-7)
```
000 - Pair 0 (R0, R1)
001 - Pair 1 (R2, R3)
010 - Pair 2 (R4, R5)
011 - Pair 3 (R6, R7)
100 - Pair 4 (R8, R9)
101 - Pair 5 (R10, R11)
110 - Pair 6 (R12, R13)
111 - Pair 7 (R14, R15)
```

## Programming Examples

### Example 1: Simple Addition
```assembly
; Add two numbers (3 + 5)
    LDM 3       ; Load 3 into accumulator
    XCH 0       ; Store in register 0
    LDM 5       ; Load 5 into accumulator
    ADD 0       ; Add register 0 (result: 8 in accumulator)
```

### Example 2: Loop Counter
```assembly
; Count from 0 to 10
LOOP:
    LDM 10      ; Load 10
    XCH 0       ; Store counter in R0
    INC 0       ; Increment R0
    ISZ 0, LOOP ; Loop if not zero
    LDM 0       ; Done
```

### Example 3: Subroutine with Parameters
```assembly
; Main program
    LDM 5       ; Load parameter
    XCH 0       ; Store in R0
    JMS DOUBLE  ; Call subroutine
    ; Result in accumulator
    
DOUBLE:
    LD 0        ; Load parameter from R0
    XCH 1       ; Save to R1
    ADD 1       ; Double it (R1 + R1)
    BBL 0       ; Return
```

### Example 4: RAM Operations
```assembly
; Write to RAM
    FIM 0, 0x12 ; Set RAM address (R0R1 = 0x12)
    SRC 0       ; Send to RAM address register
    LDM 7       ; Load data
    WRM         ; Write to RAM main character
    
; Read from RAM
    FIM 0, 0x12 ; Set RAM address
    SRC 0       ; Send to RAM address register
    RDM         ; Read from RAM (result in accumulator)
```

### Example 5: Conditional Logic
```assembly
; If-else structure
    LD 0        ; Load value from R0
    JCN NZ, ELSE ; Jump if not zero
    LDM 1       ; True branch
    JUN END
ELSE:
    LDM 0       ; False branch
END:
    NOP
```

### Example 6: Decimal Arithmetic (BCD)
```assembly
; Add two BCD digits
    LDM 5       ; First BCD digit
    XCH 0       ; Store in R0
    LDM 8       ; Second BCD digit
    ADD 0       ; Add (result may be > 9)
    DAA         ; Decimal adjust (converts to BCD)
```

## Instruction Timing

All instructions execute in exactly **8 clock cycles**:
- Clock period: 10.8 μs
- Instruction time: 86.4 μs
- Throughput: ~11,574 instructions/second

### Cycle Breakdown
```
A1 (Cycle 1): Fetch first byte - address on bus
A2 (Cycle 2): Fetch first byte - data captured
A3 (Cycle 3): Decode instruction
M1 (Cycle 4): Execute or fetch second byte
M2 (Cycle 5): Continue execution
X1 (Cycle 6): Complete execution
X2 (Cycle 7): Write back results
X3 (Cycle 8): Finish cycle, increment PC
```

## Memory Map

### ROM (Program Memory)
```
0x000 - 0xFFF: 4096 bytes of program code
  0x000 - 0x0FF: Page 0 (256 bytes)
  0x100 - 0x1FF: Page 1 (256 bytes)
  ...
  0xF00 - 0xFFF: Page 15 (256 bytes)
```

### RAM (Data Memory)
```
1280 x 4-bit locations
Organized as:
  - 320 characters (4 bits each)
  - 40 registers (16 x 4-bit nibbles each)
  - 4 status characters per chip
```

## Flags

### Carry Flag (CY)
- Set by arithmetic operations that generate carry
- Used in addition, subtraction, and rotate operations
- Can be explicitly set (STC), cleared (CLC), or complemented (CMC)

## Notes

1. **Two-byte instructions** require the second byte to be fetched during M1-M2 states
2. **Stack depth** is limited to 3 levels for subroutine calls
3. **RAM addressing** requires SRC instruction before RAM operations
4. **Accumulator** is the primary working register for most operations
5. **Register pairs** allow 8-bit data handling in a 4-bit architecture

## Assembler Syntax

```assembly
LABEL:  OPCODE  OPERAND     ; Comment
```

Example:
```assembly
START:  LDM     5           ; Load immediate 5
        ADD     0           ; Add register 0
LOOP:   ISZ     1, LOOP     ; Loop on register 1
        BBL     0           ; Return
```
