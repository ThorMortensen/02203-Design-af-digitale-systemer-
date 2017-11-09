onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /testbench/Accelerator/clk
add wave -noupdate /testbench/Accelerator/acc_state
add wave -noupdate /testbench/Accelerator/next_acc_state
add wave -noupdate -expand -group IDLE /testbench/Accelerator/start
add wave -noupdate -expand -group IDLE /testbench/Accelerator/en
add wave -noupdate -expand -group INIT /testbench/Accelerator/next_img_shift_up_cntr
add wave -noupdate -expand -group INIT /testbench/Accelerator/img_shift_up_en
add wave -noupdate -expand -group INIT /testbench/Accelerator/img_shift_in_cntr
add wave -noupdate -expand -group INIT /testbench/Accelerator/img_shift_up_cntr
add wave -noupdate -group INIT_SHIFT_IN /testbench/Accelerator/pixel_in
add wave -noupdate -group INIT_SHIFT_IN /testbench/Accelerator/next_img_shift_in_cntr
add wave -noupdate -group INIT_SHIFT_IN /testbench/Accelerator/img_shift_in_en
add wave -noupdate -group INIT_SHIFT_IN /testbench/Accelerator/img_shift_in_cntr
add wave -noupdate -radix hexadecimal -childformat {{/testbench/Accelerator/img_calc_buf(0) -radix hexadecimal} {/testbench/Accelerator/img_calc_buf(1) -radix hexadecimal} {/testbench/Accelerator/img_calc_buf(2) -radix hexadecimal}} -expand -subitemconfig {/testbench/Accelerator/img_calc_buf(0) {-height 17 -radix hexadecimal} /testbench/Accelerator/img_calc_buf(1) {-height 17 -radix hexadecimal} /testbench/Accelerator/img_calc_buf(2) {-height 17 -radix hexadecimal}} /testbench/Accelerator/img_calc_buf
add wave -noupdate /testbench/Accelerator/we_intl
add wave -noupdate -radix unsigned -childformat {{/testbench/Accelerator/read_ptr(15) -radix unsigned} {/testbench/Accelerator/read_ptr(14) -radix unsigned} {/testbench/Accelerator/read_ptr(13) -radix unsigned} {/testbench/Accelerator/read_ptr(12) -radix unsigned} {/testbench/Accelerator/read_ptr(11) -radix unsigned} {/testbench/Accelerator/read_ptr(10) -radix unsigned} {/testbench/Accelerator/read_ptr(9) -radix unsigned} {/testbench/Accelerator/read_ptr(8) -radix unsigned} {/testbench/Accelerator/read_ptr(7) -radix unsigned} {/testbench/Accelerator/read_ptr(6) -radix unsigned} {/testbench/Accelerator/read_ptr(5) -radix unsigned} {/testbench/Accelerator/read_ptr(4) -radix unsigned} {/testbench/Accelerator/read_ptr(3) -radix unsigned} {/testbench/Accelerator/read_ptr(2) -radix unsigned} {/testbench/Accelerator/read_ptr(1) -radix unsigned} {/testbench/Accelerator/read_ptr(0) -radix unsigned}} -subitemconfig {/testbench/Accelerator/read_ptr(15) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(14) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(13) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(12) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(11) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(10) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(9) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(8) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(7) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(6) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(5) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(4) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(3) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(2) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(1) {-height 17 -radix unsigned} /testbench/Accelerator/read_ptr(0) {-height 17 -radix unsigned}} /testbench/Accelerator/read_ptr
add wave -noupdate -radix unsigned /testbench/Accelerator/write_ptr
add wave -noupdate /testbench/Accelerator/we
add wave -noupdate /testbench/Accelerator/dataW
add wave -noupdate -radix hexadecimal /testbench/Memory/dataR
add wave -noupdate -radix hexadecimal /testbench/Accelerator/img_result_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40522122 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 202
configure wave -valuecolwidth 136
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
WaveRestoreZoom {40487182 ps} {42443833 ps}
