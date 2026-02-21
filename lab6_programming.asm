# Cal Poly
# Saige Sloan
# Lab 6 Programming
# Description: The following program completes the lab 6 programming assignment.
#              It waits for user input on button U17 by blinking LED0 until pressed.
#              Once pressed, the program will blink LED1 once, then blink LED2 twice,
#              then blink LED3 three times, all the way to LED9 which blinks 9 times.
#              After reaching LED9, it will move back down in reverse order, blinking
#              LED8 eight times, LED7 seven times, all the way to LED1 once. It will
#              finally return to blinking LED0 as it waits for user input again.

.text

main:
    li sp, 0x0000FFFC       # Init stack pointer
    
    li t0, 0x11008004       # Buttons input port
    li s1, 0x1100C000       # LED output port addr
wait:
    # NOTE: t1 is only ok here since no calls are done between
    #       when the value is read and used.
    lw t1, 0(t0)            # Load button input
    andi t1, t1, 0x1        # Isolate lsb (for U17)
    bne t1, zero, do_leds   # If not 0, branch to led stuff

    # Waiting for user input blinks
    li t2, 1
    call do_blink
    j wait

do_leds:
init_leds:
    li t5, 9                # 10 leds to blink
    li t2, 2                # LED to blink
    li t4, 1                # Blink count reg

go_up: 
    beq t5, zero, init_down
    mv t3, t4               # Copy blink count for loop counter

do_blinks_up_loop:
    beq t3, zero, admin_up

    call do_blink           # Do blink
    addi t3, t3, -1         # Subtract from counter

    j do_blinks_up_loop

admin_up:
    addi t4, t4, 1          # 1 more blink
    addi t5, t5, -1         # Subtract 1 from count
    slli t2, t2, 1          # Shift led to blink left
    j go_up

init_down:
    srli t2, t2, 2          # Shift back after last blink
    addi t4, t4, -2         # 1 fewer blinks to start
                            # Slightly weird, but admin_up will execute 1 extra time
                            # Meaning we need to subtract/shift 1 extra time on return
    li t5, 8                # move back down

go_down: 
    beq t5, zero, wait      # Once count is 0 again, we can go back to waiting
    mv t3, t4               # Copy blink count

do_blinks_down_loop:
    beq t3, zero, admin_down

    call do_blink           # Do blink
    addi t3, t3, -1         # Subtract from counter

    j do_blinks_down_loop
admin_down:
    srli t2, t2, 1          # Shift led right
    addi t5, t5, -1         # Subtract from counter
    addi t4, t4, -1         # 1 fewer blink 
    j go_down               # loop around




# Blinks the value based on value in t2
# IE: t2 holds the mask to xor    
do_blink:
    addi sp, sp, -4         # Save return address
    sw ra, 0(sp)            #

    mv a0, x0               # Clear a0 
    sw a0, 0(s1)            # Send to leds
    call delay              # Call delay subroutine
    xor a0, a0, t2          # Invert mask
    sw a0, 0(s1)            # Send to leds
    call delay              # Call delay subroutine

    lw ra, 0(sp)
    addi sp, sp, 4          # Pop return address

    ret                     # return to caller

#------------------------------------------------------------
# Subroutine: delay
#
# Delays for a count given by the value in x31. 0x7FFFF is
# relatively fast for human viewing and too long for
# display multiplexing; you’ll need to adjust as needed.
#
# tweaked registers: x31
#------------------------------------------------------------
delay:
    li x31, 0x1FFFFF        # load delay count
loop: 
    beq x31, x0, done       # leave if done
    addi x31, x31, -1       # decrement count
    j loop                  # rinse, repeat
done: 
    ret                     # leave it all behind
#-------------------------------------------------------------
