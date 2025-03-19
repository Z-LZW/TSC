`ifndef IRQ_IF_GUARD
`define IRQ_IF_GUARD

interface irq_if(input clk, input rst_n);

  logic irq;
  logic ira;

  clocking cb @(posedge clk);
    input  irq;
    output ira;
  endclocking

  clocking mcb @(posedge clk);
    input irq;
    input ira;
  endclocking

//----------------------------ASSERTIONS---------------------------//

  property not_unknown(signal,dsbl);
    @(posedge clk) disable iff(dsbl)
      !$isunknown(signal);
  endproperty

  property fall(signal,condition);
    @(posedge clk) disable iff(~rst_n)
      condition |=> $fell(signal)
  endproperty

  property active_together(signal,condition);
    @(posedge clk) disable iff(~rst_n)
      ~condition |-> ~signal
  endproperty

  irq_known: assert property(not_unknown(irq,~rst_n))  else $fatal("Interrupt request must not be X or Z while reset is not asserted");
  ira_known: assert property(not_unknown(ira,~rst_n))  else $fatal("Interrupt accept must not be X or Z while reset is not asserted");

  irq_fall:  assert property(fall(irq,ira))            else $fatal("Interrupt request must fall after it was accepted");
  not_alone: assert property(active_together(ira,irq)) else $fatal("Interrupt accepted cannot be active without an interrupt request");

endinterface

`endif