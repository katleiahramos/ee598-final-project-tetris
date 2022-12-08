onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /board_testbench/clk
add wave -noupdate /board_testbench/dut/y_counter
add wave -noupdate /board_testbench/current_board
add wave -noupdate /board_testbench/random_shape
add wave -noupdate /board_testbench/dut/counter
add wave -noupdate /board_testbench/reset
add wave -noupdate -expand /board_testbench/dut/ShapeCanvas
add wave -noupdate -expand /board_testbench/dut/BoardCanvas
add wave -noupdate /board_testbench/GrnPixels
add wave -noupdate /board_testbench/L_pressed
add wave -noupdate /board_testbench/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {934 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 230
configure wave -valuecolwidth 129
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
WaveRestoreZoom {0 ps} {6248 ps}
