`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 07/07/2018 08:05:03 AM
// Design Name: 
// Module Name: lab1q_fsm
// Project Name: 
// Target Devices: 
// Tool  Versions: 
// Description: Generic FSM model with both Mealy & Moore outputs. 
//    Note: data widths of state variables are not specified 
//
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created (07-07-2018) 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab1q_fsm(
reset, 
clk,
// inputs
m_btn,
prime,
done,
rco_rom,
rco_ram,

// mealy outputs
mealy_clr,
mealy_clr_ram_ctr,
// moore outputs
moore_we,
moore_disp_sel,
moore_up_rom,
moore_up_ram,
moore_start_prime,
moore_enable_reg); 

    input reset, 
          clk, 
          m_btn, 
          prime, 
          done, 
          rco_rom,
          rco_ram;
          
    output reg moore_we, 
               mealy_clr,
               mealy_clr_ram_ctr, 
               moore_disp_sel, 
               moore_up_rom, 
               moore_up_ram, 
               moore_start_prime,
               moore_enable_reg;
     
    //- next state & present state variables
    reg [2:0] NS, PS; 
    //- bit-level state representations
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
    always @ (m_btn, prime, done, rco_rom, rco_ram, PS)
    begin
       moore_we = 0;
       mealy_clr = 0;
       mealy_clr_ram_ctr = 0;
       moore_disp_sel = 0;
       moore_up_rom = 0;
       moore_up_ram = 0;
       moore_start_prime = 0;
       moore_enable_reg = 0;
       
       case(PS)
       
          st_idle:
          begin
             // loop through ram to display
             moore_up_ram = 1;
             
             // if middle button is pressed while idle    
             if (m_btn == 1) begin
                mealy_clr = 1;   
                // move to read rom state
                NS = st_read_rom; 
             end
             // otherwise, stay idle
             else begin
                mealy_clr = 0;
                NS = st_idle; 
             end  
          end
          
          st_read_rom:
             begin
                moore_disp_sel = 1;
                moore_up_rom = 1;
                moore_start_prime = 1;
                NS = st_wait_prime;
             end   
             
          st_wait_prime:
             begin 
                 moore_disp_sel = 1;
                 // if prime check has finished
                 if (done == 1) begin
                    // if finished and prime
                    if (prime == 1) begin
//                        mealy_we = 1;
                        NS = st_write_ram;
                    // if finished and no prime
                    end else begin
//                        mealy_we = 0;
                        // if rom count overflow has occurred
                        if (rco_rom == 1) begin
                            // finished incrementing rom, goto biggest
                            mealy_clr_ram_ctr = 1;
                            NS = st_find_big;
                            
                        // no rom count overflow (done and not prime)
                        end else begin
                            NS = st_read_rom;
                        end
                    end
                 end else begin
                    NS = st_wait_prime; 
                 end  
             end
            st_write_ram:
              begin
//                mealy_we = 0;
                moore_we = 1;
                moore_disp_sel = 1;
                moore_up_ram = 1;
                // if overflow is active after write
                if (rco_rom == 1) begin
                    mealy_clr_ram_ctr = 1;
                    NS = st_find_big;
                // if no rom cntr overflow
                end else begin
                    NS = st_read_rom;
                end
              end
                
            st_find_big:
              begin
                moore_disp_sel = 1;
                moore_enable_reg = 1;
                moore_up_ram = 1;
                if (rco_ram == 1) begin
                    NS = st_idle;
                end else begin
                    NS = st_find_big;
                end
              end
          default: NS = st_idle; 
            
          endcase
      end              
endmodule


