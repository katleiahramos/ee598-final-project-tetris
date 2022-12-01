// Top-level module that defines the I/Os for the DE1 SoC board	

module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input logic CLOCK_50; // 50MHz clock.
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY; // True when not pressed, False when pressed
	input logic [9:0] SW;

	// Generate clk off of CLOCK_50, whichClock picks rate.

	logic reset;
	logic [31:0] div_clk;

	assign reset = SW[9];
	parameter whichClock = 15;
	clock_divider cdiv (.clock(CLOCK_50),
	.reset(reset),
	.divided_clocks(div_clk));

	// Clock selection; allows for easy switching between simulation and board clocks
	logic clkSelect;

	// Uncomment ONE of the following two lines depending on intention
	assign clkSelect = CLOCK_50; // for simulation
	// assign clkSelect = div_clk[whichClock]; // for board

	logic [2:1] random_shape_addr;

	lfsr l (.clk(clkSelect), .reset, .out(random_shape_addr))

endmodule

`timescale 1 ps / 1 ps
module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;

	DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; 
	end

	// Test the design.
	initial begin
    SW[9] <=0; @(posedge CLOCK_50); // Initialize
    SW[9] <= 1; @(posedge CLOCK_50); // Always reset FSMs at start; turn on
	end
endmodule
