# Cal Poly SLO
# Saige Sloan
# Description: 
#
#

.data
my_lut: .byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x06, 0x07, 0x08, #LED output patterns
        .byte 0x0C, 0x0E, 0x0F, 0x10, 0x18, 0x1C, 0x1E, 0x1F


# Rename for some niceness
.equ LUT,       s0
.equ INPUT,     s1
.equ LEDS,      s2

.equ INTR_FLAG, s4
.equ COUNT,     s5
.equ ACCUM,     s6

.equ CONST,     s9 

.text
main:
init: 
    li    sp, 0x0000FFFC                # Init stack
    
    # Enable interrupts
    la    s0, ISR
    csrrw zero, mtvec, s0               # Load ISR addr
    li    s0, 0x8
    csrrs zero, mstatus, s0             # Enable interrupts mstatus[3] = 1

    la    LUT, my_lut
    li    INPUT, 0x11004444
    li    LEDS, 0x1100C000
    mv    INTR_FLAG, zero               # Clear flag
    mv    COUNT, zero
    mv    ACCUM, zero
    li    CONST, 16                     # 16 reads of io

main_loop:
    
    io_read: 
        beqz  INTR_FLAG, write_leds     # If flag is not set, skip to led check
        andi  INTR_FLAG, INTR_FLAG, 0x0 # Clear flag
        lbu   t0, 0(INPUT)              # Load byte from io
        andi  t0, t0, 0xF               # Isolate nibble
        add   ACCUM, ACCUM, t0          # Add to accumulator
        addi  COUNT, COUNT, 1           # Add to counter for write out

    write_leds: # If counter isnt 16 yet, skip average + write
        bne   COUNT, CONST, enable_interrupts 
        srli  ACCUM, ACCUM, 4           # Divide by 16
        add   t0, LUT, ACCUM            # Add divided value to LUT address to get address of output
        lbu   t0, 0(t0)                 # Load from LUT position
        sw    t0, 0(LEDS)               # Write to LED port

        mv    ACCUM, zero               # Clear accumulator
        mv    COUNT, zero               # Clear counter

    enable_interrupts:
        li    t0, 0x8 
        csrrs zero, mstatus, t0         # Set MIE bit
    j main_loop

ISR:
    addi  sp, sp, -4
    sw    t0, 0(sp) # Techincally still good practice even though
                    # I know interrupts are disabled while utilizing
                    # t0 in the main routine

    ori   INTR_FLAG, INTR_FLAG, 0x1     # Set flag
    li    t0, 0x80                      # Clear bit 7 (MPIE) to disable interrupts
    csrrc zero, mstatus, t0             # Ignore interrupts while dealing with current
                                        # interrupt flag

    lw    t0, 0(sp) # pop the stack
    addi  sp, sp, 4

    mret # out a dere
    