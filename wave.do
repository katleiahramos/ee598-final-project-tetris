onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DE1_SoC_testbench/dut/random_shape
add wave -noupdate /DE1_SoC_testbench/dut/random_shape_addr
add wave -noupdate /DE1_SoC_testbench/dut/clkSelect
add wave -noupdate -expand /DE1_SoC_testbench/dut/RedPixels
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {833 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 268
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {1943 ps}
