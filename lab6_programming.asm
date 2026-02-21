    li sp, 0x0000FFFC # Init stack pointer
    
    li x10, 0x11008004 # Buttons input port
    li x11, 0x1100C000  # LED output port addr
wait:
    lw x6, 0(x10) # Load button input
    andi x6, x6, 0x1 # Isolate lsb (for U17)
    bne x6, x0, do_leds # If not 0, branch to led stuff

    # Waiting for user input blinks
    li x5, 1
    call do_blink
    j wait

do_leds:
init_leds:
    li x30, 9 # 10 leds to blink
    li x5, 2 # LED to blink
    li x29, 1 # Blink count reg

go_up: 
    beq x30, x0, init_down
    mv x9, x29 # Copy blink count for loop counter

do_blinks_up_loop:
    beq x9, x0, admin_up

    call do_blink # Do blink
    addi x9, x9, -1 # Subtract from counter

    j do_blinks_up_loop

admin_up:
    addi x29, x29, 1 # 1 more blink
    addi x30, x30, -1 # Subtract 1 from count
    slli x5, x5, 1 # Shift led to blink left
    j go_up

init_down:
    srli x5, x5, 2 # Shift back after last blink
    addi x29, x29, -2 # 1 fewer blinks to start
                        # Slightly weird, but admin_up will execute 1 extra time
    li x30, 8 # move back down

go_down: 
    beq x30, x0, wait # Once count is 0 again, we can go back to waiting
    mv x9, x29 # Copy blink count

do_blinks_down_loop:
    beq x9, x0, admin_down

    call do_blink # Do blink
    addi x9, x9, -1 # Subtract from counter

    j do_blinks_down_loop
admin_down:
    srli x5, x5, 1 # Shift led right
    addi x30, x30, -1 # Subtract from counter
    addi x29, x29 -1 # 1 fewer blink 
    j go_down





do_blink: # Blinks the value based on value in x5
          # IE: x5 holds the mask to xor
    # Save return address
    addi sp, sp, -4
    sw ra, 0(sp)


    mv x7, x0 # Clear t2 
    sw x7, 0(x11) # Send to leds
    call delay # Call delay subroutine
    xor x7, x7, x5 # Invert mask
    sw x7, 0(x11) # Send to leds
    call delay # Call delay subroutine

    # Pop return address
    lw ra, 0(sp)
    addi sp, sp, 4

    ret


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
    li x31, 0x1FFFFF # load delay count
loop: 
    beq x31, x0, done # leave if done
    addi x31, x31, -1 # decrement count
    j loop # rinse, repeat
done: 
    ret # leave it all behind
#-------------------------------------------------------------
