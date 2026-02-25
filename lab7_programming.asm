.data
sseg: .byte 0x03,0x9F,0x25,0x0D,0x99,0x49,0x41,0x1F,0x01,0x09 # LUT for 7-segs




.text

init:
    li sp, 0x0000FFFC       # Init stack pointer
    li a0, 0x11008004       # Buttons input port
    li t0, 0x1100C004 # Segs address
    li t2, 0x1100C008 # Anodes address (4 anodes, we just want the 3rd)
    la s1, sseg # LUT address

    # NOTE: Anodes are driven high, cathodes driven low to turn a number on
    #       Slightly opposite of expected

    # Set all anodes to off, to initialize in a know state
    li s2, 15
    sw s2, 0(t2)

    mv s2, x0 # Init display offset / number
    call write_sseg # Write initial 0 value to anode 3

    

wait:

    lw t3, 0(a0) # Load from button addr
    andi t3, t3, 0x1        # Isolate lsb (for U17)
    bnez t3, do_display

    call do_blink
    j wait
    
do_display:
init_up:
    li s2, 9 # Numbers to increment through
    
loop_up:
    beqz s2, init_down 

    addi s3, s3, 10
    sub s3, s3, s2 # Subtract to get offset and counter

    mv t4, s3 # Copy display number to counter (for blink counter) 
do_blinks_up:
    beqz t4, admin_up # Once inner blink counter is 0, do admin

    call do_blink # Do blink

    addi t4, t4, -1 # Subtract from blink counter

    j do_blinks_up
admin_up:
    addi s2, s2, -1 # Decrement number counter

    j loop_up

init_down: j init_down


write_sseg:
    add t3, s1, s2 # Add offset to lut address
    lbu t3, 0(t3) # Load value
    sw t3, 0(t0) # Write to cathodes

    ret


# a0 contains the value to invert 
# Blinks the value based on value in a0
# IE: a0 holds the mask to xor    
do_blink:
    addi sp, sp, -8         # Save return address
    sw ra, 0(sp)            #
    sw s0, 4(sp)

    li s0, 15               # Clear a0 
    sw s0, 0(t2)            # Send to anode (off cycle)
    call delay              # Call delay subroutine
    xori s0, s0, 8          # Invert mask (3rd anode)
    sw s0, 0(t2)            # Send to anode (on cycle)
    call delay              # Call delay subroutine

    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8          # Pop return address

    ret                     # return to caller


delay:
    li t6, 0x13FFFF        # load delay count
loop: 
    beq t6, x0, done       # leave if done
    addi t6, t6, -1       # decrement count
    j loop                  # rinse, repeat
done: 
    ret                     # leave it all behind