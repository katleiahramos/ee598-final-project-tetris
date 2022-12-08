onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand /display_testbench/current_board
add wave -noupdate /display_testbench/GrnPixels
add wave -noupdate -expand /display_testbench/RedPixels
add wave -noupdate /display_testbench/clk
add wave -noupdate /display_testbench/reset
add wave -noupdate /display_testbench/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {99 ps} 0}
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
WaveRestoreZoom {0 ps} {473 ps}
