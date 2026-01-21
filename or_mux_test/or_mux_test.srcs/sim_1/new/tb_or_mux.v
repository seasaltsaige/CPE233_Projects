`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2026 01:28:33 PM
// Design Name: 
// Module Name: tb_or_mux
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


module tb_or_mux();

    reg D0;
    reg D1;
    
    or_mux DUT(
        .D0(D0),
        .D1(D1),
        .DOUT()
    );
    
    initial begin
        
    end
    
    always begin
        #10 D0 <= 1'b0;
            D1 <= 1'b0;            
        #10 D0 <= 1'b1;
            D1 <= 1'b0;            
        #10 D0 <= 1'b0;
            D1 <= 1'b1;                  
        #10 D0 <= 1'b1;
            D1 <= 1'b1;
            
        #20 $finish;
    end
    
endmodule
