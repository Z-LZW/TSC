onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /reg_bank_tb/clk
add wave -noupdate /reg_bank_tb/rst_n
add wave -noupdate /reg_bank_tb/psel
add wave -noupdate /reg_bank_tb/penable
add wave -noupdate /reg_bank_tb/pwrite
add wave -noupdate /reg_bank_tb/paddr
add wave -noupdate /reg_bank_tb/pwdata
add wave -noupdate /reg_bank_tb/prdata
add wave -noupdate /reg_bank_tb/pready
add wave -noupdate /reg_bank_tb/pslverr
add wave -noupdate /reg_bank_tb/op1_ba
add wave -noupdate /reg_bank_tb/op2_ba
add wave -noupdate /reg_bank_tb/ba_rez
add wave -noupdate /reg_bank_tb/no_op
add wave -noupdate /reg_bank_tb/op_code
add wave -noupdate /reg_bank_tb/ctrl
add wave -noupdate /reg_bank_tb/status
add wave -noupdate /reg_bank_tb/irq
add wave -noupdate /reg_bank_tb/irq_mask
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {10452 ps}
