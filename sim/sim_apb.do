vlib work
vmap work work

#design
vlog  ../rtl/reg_bank.v

#debug
vlog  ../debug/reg_bank_tb.v


vsim work.reg_bank_tb 

do wave.do
run -all

