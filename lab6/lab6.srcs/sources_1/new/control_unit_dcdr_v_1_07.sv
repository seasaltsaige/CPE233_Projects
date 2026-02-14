`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 01/29/2019 04:56:13 PM
// Design Name: 
// Module Name: CU_DCDR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:
// 
// Instantiation Template:
//
// CU_DCDR my_cu_dcdr(
//   .br_eq     (xxxx), 
//   .br_lt     (xxxx), 
//   .br_ltu    (xxxx),
//   .opcode    (xxxx),    
//   .func7     (xxxx),    
//   .func3     (xxxx),    
//   .ALU_FUN   (xxxx),
//   .PC_SEL    (xxxx),
//   .srcA_SEL  (xxxx),
//   .srcB_SEL  (xxxx), 
//   .RF_SEL    (xxxx)   );
//
// 
// Revision:
// Revision 1.00 - Created (02-01-2020) - from Paul, Joseph, & Celina
//          1.01 - (02-08-2020) - removed  else's; fixed assignments
//          1.02 - (02-25-2020) - made all assignments blocking
//          1.03 - (05-12-2020) - reduced func7 to one bit
//          1.04 - (05-31-2020) - removed misleading code
//          1.05 - (12-10-2020) - added comments
//          1.06 - (02-11-2021) - fixed formatting issues
//          1.07 - (12-26-2023) - changed signal names
//
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////

module CU_DCDR(
   input br_eq, 
   input br_lt, 
   input br_ltu,
   input [6:0] opcode,   //-  ir[6:0]
   input func7,          //-  ir[30]
   input [2:0] func3,    //-  ir[14:12] 
   output logic [3:0] ALU_FUN,
   output logic [1:0] PC_SEL,
   output logic srcA_SEL,
   output logic [1:0] srcB_SEL, 
	output logic [1:0] RF_SEL   );
    
   //- datatypes for RISC-V opcode types
   typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011
   } opcode_t;
   opcode_t OPCODE; //- define variable of new opcode type
    
   assign OPCODE = opcode_t'(opcode); //- Cast input enum 

   //- datatype for func3Symbols tied to values
   typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
   } func3_t;    
   func3_t FUNC3; 

   assign FUNC3 = func3_t'(func3); 
       
   always_comb
   begin 
      //- schedule all values to avoid latch
        PC_SEL = 2'b00;  srcB_SEL = 2'b00;     RF_SEL = 2'b00; 
      srcA_SEL = 1'b0;   ALU_FUN  = 4'b0000;
		
      case(OPCODE)
         LUI:
         begin
            ALU_FUN = 4'b1001; 
            srcA_SEL = 1'b1;
            RF_SEL = 2'b11; 
         end

			AUIPC: begin
            srcA_SEL = 1'b1;
            srcB_SEL = 2'b11;
            ALU_FUN = 4'b0000;
            RF_SEL = 2'b11;
         end

         JAL:
         begin
				PC_SEL = 2'b11;
            RF_SEL = 2'b00;
			end

			JALR: begin
            PC_SEL = 2'b01;
            RF_SEL = 2'b00;
         end

         BRANCH: begin
            case(FUNC3)  
               BEQ: begin
                  if (br_eq) begin
                     PC_SEL = 2'b10;
                  end else begin
                     PC_SEL = 2'b00;
                  end
               end

               BNE: begin
                  if (!br_eq) begin
                     PC_SEL = 2'b10;
                  end else begin
                     PC_SEL = 2'b00;
                  end
               end

               BLT: begin
                  if (br_lt) begin
                     PC_SEL = 2'b10;
                  end else begin
                     PC_SEL = 2'b00;
                  end
               end

               BGE: begin
                  if (!br_lt) begin
                     PC_SEL = 2'b10;
                  end else begin
                     PC_SEL = 2'b00;
                  end
               end

               BLTU: begin
                  if (br_ltu) begin
                     PC_SEL = 2'b10;
                  end else begin
                     PC_SEL = 2'b00;
                  end
               end

               BGEU: begin
                  if (!br_ltu) begin
                     PC_SEL = 2'b10;
                  end else begin
                     PC_SEL = 2'b00;
                  end
               end

               default: begin
                  PC_SEL = 2'b00;
               end
            endcase
         end

         LOAD: 
         begin
            ALU_FUN = 4'b0000; 
            srcA_SEL = 1'b0; 
            srcB_SEL = 2'b01; 
            RF_SEL = 2'b10;
         end

         STORE:
         begin
            ALU_FUN = 4'b0000; 
            srcA_SEL = 1'b0; 
            srcB_SEL = 2'b10;
         end


         OP_IMM:
         begin
            srcA_SEL = 1'b0; 
            srcB_SEL = 2'b01;
            RF_SEL = 2'b11; 
            
            case(FUNC3)
               3'b000: begin // ADDI
                  ALU_FUN = 4'b0000;
               end
               3'b010: begin // SLTI
                  ALU_FUN = 4'b0010; // slt
               end
               3'b011: begin // SLTIU
                  ALU_FUN = 4'b0011; // sltu
               end
               3'b110: begin // ORI
                  ALU_FUN = 4'b0110; // or
               end
               3'b100: begin // XORI
                  ALU_FUN = 4'b0100; // xor
               end
               3'b111: begin // ANDI
                  ALU_FUN = 4'b0111; // and
               end
               3'b001: begin // SLLI
                  ALU_FUN = 4'b0001; // sll
               end
               3'b101: begin
                  case(func7)
                     1'b0: begin // SRLI
                        ALU_FUN = 4'b0101; // srl
                     end
                     1'b1: begin // SRAI
                        ALU_FUN = 4'b1101; // sra
                     end
                  endcase

               end
					
               default: 
               begin
                  PC_SEL = 2'b00; 
                  ALU_FUN = 4'b1111;
                  srcA_SEL = 1'b0; 
                  srcB_SEL = 2'b00; 
                  RF_SEL = 2'b00; 
               end
            endcase
         end

         OP_RG3: begin
            srcA_SEL = 1'b0;
            srcB_SEL = 2'b00;
            RF_SEL = 2'b11;

            case (FUNC3)
               3'b000: begin // ADD + SUB
                  case (func7)
                     1'b0: begin // ADD
                        ALU_FUN = 4'b0000;
                     end
                     1'b1: begin // SUB
                        ALU_FUN = 4'b1000;
                     end
                  endcase
               end

               3'b001: begin // SLL
                  ALU_FUN = 4'b0001;
               end

               3'b010: begin // SLT
                  ALU_FUN = 4'b0010;
               end

               3'b011: begin // SLTU
                  ALU_FUN = 4'b0011;
               end

               3'b100: begin // XOR
                  ALU_FUN = 4'b0100;
               end

               3'b101: begin // SRL + SRA
                 case (func7) 
                     1'b0: begin // SRL
                        ALU_FUN = 4'b0101;
                     end
                     1'b1: begin // SRA
                        ALU_FUN = 4'b1101;
                     end
                  endcase
               end

               3'b110: begin // OR
                  ALU_FUN = 4'b0110;
               end

               3'b111: begin // AND
                  ALU_FUN = 4'b0111;
               end

               default: begin
                  srcA_SEL = 1'b0;
                  srcB_SEL = 2'b00;
                  RF_SEL = 2'b00;
                  ALU_FUN = 4'b1111; // DEADBEEF
               end
            endcase
         end

         default:
         begin
            PC_SEL = 2'b00; 
            srcB_SEL = 2'b00; 
            RF_SEL = 2'b00; 
            srcA_SEL = 1'b0; 
            ALU_FUN = 4'b0000;
         end
      endcase
   end

endmodule