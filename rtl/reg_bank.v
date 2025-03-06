module reg_bank(

// System

input                  pclk         ,
input                  preset_n     ,

//APB interface

input                  psel         ,
input                  penable      ,
input                  pwrite       ,
input       [3:0]      paddr        ,
input      [WIDTH-1:0] pwdata       , 
output reg [WIDTH-1:0] prdata       ,
output reg             pready       ,
output reg             pslverr      ,    //slave error

//Registers

output reg [16-1:0]    op1_ba        ,
output reg [16-1:0]    op2_ba        ,
output reg [16-1:0]    ba_rez        ,
output reg [ 4-1:0]    no_op         ,
output reg [ 4-1:0]    op_code       ,
output reg [ 3-1:0]    ctrl          ,
input      [ 5-1:0]    status        ,
output reg [ 3-1:0]    irq           ,
output reg [ 3-1:0]    irq_mask      
);


wire apb_activ = psel & penable & pready;

always@(posedge pclk or negedge preset_n)
if(~preset_n)                              pslverr <= 0           ; else
if(apb_activ)                              pslverr <= 0           ; else
if(psel & (paddr > 6'h20 | paddr[1:0] ))   pslverr <= 1           ; 
  
  
always@(posedge pclk or negedge preset_n) 
if(~preset_n)                              op1_ba <= 0            ; else
if(psel & pwrite & paddr == 6'h0)          op1_ba <= pwdata[15:0] ;
  
  
always@(posedge pclk or negedge preset_n) 
if(~preset_n)                              op2_ba <= 0            ; else
if(psel & pwrite & paddr == 6'h4)          op2_ba <= pwdata[15:0] ;
  
  
always@(posedge pclk or negedge preset_n) 
if(~preset_n)                              ba_rez <= 0            ; else
if(psel & pwrite & paddr == 6'h8)          ba_rez <= pwdata[15:0] ;
  
  
always@(posedge pclk or negedge preset_n) 
if(~preset_n)                              no_op <= 0             ;  else
if(psel & pwrite & paddr == 6'hc)          no_op <= pwdata[3:0]   ; 


always@(posedge pclk or negedge preset_n)
if(~preset_n)                              op_code <= 0           ; else
if(psel & pwrite & paddr == 6'h10)         p_code <= pwdata[3:0] ;


always@(posedge pclk or negedge preset_n)
if(~preset_n)                              ctrl <= 0              ; else
if(|ctrl)                                  ctrl <= 0              ; else
if(psel & pwrite & paddr == 6'h14)         ctrl <= pwdata[2:0]    ; 


always@(posedge pclk or negedge preset_n)
if(~preset_n)                              irq_mask <= 0          ; else
if(psel & pwrite & paddr == 6'h18)         irq_mask <= pwdata[2:0];

endmodule