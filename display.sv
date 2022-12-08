// Handle LED display shown to user
module display (clk, reset, current_board, GrnPixels, RedPixels);
    input logic clk, reset;
    input logic [14:0][7:0] current_board;
    output logic [15:0][15:0] RedPixels; // 16 x 16 array representing red LEDs on LED Matrix
	output logic [15:0][15:0] GrnPixels; // 16 x 16 array representing green LEDs on LED Matrix

    always_ff @(posedge clk) begin
        if (reset) begin
            // Set RedPixels
            RedPixels <= 0;

            // Set game boarder using green pixels
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
        end else begin
            // Assign only the Red Pixels on the display that correspond to the board
            // Start from 1 because row 0 is used by green pixels for border
            for (int i = 0; i < 15; i++) begin
                RedPixels[i][9:2]<= current_board[i]; 
            end
        end
    end
    
endmodule

module display_testbench ();
    logic clk, reset;
    logic [14:0][7:0] current_board;
    logic [15:0][15:0] RedPixels; // 16 x 16 array representing red LEDs on LED Matrix
	logic [15:0][15:0] GrnPixels; // 16 x 16 array representing green LEDs on LED Matrix

    display dut (.clk, .reset, .current_board, .GrnPixels, .RedPixels);

    // Set up a simulated clock.
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        // Forever toggle the clock
        forever #(CLOCK_PERIOD/2) clk <= ~clk; 
    end

    initial begin
        reset <= 0; current_board <= 0; RedPixels <= 0; GrnPixels <=0; @(posedge clk); // Initialize variables
        reset <= 1; @(posedge clk); // Always reset FSMs at start
        reset <= 0; @(posedge clk); 
        current_board[2:0] <= 17; @(posedge clk); 
        current_board[4:3] <= 19; @(posedge clk); // Boarder initialized
        repeat (5)@(posedge clk);
        $stop; // End the simulation.
    end

endmodule