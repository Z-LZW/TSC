`ifndef APB_IF_GUARD
`define APB_IF_GUARD

interface apb_interface#(AW=6,DW=32)(input pclk,preset_n);

  logic          psel   ;
  logic          penable;
  logic [AW-1:0] paddr  ;
  logic          pwrite ;
  logic [DW-1:0] pwdata ;
  logic [DW-1:0] prdata ;
  logic          pready ;
  logic          pslverr;

  clocking cb @(posedge pclk);
    input  psel   ;
    input  penable;
    input  paddr  ;
    input  pwrite ;
    input  pwdata ;
    output prdata ;
    output pready ;
    output pslverr;
  endclocking

  clocking mcb @(posedge pclk);
    input  psel   ;
    input  penable;
    input  paddr  ;
    input  pwrite ;
    input  pwdata ;
    input  prdata ;
    input  pready ;
    input  pslverr;
  endclocking
  
//TBD assertions

endinterface

`endif