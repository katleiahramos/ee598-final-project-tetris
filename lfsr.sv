/*
 * extended from example on verilog shfit register:
 * http://www.referencedesigner.com/tutorials/verilog/verilog_32.php
 *
 */


/*
 * Generate a 10 bit random number using an LFSR, Using 10 bits makes it more random
 * Out put the last 2 bits since we only need 2 bits to represent our 4 different shapes



 Will constantly cycle, and will be assigned when creating a new block
 */ 
module lfsr (clk, reset, out);
    input logic clk, reset;
    output logic [1:0] out;

    logic [9:0] ps, ns;

    always_ff @(posedge clk) begin
        if (reset)
            ps <= 0;
        else
            ps <= ns;
    end

    assign ns = {ps[8:0] , ~(ps[9]^ps[6]) };
    
    assign out = ps[1:0];
endmodule

module lfsr_testbench ();
    logic clk, reset;
    logic [1:0] out;

    lfsr dut (.clk, .reset, .out);

    // Set up a simulated clock.
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        // Forever toggle the clock
        forever #(CLOCK_PERIOD/2) clk <= ~clk; 
    end

    initial begin
        reset <= 1; @(posedge clk); // Always reset FSMs at start
        reset <= 0; @(posedge clk); // count = 0
        repeat(15) @(posedge clk);
        $stop; // End the simulation.
    end
endmodule