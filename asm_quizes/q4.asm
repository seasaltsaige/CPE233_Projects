# PART A
li x25, 0xFFF00000 	# Load mask
and x25, x15, x25  	# Mask data in x15 with mask

# PART B
ori x25, x15, 0xF	# Set lower nibble
lui x16, 0xFF000	# Load upper 2 nibble mask
xor x25, x25, x16	# Invert upper 2 nibbles

# PART C
li x16, 0x000FF000	# Load mask into x16
xor x25, x15, x16	# invert middle nibbles
li x16, 0xFFFFFFF8 	# Load second mask
and x25, x25, x16	# Mask out lower 3 bits

# PART D
not x25, x15  		# Setting all 0s to 1s is eq to loading all 1s
or x25, x25, x15	# Or with original number, setting all bits to 1
			        # Loading 32'b1 would do the same thing too though
