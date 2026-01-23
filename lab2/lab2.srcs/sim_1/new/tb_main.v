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
    reg INIT;
    reg PC_RESET;
    reg PC_WE;
    
    reg [1:0] PC_SEL;
    
    main PROG_COUNTER(
        .clk(clk),
        .PC_CLR(PC_RESET),
        .INIT(INIT),
        .PC_LD(PC_WE),
        .PC_SEL(PC_SEL)
    );

    initial begin
       clk = 1'b0;
       forever #5 clk = ~clk; 
    end

    always begin
        
        #10 INIT <= 1;
            PC_RESET <= 0;
            PC_WE <= 1'b1;
            PC_SEL <= 2'b00;
        
        #10 INIT <= 0;
            PC_SEL <= 2'b00;
            PC_WE <= 1'b1;
       
        #10 PC_SEL <= 2'b00;
            PC_WE <= 1'b0;
            
        #10 PC_SEL <= 2'b00;
            PC_WE <= 1'b1;
            
        #10 PC_SEL <= 2'b00;
            PC_WE <= 1'b0;
            
        #10 PC_SEL <= 2'b01;
            PC_WE <= 1'b1;
            
        #10 PC_WE <= 1'b0;
        
        #10 PC_SEL <= 2'b10;
            PC_WE <= 1'b1;
            
        #10 PC_WE <= 1'b0;
        
        #10 PC_SEL <= 2'b11;
            PC_WE <= 1'b1;
            
        #10 PC_WE <= 1'b0;
            PC_RESET <= 1'b1;
    
        #10 $finish;
        
    end

endmodule
