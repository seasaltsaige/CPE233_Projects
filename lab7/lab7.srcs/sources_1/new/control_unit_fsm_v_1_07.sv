`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer: James Ratner
//
// Create Date: 01/07/2020 09:12:54 PM
// Design Name:
// Module Name: top_level
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Control Unit Template/Starter File for RISC-V OTTER
//
//     //- instantiation template
//     CU_FSM my_fsm(
//        .intr     (xxxx),
//        .clk      (xxxx),
//        .RST      (xxxx),
//        .opcode   (xxxx),   // ir[6:0]
//        .PC_WE    (xxxx),
//        .RF_WE    (xxxx),
//        .memWE2   (xxxx),
//        .memRDEN1 (xxxx),
//        .memRDEN2 (xxxx),
//        .reset    (xxxx)   );
//
// Dependencies:
//
// Revision  History:
// Revision 1.00 - File Created - 02-01-2020 (from other people's files)
//          1.01 - (02-08-2020) switched states to enum type
//          1.02 - (02-25-2020) made PS assignment blocking
//                              made rst output asynchronous
//          1.03 - (04-24-2020) added "init" state to FSM
//                              changed rst to reset
//          1.04 - (04-29-2020) removed typos to allow synthesis
//          1.05 - (10-14-2020) fixed instantiation comment (thanks AF)
//          1.06 - (12-10-2020) cleared most outputs, added commentes
//          1.07 - (12-27-2023) changed signal names
//
//////////////////////////////////////////////////////////////////////////////////
`include "riscv_instruction_types.svh"  

module CU_FSM(
   input intr,
   input clk,
   input RST,
   input [6:0] opcode,     // ir[6:0]
   output logic PC_WE,
   output logic RF_WE,
   output logic memWE2,
   output logic memRDEN1,
   output logic memRDEN2,
   output logic reset
   );

   typedef  enum logic [1:0] {
      st_INIT,
	   st_FET,
      st_EX,
      st_WB
   } state_type;
   state_type NS, PS;
    
	opcode_t OPCODE;    //- symbolic names for instruction opcodes
	assign OPCODE = opcode_t'(opcode); //- Cast input as enum

	//- state registers (PS)
	always @(posedge clk) begin
      if (RST == 1)
         PS <= st_INIT;
      else
         PS <= NS;
   end
    
   always_comb begin              
      //- schedule all outputs to avoid latch
      PC_WE    = DISABLE;
      RF_WE    = DISABLE;
      reset    = DISABLE;
      memWE2   = DISABLE;
      memRDEN1 = DISABLE;
      memRDEN2 = DISABLE;
                   
      case (PS)
         st_INIT: begin // INIT state  
            reset = ENABLE;
            NS = st_FET; 
         end
         st_FET: begin // FETCH state
            memRDEN1 = ENABLE;
            NS = st_EX; 
         end
           
         st_EX: begin // Decode + Execute
            PC_WE = ENABLE;
		      case (OPCODE)
               LOAD: begin
                  PC_WE = DISABLE;
                  memRDEN2 = ENABLE;
                  NS = st_WB;
               end
               AUIPC: begin
                  PC_WE = ENABLE;
                  RF_WE = ENABLE;
                  NS = st_FET;
               end
				   STORE: begin
                  PC_WE = ENABLE;
                  memWE2 = ENABLE;
                  NS = st_FET;
               end
                 
				   BRANCH: begin
                  PC_WE = ENABLE;
                  NS = st_FET;
               end
				
				   LUI: begin
                  PC_WE = ENABLE;
                  RF_WE = ENABLE;			      
				      NS = st_FET;
				   end
				  
				   OP_IMM: begin 
                  PC_WE = ENABLE;
                  RF_WE = ENABLE;
				      NS = st_FET;
				   end
				   OP_RG3: begin
                  PC_WE = ENABLE;
                  RF_WE = ENABLE;
                  NS = st_FET;
               end
	            JAL: begin
				      PC_WE = ENABLE;
                  RF_WE = ENABLE;
				      NS = st_FET;
				   end
				   
				   JALR: begin
                  PC_WE = ENABLE;
                  RF_WE = ENABLE;
                  NS = st_FET;
               end
                    
                    
               default: begin 
				      NS = st_FET;
				   end
				endcase
         end
            
         st_WB: begin
            // Write to reg file
            PC_WE = ENABLE;
            RF_WE = ENABLE; 
            NS = st_FET;
         end

         default: NS = st_FET;
        
      endcase //- case statement for FSM states
   end
           
endmodule
