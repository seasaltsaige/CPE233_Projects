# Cal Poly SLO
# Saige Sloan
# Description: The following program will debounce a given button based on a timer delay.
#              once the button is asserted high and valid, you are able to execute actions
#              based on it. Once the execution is complete, the program will then wait for 
#              the button to be released, so that holding the button down does not execute
#              multiple valid button presses.


.equ BUTTONS, s0 # Button input port
.equ PRESSED, s1 # Initial press value
.equ VALID,   s2 # Delayed check value


init:
    li BUTTONS, 0x11008004
debounce_button: 
    lw   PRESSED, 0(BUTTONS)        # Load input from buttons
    andi PRESSED, PRESSED, 0x1      # LSB is button of interest for this
    beqz PRESSED, skip              # If LSB is 0, skip debounce

    call delay

    lw   PRESSED, 0(BUTTONS)          # Load from input again after delay
    andi PRESSED, PRESSED, 0x1        # Isolate

    beqz PRESSED, skip

    # This is where you do your stuff probably
    # The press is now valid here


    # Wait for release so you dont execute multiple times
    # for one press action
    wait_for_release:
        lw   PRESSED, 0(BUTTONS)        # Load
        andi PRESSED, PRESSED, 0x1      # Isolate
        bnez PRESSED, wait_for_release  # Loop while held


    skip: nop
    j debounce_button


delay: 
    li t0, 0x7A120  # ~10ms debounce time?                 

loop: 
    beq t0, zero, done_loop           # leave if done
    addi t0, t0, -1                 # decrement count
    j loop                          # rinse, repeat
done_loop: 
    ret                             # leave it all behind