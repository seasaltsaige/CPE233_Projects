# Cal Poly SLO
# Saige Sloan
# Description: The following subroutine counts the number of times a word
#              passed in s0 has bytes that match any of the values in the
#              look up table defined at 'byte_check' and returns it in a1

.data

byte_check:      .byte 0x34,0xAF,0x49,0x4B,0x7C,0x9D,0x40,0x3E

.text

count_matches:
init:                       # Word passed in s0
    mv a1, x0               # Clear accumulator
    mv t1, s0               # Copy passed word to temp reg
    li t2, 0x4              # Outer loop counter
word_loop:                  # Loop through the 4 bytes in the passed word
    beq t2, x0, done        # Once outer loop is zero, we are done
    la t0, byte_check       # Load LUT address
    li t4, 0x8              # Inner loop counter, 8 bytes in LUT
    andi t5, t1, 0xFF       # Isolate lower byte
lut_loop:
    beq t4, x0, lut_admin   # Admin for inner loop completion
    lbu t3, 0(t0)           # Load byte from current address

    xor t3, t3, t5          # XOR lut byte and word byte
    seqz t3, t3             # If t3 is 0, set equal to 1, oterwise zero
                            # If t3 == t5, t3 will be 0 after xor
    add a1, a1, t3          # Add result to accumulator

    addi t0, t0, 1          # Increment address
    addi t4, t4, -1         # Decrement inner counter
    j lut_loop
lut_admin:
    srli t1, t1, 8          # Shift 8 bits right
    addi t2, t2, -1         # Decrement outer counter
    j word_loop
done:
    ret


