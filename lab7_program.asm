.text
main: 
init:    li     x15,0x1100C000  # put output address into register
         la     x6,ISR          # load address of ISR into x6
         csrrw  x0,mtvec,x6     # store address as interrupt vector CSR[mtvec]

         mv     x8,x0           # clear x8; use as flag
         mv     x20,x0          # keep track of current output value
         sw     x20,0(x15)      # put LEDs in known state
         li     x7,0x80         # store the MPIE bit position
         
         li     x6,0x8          # set value in x10
         csrrw  x0,mstatus,x6   # enable interrupts

loop:    nop                    # do nothing (easier to see in simulator) 
         beq    x8,x0,loop      # wait for interrupt

         xori   x20,x20,1       # toggle current LED value
         sw     x20,0(x15)      # output LED value

         mv     x8,x0           # clear flag
         csrrs  x0,mstatus,x6   # enable interrupt
         j      loop            # return to loopville

#-----------------------------------------------------------------------
#- The ISR: sets bit x8 to act as flag to task code. 
#-----------------------------------------------------------------------
ISR:     li     x8,1            # set flag to non-zero
         csrrc  x0,mstatus,x7   # prepare to disable interrupts
                 
         mret                   # return from interrupt
#-----------------------------------------------------------------------
