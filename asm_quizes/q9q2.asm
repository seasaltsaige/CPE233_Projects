# Cal Poly SLO
# Saige Sloan
# Description: This is such a weird program lol.
#              The following program reads from the switches port
#              every other time there is an interrupt. After reading
#              the half word from the port, it swaps the ordering of
#              the bytes, then outputs it to the LEDs. It will then
#              poll the buttons, and wait until ONLY the right most
#              button is pressed. (NO IO IN FOREGROUND LOOP)

.text

.equ SWITCHES,  s0
.equ BUTTONS,   s1
.equ LEDS,      s2

.equ INTR_FLAG, s3


init:
    li    sp, 0x0000FFFC # Init stack
    la    s0, ISR
    csrrw zero, mtvec, s0 # Load ISR address
    li    s0, 0x8
    csrrs zero, mstatus, s0 # Enable interrupts mstatus[3] = 1
 
    li SWITCHES, 0x1100F000
    li BUTTONS, 0x1100F004
    li LEDS, 0x1100F008

    mv INTR_FLAG, zero # Clear flag

main:
    j main

ISR:
    addi sp, sp, -8
    sw   t0, 0(sp)
    sw   t1, 4(sp)
    xori INTR_FLAG, INTR_FLAG, 0x1 # Swap flag
    bnez INTR_FLAG, skip_intr # Skip IO if not 'other'

        lhu t0, 0(SWITCHES)
        srli t1, t0, 8              # Shift input right 8 bits
                                    # to isolate next byte
        slli t0, t0, 8              # Shift input left 8 bits to
                                    # make room for swap
        or   t0, t0, t1             # Or back together

        sw   t0, 0(LEDS)

        # Poll for buttons
        poll_loop:
            # Looking at right most button
            # T17 on board, or bit t0[1]
            lw t0, 0(BUTTONS)
            
            # If only our button of interest was pressed
            # Then t0 should just be 2
            li   t1, 0x2
            bne  t0, t1, poll_loop
    skip_intr:

    lw   t1, 4(sp)
    lw   t0, 0(sp)
    addi sp, sp, 8

    mret