`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 09/01/2020 03:14:59 PM
// Design Name: 
// Module Name: prime_num_check
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This model determines whether the input value is a prime 
//        number or not. A FSM controls this model. To start a test, assert
//        the "start" input, but don't leave it asserted for too long. 
//        When the test complete, the DONE output asserts
//        and the PRIME output is valid, where PRIME=1 indicates the input
//        is a prime number. For this model, 0 & 1 are not prime numbers.
//
//        This module has a clock divider inside; to disable the clock 
//        divider for testing, assert the test input; otherwise, keep the 
//        test input cleared.  
//
//     Instantiation Template: 
//
//  prime_num_check  my_prime (
//      .start (my_start),
//      .test  (my_test),
//      .clk   (my_clk),
//      .num   (my_num),
//      .DONE  (my_DONE),
//      .PRIME (my_PRIME)     ); 
// 
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created (09-02-2020) 
//
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module prime_num_check(
    input start,
    input test,
    input clk,
    input [9:0] num,
    output reg DONE,
    output reg PRIME    );
    
    reg  LD1; 
    reg  LD2; 
    reg  LD3; 
    reg  LT; 
    reg  EQ; 
    reg  GT; 
    reg  UP; 
    reg  CLR; 
    reg [9:0] val; 
    reg [9:0] i_cnt; 
    reg [10:0] rca_result; 
    reg [10:0] accum_result; 
    reg [9:0] cnt; 
    reg s_clk; 
            
    reg  QUIT; 
    reg  q_nprime;
    
    //- next state & present state variables
    reg [1:0] NS, PS; 
	parameter [1:0] st_nPR=2'b00, st_PR=2'b01, st_work=2'b11; 
	
    parameter n = 3; 
    reg [n:0] count = 0; 
    
    
    // the basic binary divider
    always@(posedge clk) 
    begin 
        count <= count + 1; 
    end 

    // MUX for no clock division on testing
    always @ (*)
    begin
       if (test == 1)
          s_clk = clk; 
       else
          s_clk = count[n]; 
    end
       

    // for incrementing increment value      
    always @(posedge s_clk)
    begin 
        if (LD2 == 1)   // load new value
           cnt <= 10'd2; 
        else if (UP == 1)   // count up (increment)
           cnt <= cnt + 1;  
    end           
          
    // counts number of iterations      
    always @(posedge CLR, posedge s_clk)
    begin 
        if (CLR == 1)       // asynch reset
           i_cnt <= 0;
        else
           i_cnt <= i_cnt + 1;  
    end  

    // the number being checked for primg
    always @(posedge s_clk)
    begin 
       if (LD1 == 1)   // synch load
          val <= num; 
    end

          
    // accumulator register      
    always @(posedge s_clk)
    begin 
       if (CLR == 1)       
          accum_result <= 0;
       else if (LD3 == 1)   // synch load
          accum_result <= rca_result; 
    end                            

    // RCA (adder) 
    always @ (*)
    begin
       rca_result = {1'b0,cnt} + accum_result;    
    end
            
    
    // comparator 
    always @ (*)
    begin    
       EQ = 0; LT = 0;  GT = 0;   
       if (accum_result == {1'b0,val})
          EQ = 1;  
       else if (accum_result > {1'b0,val})   
          GT = 1; 
       else  
          LT = 1;  ; 
    end          
          
  // kludgy logic block        
  always @ (*)
  begin
     q_nprime = 1'b0;   QUIT = 1'b0;
     
     //handles the 0 & 1 cases 
     if (cnt > val)     
        q_nprime = 1'b1; 
        
     // handles the 2 & 3 cases   
     else if ((cnt == val) && (i_cnt == 10'd0) )
        QUIT = 1'b1; 
        
     // handles all the other cases   
     else if ( (cnt > 10'd3) && (cnt > val/2) )
        QUIT = 1'b1;         
  end  
  

    // the FSM that controls this circuit
	always @ (posedge s_clk)
          PS <= NS; 
    
    always @ (start,LT,GT,EQ,QUIT,PS)
    begin
       LD1=0; LD2=0; LD3=0; UP=0; DONE=0; PRIME=0; CLR=0; 
       
       case(PS)
          st_nPR:
          begin
             PRIME=0; DONE=1; LD3=0;         
             if (start == 1)
             begin
                NS = st_work; 
                LD1=1; LD2=1; CLR=1;   
             end  
             else 
                NS = st_nPR;
          end 
          
          st_PR:
          begin
             PRIME=1; DONE=1; LD3=0;         
             if (start == 1)
             begin
                LD1=1; LD2=1; CLR=1;   
                NS = st_work; 
             end  
             else 
                NS = st_PR;
          end
             
          st_work:
          begin
             LD1=0; LD2=0; LD3=0;  
             
             if (q_nprime == 1'b1)
                NS = st_nPR; 
                                 
             else if (QUIT == 1)
                NS = st_PR; 
             
             else if (EQ == 1)
                NS = st_nPR; 
          
             else if (GT == 1)
             begin   
                UP=1; CLR=1; 
                NS = st_work; 
             end
             
             else if (LT == 1)
             begin
                LD3=1; UP=0;
                NS = st_work; 
             end 
             
             else
               NS = st_nPR;
             end
             
          default: 
             NS = st_nPR;
             
          endcase
      end
  
                    
   
endmodule
