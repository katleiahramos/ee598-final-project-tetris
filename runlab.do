# Create work library
vlib work
# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./DE1_SoC.sv"
vlog "./binary_search.sv"
vlog "./ram32x8_2.v"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.

#vsim -voptargs="+acc" -t 1ps -lib work DE1_SoC_testbench
vsim -voptargs="+acc" -t 1ps -lib work binary_search_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
#do DE1_SoC_wave.do
do binary_search_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
