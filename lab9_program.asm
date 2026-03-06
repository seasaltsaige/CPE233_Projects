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

.data
    sseg: .byte 0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs

.text

init:
    li    sp, 0x0000FFFC                # Init stack
    
    la    s0, ISR
    csrrw zero, mtvec, s0                 # Load ISR addr
    li    s0, 0x8
    csrrs zero, mstatus, s0               # Enable interrupts mstatus[3] = 1


# For this lab, the ISR will represent a multiplex cycle
# Since my previous lab implemented scalability to utilizing all four
# segments, this will also do so, though be hard limited to only ever display
# on the first two
ISR:


    mret