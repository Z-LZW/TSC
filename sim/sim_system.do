vlib work
vmap work work

#design
vlog  ../rtl/reg_bank.v
vlog  ../rtl/divider.v
vlog  ../rtl/multiplier.v
vlog  ../rtl/alu.v
vlog  ../rtl/irq_handler.v
vlog  ../rtl/mem_controller.v
vlog  ../rtl/reg_bank.v
vlog  ../rtl/system.v

#debug
vlog  ../debug/system_tb.sv


vsim work.system_tb 

do system_wave.do
#run -all

