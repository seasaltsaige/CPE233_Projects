.data
sseg: .byte 0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs

# ALIAS SOME REGISTERS FOR READIBILITY
.eqv SWITCHES   s0
.eqv BUTTONS    s1
.eqv LEDS       s2
.eqv SEGS       s3
.eqv ANODES     s4
.eqv SSEG_LUT   s5
.eqv AN_CUR     s6
.eqv LED_CUR    s7
.eqv CNT_DISP   a0

.text

init:
    li sp, 0x0000FFFC               # Init stack
    
    la s0, ISR
    csrrw x0, mtvec, s0             # Load ISR addr
    li s0, 0x8
    csrrs x0, mstatus, s0           # Enable interrupts mstatus[3] = 1

    li SWITCHES, 0x11008000         # Switches input port
    li BUTTONS, 0x11008004          # Buttons input port

    li LEDS, 0x1100C000             # LEDs output port
    li SEGS, 0x1100C004             # Segs output port
    li ANODES, 0x1100C008           # Anodes output port (4 anodes)
    la SSEG_LUT, sseg               # LUT address

    # Turn off all anodes
    li AN_CUR, 0xF
    sw AN_CUR, 0(ANODES) # Write to anodes
    mv AN_CUR, zero 

    mv CNT_DISP, zero               # reset count 

    # Initialize LED at position 15
    li LED_CUR, 1
    slli LED_CUR, LED_CUR, 15
    sw LED_CUR, 0(LEDS)

main_loop:
    call multiplex_anodes
    j main_loop


# general function for multiplexing all 4 sseg segments
# operates from right to left
# writes 1s place, 10s place, 100s place, 1000s place
# utilizes lead 0 blanking
multiplex_anodes:
    addi sp, sp, -4
    sw ra, 0(sp)

    li AN_CUR, 0xF
    sw AN_CUR, 0(ANODES)            # Turn em all off just in case

    li t0, 0xF

    li t5, 0x8                      # this will sense i promise (maybe)
    # Do ones always!
    and t2, CNT_DISP, t0            # Isolate nibble 
    add t0, t2, SSEG_LUT            # Get address of target cathode value
    
    lbu t0, 0(t0)                   # Load from LUT
    sw t0, 0(SEGS)                  # write to segs output
    xor AN_CUR, AN_CUR, t5          # turn on anode
    sw AN_CUR, 0(ANODES)            # write to anodes to enable display

    call delay                      # delay for display

    li AN_CUR, 0xF                  # turn off
    sw AN_CUR, 0(ANODES)            # disable anode
    srli t5, t5, 1                  # Get ready for next anode


    li t0, 0xF
    li t3, 3                        # 3 more anodes to enable and disable
    srli t4, CNT_DISP, 4            # shift count display right 4 to get next nibble

    # Utilizes lead 0 blanking, so if a 0 nibble is encountered, we can just delay and not display
    multiplex_loop:
        beqz t3, done
        and t2, t4, t0              # Isolate lower nibble
        seqz t6, t2                 # set to 1 if lower nibble is 0
        xor AN_CUR, AN_CUR, t5      # turn current anode on

        bnez t6, skip_on
        
        add t2, t2, SSEG_LUT        # Get offset address
        lbu t2, 0(t2)               # get byte
        sw t2, 0(SEGS)              # send to ssegs
        sw AN_CUR, 0(ANODES)        # Send to anodes

        skip_on:

        call delay                  # delay for display

        addi t3, t3, -1             # subtract from counter
        
        li AN_CUR, 0xF
        sw AN_CUR, 0(ANODES)        # turn it off
        srli t5, t5, 1              # shift left for next anode
        srli t4, t4, 4              # next nibble to display
        j multiplex_loop
    done:

    lw ra 0(sp)
    addi sp, sp, 4
ret

delay: 
    li a7, 0x61A8                   # ~ 3ms per seg; given 6 clock cycles per loop, 
                                    # 20ns s_clock, and target of 3ms, gives 0x61A8
loop: 
    beq a7, x0, done_loop           # leave if done
    addi a7, a7, -1                 # decrement count
    j loop                          # rinse, repeat
done_loop: 
    ret                             # leave it all behind


ISR:
    addi sp, sp, -8
    sw t0, 0(sp)                    # isr weird so saving temp reg is safer
    sw t2, 4(sp)

    srli LED_CUR, LED_CUR, 1
    bnez LED_CUR, skip_set          # If led didnt overflow to 0, skip reset
    
    li LED_CUR, 1
    slli LED_CUR, LED_CUR, 15
    
    skip_set:
    sw LED_CUR, 0(LEDS)             # Store current led to output

    lw t0, 0(SWITCHES)              # Load from switches port
    and t0, t0, LED_CUR             # Isolate the switch the port is at
    snez t0, t0                     # If t0 is not 0, set it to 1 otherwise 0
    beqz t0, done_if_else           # Skip if switch is off

    # Weird shit here
    # Add to count
    # 0000 0000 --> 1001 1001 == 99 (bcd) == 0x99 == 153 (base 10)
    # ifs current count is equal to 9
    # increment 10s place by 1 (add 10000 or 0x10)
    # and reset ones to 0
    # otherwise just add to the ones place
    # tbd: better way to handle this for up to 1000s place (modular)

    mv t0, CNT_DISP
    li t2, 0x99
    beq t0, t2, reset_display


    andi t0, CNT_DISP, 0xF          # Lower nibble of display
    li t2, 0x9 
    bne t0, t2, ones_else           # if count[3:0] == 9

    addi CNT_DISP, CNT_DISP, 0x10   # Add to 10s place
    andi CNT_DISP, CNT_DISP, 0xF0   # Clear 1s place
    j done_if_else

    ones_else: # else

    addi CNT_DISP, CNT_DISP, 0x1    # Add to 1s place
    j done_if_else

    reset_display:
    mv CNT_DISP, zero               # reset count when count reaches 0x99
    done_if_else:                   # Jump label for if branch

    lw t2, 4(sp)
    lw t0, 0(sp)
    addi sp, sp, 8                  # restore stack

    mret
