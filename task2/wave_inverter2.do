onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/Accelerator/clk
add wave -noupdate -expand -group acc /testbench/Accelerator/clk
add wave -noupdate -expand -group acc /testbench/Accelerator/reset
add wave -noupdate -expand -group acc /testbench/Accelerator/addr
add wave -noupdate -expand -group acc -radix hexadecimal /testbench/Accelerator/dataR
add wave -noupdate -expand -group acc -radix hexadecimal /testbench/Accelerator/dataW
add wave -noupdate -expand -group acc /testbench/Accelerator/en
add wave -noupdate -expand -group acc /testbench/Accelerator/we
add wave -noupdate -expand -group acc /testbench/Accelerator/start
add wave -noupdate -expand -group acc /testbench/Accelerator/finish
add wave -noupdate -expand -group acc /testbench/Accelerator/acc_state
add wave -noupdate -expand -group acc /testbench/Accelerator/acc_next_state
add wave -noupdate -expand -group acc -radix unsigned /testbench/Accelerator/write_ptr
add wave -noupdate -expand -group acc -radix unsigned /testbench/Accelerator/next_write_ptr
add wave -noupdate -expand -group acc -radix unsigned /testbench/Accelerator/read_ptr
add wave -noupdate -expand -group acc -radix unsigned /testbench/Accelerator/next_read_ptr
add wave -noupdate -expand -group acc -radix hexadecimal /testbench/Accelerator/pixel_out
add wave -noupdate -expand -group acc -radix hexadecimal /testbench/Accelerator/next_pixel_out
add wave -noupdate -expand -group acc -radix hexadecimal /testbench/Accelerator/next_pixel_in
add wave -noupdate /testbench/Memory/en
add wave -noupdate /testbench/Memory/we
add wave -noupdate -radix decimal /testbench/Memory/addr
add wave -noupdate -radix hexadecimal /testbench/Memory/dataW
add wave -noupdate -radix hexadecimal /testbench/Memory/dataR
add wave -noupdate /testbench/Memory/dump_image
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {687026 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 139
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {502440 ps} {870279 ps}
