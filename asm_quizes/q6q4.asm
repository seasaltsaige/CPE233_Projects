# Cal Poly SLO
# Saige Sloan
# Description: The following subroutine takes in input on s0,
#              then outputs a modified version to a0.
#              The output of the program shifts the input number
#              filling the MSB with 1s until the LSB is no longer
#              equal to 0. The number of shifts needed to do this
#              is output to a1.

# Assuming stack pointer is initialized
.text
    # Save s0 context, as it is a saved register
    addi sp, sp, -4 
    sw s0, 0(sp)
    
    mv t1, x0           # Init accum
    li t2, 0x80000000   # Load mask
loop:
    andi t0, s0, 0x1    # Isolate LSB
    bnez t0, done       # If LSB is NOT zero

    srli s0, s0, 1      # Shift right by one
    or s0, s0, t2       # Mask MSB to be a 1
                        # SRAI would only work if number is already negative
    addi t1, t1, 1      # Add to accumulator for # of lsb's removed
    j loop              # Continue the loop

done:
    mv a0, s0           # Copy return values to return registers
    mv a1, t1

    # Pop s0 contextss
    lw s0, 0(sp)
    addi sp, sp, 4
    ret
