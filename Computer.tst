// Team 18 - Computer Test Script
// Run this in the Nand2Tetris Hardware Simulator
// File: Computer.tst
//
// Tests that our static/field variable access program runs correctly.
// After execution:
//   RAM[16]  should be 6   (static var: instanceCount after increment)
//   RAM[3]   should be 100 (THIS pointer)
//   RAM[100] should be 42  (field var: value)
//   RAM[101] should be 1   (field var: id)
//   RAM[0]   should be 48  (42 + 6, stored in R0)

load Computer.hdl,
output-file Computer.out,
compare-to Computer.cmp,
output-list RAM[0]%D1.6.1 RAM[3]%D1.6.1 RAM[16]%D1.6.1 RAM[100]%D1.6.1 RAM[101]%D1.6.1;

// Load our machine code program into ROM
ROM32K load team18_test.hack,

// Reset the computer (PC = 0)
set reset 1,
tick, tock,
set reset 0,

// Run for enough cycles to complete all 34 instructions
// (use extra cycles to account for the infinite loop at the end)
repeat 50 {
    tick, tock,
}

// Output the relevant RAM values
output;
