// Handles what is displayed on the board
module board (clk, game_clk_count, reset, current_board, random_shape, L_pressed, R_pressed, GrnPixels );
    input clk, reset, L_pressed, R_pressed;
    input int game_clk_count;
    input logic [3:0][7:0] random_shape;
    input logic [15:0][15:0]GrnPixels; 

    output logic [14:0][7:0] current_board; // What should be displayed to user


    logic [19:0][7:0] ShapeCanvas; // 20 x 16 array representing only the current shape LEDs ( holds incoming shape)
    logic [19:0][7:0] BoardCanvas; // 20 x 16 array representing the existing shape's on the board LEDs

    int counter;
	int y_counter; // to keep track of row current shape is in
    always_ff @(posedge clk) begin
        counter <= counter + 1; // Count every clock cycle, used to determine the game clock cycle

        if (reset) begin 
            // Initialize counters
            counter <= 0;
            y_counter <=0;

            // Load initial shape 
            ShapeCanvas[00][7:0] <= random_shape[03];
            ShapeCanvas[01][7:0] <= random_shape[02];
            ShapeCanvas[02][7:0] <= random_shape[01];
			ShapeCanvas[03][7:0] <= random_shape[00];
            ShapeCanvas[19:4] <= 0; // Fill rest of the Shape board

            // Clear board canvas
            BoardCanvas <= 0;

            // Set current board
            current_board <= 0; 
        end else begin
            
            if(L_pressed) begin // Check if we've reached the boundary of the board
                if(ShapeCanvas[y_counter + 3][7] == 0 )begin
                    ShapeCanvas <= ShapeCanvas << 1;
                end
            end 

            if(R_pressed) begin // Check if we've reached the boundary of the board
                if(ShapeCanvas[y_counter + 3][0] == 0) begin
                    ShapeCanvas <= ShapeCanvas >> 1;
                end
            end 

            if (counter == game_clk_count) begin
                counter <= 0;
                y_counter <= y_counter + 1;

                if ((BoardCanvas[y_counter + 4] & ShapeCanvas[y_counter + 3] ) | y_counter == 15) begin
                    // check if any rows are full, if so clear them, and then shift rows down

                    // add current piece to board canvas
                    BoardCanvas[19:4] <= BoardCanvas[19:4] | ShapeCanvas[19:4] ;
                    // assign a new current piece
                    y_counter <= 0;

                    ShapeCanvas[00][7:0] <= random_shape[03];
                    ShapeCanvas[01][7:0] <= random_shape[02];
                    ShapeCanvas[02][7:0] <= random_shape[01];
                    ShapeCanvas[03][7:0] <= random_shape[00];
                    ShapeCanvas[19:4] <= 0; // Fill rest of the Shape board
                end else begin
                    // Set current board
                    $display("IN ELSE");
                    ShapeCanvas <= ShapeCanvas << 8 ;
                end
            end

         current_board <= ShapeCanvas[18:4] | BoardCanvas[18:4]; // Continously sync current_board
        end 
    end
endmodule


module board_testbench();
    logic clk, reset, L_pressed, R_pressed;
    logic [3:0][7:0] random_shape;
    logic [14:0][7:0] current_board;
    int game_clk_count;
    logic [15:0][15:0]GrnPixels; 

    assign GrnPixels[00] = 16'b0000010000000010;
    assign GrnPixels[01] = 16'b0000010000000010;
    assign GrnPixels[02] = 16'b0000010000000010;
    assign GrnPixels[03] = 16'b0000010000000010;
    assign GrnPixels[04] = 16'b0000010000000010;
    assign GrnPixels[05] = 16'b0000010000000010;
    assign GrnPixels[06] = 16'b0000010000000010;
    assign GrnPixels[07] = 16'b0000010000000010;
    assign GrnPixels[08] = 16'b0000010000000010;
    assign GrnPixels[09] = 16'b0000010000000010;
    assign GrnPixels[10] = 16'b0000010000000010;
    assign GrnPixels[11] = 16'b0000010000000010;
    assign GrnPixels[12] = 16'b0000010000000010;
    assign GrnPixels[13] = 16'b0000010000000010;
    assign GrnPixels[14] = 16'b0000010000000010;
    assign GrnPixels[15] = 16'b0000011111111110;

    board dut (.clk, .game_clk_count, .reset, .current_board, .random_shape, .L_pressed, .R_pressed, .GrnPixels);

      // Set up a simulated clock.
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        // Forever toggle the clock
        forever #(CLOCK_PERIOD/2) clk <= ~clk; 
    end

    initial begin
        reset <= 0;
        L_pressed <= 0;
         R_pressed <= 0;
         game_clk_count<= 5;
         random_shape <= {
                // SQAURE
                8'b00000000,
                8'b00000000,
                8'b00011000,
                8'b00011000
            }; @(posedge clk); // Initialize variables
        reset <= 1; @(posedge clk); // Always reset FSMs at start
        reset <= 0; @(posedge clk); 
        repeat (5)@(posedge clk);
        L_pressed <= 1; @(posedge clk); 
        L_pressed <= 0; @(posedge clk); 
        L_pressed <= 1; @(posedge clk); 
        L_pressed <= 0; @(posedge clk); 
        L_pressed <= 1; @(posedge clk); 
        L_pressed <= 0; @(posedge clk); 
                L_pressed <= 1; @(posedge clk); 
        L_pressed <= 0; @(posedge clk); 
        repeat (50)@(posedge clk);
        $stop; // End the simulation.
    end

endmodule