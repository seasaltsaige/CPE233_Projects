# Created by Saige Sloan
# Cal Poly SLO
# 01/22/2026
# Subroutine which negates the 2’s complement values in x20 and x21,
# Adds them together, subtracts 0x100 from them, and stores it in x31
.text
neg_add_sub:
init:
    # Handle stack pushes
    addi sp, sp, -8
    sw x20, 0(sp)
    sw x21, 4(sp)
    # temp store values in x20, x21 for testing
    # li x20, 0xFFF08390
    # li x21, 0xFFFFC992

    li x22, 0xFFFFFFFF # initialize mask for xor

    xor x20, x20, x22 # XOR msb in reg 20 (negate)
    addi x20, x20, 1 # Add one for 2's complement
    xor x21, x21, x22 # XOR msb in reg 21 (negate)
    addi x20, x20, 1 # Add one for 2's complement
    
    add x31, x20, x21 # Add x31 <- x20 + x21 
    addi x31, x31, -0x100 # Sub 0x100 from result

done:
    # Handle stack pops
    lw x21, 4(sp)
    lw x20, 0(sp)
    addi sp, sp, 8

    ret