`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CAL POLY SLO
// Engineer: Saige Sloan
// 
// Create Date: 01/15/2026 02:21:53 PM
// Design Name: Program Counter
// Module Name: main
// Project Name: RISCV Otter Program Counter
// Target Devices: Basys3 (xc7a35tcpg236-1)
// Tool  Versions: Vivado 2025.2
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
        input PC_RESET, // Reset signal used to set PC to 32'h0 address
        input PC_LD, // Load signal used to load next "MUX'd" address value 
        input [1:0] PC_SEL // MUX Select signal used to select which address input to input to the PC reg
    );
    
    // Address output from the MUX to the PC Reg
    wire [31:0] ADDR_MUX_OUT;
    // Output address value currently stored in the PC Reg
    wire [31:0] PC_ADDR;
    // Otter Memory module output
    wire [31:0] OTTER_MEM_OUT;
    
    // Main program counter MUX for the address input
    // PC_SEL is a 2 bit signal, used to select between 4 possible inputs
    // D0 is always the current address (stored in the reg) plus 4
    // D1 through D3 are hard coded test values for this example, as they
    // have not been set up at this point.
    mux_4t1_nb  #(.n(32)) PROG_CTR_MUX  (
        .SEL   (PC_SEL), 
        .D0    (PC_ADDR + 32'd4), 
        .D1    (32'h00004444), 
        .D2    (32'h00008888), 
        .D3    (32'h0000CCCC),
        .D_OUT (ADDR_MUX_OUT) 
    );
    
    // Main storage element for the program counter
    // Accepts input from the PC Mux
    // PC_LD will load whatever value is at the ADDR_MUX_OUT
    // PC_RESET will reset the PC to 32'h0
    reg_nb #(.n(32)) PROGRAM_CTR_REG (
        .data_in  (ADDR_MUX_OUT), 
        .ld       (PC_LD), 
        .clk      (clk), 
        .clr      (PC_RESET), 
        .data_out (PC_ADDR)
    ); 
    
    // The main OTTER_MEMORY module used to store instruction memory (text segment)
    // and all used memory during execution.
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