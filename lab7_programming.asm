# Cal Poly SLO
# Saige Sloan
# Description: The following program will blink zero on the right-most sseg display
#              until the bottom button (U17) is pressed. Once pressed, the right-
#              most sseg display will blink 1 once, 2 twice, 3 thrice... 9 nine times,
#              then blink 8 eight times... 1 once. Then it will continue to blink zero
#              until the button is pressed again.

.data
# LUT for 7-segs
sseg: .byte 0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09

.text
init:
    li sp, 0x0000FFFC       # Init stack pointer
    li a0, 0x11008004       # Buttons input port
    li t0, 0x1100C004       # Segs address
    li t2, 0x1100C008       # Anodes address (4 anodes, we just want the 4th)
    la s1, sseg             # LUT address

    # Set all anodes to off, to initialize in a know state
    li s2, 0xF              # 1111 | All 4 off, active low
    sw s2, 0(t2)            # Send it

    mv s3, x0               # Init display offset / number
    call write_sseg         # Write initial 0 value to anode 4

wait:

    lw t3, 0(a0)            # Load from button addr
    andi t3, t3, 0x1        # Isolate lsb (for U17)
    bnez t3, do_display     # Do display sequence if button pressed
    call do_blink           # Blink otherwise
    j wait                  # Loop it
    
do_display:
init_up:
    li s2, 9                # Numbers to increment through
    li s4, 10               # Init to 10 to get offset by subtraction
                            # Doing it this way so we can use beqz

loop_up:
    beqz s2, init_down 
    sub s3, s4, s2          # Subtract to get offset and counter

    call write_sseg         # Write number to sseg port
do_blinks_up:
    beqz s3, admin_up       # Once inner blink counter is 0, do admin
    call do_blink           # Do blink

    addi s3, s3, -1         # Subtract from blink counter
    j do_blinks_up
admin_up:
    addi s2, s2, -1         # Decrement number counter
                            # (Increments displayed number)
    j loop_up

init_down: 
    addi s2, s2, 2          # Add two to number value to get subtraction back to display 8
    li a5, 10               # Target to add back to
loop_down:
    beq s2, a5 init         # Once back to 10, return to wait/init
    sub s3, s4, s2          # Subtract s2 from s4 (10 - x)
    call write_sseg         # Write number to sseg

do_blinks_down:
    beqz s3, admin_down     
    call do_blink           # Do the blink thing
    addi s3, s3, -1         # Subtract from counter for blinks
    j do_blinks_down
admin_down:
    addi s2, s2, 1          # Increment number counter
                            # (Decrements displayed number)
    j loop_down             # Loop it


# Write sseg will take an offset in s3, and add it to the 
# LUT address, getting an address of the digit to write
# It will then write the value at the address to the sseg
write_sseg:
    add t3, s1, s3          # Add offset to LUT address
    lbu t3, 0(t3)           # Load value from LUT
    sw t3, 0(t0)            # Write to cathodes/sseg

    ret                     # BACK BACK BACK BACK


# This blink function will blink the 4th sseg segment
# (4th from the left, when looking at it from the switches)
do_blink:
    addi sp, sp, -8         # Save return address
    sw ra, 0(sp)            #
    sw s0, 4(sp)

    li s0, 15               # Clear a0 
    sw s0, 0(t2)            # Send to anode (off cycle)
    call delay              # Call delay subroutine
    xori s0, s0, 8          # Invert mask (4th anode)
    sw s0, 0(t2)            # Send to anode (on cycle)
    call delay              # Call delay subroutine

    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8          # Pop return address

    ret                     # Where to next


delay:
    li t6, 0xFFFFF          # load delay count
loop: 
    beq t6, x0, done        # leave if done
    addi t6, t6, -1         # decrement count
    j loop                  # rinse, repeat
done: 
    ret                     # leave it all behind
