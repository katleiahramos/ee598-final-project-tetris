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
	// assign clkSelect = CLOCK_50; // for simulation
	// parameter COUNT_MAX = 2; // for simulation

	assign clkSelect = div_clk[whichClock]; // for board
	parameter COUNT_MAX = 1526; // for board - because we are using div_clk[14] = 1526 Hz, faster clk caused LED issues

	// ***** TETRIS LOGIC ***** //
	logic [1:0] random_shape_addr;
	logic [3:0][7:0] random_shape;
	logic [3:0][7:0] current_shape;
	

	lfsr l (.clk(clkSelect), .reset, .out(random_shape_addr));
	generate_shape g (.shape_addr(random_shape_addr), .shape(random_shape));
	logic [19:0][15:0] ShapeCanvas; // 20 x 16 array representing only the current shape LEDs ( holds incoming shape)
	logic [19:0][15:0] BoardCanvas; // 16 x 16 array representing the existing shape's on the board LEDs
	logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs on LED Matrix
	logic [15:0][15:0]GrnPixels; // 16 x 16 array representing red LEDs on LED Matrix

	logic L_pressed, R_pressed;
	button_detection bL (.clk(clkSelect), .reset, .b(~KEY[3]), .out(L_pressed));
	// button_detection bR (.clk(clkSelect), .reset, .b(~KEY[0]), .out(R));

	int counter;
	int y_counter; // to keep track of row current shape is in
	logic [15:0][15:0] NextShapeCanvas;
	logic start;
	// int y_counter; // to keep track of column current shape is in 
	always_ff @(posedge clkSelect) begin
		counter <= counter + 1;
		if (reset) begin
			counter <= 0;
			y_counter <=0;
			start <= 0;
			ShapeCanvas[00] <= { 6'b000000, random_shape[03], 2'b00 };
			ShapeCanvas[01] <= { 6'b000000, random_shape[02],  2'b00};
			ShapeCanvas[02] <= { 6'b000000, random_shape[01],  2'b00 };
			ShapeCanvas[03] <= { 6'b000000, random_shape[00],  2'b00 };
			ShapeCanvas[04] <= 16'b0000000000000000;
			ShapeCanvas[05] <= 16'b0000000000000000;
			ShapeCanvas[06] <= 16'b0000000000000000;
			ShapeCanvas[07] <= 16'b0000000000000000;
			ShapeCanvas[08] <= 16'b0000000000000000;
			ShapeCanvas[09] <= 16'b0000000000000000;
			ShapeCanvas[10] <= 16'b0000000000000000;
			ShapeCanvas[11] <= 16'b0000000000000000;
			ShapeCanvas[12] <= 16'b0000000000000000;
			ShapeCanvas[13] <= 16'b0000000000000000;
			ShapeCanvas[14] <= 16'b0000000000000000;
			ShapeCanvas[15] <= 16'b0000000000000000;
			ShapeCanvas[16] <= 16'b0000000000000000;
			ShapeCanvas[17] <= 16'b0000000000000000;
			ShapeCanvas[18] <= 16'b0000000000000000;
			ShapeCanvas[19] <= 16'b0000000000000000;

			BoardCanvas[00] <= 16'b0000000000000000;
			BoardCanvas[01] <= 16'b0000000000000000;
			BoardCanvas[02] <= 16'b0000000000000000;
			BoardCanvas[03] <= 16'b0000000000000000;
			BoardCanvas[04] <= 16'b0000000000000000;
			BoardCanvas[05] <= 16'b0000000000000000;
			BoardCanvas[06] <= 16'b0000000000000000;
			BoardCanvas[07] <= 16'b0000000000000000;
			BoardCanvas[08] <= 16'b0000000000000000;
			BoardCanvas[09] <= 16'b0000000000000000;
			BoardCanvas[10] <= 16'b0000000000000000;
			BoardCanvas[11] <= 16'b0000000000000000;
			BoardCanvas[12] <= 16'b0000000000000000;
			BoardCanvas[13] <= 16'b0000000000000000;
			BoardCanvas[14] <= 16'b0000000000000000;
			BoardCanvas[15] <= 16'b0000000000000000;
			BoardCanvas[16] <= 16'b0000000000000000;
			BoardCanvas[17] <= 16'b0000000000000000;
			BoardCanvas[18] <= 16'b0000000000000000;
			BoardCanvas[19] <= 16'b0000000000000000;

			GrnPixels[00] <= 16'b0000010000000010;
			GrnPixels[01] <= 16'b0000010000000010;
			GrnPixels[02] <= 16'b0000010000000010;
			GrnPixels[03] <= 16'b0000010000000010;
			GrnPixels[04] <= 16'b0000010000000010;
			GrnPixels[05] <= 16'b0000010000000010;
			GrnPixels[06] <= 16'b0000010000000010;
			GrnPixels[07] <= 16'b0000010000000010;
			GrnPixels[08] <= 16'b0000010000000010;
			GrnPixels[09] <= 16'b0000010000000010;
			GrnPixels[10] <= 16'b0000010000000010;
			GrnPixels[11] <= 16'b0000010000000010;
			GrnPixels[12] <= 16'b0000010000000010;
			GrnPixels[13] <= 16'b0000010000000010;
			GrnPixels[14] <= 16'b0000010000000010;
			GrnPixels[15] <= 16'b0000011111111110;
		end

		// if(L_pressed) begin // Check if we've reached the boundary of the board
		// 	$display("IN IF STATEMENT");
		// 	NextShapeCanvas <= ShapeCanvas << 1;
		// 	if(~(GrnPixels[y_counter+1] & NextShapeCanvas[y_counter] ))
		// 		ShapeCanvas <= NextShapeCanvas;

		// 	RedPixels <= ShapeCanvas  | BoardCanvas;
		// end 

		if (counter == COUNT_MAX) begin
			counter <= 0;
			RedPixels <= ShapeCanvas[19:4] | BoardCanvas[19:4];
			y_counter <= y_counter + 1;
		// for each game clock print out game canvas, shape canvas, and counter
		// tick1, tick
		// change count_max to 1

			if ((BoardCanvas[y_counter + 4] & ShapeCanvas[y_counter + 3] ) | y_counter == 15) begin
				// check if any rows are full, if so clear them, and then shift rows down
				
				// add current piece to board canvas
				BoardCanvas[19:4] <= BoardCanvas[19:4] | ShapeCanvas[19:4] ;
				// assign a new current piece
				y_counter <= 0;

				ShapeCanvas[00] <= { 6'b000000, random_shape[03], 2'b00 };
				ShapeCanvas[01] <= { 6'b000000, random_shape[02],  2'b00};
				ShapeCanvas[02] <= { 6'b000000, random_shape[01],  2'b00 };
				ShapeCanvas[03] <= { 6'b000000, random_shape[00],  2'b00 };
				ShapeCanvas[04] <= 16'b0000000000000000;
				ShapeCanvas[05] <= 16'b0000000000000000;
				ShapeCanvas[06] <= 16'b0000000000000000;
				ShapeCanvas[07] <= 16'b0000000000000000;
				ShapeCanvas[08] <= 16'b0000000000000000;
				ShapeCanvas[09] <= 16'b0000000000000000;
				ShapeCanvas[10] <= 16'b0000000000000000;
				ShapeCanvas[11] <= 16'b0000000000000000;
				ShapeCanvas[12] <= 16'b0000000000000000;
				ShapeCanvas[13] <= 16'b0000000000000000;
				ShapeCanvas[14] <= 16'b0000000000000000;
				ShapeCanvas[15] <= 16'b0000000000000000;
				ShapeCanvas[16] <= 16'b0000000000000000;
				ShapeCanvas[17] <= 16'b0000000000000000;
				ShapeCanvas[18] <= 16'b0000000000000000;
				ShapeCanvas[19] <= 16'b0000000000000000;
			end else begin
				ShapeCanvas <= ShapeCanvas << 16 ;	
			end


		end

		
	end

	logic game_clk;

	assign game_clk = counter == COUNT_MAX;
	assign LEDR[0] = game_clk;
	assign LEDR[2] = reset;
	assign LEDR[9] = clkSelect;



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
		SW[9] <=0; KEY[3]=1; @(posedge CLOCK_50); // Initialize
		SW[9] <= 1; @(posedge CLOCK_50); // Always reset FSMs at start; turn on
		SW[9] <= 0; @(posedge CLOCK_50);
		repeat(150) @(posedge CLOCK_50); // Always reset FSMs at start; turn on
		$stop; // End the simulation.
	end
endmodule
