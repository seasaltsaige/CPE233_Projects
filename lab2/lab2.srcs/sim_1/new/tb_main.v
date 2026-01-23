`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2026 06:39:22 PM
// Design Name: 
// Module Name: tb_main
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


module tb_main();
    
    reg clk;
    reg PC_RESET;
    reg PC_WE;
    
    reg [1:0] PC_SEL;
    
    main PROG_COUNTER(
        .clk(clk),
        .PC_RESET(PC_RESET),
        .PC_LD(PC_WE),
        .PC_SEL(PC_SEL)
    );

    initial begin
       clk = 1'b0;
       forever #5 clk = ~clk; 
    end

    always begin
        // Clear counter to 0
        #5 PC_WE <= 1'b0;
            PC_RESET <= 1'b1;
            PC_SEL <= 2'b00;
        // Turn iff RESET signal
        #10 PC_RESET <= 1'b0;
            PC_WE <= 1'b0;
        // Enable PC SEL 0
        // Write PC_ADDR + 4 
        #10 PC_RESET <= 0;
            PC_WE <= 1'b1;
            PC_SEL <= 2'b00;
        // Disable WE 
        #10 PC_WE <= 1'b0;
        // Enable PC SEL 0
        // Write PC_ADDR + 4 
        #10 PC_SEL <= 2'b00;
            PC_WE <= 1'b1;
        // Disable WE 
        #10 PC_WE <= 1'b0;    
        // Enable PC SEL 0
        // Write PC_ADDR + 4 
        #10 PC_SEL <= 2'b00;
            PC_WE <= 1'b1;
        // Disable WE
        #10 PC_SEL <= 2'b00;
            PC_WE <= 1'b0;
        // Enable PC SEL 1 (0x00004444)
        // Write value to counter
        #10 PC_SEL <= 2'b01;
            PC_WE <= 1'b1;
        // Disable WE
        #10 PC_WE <= 1'b0;
        // Enable PC SEL 2 (0x00008888)
        // Write value to coutner
        #10 PC_SEL <= 2'b10;
            PC_WE <= 1'b1;
        // Disable WE
        #10 PC_WE <= 1'b0;
        // Enable PC SEL 3 (0x0000CCCC)
        // Write value to counter
        #10 PC_SEL <= 2'b11;
            PC_WE <= 1'b1;
        // Disable WE
        #10 //PC_SEL <= 2'b00;
            PC_WE <= 1'b0;
        // Enable RESET signal (Clear counter to 0)
        #10 PC_WE <= 1'b0;
            PC_RESET <= 1'b1;
            
        #10 PC_RESET <= 1'b0;
    
        #25 $finish;
        
    end

endmodule
