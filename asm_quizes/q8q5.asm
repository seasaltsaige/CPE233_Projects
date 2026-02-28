# Cal Poly SLO
# Saige Sloan
# Description: The following subroutine processes the number of words passed in s0, starting
#              at the address in s1, converting each nibble of the word into signed haflwords, 
#              and stores it at a temporary location, if the nibble is not zero. It will then
#              take those temporary signed halfwords, and put them back in the original memory
#              location as signed bytes.


init:   # s0: Number of words
        # s1: First word
        # Store as signed halfwords in convert loop
        # Store as signed bytes in move loop

    mv t0, s0 # Copy Number of words
    mv t1, s1 # Copy location of first word
    
    slli t3, t0, 2 # Multiply num of words by 4
    add t2, s1, t3 # Add number of words offset to get byte offset for temp storage
    
    # Each word loaded has 8 nibbles
    # Each nibble needs to be converted to a signed halfword
    # Stored temporarily, then moved back as signed bytes

    # s0 * 4 = offset for half word storage

    mv a2, zero             # Clear stored counter for move step
    li t5, 0xF              # Nibble
convert:
    beqz t0, init_move      # Once word count is zero, go to move them back
    lw t3, 0(t1)            # Load word from current load spot 
    li t4, 8                # 8 nibbles to convert

nibble_to_hw:
    beqz t4, convert_admin
    and a0, t3, t5          # Isolate nibble

    beqz a0, skip_store     # If nibble is 0, skip it

    slli a0, a0 28          # Shift left to get nibble[msb] at word[msb]
    srai a0, a0, 28         # Shift right arithmetic to sext 

    sh a0 0(t2)             # Store nibble/hw at current storage spot
    addi t2, t2, 2          # Increment storage spot (half words)
    addi a2, a2, 1          # Increment counter for number of stored halfwords

    skip_store: # Store is skipped if nibble is 0

    addi t4, t4, -1         # Decrement nibble counter
    srli t3, t3, 4          # Next nibble
    j nibble_to_hw
convert_admin:
    addi t1, t1, 4          # Add 4 bytes to get next word from mem
    addi t0, t0, -1         # Decrement number of words
    j convert
init_move:
    mv t1, s1               # Starting storage point (storing bytes)
    mv t2, s1               # Starting loading point (loading halfs)
    slli t3, s0, 2          # Multiply num of words by 4
    add t2, t2, t3          # Add number of words offset to get byte offset for temp storage (for loading)
    
move:
    beqz a2, done           # Once all halfwords have been moved back 

    lh t4, 0(t2)            # Load half word from current location
    sb t4, 0(t1)            # Store as byte at current store location

    addi t1, t1, 1          # Increment 1 byte
    addi t2, t2, 2          # Increment 1 half

    addi a2, a2, -1         # One fewer to process

    j move                  # loop it
done:
    ret                     # Finally done!