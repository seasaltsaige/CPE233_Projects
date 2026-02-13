# Cal Poly SLO
# Saige Sloan
# Description: The following subroutine outputs bytes from the tables below
#              based on the input word. It does so for all non-zero nibbles
#              in the word.

.data
                        # 0 to 7 portion of table
                        # NOTE: ADDR(0x34) should never be used, as non-zero nibbles are output
nib_table_lo:      .byte 0x34, 0xAF, 0x49, 0x4B, 0x7C, 0x9D, 0x40, 0x3E
                        # 8 to 15 portion of table
                        # NOTE: 0xF4 is at ADDR(0x3E) + 1, so nib_table_hi is 'meaningless'
                        #       
nib_table_hi:      .byte 0xF4, 0x1F, 0xE9, 0xCB, 0x2C, 0x3D, 0x61, 0x31

.text

init:
    li t0, 0x1100AA00   # Load input IO address
                        # Output IO address is t0 + 4
    la t1, nib_table_lo
    lw t2, 0(t0)

loop:
    beqz t2, done       # Branch to done once input is empty

    andi t3, t2, 0xF    # Isolate lowest nibble
    beqz t3, admin      # If nibble is zero, skip it, as described

    add t3, t1, t3      # Add offset (nibble value) to address to get absolute address
    lbu t3, 0(t3)       # Load the byte at the address

    sb t3, 4(t0)        # Output byte to output address (t0 + 4)

admin:
    srli t2, t2, 4      # Shift to next nibble
    j loop

done: ret
