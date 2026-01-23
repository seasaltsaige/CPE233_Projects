# Created by Saige Sloan
# Cal Poly SLO
# 01/22/2026
.text
neg_add_sub:
init:
    # Handle stack pushes
    addi sp, sp, -12
    sw x20, 0(sp)
    sw x21, 4(sp)
    sw x31, 8(sp)
    # temp store values in x20, x21 for testing
    # li x20, 0xFFF08390
    # li x21, 0xFFFFC992

    li x22, 0x80000000 # initialize mask for first bit

    xor x20, x20, x22 # XOR msb in reg 20 (negate)
    xor x21, x21, x22 # XOR msb in reg 21 (negate)
    
    add x31, x20, x21 # Add x31 <- x20 + x21 
    addi x31, x31, -0x100 

done:
    # Handle stack pops
    lw x31, 8(sp)
    lw x21, 4(sp)
    lw x20, 0(sp)
    addi sp, sp, 12