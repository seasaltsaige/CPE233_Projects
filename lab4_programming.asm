# Saige Sloan
# Cal Poly SLO
# The following assembly program converts a given decimal value in x10 into a BCD stored
# in x20. The conversion is done by first subtracting 1000 until x10 is < 1000, then doing
# the same for 100, 10, and finally adding the remaining value from x10 into x20.
# After each iteration, the value in x20 is shifted left 4 times to make room for the
# next place.


init:
    # x10 holds the binary value
    # x20 will hold the BCD value
    mv x20, x0

init_thous:
    li x15, 1000
convert_thous:                  # We will be subtracting 1000 from x10 
                                # until x10 is less than 1000

    blt x10, x15, admin_thous   # Move to admin

    sub x10, x10, x15           # Subtract x15 from x10
    addi x20, x20, 1            # Add to BCD reg

    j convert_thous

admin_thous:
    slli x20, x20, 4            # Shift thousands place over to 
                                # make room for hundreds

init_huns:
    li x15, 100

convert_huns:
    blt x10, x15, admin_huns    # Move to admin

    sub x10, x10, x15 
    addi x20, x20, 1

    j convert_huns

admin_huns:
    slli x20, x20, 4            # Shift left 4 more times to make room for 10s place

init_tens:
    li x15, 10 

convert_tens:
    blt x10, x15, admin_tens

    sub x10, x10, x15
    addi x20, x20, 1

    j convert_tens

admin_tens:
    slli x20, x20, 4            # Shift left 4 more times to make room for 1s place

convert_ones:                   # Ones place is simple, as value left 
                                # in x10 should be only ones place
    add x20, x20, x10

done: nop                       # x20 should now contain 4 nibbles of BCD data