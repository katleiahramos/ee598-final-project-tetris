onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DE1_SoC_testbench/dut/clkSelect
add wave -noupdate /DE1_SoC_testbench/dut/BoardCanvas
add wave -noupdate /DE1_SoC_testbench/dut/ShapeCanvas
add wave -noupdate /DE1_SoC_testbench/dut/current_shape
add wave -noupdate -expand /DE1_SoC_testbench/dut/random_shape
add wave -noupdate /DE1_SoC_testbench/dut/reset
add wave -noupdate /DE1_SoC_testbench/dut/y_counter
add wave -noupdate /DE1_SoC_testbench/dut/random_shape_addr
add wave -noupdate /DE1_SoC_testbench/dut/GrnPixels
add wave -noupdate /DE1_SoC_testbench/dut/counter
add wave -noupdate -expand /DE1_SoC_testbench/dut/RedPixels
add wave -noupdate /DE1_SoC_testbench/dut/start
add wave -noupdate {/DE1_SoC_testbench/KEY[3]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1319 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 268
configure wave -valuecolwidth 142
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {5513 ps}
