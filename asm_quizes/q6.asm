.text
start:
    # Handle stack pushes
    addi sp, sp, -8
    sw	ra, 0(sp)
    sw  x20, 4(sp)
    # test input from question, results in 3 in x20
    # li x10, 0x690026D
    
    mv x20, x0 		# Init Accumulator

loop:
    beq x10, x0, done 	# while x10 != 0
                      	# Alternatively could blt 3'b101
                      	
    andi x25, x10, 7 	# x25 <- x10 & 3b111
    			        # Mask out 3 LSB bits
    xori x25, x25, 5 	# x25 <- x25 ^ 3b101
    seqz x25, x25	    # if x25 == 0, x25 <- 1 else x25 <- 0
    srli x10, x10, 1 	# Shift right to check next 3 bits

    add x20, x20, x25  	# Add result in x25 to our accumulator
    j   loop          	# Continue looping
done:
    # Handle stack pops
    lw x20, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8
    ret
