# Created by Saige Sloan
# Cal Poly SLO
# 01/22/2026
# Subroutine which negates the 2’s complement values in x20 and x21,
# Adds them together, subtracts 0x100 from them, and stores it in x30
.text
neg_add_sub:
init:
    # Handle stack pushes
    addi sp, sp, -12
    sw ra, 0(sp)
    sw x20, 4(sp)
    sw x21, 8(sp)
    # temp store values in x20, x21 for testing
    # li x20, 0xFFF08390
    # li x21, 0xFFFFC992

    neg x20, x20            # negate reg 20
    neg x21, x21            # negate reg 21

    add x30, x20, x21       # Add x31 <- x20 + x21 
    addi x30, x30, -0x100   # Sub 0x100 from result

done:
    # Handle stack pops
    lw ra, 0(sp)
    lw x20, 4(sp)
    lw x21, 8(sp)
    addi sp, sp, 12

    ret