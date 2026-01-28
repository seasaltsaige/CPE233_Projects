# Saige Sloan
# Cal Poly SLO
# 01/27/2026
.text

init:
  li x20, 0x1100DD00  # Port address
  li x21, 1000        # Counter to load 1000 uhw
  li x31, 0xFFFFFF00  # Mask to check if smaller than or equal to 255 
  mv x19, x0          # Initialize accum

get: 
  beq x21, x0, check  #
  lhu x22, 0(x20)     # Load from port

admin: 
  addi x21, x21, -1   # Decrement loop counter
  add x19, x19, x22   # Accumulate
  j get               # Continue getting and accumulating
check:
  and x30, x31, x19   # Mask accumulator with mask
  beq x30, x0, done   # If mask results in 0, we are smaller than 255

divide: 
  srli x19, x19, 1    # Divide by 2
  j check             # Continue checking
done: nop             # nop, x30 contains divided result (squished to 255)

label: j label