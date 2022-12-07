/*
* return 4 rows corresponding to 4 rows of LEDs
*/
module generate_shape (
    shape_addr,
    shape
);
    input logic [1:0] shape_addr;
    output logic [3:0][7:0] shape;

    always_comb begin
        case(shape_addr)
            2'b00: shape = { 
                // SQAURE
                8'b00000000,
                8'b00000000,
                8'b00011000,
                8'b00011000
            };
            2'b01: shape = { 
                // LINE
                8'b00010000,
                8'b00010000,
                8'b00010000,
                8'b00010000
            };
            2'b10: shape = { 
                // EMPTY
                8'b00000000,
                8'b00110000,
                8'b00010000,
                8'b00010000
            };
            2'b11: shape = {
                // EMPTY
                8'b00000000,
                8'b00000000,
                8'b00001000,
                8'b000111000
            };
            default: shape = {
                // EMPTY
                8'b00000000,
                8'b00000000,
                8'b00000000,
                8'b00001111
            };
        endcase
    end
    
endmodule

module generate_shape_testbench ();
    logic [1:0] shape_addr;
    logic [3:0][7:0] shape ;

    generate_shape dut (
        .shape_addr,
        .shape
    );

    // Set up a simulated clock.
    // parameter CLOCK_PERIOD=100;
    // initial begin
    //     clk <= 0;
    //     // Forever toggle the clock
    //     forever #(CLOCK_PERIOD/2) clk <= ~clk; 
    // end

    initial begin
        shape_addr = 2'b00; #15;	
        shape_addr = 2'b01; #15;	
        shape_addr = 2'b10; #15;	
        shape_addr = 2'b11; #15;	
    end
endmodule