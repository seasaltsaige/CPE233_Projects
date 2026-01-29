.text                 # code goes in text segment
  nop                 # place holder
cat: nop              # place holder
dog: nop              # place holder
  jal x0, dog         # jal addr = 8 (J-type test)
  jalr x0, x20, -8    # jalr addr = 4 (I-type test) x20=rs1
  beq x10, x10, cat   # branch addr = 4 (B-type test)
  sw x10, 12(x20)     # S-type immed = 12 (S-type test) x20=rs1
  lui x0, 255         # U-type immed = 0x000FF000 (U-type test)
end: j end            # die here
