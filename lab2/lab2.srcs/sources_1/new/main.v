`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2026 02:21:53 PM
// Design Name: 
// Module Name: main
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


module main(
        input clk,
        input PC_RESET,
        input PC_LD,
        input [1:0] PC_SEL
    );
    
    wire [31:0] ADDR_MUX_OUT;
    wire [31:0] PC_ADDR;
    wire [31:0] OTTER_MEM_OUT;
    
    mux_4t1_nb  #(.n(32)) PROG_CTR_MUX  (
        .SEL   (PC_SEL), 
        .D0    (PC_ADDR + 32'd4), 
        .D1    (32'h00004444), 
        .D2    (32'h00008888), 
        .D3    (32'h0000CCCC),
        .D_OUT (ADDR_MUX_OUT) 
    );
    
    
    reg_nb #(.n(32)) PROGRAM_CTR_REG (
        .data_in  (ADDR_MUX_OUT), 
        .ld       (PC_LD), 
        .clk      (clk), 
        .clr      (PC_RESET), 
        .data_out (PC_ADDR)
    ); 
    
    Memory OTTER_MEMORY (
        .MEM_CLK (clk),
        .MEM_RDEN1 (1'b1),
        .MEM_RDEN2 (1'b0),
        .MEM_WE2 (1'b0),
        .MEM_ADDR1 (PC_ADDR[15:2]),
        .MEM_ADDR2 (32'd0),
        .MEM_DIN2 (32'd0),
        .MEM_SIZE (2'b10),
        .MEM_SIGN (1'b0),
        .IO_IN (1'b0),
        .IO_WR (),
        .MEM_DOUT1 (OTTER_MEM_OUT),
        .MEM_DOUT2 ()  
    );
    
endmodule
