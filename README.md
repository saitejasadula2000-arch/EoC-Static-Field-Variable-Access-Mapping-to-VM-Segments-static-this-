# Team 18 — EOC End Semester Project
## Static and Field Variable Access Mapping to VM Segments (static, this)

---

## 🎯 Project Overview

This project implements **static** and **field** variable access mapping to VM memory
segments in the Nand2Tetris / Jack compiler framework.

| Jack Variable Type | VM Segment | RAM Address     | Scope         |
|--------------------|------------|-----------------|---------------|
| `static`           | `static`   | RAM[16], [17]…  | Class-wide    |
| `field`            | `this`     | RAM[THIS+0], … | Per-object    |

---

## 📁 File Structure

```
Part1_Jack/
  Counter.jack              ← Jack class with static + field variables
  Main.jack                 ← Test driver program
  Counter_expected_VM.vm    ← Expected VM code (for verification)

Part2_Assembler/
  assembler.py              ← Our custom Python assembler
  team18_test.asm           ← Test assembly program
  team18_test.hack          ← Generated 16-bit machine code

Part3_Hardware/
  Computer.hdl              ← Top-level architecture (CPU + ROM + RAM)
  ROM_with_program.hdl      ← ROM chip with machine code documentation
  Computer.tst              ← Hardware Simulator test script
  Computer.cmp              ← Expected output for test
```

---

## Part 1: Jack Program

### Concept
- `static int instanceCount` → compiled to `static 0` in VM → stored at `RAM[16]`
- `field int value`          → compiled to `this 0`   in VM → stored at `RAM[THIS+0]`
- `field int id`             → compiled to `this 1`   in VM → stored at `RAM[THIS+1]`

### How to run on VM Emulator
1. Open Nand2Tetris **VM Emulator**
2. Compile `Counter.jack` and `Main.jack` using the Jack Compiler
3. Load the generated `.vm` files
4. Run and verify the output matches:
   ```
   Counter 1 Value: 5
   Counter 2 Value: 10
   After increment -> Counter 1 Value: 6
   Total Instances: 2
   After reset    -> Total Instances: 0
   ```

### Key VM Instructions Generated
```
// field access (this segment):
push this 0     ← read field 'value'
pop  this 0     ← write field 'value'
push this 1     ← read field 'id'

// static access:
push static 0   ← read instanceCount
pop  static 0   ← write instanceCount

// object setup in constructor:
push constant 2   ← 2 fields to allocate
call Memory.alloc 1
pop pointer 0     ← sets THIS pointer
```

---

## Part 2: Custom Assembler

### How to run
```bash
python assembler.py team18_test.asm
```
This produces `team18_test.hack` with 16-bit binary machine code.

### Assembler Design
The assembler works in **two passes**:

**Pass 1 — Label Resolution:**
- Scans for `(LABEL)` declarations
- Records their ROM address in the symbol table

**Pass 2 — Code Generation:**
- A-instructions (`@value` or `@symbol`) → `0vvvvvvvvvvvvvvv`
- C-instructions (`dest=comp;jump`) → `111accccccdddjjj`
- New variable symbols are assigned RAM addresses starting at 16

### Predefined symbols included:
`SP, LCL, ARG, THIS, THAT, R0–R15, SCREEN, KBD`

---

## Part 3: Hardware Architecture

### Architecture Diagram
```
                    reset
                      │
                      ▼
┌─────────────────────────────────────────┐
│              COMPUTER                   │
│                                         │
│  ┌──────────┐  instruction  ┌────────┐  │
│  │          │◄──────────────│ ROM32K │  │
│  │   CPU    │               │(.hack) │  │
│  │          │────pc────────►│        │  │
│  │          │               └────────┘  │
│  │          │                           │
│  │          │  addressM[0..13]          │
│  │          │──────────────►┌────────┐  │
│  │          │◄──inM─────────│ RAM16K │  │
│  │          │───outM───────►│        │  │
│  │          │───writeM─────►│        │  │
│  └──────────┘               └────────┘  │
└─────────────────────────────────────────┘
```

### Expected RAM state after execution
| RAM Address | Value | Meaning                          |
|-------------|-------|----------------------------------|
| RAM[0]      | 48    | Result: field(42) + static(6)    |
| RAM[3]      | 100   | THIS pointer (object base addr)  |
| RAM[16]     | 6     | static 0: instanceCount          |
| RAM[100]    | 42    | this 0: field 'value'            |
| RAM[101]    | 1     | this 1: field 'id'               |

### How to run in Hardware Simulator
1. Open Nand2Tetris **Hardware Simulator**
2. Load `Computer.hdl`
3. Load program: `team18_test.hack` into ROM32K
4. Run `Computer.tst` test script
5. Verify output matches `Computer.cmp`

---

## Summary: Static vs Field Mapping

```
Jack Source          VM Code          Machine Code Example
─────────────────────────────────────────────────────────
let instanceCount    pop static 0  →  @16 + M=D
= instanceCount+1    push static 0    @16 + D=M

let value = 42       push constant 42  @42 + D=A
                     pop this 0        @THIS + A=M + M=D

let id = 1           push constant 1   @1 + D=A
                     pop this 1        @THIS + A=M + A=A+1 + M=D
```

---

## Team 18 Members
*S Sai Teja (Team Lead), K Rathan, N Dileep Reddy, S Veekshith Reddy*

---
*23AID113 Elements of Computing - II | End Semester Project*
