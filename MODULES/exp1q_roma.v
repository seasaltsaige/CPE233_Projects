`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 09/12/2023 12:09:56 PM
// Design Name: 
// Module Name: ROM_16x32_exp1Na
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple 16x32 ROM for Exp1N
//
// Instantiation Template
//
//   ROM_16x32_exp1Na my_ROMa (
//      .addr  (xxxx),  
//      .data  (xxxx),  
//      .rd_en (xxxx)    );
// 
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created (04-10-2024)
//
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ROM_16x32_exp1q_a(
   input [3:0] addr,   // address
   output [31:0] data,  // data
   input rd_en         // read enable
);
          
   reg [31:0] ROM [0:15];  // ROM definition     

   initial begin
        $readmemh("exp1q_roma.mem", ROM, 0, 15);
   end

   assign data = (rd_en) ? ROM[addr] : 32'h0000_0000;
  
endmodule
