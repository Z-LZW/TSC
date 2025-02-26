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

endinterface

`endif