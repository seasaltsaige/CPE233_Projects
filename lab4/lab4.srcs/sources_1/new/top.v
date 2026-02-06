`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: Saige Sloan
// 
// Create Date: 01/30/2026 05:57:21 PM
// Design Name: Top Module
// Module Name: top
// Project Name: Generators
// Target Devices: Basys3 (xc7a35tcpg236-1)
// Tool Versions: Vivado 2025.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
        input clk,
        input rst,
        input PC_WE,
        input [1:0] PC_SEL,
        output [31:0] u_type_imm, 
        output [31:0] s_type_imm 
    );
    
    wire [31:0] ir;
    wire [31:0] pc_addr;
    
    wire [31:0] J_TYPE;
    wire [31:0] B_TYPE;
    wire [31:0] I_TYPE;
    
    wire [31:0] JAL;
    wire [31:0] BRANCH;
    wire [31:0] JALR;
    
    PC PROGRAM_COUNTER (
        .clk(clk),
        .PC_RESET(rst),
        .PC_LD(1'b1), 
        .PC_SEL(2'b0), 
        
        .PC_ADDR(pc_addr),
        .DOUT1(ir)
    );
    
    
    immed_gen IMMED_GEN (
        .ir(ir),
        
        .j_type(J_TYPE),
        .b_type(B_TYPE),
        .u_type(u_type_imm),
        .i_type(I_TYPE),
        .s_type(s_type_imm)
    );
    
    branch_gen BRANCH_GEN (
        .pc_addr(pc_addr - 32'd4), // Subtract 4 for this exp
        .j_type(J_TYPE),
        .b_type(B_TYPE),
        .i_type(I_TYPE),
        .rs(32'h0000000C),
        
        .jal(JAL),
        .branch(BRANCH),
        .jalr(JALR)
    );
    
    
endmodule
