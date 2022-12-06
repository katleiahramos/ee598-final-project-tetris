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
	
	logic clkSelect; // Clock selec`tion; allows for easy switching between simulation and board clocks

	// Uncomment ONE of the following two lines depending on intention
	// assign clkSelect = CLOCK_50; // for simulation
	assign clkSelect = div_clk[whichClock]; // for board

	// ***** TETRIS LOGIC ***** //
	logic [1:0] random_shape_addr;
	logic [3:0][7:0] random_shape;
	logic [3:0][7:0] current_shape;
	
	// parameter COUNT_MAX = 5; // for simulation
	parameter COUNT_MAX = 1526; // for board - because we are using div_clk[14] = 1526 Hz, faster clk caused LED issues
	lfsr l (.clk(clkSelect), .reset, .out(random_shape_addr));
	generate_shape g (.shape_addr(random_shape_addr), .shape(random_shape));
	logic [15:0][15:0] ShapeCanvas; // 16 x 16 array representing only the current shape LEDs
	logic [15:0][15:0] BoardCanvas; // 16 x 16 array representing the existing shape's on the board LEDs
	logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs on LED Matrix
	logic [15:0][15:0]GrnPixels; // 16 x 16 array representing red LEDs on LED Matrix

	int counter;
	int place_marker; // to keep track of first row current shape is in
	always_ff @(posedge clkSelect) begin
		if (reset) begin
			counter <= 0;
			place_marker <=0;
			// current_shape <= random_shape;\
			current_shape <= { 
                // SQAURE
                8'b00000000,
                8'b00000000,
                8'b00011000,
                8'b00011000
            };

			ShapeCanvas[00] <= 16'b0000000000000000;
			ShapeCanvas[01] <= 16'b0000000000000000;
			ShapeCanvas[02] <= 16'b0000000000000000;
			ShapeCanvas[03] <= 16'b0000000000000000;
			ShapeCanvas[04] <= 16'b0000000000000000;
			ShapeCanvas[05] <= 16'b0000000000000000;
			ShapeCanvas[06] <= { 6'b000000, current_shape[00], 2'b00 };
			ShapeCanvas[07] <= { 6'b000000, current_shape[01],  2'b00};
			ShapeCanvas[08] <= { 6'b000000, current_shape[02],  2'b00 };
			ShapeCanvas[09] <= { 6'b000000, current_shape[03],  2'b00 };
			ShapeCanvas[10] <= 16'b0000000000000000;
			ShapeCanvas[11] <= 16'b0000000000000000;
			ShapeCanvas[12] <= 16'b0000000000000000;
			ShapeCanvas[13] <= 16'b0000000000000000;
			ShapeCanvas[14] <= 16'b0000000000000000;
			ShapeCanvas[15] <= 16'b0000000000000000;

			BoardCanvas[00] <= 16'b0000000000000000;
			BoardCanvas[01] <= 16'b0000000000000000;
			BoardCanvas[02] <= 16'b0000000000000000;
			BoardCanvas[03] <= 16'b0000000000000000;
			BoardCanvas[04] <= 16'b0000000000000000;
			BoardCanvas[05] <= 16'b0000000000000000;
			BoardCanvas[06] <= 16'b0000010000000010;
			BoardCanvas[07] <= 16'b0000010000000010;
			BoardCanvas[08] <= 16'b0000010000000010;
			BoardCanvas[09] <= 16'b0000010000000010;
			BoardCanvas[10] <= 16'b0000010000000010;
			BoardCanvas[11] <= 16'b0000010000000010;
			BoardCanvas[12] <= 16'b0000010000000010;
			BoardCanvas[13] <= 16'b0000010000000010;
			BoardCanvas[14] <= 16'b0000010000000010;
			BoardCanvas[15] <= 16'b0000011111111110;

			RedPixels = ShapeCanvas | BoardCanvas;
		end

		if (BoardCanvas[place_marker + 1] & ShapeCanvas[place_marker]) begin
			// add current piece to board canvas
			BoardCanvas <= BoardCanvas | ShapeCanvas;
			// assign a new current piece
			place_marker <= 0;
		end
		if (counter == COUNT_MAX) begin
			counter <= 0;
			ShapeCanvas <= ShapeCanvas << 16 ;	
			RedPixels <= ShapeCanvas | BoardCanvas;
		end 
		else 
			counter <= counter + 1;
			place_marker <= place_marker + 1;
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
		SW[9] <=0; KEY[0] <= 1; KEY[1] <= 1; @(posedge CLOCK_50); // Initialize
		SW[9] <= 1; @(posedge CLOCK_50); // Always reset FSMs at start; turn on
		SW[9] <= 0; @(posedge CLOCK_50);
		KEY[1] <= 0; repeat (5) @(posedge CLOCK_50);
		KEY[1] <= 1; @(posedge CLOCK_50);
		repeat(15) @(posedge CLOCK_50); // Always reset FSMs at start; turn on
		$stop; // End the simulation.
	end
endmodule
