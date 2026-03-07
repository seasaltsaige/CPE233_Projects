# Cal Poly SLO
# Saige Sloan
# Description: 

# ALIAS SOME REGISTERS FOR READIBILITY
.eqv SWITCHES   s0                  # Switches Port
.eqv BUTTONS    s1                  # Buttons Port
.eqv LEDS       s2                  # LEDs Port
.eqv SEGS       s3                  # SSEG Port
.eqv ANODES     s4                  # Anodes Port
.eqv SSEG_LUT   s5                  # SSEG Look up table base address
.eqv AN_CUR     s6                  # Current anode to turn on
.eqv LED_CUR    s7                  # Current LED to send to IO
.eqv CNT_CUR    s8                  # Current Binary Counter
.eqv CNT_DISP   s9                  # Current BCD to be displayed value

.eqv DISP_FLAG  s10                 # Flag set when count needs to be converted to BCD


.data
sseg: .byte 0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs

.text

init:
    li    sp, 0x0000FFFC                # Init stack
    
    la    s0, ISR
    csrrw x0, mtvec, s0                 # Load ISR addr
    li    s0, 0x8
    csrrs x0, mstatus, s0               # Enable interrupts mstatus[3] = 1

    li    SWITCHES, 0x11008000          # Switches input port
    li    BUTTONS, 0x11008004           # Buttons input port

    li    LEDS, 0x1100C000              # LEDs output port
    li    SEGS, 0x1100C004              # Segs output port
    li    ANODES, 0x1100C008            # Anodes output port (4 anodes)
    la    SSEG_LUT, sseg                # LUT address

    # Turn off all anodes
    li    AN_CUR, 0xF
    sw    AN_CUR, 0(ANODES)             # Write to anodes
    mv    AN_CUR, zero 

    mv    CNT_DISP, zero                # reset count display 
    mv    CNT_CUR, zero                 # reset current binary count

    # Initialize LED at position 15
    li    LED_CUR, 1
    slli  LED_CUR, LED_CUR, 15
    sw    LED_CUR, 0(LEDS)



main:
    skip_bcd_conversion:

    poll_button:

        lw t0, 0(BUTTONS)   # Load input from buttons
        andi t0, t0, 0x10   # Isolate middle button for polling 

        beqz t0, main       # If button isn't pressed, exit polling

        call delay          # debounce time

        lw t0, 0(BUTTONS)   # Load input from buttons
        andi t0, t0, 0x10   # Isolate middle button for polling 

        beqz t0, main       # If button isn't still high, exit back to main loop

        # Button is now a valid press!
        # Do the led movement + count incrementing
        srli LED_CUR, LED_CUR, 1
        bnez LED_CUR, skip_set              # If led didnt overflow to 0, skip reset
        
        li   LED_CUR, 1
        slli LED_CUR, LED_CUR, 15
        
        skip_set:
        sw   LED_CUR, 0(LEDS)               # Store current led to output

        lw   t0, 0(SWITCHES)                # Load from switches port
        and  t0, t0, LED_CUR                # Isolate the switch the port is at
        snez t0, t0                         # If t0 is not 0, set it to 1 otherwise 0
    
        beqz t0, skip_reset_zero            # Skip addition if number to add is zero

        li   t2, 99
        # Just for this assignment, if count is > 99 
        beq  CNT_CUR, t2, reset_zero        # If count is 99 before add, reset to 0 
        # otherwise, add to current count
        add  CNT_CUR, CNT_CUR, t0           # Adds to current binary count
        j    skip_reset_zero
        reset_zero:
        mv   CNT_CUR, zero                  # Reset to 0
        skip_reset_zero:


        # Block while button is held down
        falling_edge_loop:
            lw   t0, 0(BUTTONS)
            andi t0, t0, 0x10
            bnez t0, falling_edge_loop

        # Once the above loop exits it is then
        # time to debounce on the falling edge
        # If the button is read as on again, we 
        # can just branch back to the hold loop
        call delay # Delay to check button later

        # This MIGHT be bad... todo: figure that out
        # it could cause problems on fast presses... maybe
        lw t0, 0(BUTTONS)
        andi t0, t0, 0x10
        bnez t0, falling_edge_loop

    j main


# The following subroutine will convert the current binary count held in
# CNT_CUR into a BCD value (up to 4 digits) and move it into CNT_DISP
# for the multiplexing to use
dec_to_bcd:
    mv   t1, CNT_CUR                    # t1/CNT_CUR = input number
    mv   t0, zero                       # accumulator for BCD

    # thousands digit
    li   t2, 1000                       # Load thousands
    mv   t3, zero                       # bcd[3]
thousands_loop:
    blt  t1, t2, hundreds_start
    sub  t1, t1, t2
    addi t3, t3, 1
    j    thousands_loop
hundreds_start:
    slli t3, t3, 12                     # move to top nibble
    or   t0, t0, t3                     # or it into spot in output temp

    li   t2, 100                        # Load hundreds
    mv   t3, zero                       # bcd[2]
hundreds_loop:
    blt  t1, t2, tens_start
    sub  t1, t1, t2
    addi t3, t3, 1
    j    hundreds_loop
tens_start:
    slli t3, t3, 8                      # Shift into place
    or   t0, t0, t3                     # or it into output

    # tens digit
    li   t2, 10                         # Load tens
    mv   t3, zero                       # bcd[1]
tens_loop:
    blt  t1, t2, units_start
    sub  t1, t1, t2
    addi t3, t3, 1
    j    tens_loop
units_start:
    slli t3, t3, 4                      # move tens digit into place
    or   t0, t0, t3                     # or it into output

    or   t0, t0, t1                     # 1s place needs nothing special
    mv   CNT_DISP, t0                   # move it into output
    ret



delay: 
    li t0, 0x208D  # ~1ms debounce time?              

loop: 
    beq t0, zero, done_loop             # leave if done
    addi t0, t0, -1                     # decrement count
    j loop                              # rinse, repeat
done_loop: 
    ret                                 # leave it all behind


# For this lab, the ISR will represent a multiplex cycle
# Since my previous lab implemented scalability to utilizing all four
# segments, this will also do so, though be hard limited to only ever display
# on the first two
ISR:


    mret