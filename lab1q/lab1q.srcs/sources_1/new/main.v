`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Cal Poly SLO
// Engineer: Saige Sloan
// 
// Create Date: 01/06/2026
// Design Name: Experiment 1Q
// Module Name: exp_1q
// Project Name: Lab 1
// Target Devices: Basys3 (xc7a35tcpg236-1)
// Tool  Versions: Vivado 2025.2
// Description: 
//
// Dependencies: While waiting for user input through the center button, increments
//               through memory, initially empty, displaying the current value, and
//               largest prime. When input is received, it will read through two
//               16x32 ROMs, checking if each value is prime, and if it is, writing
//               it to memory. Once every value in both ROMs are checked, it will
//               increment through each value in memory, finding the largest prime
//               number. Once the largest prime number is found, it will re-enter
//               the idle state, displaying the data stored in RAM, along with the
//               largest prime number.
// 
// Revision:
// Revision 1.00 - File Created (07-07-2018) 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module exp_1q (
    input btnC,         // Middle/Center Button button input from the Basys3 Board
    input clk,          // Clock signal fed to 
    output [7:0] seg,   // Control for displaying content on the 7 segment display
    output [3:0] an,    // 
    output [15:0] led   // LED control from the board. [15:11] displays current ROM address, [4:0] displays current RAM address
);

    // ------ STATUS SIGNALS ------
    // Divided clock signal which is fed to all modules except for the PNC and SSEG 
    wire slow_clock;
    
    // Prime checker start signal
    wire check_prime;
    // Signal used to notify the circuit that the PNC has finished its operation
    wire prime_check_done;
    // Signal used by the PNC to designate if the given number is prime or not
    wire is_prime;

    // Signal(s) used by the two counters to notify the FSM if they have overflown
    wire rom_cntr_overflown;
    wire ram_cntr_overflown;

    // Comparator GT signal, used in addition to FSM moore_enable_reg/reg_enabled signal
    // which enables the REG load control
    wire greater_than;
    
    
    // ------ CONTROL SIGNALS ------

    // Control signal used to clear the REG and both Counters 
    wire clear;
    wire clear_ram_cntr;
    wire clear_rom_cntr;

    // Control signal used to enable RAM writes
    wire ram_write_enabled;
    
    // Control signal(s) used to tell counter to increment (up) their count
    wire increment_rom;
    wire increment_ram;
    
    // Control signal to switch MUX output between ROM ADDR - ROM DATA : and : RAM DATA - BIGGEST
    wire display_sel;

    // Control signal used to enable REG ld
    wire reg_enabled;
    
    // ------ DATA OUTPUT ------

    // Data output from the ROM and RAM counters, 5 bits are used for both, as there are a total
    // of 32 values possible for both.
    // A 5 bit counter is used for both ROMA and ROMB, even though each only have 4 bit addresses
    // The MSB is used to control a MUX, which determines which data is output, and bits [3:0] are 
    // the current address.
    wire [4:0] rom_count;
    wire [4:0] ram_count;

    // Data output for both ROMA and ROMB. Both have 32 bit data outputs
    // though it is guaranteed that we will only need a maximum of 7 bits (127 max)
    // as we do not exceed numbers larger than 99, due to limits of the SSEG (2 digits)
    wire [31:0] roma_data;
    wire [31:0] romb_data;

    // MUXED data output of ROMA and ROMB, controlled by the MSB of the ROM Counter
    wire [31:0] rom_mux_selected;
    
    // Data output for RAM data. Output of 7 bits is enough space for up to 127. 
    // ROM memory is guaranteed by assignment to never exceed 99, similar to ROM
    wire [6:0] ram_data; 
    // Same thing applies to the register size.
    wire [6:0] reg_data; 
    
    // Data for left SSEG display
    wire [6:0] cnt_left;
    // Data for right SSEG display
    wire [6:0] cnt_right;
    
    // ------ MAIN PROGRAM ------

    // Left LEDS will always get current ROM Address (though not active in all states)
    assign led [15:11] = rom_count;
    // Right LEDS will always get current RAM Address
    assign led[4:0] = ram_count;
    
    // CLOCK_DIVIDER divides the main onboard clock by counting up
    // through a n=25 bit 'counter', dividing by 2^n. It is used to 
    // synchronize all modules, excluding the PRIME_CHECKER and SSEG
    clk_2n_div_test #(.n(25)) CLOCK_DIVIDER (
        .clockin   (clk), 
        .fclk_only (1'b0),          
        .clockout  (slow_clock)   
    );
    
    // The implemented LAB1Q_FSM receives the middle button status, along with any
    // needed module output signals, allowing it to determine what state to enter next.
    // For a more detailed explanation of the FSM implemented for this lab, view the comment
    // at the top of this file.
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
        .mealy_up_rom(increment_rom),
        .mealy_we(ram_write_enabled),
        
        .moore_clr_rom_ctr(clear_rom_cntr),
        .moore_disp_sel(display_sel),
        .moore_up_ram(increment_ram),
        .moore_start_prime(check_prime),
        .moore_enable_reg(reg_enabled)
    );
    
    // ROM_A is implemented as a 16x32 ROM, allowing for up to 16 addresses of 32 bits each
    // Therefore, a 4 bit counter is used to access each address
    ROM_16x32_exp1q_a ROM_A (
        .addr  (rom_count[3:0]),
        .data  (roma_data),
        .rd_en (1'b1)
    );
       
    // ROM_B is implemented as a 16x32 ROM, allowing for up to 16 addresses of 32 bits each
    // Therefore, a 4 bit counter is used to access each address
    ROM_16x32_exp1q_b ROM_B (
        .addr  (rom_count[3:0]),  
        .data  (romb_data),  
        .rd_en (1'b1)
    );

    // ROM_COUNTER is implemented as a 5 bit counter. Though both ROM_A and ROM_B only
    // take a 4 bit address value, ROM_COUNTER is 5 bits to allow selection between them
    // using the MSB to MUX between the outputs
    cntr_up_clr_nb #(.n(5)) ROM_COUNTER (
        .clk   (slow_clock), 
        .clr   (clear_rom_cntr), 
        .up    (increment_rom), 
        .ld    (1'b0), 
        .D     (5'b00000), 
        .count (rom_count), 
        .rco   (rom_cntr_overflown)
    );
    
    // ROM_DATA_MUX is used, as stated above, to select between ROM_A and ROM_B.
    // The MSB of rom_count is used to do so, yielding ROM_A for the first 0-15,
    // and ROM_B for the next 16-31 address values.
    mux_2t1_nb  #(.n(32)) ROM_DATA_MUX (
        .SEL   (rom_count[4]), 
        .D0    (roma_data), 
        .D1    (romb_data), 
        .D_OUT (rom_mux_selected)
    );
    
    // PRIME_CHECKER is checks if its given number is prime or not, signaling other
    // modules accordingly with the DONE and PRIME signals
    prime_num_check  PRIME_CHECKER (
        .start (check_prime),
        .test  (1'b0),
        .clk   (clk),
        .num   (rom_mux_selected[9:0]),
        .DONE  (prime_check_done),
        .PRIME (is_prime)
    ); 
    
    // RAM_COUNTER is used for two things. First to increment through ram while storing
    // each found prime number in the current location, next it is used to increment through,
    // all values in ram, finding the largest prime number, then it is used to increment through
    // all positions in memory to display the contents on the SSEG display.
    cntr_up_clr_nb #(.n(5)) RAM_COUNTER (
        .clk   (slow_clock), 
        .clr   (clear_ram_cntr), 
        .up    (increment_ram), 
        .ld    (1'b0), 
        .D     (5'b00000), 
        .count (ram_count), 
        .rco   (ram_cntr_overflown)
    );
    
    // PRIME_RAM is a 32x7 RAM Module, and is used to store all the found prime numbers.
    // It is only 32x7 due to the fact that a given number in this assignment will never
    // exceed 99, so only 7 bits are needed to display such a number.
    ram_single_port #(.n(5),.m(7)) PRIME_RAM (
        .data_in  (rom_mux_selected[6:0]),  // m spec
        .addr     (ram_count),  // n spec 
        .we       (ram_write_enabled),
        .clk      (slow_clock),
        .data_out (ram_data)
    );
    
    // GT_COMP will take in the current ram_data and stored reg_data, comparing
    // if the ram_data is larger, and if so, signal that it is greater_than, allowing
    // the register to load the new largest prime number. 
    comp_nb #(.n(7)) GT_COMP (
        .a  (ram_data),
        .b  (reg_data), // reg data 
        .eq (), 
        .gt (greater_than), 
        .lt ()
    );
    
    // BIG_PRIME_REG is used to keep track of the largest encountered prime number in 
    // memory. It is controlled both by the FSM state and the GT_COMP signal.
    reg_nb #(.n(7)) BIG_PRIME_REG (
        .data_in  (ram_data), 
        .ld       (greater_than && reg_enabled), 
        .clk      (slow_clock), 
        .clr      (1'b0), 
        .data_out (reg_data)
    );
    
    // DISP_LEFT_SEG_MUX selects between RAM_DATA and ROM_COUNT for the Left Segment,
    // depending on DISPLAY_SEL. By default, when display_sel is low, ram_data is displayed, 
    // which is the case in the FSM Idle state
    mux_2t1_nb  #(.n(7)) DISP_LEFT_SEG_MUX (
        .SEL   (display_sel), 
        .D0    (ram_data), 
        .D1    ({{3'b0}, {rom_count[3:0]}}), 
        .D_OUT (cnt_left)
    );
    
    // DISP_RIGHT_SEG_MUX selects between REG_DATA (or biggest) and the ROM output for the Right
    // Segment, depending on DISPLAY_SEL. By default, when display_sel is low, reg_data 
    // is displayed, which is the case in the FSM Idle state
    mux_2t1_nb  #(.n(7)) DISP_RIGHT_SEG_MUX (
        .SEL   (display_sel), 
        .D0    (reg_data), 
        .D1    (rom_mux_selected[6:0]), 
        .D_OUT (cnt_right)
    );
    
    // SEVEN_SEG displays either ram_data : reg_data, or, rom_count : rom_data_mux_selected
    // depending on the state of display_sel. In the FSM idle and find_big states, the former is displayed,
    // and in all other states, the latter is displayed.
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