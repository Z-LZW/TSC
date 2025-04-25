onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group SYSTEM /system_tb/clk
add wave -noupdate -expand -group SYSTEM /system_tb/rst_n
add wave -noupdate -expand -group APB /system_tb/psel
add wave -noupdate -expand -group APB /system_tb/penable
add wave -noupdate -expand -group APB /system_tb/pwrite
add wave -noupdate -expand -group APB -radix hexadecimal /system_tb/paddr
add wave -noupdate -expand -group APB /system_tb/pwdata
add wave -noupdate -expand -group APB -radix hexadecimal /system_tb/prdata
add wave -noupdate -expand -group APB /system_tb/pready
add wave -noupdate -expand -group APB /system_tb/pslverr
add wave -noupdate -expand -group MEMORY /system_tb/ce
add wave -noupdate -expand -group MEMORY /system_tb/we
add wave -noupdate -expand -group MEMORY -radix hexadecimal /system_tb/addr
add wave -noupdate -expand -group MEMORY -radix unsigned /system_tb/wdata
add wave -noupdate -expand -group MEMORY -radix unsigned /system_tb/rdata
add wave -noupdate -expand -group IRQ /system_tb/irq
add wave -noupdate -expand -group IRQ /system_tb/ira
add wave -noupdate -expand -group REGISTERS -radix hexadecimal /system_tb/DUT/i_reg_bank/op1_ba
add wave -noupdate -expand -group REGISTERS -radix hexadecimal /system_tb/DUT/i_reg_bank/op2_ba
add wave -noupdate -expand -group REGISTERS -radix hexadecimal /system_tb/DUT/i_reg_bank/ba_rez
add wave -noupdate -expand -group REGISTERS -radix unsigned /system_tb/DUT/i_reg_bank/no_op
add wave -noupdate -expand -group REGISTERS /system_tb/DUT/i_reg_bank/op_code
add wave -noupdate -expand -group REGISTERS -radix binary /system_tb/DUT/i_reg_bank/ctrl
add wave -noupdate -expand -group REGISTERS /system_tb/DUT/i_reg_bank/status
add wave -noupdate -expand -group REGISTERS /system_tb/DUT/i_reg_bank/irq
add wave -noupdate -expand -group REGISTERS /system_tb/DUT/i_reg_bank/irq_mask
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {269 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {595 ps}
