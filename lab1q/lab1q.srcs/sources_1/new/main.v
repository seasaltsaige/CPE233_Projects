`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly SLO
// Engineer: 
//
// Create Date: 
// Design Name: Experiment 1N
// Module Name: exp_1q
// Project Name: Lab 1Q
// Target Devices: Basys3
// Tool Versions: Vivado 2025.2
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module exp_1q (
    input btnC,
    input clk,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
);

    wire slow_clock;
    
    wire check_prime;
    wire prime_check_done;
    wire is_prime;
    wire rom_cntr_overflown;
    wire ram_cntr_overflown;
    
    wire clear;
    wire clear_ram_cntr;
    wire ram_write_enabled;
    
    wire increment_rom;
    wire increment_ram;
    
    wire display_sel;
    
    wire [4:0] rom_count;
    wire [4:0] ram_count;

    wire [31:0] roma_data;
    wire [31:0] romb_data;
    wire [31:0] rom_mux_selected;
    
    
    wire [6:0] ram_data; // 7 bits is enough for up to 127. ROM mem is gaurenteed by assignment to never exceed 99
    wire [6:0] reg_data; // same thing for register
    
    wire [6:0] cnt_left;
    wire [6:0] cnt_right;
    
    wire greater_than;
    
    wire reg_enabled;
    
    
//    always @ (posedge clk) begin
//        if (display_sel == 0) begin
//            assign led[15:11] = rom_count;
//            assign led = {{rom_count}, {6'b0}, ram_count};
//            assign led[4:0] = ram_count;
//        end else begin
//            led = {{}};
//        end
//    end
    
    clk_2n_div_test #(.n(25)) CLOCK_DIVIDER (
        .clockin   (clk), 
        .fclk_only (1'b0),          
        .clockout  (slow_clock)   
    );
        
    lab1q_fsm(
        .reset(1'b0), 
        .clk(slow_clock),

        .m_btn(btnC),
        .prime(is_prime),
        .done(prime_check_done),
        .rco_rom(rom_cntr_overflown),
        .rco_ram(ram_cntr_overflown),
        
        .mealy_clr(clear),
        .mealy_clr_ram_ctr(clear_ram_cntr),
        
        .moore_we(ram_write_enabled),
        .moore_disp_sel(display_sel),
        .moore_up_rom(increment_rom),
        .moore_up_ram(increment_ram),
        .moore_start_prime(check_prime),
        .moore_enable_reg(reg_enabled)
    );
    
    
    
    ROM_16x32_exp1q_a ROM_A (
        .addr  (rom_count[3:0]),
        .data  (roma_data),
        .rd_en (1'b1)
    );
       
    ROM_16x32_exp1q_b ROM_B (
        .addr  (rom_count[3:0]),  
        .data  (romb_data),  
        .rd_en (1'b1)
    );
    
     cntr_up_clr_nb #(.n(5)) ROM_COUNTER (
         .clk   (slow_clock), 
         .clr   (clear), 
         .up    (increment_rom), 
         .ld    (1'b0), 
         .D     (5'b00000), 
         .count (rom_count), 
         .rco   (rom_cntr_overflown)
    );
    
    mux_2t1_nb  #(.n(32)) ROM_DATA_MUX (
        .SEL   (rom_count[4]), 
        .D0    (roma_data), 
        .D1    (romb_data), 
        .D_OUT (rom_mux_selected)
    );
    
    prime_num_check  PRIME_CHECKER (
        .start (check_prime),
        .test  (1'b0),
        .clk   (clk),
        .num   (rom_mux_selected),
        .DONE  (prime_check_done),
        .PRIME (is_prime)
    ); 
    
    
    cntr_up_clr_nb #(.n(5)) RAM_COUNTER (
         .clk   (slow_clock), 
         .clr   (clear_ram_cntr), 
         .up    (increment_ram), 
         .ld    (1'b0), 
         .D     (5'b00000), 
         .count (ram_count), 
         .rco   (ram_cntr_overflown)
    );
    
    ram_single_port #(.n(5),.m(7)) PRIME_RAM (
        .data_in  (rom_mux_selected[6:0]),  // m spec
        .addr     (ram_count),  // n spec 
        .we       (ram_write_enabled),
        .clk      (slow_clock),
        .data_out (ram_data)
    );
    
    comp_nb #(.n(7)) GT_COMP (
        .a  (ram_data),
        .b  (reg_data), // reg data 
        .eq (), 
        .gt (greater_than), 
        .lt ()
    );
    
    reg_nb #(.n(7)) BIG_PRIME_REG (
        .data_in  (ram_data), 
        .ld       (greater_than && reg_enabled), 
        .clk      (slow_clock), 
        .clr      (1'b0), 
        .data_out (reg_data)
    );
    
    
    mux_2t1_nb  #(.n(7)) DISP_LEFT_SEG_MUX (
        .SEL   (display_sel), 
        .D0    (ram_data), 
        .D1    ({{2'b0}, {rom_count}}), 
        .D_OUT (cnt_left)
    );
    
    mux_2t1_nb  #(.n(7)) DISP_RIGHT_SEG_MUX (
        .SEL   (display_sel), 
        .D0    (reg_data), 
        .D1    (rom_mux_selected[6:0]), 
        .D_OUT (cnt_right)
    );
        
    univ_sseg SEVEN_SEG (
        .cnt1    ({{7'b0}, cnt_left}), 
        .cnt2    (cnt_right), 
        .valid   (1'b1), 
        .dp_en   (1'b0), 
        .dp_sel  (), 
        .mod_sel (2'b01), 
        .sign    (1'b0), 
        .clk     (clk), 
        .ssegs   (seg), 
        .disp_en (an)
    ); 

endmodule