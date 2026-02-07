# Saige Sloan
# Cal Poly SLO
# Description: The following subroutine continuously loads half words
#              from the port id 0x11000010, evaluating each nibble
#              (4 per halfword) to see if they are equal to a nibble
#              passed to the subroutine in x10. Once 32 total nibbles
#              are seen that are equivalent to the input, the program
#              outputs the total halfwords read to 0x11000011.

.text

# x10 will contain what nibble to compare to
init:
    li x15, 0x11000010 # Read port (1) for out
    mv x16, x0 # Counter for hw's needed
    li x25, 32 # Counter for matches found
start:
    beq x25, x0, done # If found 32 matches
    lhu x20, 0(x15) # Load halfword from port

    li x22, 4 # Four nibbles per halfword
nibbles:
    beq x22, x0, done_nibbles

    andi x31, x20, 0xF # Isolate nibble
    xor x30, x31, x10 # Compare x31 and x10 nibbles
                      # If x31 == x10, x30 is 0
    seqz x30, x30 # If x30 is zero, set to 1, else 0

    sub x25, x25, x30 # Subtract value in x30 from x25
    
    srli x20, x20, 4 # Shift to next nibble
    addi x22, x22, -1 # Decrement nibble counter
    j nibbles
done_nibbles:
    addi x16, x16, 1 # Add to hw's needed
    j start

done: # Found enough hws to satisfy 32 nibble matches
      # x16 will contain this value
    sw x16, 1(x15) # Offset of 1 for 0x11000011
    ret
