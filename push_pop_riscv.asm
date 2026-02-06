li x30, 0x0000FFFC # Stack Pointer value
mv sp, x30 # Init stack pointer for examples

# Push/Pop pairs

push_before: # Push will store the current
    addi sp, sp, -8
    sw  x8, 0(sp)
    sw  x10, 4(sp)

pop_after: # Pop 
    lw x10, 4(sp)
    lw x8, 0(sp)
    addi sp, sp, 8


push_after:
    sw x8, -8(sp)
    sw x10, -4(sp)
    addi sp, sp, -8

pop_before:
    addi sp, sp, 8
    lw x10, -4(sp)
    lw x8, -8(sp)