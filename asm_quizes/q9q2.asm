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
.equ INIT_FLAG, s4  # Used to designate no interrupts have happened
                    # As the XOR method I use has a limitation that 
                    # 'every other' is undefined at the start. 


init:
    li    sp, 0x0000FFFC    # Init stack
    la    s0, ISR
    csrrw zero, mtvec, s0   # Load ISR address
    li    s0, 0x8
    csrrs zero, mstatus, s0 # Enable interrupts mstatus[3] = 1
 
    li    SWITCHES, 0x1100F000
    li    BUTTONS, 0x1100F004
    li    LEDS, 0x1100F008

    mv    INTR_FLAG, zero   # Clear flag
                            # Interrupt flag starts at 0, so when flag is 1, dont do IO
                            # and when flag is 0, do IO
    li    INIT_FLAG, 0x1    # Set flag that no interrupts have occurred

# I forgot which was background and which as foreground... woops
# Hopefully this is alright to re-submit...
main:
    # There is probably a cleaner way to handle this, but I can not think of one
    # at the moment.
    bnez INIT_FLAG, main        # If no interrupts have happened, skip as well
    bnez INTR_FLAG, main        # If interrupt flag is set, we can skip all the IO

    lhu  t0, 0(SWITCHES)
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
        lw    t0, 0(BUTTONS)
            
        # If only our button of interest was pressed
        # Then t0 should just be 2
        li    t1, 0x2
        bne   t0, t1, poll_loop

        li    t1, 0x8 # MIE bit
        csrrs zero, mstatus, t1 # Re-enable interrupts after button is pressed

    j main

ISR:
    addi sp, sp, -4
    sw   t0, 0(sp)
    mv   INIT_FLAG, zero            # Now that an interrupt has happened, clear the init flag
    xori INTR_FLAG, INTR_FLAG, 0x1  # Swap flag
    bnez INTR_FLAG, skip_intr       # Skip IO if not every 'other'
    
        li    t0, 0x80              # Bit 7 for mpie bit
        csrrc zero, mstatus, t0     # Disable interrupts

    skip_intr:

    lw   t0, 0(sp)
    addi sp, sp, 4

    mret