`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2026 07:25:05 PM
// Design Name: 
// Module Name: OTTER_MCU
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


module OTTER_MCU(
    input RST,
    input intr,
    input clk,
    input [31:0] iobus_in,
    output [31:0] iobus_out, 
    output [31:0] iobus_addr, 
    output iobus_wr
);
    
    
    wire PC_WE;
    wire [1:0] PC_SEL;
    wire [31:0] PC_ADDR;
   
    wire [31:0] ADDR_MUX_OUT;
   
    wire [31:0] DOUT1;
    wire [31:0] DOUT2;
    
    // Reg file stuff
    wire [1:0] RF_SEL;
    wire RF_WE;
    wire [31:0] W_DATA;
    
    wire [31:0] rs1;
    wire [31:0] rs2;
    
    
    // BRANCH GENERATOR STUFF
    wire [31:0] j_type;
    wire [31:0] b_type;
    wire [31:0] i_type;
    
    wire [31:0] jal;
    wire [31:0] jalr;
    wire [31:0] branch;
    
    // IMMED GEN STUFF
    wire [31:0] u_type;
    wire [31:0] s_type;
      
    // ALU STUFF
    wire alu_srcA_SEL;
    wire [1:0] alu_srcB_SEL;
    wire [3:0] alu_fun;
    wire [31:0] alu_srcA;
    wire [31:0] alu_srcB;
    wire [31:0] alu_res;
   
   
    // CU_FSM STUFF
    wire reset;
    
    // CU_DCDR STUFF
    wire memWE2;
    wire memRDEN1;
    wire memRDEN2;
    
    // Main program counter MUX for the address input
    mux_4t1_nb  #(.n(32)) PROG_CTR_MUX  (
        .SEL(PC_SEL), 
        .D0(PC_ADDR + 32'd4), 
        .D1(jalr), 
        .D2(branch), 
        .D3(jal),
        .D_OUT(ADDR_MUX_OUT) 
    );
    
    PC PROGRAM_COUNTER(
        .clk(clk),
        .PC_RESET(reset),         // Reset signal used to set PC to 32'h0 address
        .PC_LD(PC_WE),          // Load signal used to load next "MUX'd" address value 
        .ADDR_MUX_OUT(ADDR_MUX_OUT),
        .PC_ADDR(PC_ADDR) 
    );
    
    branch_gen BRANCH_GEN(
        .pc_addr(PC_ADDR),
        .j_type(j_type),
        .b_type(b_type),
        .i_type(i_type),
        .rs(rs1),
        
        .jal(jal),
        .branch(branch),
        .jalr(jalr)
    );

    immed_gen(
        .ir(DOUT1),
        .j_type(j_type),
        .b_type(b_type),
        .u_type(u_type),
        .i_type(i_type),
        .s_type(s_type)
    );
    
    // The main OTTER_MEMORY module used to store instruction memory (text segment)
    // and all used memory during execution.
    Memory OTTER_MEMORY (
        .MEM_CLK(clk),
        .MEM_RDEN1(memRDEN1),
        .MEM_RDEN2(memRDEN2),
        .MEM_WE2(memWE2),
        .MEM_ADDR1(PC_ADDR[15:2]),
        .MEM_ADDR2(alu_res),
        .MEM_DIN2(rs2),
        .MEM_SIZE(DOUT1[13:12]),
        .MEM_SIGN(DOUT1[14]),
        .IO_IN(iobus_in),
        .IO_WR(iobus_wr),
        .MEM_DOUT1(DOUT1),
        .MEM_DOUT2(DOUT2)  
    );
    
    
    mux_4t1_nb  #(.n(32)) REG_FILE_MUX ( 
        .SEL(RF_SEL), 
        .D0(PC_ADDR + 32'd4), 
        .D1(32'd0), 
        .D2(DOUT2), 
        .D3(alu_res),
        .D_OUT(W_DATA)
    );
    
    RegFile my_regfile (
        .w_data(W_DATA),
        .clk(clk), 
        .en(RF_WE),
        .adr1(DOUT1[19:15]),
        .adr2(DOUT1[24:20]),
        .w_adr(DOUT1[11:7]),
        .rs1(rs1), 
        .rs2(rs2)  
    );
    
    
    mux_2t1_nb  #(.n(32)) ALU_SRC_A_MUX (
        .SEL(alu_srcA_SEL), 
        .D0(rs1), 
        .D1(u_type), 
        .D_OUT(alu_srcA) 
    ); 
    
    mux_4t1_nb  #(.n(32)) ALU_SRC_B_MUX ( 
        .SEL(alu_srcB_SEL), 
        .D0(rs2), 
        .D1(i_type), 
        .D2(s_type), 
        .D3(PC_ADDR),
        .D_OUT(alu_srcB)
    );
        
    riscv_alu(
        .alu_fun(alu_fun),
        .srcA(alu_srcA),
        .srcB(alu_srcB),
        .result(alu_res)
    );
    
    // Control modules
    CU_DCDR cu_dcdr(
        .br_eq(1'd0), 
        .br_lt(1'd0), 
        .br_ltu(1'd0),
        .opcode(DOUT1[6:0]),    
        .func7(DOUT1[30]),    
        .func3(DOUT1[14:12]),    
        .ALU_FUN(alu_fun),
        .PC_SEL(PC_SEL),
        .srcA_SEL(alu_srcA_SEL),
        .srcB_SEL(alu_srcB_SEL), 
        .RF_SEL(RF_SEL)   
    );
    
    
    CU_FSM cu_fsm(
        .intr(1'b0),
        .clk(clk),
        .RST(RST),
        .opcode(DOUT1[6:0]),   // ir[6:0]
        
        .PC_WE(PC_WE),
        .RF_WE(RF_WE),
        .memWE2(memWE2),
        .memRDEN1(memRDEN1),
        .memRDEN2(memRDEN2),
        .reset(reset)   
    );
    
    
    // Assign IO output busses
    assign iobus_out = rs2;
    assign iobus_addr = alu_res;
    
endmodule

