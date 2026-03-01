dec_to_bcd:
    mv t1, a0         # t1 = input number
    mv t0, zero       # accumulator for BCD

    # thousands digit
    li t2, 1000
    mv t3, zero          # bcd[3]
thousands_loop:
    blt t1, t2, hundreds_start
    sub t1, t1, t2
    addi t3, t3, 1
    j thousands_loop
hundreds_start:
    slli t3, t3, 12   # move to top nibble
    or t0, t0, t3   # or it into spot in output temp

    li t2, 100 # load hundreds
    mv t3, zero          # bcd[2]
hundreds_loop:
    blt t1, t2, tens_start
    sub t1, t1, t2
    addi t3, t3, 1
    j hundreds_loop
tens_start:
    slli t3, t3, 8
    or t0, t0, t3

    # tens digit
    li t2, 10
    mv t3, zero          # bcd[1]
tens_loop:
    blt t1, t2, units_start
    sub t1, t1, t2
    addi t3, t3, 1
    j tens_loop
units_start:
    slli t3, t3, 4    # move tens digit to correct nibble
    or t0, t0, t3

    # 1s place
    or t0, t0, t1

    ret