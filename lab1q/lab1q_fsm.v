`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Cal Poly SLO
// Engineer: Saige Sloan
// 
// Create Date: 01/06/2026
// Design Name: Experiment 1Q
// Module Name: lab1q_fsm
// Project Name: Lab 1
// Target Devices: Basys3 (xc7a35tcpg236-1)
// Tool  Versions: Vivado 2025.2
// Description: FSM Module with 5 states, controlling the logic for Lab 1Q implementation. 
//
// Dependencies:
// 
// Revision:
// Revision 1.00 - File Created (07-07-2018) 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab1q_fsm(
   input reset, 
   input clk,
   // FSM Inputs
   input m_btn,
   input prime,
   input done,
   input rco_rom,
   input rco_ram,

   // FSM Mealy Outputs
   output reg mealy_clr,
   output reg mealy_clr_ram_ctr,
   output reg mealy_up_rom,
   output reg mealy_we,

   // FSM Moore Outputs
   output reg moore_clr_rom_ctr,
   output reg moore_disp_sel,
   output reg moore_up_ram,
   output reg moore_start_prime,
   output reg moore_enable_reg
);     
   // Each state is 3 bits.
   reg [2:0] NS, PS; 
   // 5 States are needed, so we will need a minimum of 3 bits, allowing for up to 8 states; leaving 3 unused states.
   parameter [2:0] st_idle=3'b000, 
                   st_read_rom=3'b001, 
                   st_wait_prime=3'b010, 
                   st_write_ram=3'b011, 
                   st_find_big=3'b100;
    

    //- model the state registers
   always @ (posedge clk)
      if (reset == 1) 
         PS <= st_idle; 
      else
         PS <= NS; 
    
    
    //- model the next-state and output decoders
   always @ (m_btn, prime, done, rco_rom, rco_ram, PS) begin
      // Default all outputs to 0 to avoid latches
      mealy_we = 0;
      mealy_clr = 0;
      mealy_clr_ram_ctr = 0;
      mealy_up_rom = 0;
      moore_clr_rom_ctr = 0;
      moore_disp_sel = 0;
      moore_up_ram = 0;
      moore_start_prime = 0;
      moore_enable_reg = 0;
      
      case(PS)
         // IDLE state, either when first flashed, or after finding the largest prime number in RAM
         st_idle:
         begin
            // Enable UP_RAM signal to loop through RAM; 
            // current RAM values are displayed on the left two digits of the SSEG. 
            moore_up_ram = 1;
            // While in this idle state, ROM counter should be cleared to ensure that loop begins at address zero.
            moore_clr_rom_ctr = 1;
            // Check to see if the middle button is pressed while in the IDLE state    
            if (m_btn == 1) begin
               // Clear all devices, including RAM address counter and Register stored value.
               mealy_clr = 1;
               mealy_clr_ram_ctr = 1;
               // Continue to the read rom state
               NS = st_read_rom; 
            // Otherwise, we will stay in the idle state, looping through RAM
            end else begin
               NS = st_idle; 
            end  
         end
         
         // READ_ROM state, starts prime checker for current rom value
         st_read_rom:
         begin
            moore_disp_sel = 1;
            moore_start_prime = 1;
            // Moves to WAIT_PRIME state
            NS = st_wait_prime;
         end   
         // WAIT_PRIME state will stay in the current state as long as the PNC does not
         // output a done signal   
         st_wait_prime:
         begin 
            moore_disp_sel = 1;
            // Wait for done signal
            if (done == 0) begin
               NS = st_wait_prime;
            // If done signal is received, check to see if PRIME signal is seen as well
            end else if (prime == 1) begin
               // If it is, enable RAM write, and move to WRITE_RAM state
               mealy_we = 1;
               NS = st_write_ram;
            // Otherwise, if the number is NOT prime, and we see the ROM counter has reached the end (32),
            // We can now continue to the biggest number finder.
            end else if (rco_rom == 1) begin
               mealy_clr_ram_ctr = 1;
               NS = st_find_big;
            // Finally, if none of the above is true, we can simply move back to the READ_ROM state to read the next
            // ROM value.
            end else begin
               mealy_up_rom = 1;
               NS = st_read_rom;
            end 
         end
         // WRITE_RAM state will increment the RAM Address Counter after being written to
         // then if the ROM counter has encountered RCO, we can now move to the FIND_BIG state
         st_write_ram:
         begin
            moore_disp_sel = 1;
            moore_up_ram = 1;
            // If ROM overflow is active, clear RAM counter and move to FIND_BIG state
            if (rco_rom == 1) begin
               mealy_clr_ram_ctr = 1;
               NS = st_find_big;
            // Otherwise, ROM counter has not ended, so continue back to READ_ROM state
            end else begin
               mealy_up_rom = 1; 
               NS = st_read_rom;
            end
         end
         // FIND_BIG state will loop through RAM contents until RCO, looking for the largest prime
         st_find_big:
            begin
               // Switch display selection to display biggest and RAM contents
               moore_disp_sel = 0;
               // Clear ROM counter for LEDS
               moore_clr_rom_ctr = 1;
               // Enable Register writing (controlled by this output AND GT condition from comparator)
               moore_enable_reg = 1;
               // Increment RAM address
               moore_up_ram = 1;
               // If RAM overflow is active, move back to IDLE state
               if (rco_ram == 1) begin
                  NS = st_idle;
               // Otherwise continue looping through RAM
               end else begin
                  NS = st_find_big;
               end
            end
         // Default to IDLE state if something goes horribly wrong
         default: NS = st_idle; 
      endcase
   end              
endmodule