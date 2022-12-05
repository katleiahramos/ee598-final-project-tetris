module button_detection (clk, reset, b, out);
  input logic clk, reset, b;
  output logic out;

  logic ps, ns;

  assign out = ~ps & b;
  assign ns = b;
  
  // DFFs
  always_ff @(posedge clk) begin
    if (reset)
      ps <= 0;
    else
      ps <= ns;
  end
endmodule

module button_detection_testbench();
  logic clk, reset, w;
  logic out;
  button_detection dut (.clk, .reset, .b(w), .out);
  // Set up a simulated clock.
  parameter CLOCK_PERIOD=100;
  initial begin
    clk <= 0;
    //Forever toggle the  clock
    forever #(CLOCK_PERIOD/2) clk <= ~clk;  
  end
  // Set up the inputs to the design. Each line is a clock cycle.
  initial begin
                @(posedge clk);
    reset <= 1; @(posedge clk); // Always reset FSMs at start
    reset <= 0; w <= 0; @(posedge clk);
                @(posedge clk);
                @(posedge clk);
                @(posedge clk);
    w <= 1; @(posedge clk);
    w <= 0; @(posedge clk);
    w <= 1; @(posedge clk);
                @(posedge clk);
                @(posedge clk);
                @(posedge clk);
    w <= 0; @(posedge clk);
                @(posedge clk);
    $stop; // End the simulation.
  end
endmodule

