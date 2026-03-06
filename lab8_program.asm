# Cal Poly SLO
# Saige Sloan
# Description: The following program will on button press, through an ISR, move an LED
#              accross the 16 leds on the board, left to right, and increment the value
#              displayed on the SSEG display, utilizing multiplexing to display 2 digit numbers.
#              The value displayed on the SSEG will only increment if the corresponding
#              switch is enabled as well.

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
    mv    DISP_FLAG, zero               # reset display to bcd flag

    # Initialize LED at position 15
    li    LED_CUR, 1
    slli  LED_CUR, LED_CUR, 15
    sw    LED_CUR, 0(LEDS)

main_loop:
    beqz  DISP_FLAG, skip_bcd_conversion # Skip conversion
    
    mv    DISP_FLAG, zero               # clear flag
    call  dec_to_bcd                    # otherwise convert current binary count to bcd to be displayed
    
    skip_bcd_conversion:
    
    call  multiplex_anodes
    
    j     main_loop


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



# general function for multiplexing all 4 sseg segments
# operates from right to left
# writes 1s place, 10s place, 100s place, 1000s place
# utilizes lead 0 blanking
multiplex_anodes:
    addi sp, sp, -4
    sw   ra, 0(sp)

    li   AN_CUR, 0xF
    sw   AN_CUR, 0(ANODES)              # Turn em all off just in case

    li   t0, 0xF

    li   t5, 0x8                        # t5 tracks the current anode to enable
                                        # starting at the right anode, moving to the left anode
    # Do ones always!
    and  t2, CNT_DISP, t0               # Isolate nibble 
    add  t0, t2, SSEG_LUT               # Get address of target cathode value
    
    lbu  t0, 0(t0)                      # Load from LUT
    sw   t0, 0(SEGS)                    # write to segs output
    xor  AN_CUR, AN_CUR, t5             # turn on anode
    sw   AN_CUR, 0(ANODES)              # write to anodes to enable display

    call delay                          # delay for display

    li   AN_CUR, 0xF                    # turn off
    sw   AN_CUR, 0(ANODES)              # disable anode
    srli t5, t5, 1                      # Get ready for next anode


    li   t0, 0xF
    li   t3, 3                          # 3 more anodes to enable and disable
    srli t4, CNT_DISP, 4                # shift count display right 4 to get next nibble

    # Utilizes lead 0 blanking, so if a 0 nibble is encountered, we can just delay and not display
    multiplex_loop:
        beqz t3, done
        and  t2, t4, t0                 # Isolate lower nibble
        seqz t6, t2                     # set to 1 if lower nibble is 0
        xor  AN_CUR, AN_CUR, t5         # turn current anode on

        bnez t6, skip_on                # I decided to only skip the on portion, and not exit the loop early
                                        # So that the display does not change brightness between 0, 1, 2, 3, or all 4
                                        # digits being displayed. A small but nice thing, in my opinion
        
        add  t2, t2, SSEG_LUT           # Get offset address
        lbu  t2, 0(t2)                  # get byte
        sw   t2, 0(SEGS)                # send to ssegs
        sw   AN_CUR, 0(ANODES)          # Send to anodes

        skip_on:

        call delay                      # delay for display

        addi t3, t3, -1                 # subtract from counter
        
        li   AN_CUR, 0xF
        sw   AN_CUR, 0(ANODES)          # turn it off
        srli t5, t5, 1                  # shift left for next anode
        srli t4, t4, 4                  # next nibble to display
        j    multiplex_loop
    done:

    lw   ra 0(sp)
    addi sp, sp, 4
ret

delay: 
    li   a7, 0x61A8                     # ~ 3ms per seg; given 6 clock cycles per loop, 
                                        # 20ns s_clock, and target of 3ms, gives 0x61A8
loop: 
    beq  a7, x0, done_loop              # leave if done
    addi a7, a7, -1                     # decrement count
    j    loop                           # rinse, repeat
done_loop: 
    ret                                 # leave it all behind


ISR:
    addi sp, sp, -8
    sw   t0, 0(sp)                      # isr weird so saving temp reg is safer
    sw   t2, 4(sp)

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

    ori  DISP_FLAG, DISP_FLAG, 0x1      # Set flag so main routine knows to convert new value
    li   t2, 99
    # Just for this assignment, if count is > 99 
    beq  CNT_CUR, t2, reset_zero        # If count is 99 before add, reset to 0 
    # otherwise, add to current count
    add  CNT_CUR, CNT_CUR, t0           # Adds to current binary count
    j    skip_reset_zero
    reset_zero:
    mv   CNT_CUR, zero                  # Reset to 0
    skip_reset_zero:

    lw   t2, 4(sp)
    lw   t0, 0(sp)
    addi sp, sp, 8                      # restore stack

    mret