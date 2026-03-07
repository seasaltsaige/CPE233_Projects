# Cal Poly SLO
# Saige Sloan
# Description: 


# Tested on LAB8 config, utilizing the middle button as the interrupt source
.text

.eqv ACCUM,     s0 # Accumulator
.eqv COUNT,     s1 # Counter designating how many numbers loaded 
.eqv INTR_FLAG, s2 # Interrupt flag to let background task know to read from IO
.eqv SWITCHES,  s3
.eqv LEDS,      s4

init:
    la    t0, ISR               # ISR mtvec
    csrrw zero, mtvec, t0       # Load machine trap vector
    
    mv    ACCUM, zero
    mv    COUNT, zero           # Clear accum and count
    mv    INTR_FLAG, zero

    li    LEDS, 0x1100C000      # LEDs output port
    li    SWITCHES, 0x11008000  # Switches input port

    mv    t0, zero
    sw    t0, 0(LEDS)           # Turn off LEDs

    li    t0, 0x8
    csrrs zero, mstatus, t0     # Enable interrupts
main:
    beqz INTR_FLAG, main        # If no interrupt has occurred, we don't need to do anything

    # Interrupt has occurred, load value
    lw  t0, 0(SWITCHES)         # Load value from the switches port
    add ACCUM, ACCUM, t0        # Add to accumulator
    addi COUNT, COUNT, 1        # Add to count

    li t0, 4                    # If we dont have 4 values counted, skip average
    bne COUNT, t0, enable 

        srli ACCUM, ACCUM, 2    # Divide by four
        sw   ACCUM, 0(LEDS)     # Write to LEDs
        mv   ACCUM, zero        # Clear accumulator
        mv   COUNT, zero        # Clear counter

    enable:
        mv    INTR_FLAG, zero   # Clear interrupt flag
        li    t1, 0x8           # MIE bit
        csrrs zero, mstatus, t1 # Re-enable interrupts after button is pressed
    j     main

ISR:
    # In an attempt to not use the stack here,
    # I have opted to designate t6 for ISR use only.

    li    t0, 0x80              # Bit 7 for mpie bit
    csrrc zero, mstatus, t0     # Disable interrupts
    seqz  INTR_FLAG, INTR_FLAG  # Tell main loop interrupt occurred
    mret                        # Leave with interrupts masked
