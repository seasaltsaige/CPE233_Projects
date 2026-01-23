# Created by Saige Sloan
# Cal Poly SLO
# 01/22/2026
.text
mult:
init:
    # Handle stack pushes
    addi sp, sp, -4  
    sw  x20, 0(sp)

    # temp load values for multiplication
    # li x20, 23
    # li x10, 5

    mv  x31, x0         # Clear accumulator
    beq x10, x0, done   # Check x10 for 0 value (done)
main:
    beq x20, x0, done   # If x20 equals 0, we are done
    add x31, x31, x10   # Add value in x10 to accumulator

    addi x20, x20, -1   # Subtract 1 from x20
    j   main            # Jump to main for loop

done: 
    # Handle stack pops
    lw x20, 0(sp)
    addi sp, sp, 4
