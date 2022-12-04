// Top-level module that defines the I/Os for the DE1 SoC board	

// module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
// 	output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
// 	output logic [9:0]  LEDR;
// 	input  logic [3:0]  KEY;
// 	input  logic [9:0]  SW;
// 	output logic [35:0] GPIO_1;
// 	input logic CLOCK_50;
	
// 	logic [31:0] clk;
// 	logic SYSTEM_CLOCK;
// 	// Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
// 	assign SYSTEM_CLOCK = clk[14]; // increase freq for no-flicker, lower for brighter
// 	logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
// 	logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
// 	logic RST;                   // reset - toggle this on startup
		
// 	assign RST = ~KEY[3];

// 	clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
// 	LEDDriver Driver (.CLK(SYSTEM_CLOCK), .RST, .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);
	
// 	LED_test test (.RST, .RedPixels, .GrnPixels);

// 	assign HEX0 = '1;
// 	assign HEX1 = '1;
// 	assign HEX2 = '1;
// 	assign HEX3 = '1;
// 	assign HEX4 = '1;
// 	assign HEX5 = '1;
// endmodule

module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, GPIO_1);
	input logic CLOCK_50; // 50MHz clock.
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY; // True when not pressed, False when pressed
	input logic [9:0] SW;
	output logic [35:0] GPIO_1;

	// ***** CLOCK SELECTION ***** //
	// Generate clk off of CLOCK_50, whichClock picks rate.
	logic reset;
	logic [31:0] div_clk;

	parameter whichClock = 15;
	clock_divider cdiv (.clock(CLOCK_50),
	.reset(reset),
	.divided_clocks(div_clk));
	
	logic clkSelect; // Clock selection; allows for easy switching between simulation and board clocks

	// Uncomment ONE of the following two lines depending on intention
	// assign clkSelect = CLOCK_50; // for simulation
	assign clkSelect = div_clk[14]; // for board

	// ***** TETRIS LOGIC ***** //
	logic [1:0] random_shape_addr;
	logic [3:0][7:0] random_shape;
	logic [3:0][7:0] current_shape;
	logic game_clk;

	assign game_clk = ~KEY[0];

	lfsr l (.clk(clkSelect), .reset, .out(random_shape_addr));
	generate_shape g (.shape_addr(random_shape_addr), .shape(random_shape));

	always_ff @(posedge game_clk) begin
		current_shape <= random_shape;
	end


	logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
	logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs

	LEDDriver Driver (.CLK(clkSelect), .RST(reset), .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);

	assign RedPixels[00] = 16'b0000000000000000;
	assign RedPixels[01] = 16'b0000000000000000;
	assign RedPixels[02] = 16'b0000000000000000;
	assign RedPixels[03] = 16'b0000000000000000;
	assign RedPixels[04] = 16'b0000000000000000;
	assign RedPixels[05] = 16'b0000000000000000;
	assign RedPixels[06] = { 8'b00000000, current_shape[00] };
	assign RedPixels[07] = { 8'b00000000, current_shape[01] };
	assign RedPixels[08] = { 8'b00000000, current_shape[02] };
	assign RedPixels[09] = { 8'b00000000, current_shape[03] };
	assign RedPixels[10] = 16'b0000000000000000;
	assign RedPixels[11] = 16'b0000000000000000;
	assign RedPixels[12] = 16'b0000000000000000;
	assign RedPixels[13] = 16'b0000000000000000;
	assign RedPixels[14] = 16'b0000000000000000;
	assign RedPixels[15] = 16'b0000000000000000;
	
	// LED_test test (.RST(reset), .RedPixels, .GrnPixels); // Replace with Display module for Tetris

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

		repeat(15) @(posedge CLOCK_50); // Always reset FSMs at start; turn on
		$stop; // End the simulation.
	end
endmodule
