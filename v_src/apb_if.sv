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
  
//----------------------------ASSERTIONS---------------------------//

  property not_unknown(signal,dsbl);
    @(posedge pclk) disable iff(dsbl)
      !$isunknown(signal);
  endproperty

  property stable(signal,condition,dsbl);
    @(posedge pclk) disable iff(dsbl | (~preset_n))
      (condition) |=> $stable(signal);
  endproperty

  property rise_next_cycle(signal,condition)
    @(posedge pclk) disable iff (~preset_n)
      $rose(condition) |=> $rose(signal);
  endproperty

  property fall(signal,condition);
    @(posedge pclk) disable iff (~preset_n)
      (condition) |=> $fell(signal);
  endproperty

  property active_together(signal,condition)
    @(posedge pclk) disable iff (~preset_n)
      (~condition) |-> (~signal);
  endproperty

  property rise_delay(signal,condition)
    @(posedge pclk) disable iff (~preset_n)
      $rose(condition) |-> (~signal)
  endproperty

  //control signals known
  psel_known:    assert property (not_unknown(psel   ,~preset_n)) else $error("PSEL must not be unknown while reset is not asserted"   );
  penable_known: assert property (not_unknown(penable,~preset_n)) else $error("PENABLE must not be unknown while reset is not asserted");
  pwrite_known:  assert property (not_unknown(pwrite ,~preset_n)) else $error("PWRITE must not be unknown while reset is not asserted" );
  pready_known:  assert property (not_unknown(pready ,~preset_n)) else $error("PREADY must not be unknown while reset is not asserted" );

  //bus signals known
  paddr_known:   assert property (not_unknown(paddr,(~preset_n   | ~psel)))               else $error("PADDR must not be unknown while PSEL is active"                           );
  prdata_known:  assert property (not_unknown(prdata,(~preset_n  | ~(pready & ~pwrite)))) else $error("PRDATA must not be unknown while in read transaction and PREADY is active");
  pwdata_known:  assert property (not_unknown(pwdata,(~preset_n  | ~(psel & pwrite))))    else $error("PWDATA must not be unknown while in write transaction and PSEL is active" );
  pslverr_knwon: assert property (not_unknown(pslverr,(~preset_n | ~pready)))             else $error("PSLVERR must not be unknown while PREADY is active"                       ); 

  //bus is stable
  paddr_stable:  assert property (stable(paddr,psel,pready))             else $error("PADDR must be stable while PSEL is active"             );
  pwdata_stable: assert property (stable(pwdata,(psel & pwrite),pready)) else $error("PWDATA must be stable while PSEL and PWRITE are active");

  //protocol specific control
  penable_after_psel:    assert property (rise_next_cycle(penable,psel))         else $error("PENABLE must rise after PSEL rose"                             );
  penable_fall:          assert property (fall(penable,psel & penable & pready)) else $error("PENABLE must fall after a transaction ended"                   );
  penable_and_psel:      assert property (active_together(penable,psel))         else $error("PENABLE must not be active without PSEL"                       );
  rise_psel_not_penable: assert property (rise_delay(penable,psel))              else $error("PENABLE must not be active on the firt tick of the transaction");
  
endinterface

`endif