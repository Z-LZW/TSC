`ifndef MEM_IF_GUARD
`define MEM_IF_GUARD

interface#(AW=16,DW=8) mem_interface(input clk,rst_n);

  logic          ce   ;
  logic          we   ;
  logic [AW-1:0] addr ;
  logic [DW-1:0] wdata;
  logic [DW-1:0] rdata;

  clocking cb @(posedge clk);
    input  ce   ;
    input  we   ;
    input  addr ;
    input  wdata;
    output rdata;
  endclocking

  clocking mcb @(posedge clk);
    input ce   ;
    input we   ;
    input addr ;
    input wdata;
    input rdata;
  endclocking

//TBD assertions

  property not_unknown(signal,dsbl);
    @(posedge clk) disable iff (dsbl)
      !$isunknown(signal);
  endproperty

  property not_unknown_next(signal,condition,dsbl);
    @(posedge clk) disable iff (dsbl)
      (condition) |=> !$isunknown(signal);
  endproperty

  ce_not_unknown:    assert property(not_unknown(ce,~rst_n))                 else $fatal("ce must not be X or Z while reset is not asserted"              );
  we_not_unknown:    assert property(not_unknown(we,~(ce & rst_n)))          else $fatal("we must not be X or Z while ce is asserted"                     );
  addr_not_unknown:  assert property(not_unknown(addr,~(ce & rst_n)))        else $fatal("addr must not be X or Z while ce is asserted"                   );
  wdata_not_unknown: assert property(not_unknown(wdata,~(ce & we & rst_n)))  else $fatal("wdata must not be X or Z while a write transaction is requested");
  rdata_not_unknown: assert property(not_unknown_next(rdata,(ce&we),~rst_n)) else $fatal("rdata must not be unknown a cycle after a read request"         );

endinterface

`endif