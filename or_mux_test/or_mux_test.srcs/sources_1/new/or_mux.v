`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/15/2026 01:26:23 PM
// Design Name: 
// Module Name: or_mux
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


module or_mux(
    input D0,
    input D1,
    output reg DOUT
    );
        
        always @(*) begin
            case(D0)
                1'b0: DOUT <= D1;
                1'b1: DOUT <= 1'b1;
            endcase
        end
    
endmodule
