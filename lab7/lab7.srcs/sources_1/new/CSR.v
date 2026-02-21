`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2026 01:37:55 PM
// Design Name: 
// Module Name: CSR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CSR(
    input reset,
    input mret_exec,
    input int_taken,
    input [11:0] addr,
    input csr_WE,
    input [31:0] PC,
    input [31:0] WD,
    
    output reg mstatus,
    output reg [31:0] mepc,
    output reg [31:0] mtvec,
    output reg [31:0] csr_RD
    );
    
    
    
endmodule
