// Top-level module that defines the I/Os for the DE1 SoC board	

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
	assign reset = SW[9];

	logic [31:0] div_clk;

	parameter whichClock = 14;
	clock_divider cdiv (.clock(CLOCK_50),
	.reset(reset),
	.divided_clocks(div_clk));
	
	logic clkSelect; // Clock selection; allows for easy switching between simulation and board clocks

	// Uncomment ONE of the following two lines depending on intention
	assign clkSelect = CLOCK_50; // for simulation
	parameter COUNT_MAX = 2; // for simulation

	// assign clkSelect = div_clk[whichClock]; // for board
	// parameter COUNT_MAX = 1526; // for board - because we are using div_clk[14] = 1526 Hz, faster clk caused LED issues

	// ***** TETRIS LOGIC ***** //
	logic [1:0] random_shape_addr;
	logic [3:0][7:0] random_shape;

	lfsr l (.clk(clkSelect), .reset, .out(random_shape_addr));
	generate_shape g (.shape_addr(random_shape_addr), .shape(random_shape));
	logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs on LED Matrix
	logic [15:0][15:0]GrnPixels; // 16 x 16 array representing red LEDs on LED Matrix

	logic L_pressed, R_pressed;
	button_detection bL (.clk(clkSelect), .reset, .b(~KEY[3]), .out(L_pressed));
	button_detection bR (.clk(clkSelect), .reset, .b(~KEY[0]), .out(R_pressed));

	// ***** GAME MODULES ***** /
	logic [14:0][7:0] current_board;
	board game_board (.clk(clkSelect), .game_clk_count(COUNT_MAX) , .reset, .current_board, .random_shape, .L_pressed, .R_pressed);

	// ***** DISPLAY MODULES ***** /
	display disp (.clk(clkSelect), .reset, .current_board, .GrnPixels, .RedPixels);
	LEDDriver Driver (.CLK(clkSelect), .RST(reset), .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);

endmodule

`timescale 1 ps / 1 ps
module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [35:0] GPIO_1;

	DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, GPIO_1);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; 
	end

	// Test the design.
	initial begin
		SW[9] <=0; KEY[3] <=1; KEY[0] <=1; @(posedge CLOCK_50); // Initialize
		SW[9] <= 1; @(posedge CLOCK_50); // Always reset FSMs at start; turn on
		SW[9] <= 0; @(posedge CLOCK_50);
		repeat(20) @(posedge CLOCK_50); // Always reset FSMs at start; turn on
		KEY[0] <= 0; @(posedge CLOCK_50);
		KEY[0] <= 1; @(posedge CLOCK_50);
		KEY[0] <= 0; @(posedge CLOCK_50);
		KEY[0] <= 1; @(posedge CLOCK_50);
		KEY[0] <= 0; @(posedge CLOCK_50);
		KEY[0] <= 1; @(posedge CLOCK_50);
		KEY[0] <= 0; @(posedge CLOCK_50);
		KEY[0] <= 1; @(posedge CLOCK_50);
		KEY[0] <= 0; @(posedge CLOCK_50);
		KEY[0] <= 1; @(posedge CLOCK_50);
		repeat(100) @(posedge CLOCK_50); // Always reset FSMs at start; turn on
		$stop; // End the simulation.
	end
endmodule
