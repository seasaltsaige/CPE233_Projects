# Saige Sloan
# Cal Poly SLO
# Quiz 4 Question 6
# The following subroutine takes input from the port in x20
# four times

.text

init:
  li x20, 0x1100F000    # Note: Used for both loads and stores 
                        # (offset of 8 for store)

  li x30, 4             # Init outer counter, total of 4 bytes to look at
  lw x21, 0(x20)        # Load word from port

outer: 
  beq x30, x0, done     # If outer loop counter = 0, we are done

loop_init:
  li x29, 8             # init byte counter (8 times per loop)
  mv x31, x0            # Init accum for loop

loop: 
  beq x29, x0, admin    # If inner counter = 0, goto admin
  andi x25, x21, 1      # look at LSB
  add x31, x31, x25     # Add lsb to accum

admin_inner:
  addi x29, x29, -1     # Subtract from inner loop
  srli x21, x21, 1      # Shift port input right by one
  j loop

admin:                  # At this point, inner loop is done
  addi x30, x30, -1     # Subtract from outer loop
  andi x31, x31, 1      # Isolate LSB of accum
  sw x31, 8(x20)        # Store parity at 0x1100F008 
  j outer

done: ret               # Return to call location