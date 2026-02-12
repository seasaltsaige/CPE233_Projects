# Cal Poly SLO
# Saige Sloan
# Description: The following subroutine utilizes a look up table which maps BCD values
#              to output, binary numbers. For example, if the tens BCD is a 7, it will map
#              to binary 70. Sam applies to the hundreds and tousands place for the BCDs.
#              the ones place will be identical to the corresponding first BCD value.

.data

# Init tens, huns, thous tables for BCD mappings
tens: .byte 0, 10, 20, 30, 40, 50, 60, 70, 80, 90
huns: .half 0, 100, 200, 300, 400, 500, 600, 700, 800, 900
thou: .half 0, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000


.text

init:               # x20 contains input BCD to start

  mv t0, x0         # Holds output value temporarily
                    # Will be moved to x20 before ret
do_ones:
  andi t3, x20, 0xF # Isolate lower nibble (ones) (ones value is identical to potential mapping)
  add t0, t0, t3    # Add value loaded to output

  srli x20, x20, 4  # Shift input value right 4 bits to now look at 10s place

init_tens:
  la t1, tens
do_tens:
  andi t3, x20, 0xF # tens nibble
  add t1, t1, t3    # Offset address
  lb t1, 0(t1)      # Load value from tens table
  add t0, t0, t1    # Add value to output

  srli x20, x20, 4  # Shift to hundreds place

init_huns:
  la t1, huns       # Note, this is half words now
do_huns:
  andi t3, x20, 0xF # huns nibble
  add t3, t3, t3    # Double offset (half words, not bytes)
  add t1, t1, t3    # Add offset to address
  lh t1 0(t1)       # Load value from huns table
  add t0, t0, t1    # Add value to output

  srli x20, x20, 4  # Shift to thousands place

init_thous: 
  la t1, thous
do_thou:
  andi t3, x20, 0xF # thou nibble
  add t3, t3, t3    # Double offset (half words, not bytes)
  add t1, t1, t3    # Add offset to address
  lh t1, 0(t1)      # Load value from thous table
  add t0, t0, t1    # Add value to output

finish:
  mv x20, t0        # Move temp to output register
  ret