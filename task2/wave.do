onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Yellow /testbench/Accelerator/clk
add wave -noupdate /testbench/Accelerator/acc_state
add wave -noupdate /testbench/Accelerator/next_acc_state
add wave -noupdate -group IDLE /testbench/Accelerator/start
add wave -noupdate -group IDLE /testbench/Accelerator/en
add wave -noupdate -expand -group INIT /testbench/Accelerator/next_img_shift_up_cntr
add wave -noupdate -expand -group INIT /testbench/Accelerator/img_shift_up_en
add wave -noupdate -expand -group INIT /testbench/Accelerator/img_shift_in_cntr
add wave -noupdate -expand -group INIT /testbench/Accelerator/img_shift_up_cntr
add wave -noupdate -group INIT_SHIFT_IN /testbench/Accelerator/pixel_in
add wave -noupdate -group INIT_SHIFT_IN /testbench/Accelerator/next_img_shift_in_cntr
add wave -noupdate -group INIT_SHIFT_IN /testbench/Accelerator/img_shift_in_en
add wave -noupdate -group INIT_SHIFT_IN /testbench/Accelerator/img_shift_in_cntr
add wave -noupdate -expand /testbench/Accelerator/img_calc_buf
add wave -noupdate /testbench/Accelerator/we_intl
add wave -noupdate -radix unsigned /testbench/Accelerator/read_ptr
add wave -noupdate -radix unsigned /testbench/Accelerator/write_ptr
add wave -noupdate /testbench/Accelerator/we
add wave -noupdate /testbench/Accelerator/dataW
add wave -noupdate /testbench/Memory/dataR
add wave -noupdate /testbench/Accelerator/img_result_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22160000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 202
configure wave -valuecolwidth 250
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
WaveRestoreZoom {20735999 ps} {29104171 ps}
