// Team 18 - Test Assembly Program
// Simulates static and field variable access at machine level
//
// In the Hack architecture:
//   static variables are stored at fixed RAM addresses (16, 17, ...)
//   field/this variables are accessed via the THIS pointer (RAM[3])
//
// This program:
//   1. Stores a value into a "static" variable (RAM[16])
//   2. Sets up a THIS pointer (RAM[3] = 100)
//   3. Stores a "field" value via THIS pointer (RAM[100] = 42)
//   4. Reads back both values and stores result in RAM[0]

// ── STEP 1: Set static variable (RAM[16] = 5) ──────────────
// Equivalent to: let instanceCount = 5
@5
D=A
@16         // static 0 lives at RAM[16]
M=D         // RAM[16] = 5

// ── STEP 2: Increment static variable (RAM[16] = RAM[16] + 1) ──
// Equivalent to: let instanceCount = instanceCount + 1
@16
D=M
@1
D=D+A
@16
M=D         // RAM[16] = 6

// ── STEP 3: Set THIS pointer to base address 100 ───────────
// Equivalent to: pointer 0 = 100  (sets THIS)
@100
D=A
@THIS       // THIS = RAM[3]
M=D         // RAM[3] = 100

// ── STEP 4: Store field variable value (RAM[100] = 42) ─────
// Equivalent to: let value = 42  (field 'value' → this 0)
@42
D=A
@THIS
A=M         // A = RAM[3] = 100
M=D         // RAM[100] = 42

// ── STEP 5: Store second field variable (RAM[101] = 1) ─────
// Equivalent to: let id = 1  (field 'id' → this 1)
@1
D=A
@THIS
A=M
A=A+1       // A = 101
M=D         // RAM[101] = 1

// ── STEP 6: Read field value + static, store sum in RAM[0] ─
// Equivalent to: SP = value + instanceCount
@THIS
A=M         // A = 100
D=M         // D = RAM[100] = 42

@16         // static 0
D=D+M       // D = 42 + 6 = 48

@R0
M=D         // RAM[0] = 48

// ── INFINITE LOOP (end of program) ─────────────────────────
(END)
@END
0;JMP
