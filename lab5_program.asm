li x10,0x11008000 # switch input port addr
li x11,0x1100C000 # LED output port addr
li x9,0x1 # load reg with constant
loop: lw x12,0(x10) # get switch data
add x12,x12,x9 # increment
sw x12,0(x11) # output data
j loop # repeat ad nauseum