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

	assign reset = ~KEY[0];
	parameter whichClock = 15;
	clock_divider cdiv (.clock(CLOCK_50),
	.reset(reset),
	.divided_clocks(div_clk));

	// Clock selection; allows for easy switching between simulation and board clocks
	logic clkSelect;

	// Uncomment ONE of the following two lines depending on intention
	assign clkSelect = CLOCK_50; // for simulation
	// assign clkSelect = div_clk[whichClock]; // for board

	logic [4:0] loc;
	logic start, found, not_found;
	// assign start = SW[9];
	assign LEDR[9] = found;
	assign LEDR[0] = not_found;

	button_detection b (.clk(clkSelect), .reset, .b(SW[9]), .out(start));

	binary_search c (
		.clk(clkSelect), 
		.reset,
		.start,
		.A(SW[7:0]),
		.loc,
		.found,
		.not_found
		);

	// Hex Displays
	seg7 a_disp1 (.bcd(loc[3:0]), .leds(HEX0));
	seg7 a_disp2 (.bcd({3'b000, loc[4]}), .leds(HEX1));
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
    SW[7:0] <= 0; SW[9] <=0; @(posedge CLOCK_50); // Initialize
    KEY[0] <= 0; @(posedge CLOCK_50); // Always reset FSMs at start; turn on
    KEY[0] <= 1; SW[9] <= 1; SW[7:0] <= 17; @(posedge CLOCK_50); // Always reset FSMs at start; turn on
    SW[9] <= 0; @(posedge CLOCK_50);
    repeat(15) @(posedge CLOCK_50);

    KEY[0] <= 0;@(posedge CLOCK_50);
    KEY[0] <=1; @(posedge CLOCK_50); 
    SW[9] <= 1; SW[7:0] <= 3; @(posedge CLOCK_50); 
    SW[9] <= 0; @(posedge CLOCK_50);
    repeat(15) @(posedge CLOCK_50);

    // Middle val
    KEY[0] <= 0;@(posedge CLOCK_50);
    KEY[0] <=1; @(posedge CLOCK_50); 
    SW[9] <= 1; SW[7:0] <= 7; @(posedge CLOCK_50); 
    SW[9] <= 0; @(posedge CLOCK_50);
    repeat(15) @(posedge CLOCK_50);

    // Not Found
    KEY[0] <= 0;@(posedge CLOCK_50); 
    KEY[0] <=1; @(posedge CLOCK_50); 
    SW[9] <= 1; SW[7:0] <= 40; @(posedge CLOCK_50); 
    SW[9] <= 0; @(posedge CLOCK_50);
    repeat(35) @(posedge CLOCK_50);
		$stop; // End the simulation.
	end
endmodule
