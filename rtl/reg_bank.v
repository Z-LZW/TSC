module reg_bank(

// System
input               pclk    , //system clock
input               preset_n, //asynchronous reset, active low

//APB interface
input               psel    , //select, indicates that the device is selected
input               penable , //enable, indicates the acces phase of the transaction
input               pwrite  , //operation type [1 -> write | 0 -> read]
input      [ 6-1:0] paddr   , //address
input      [32-1:0] pwdata  , //write data
output reg [32-1:0] prdata  , //read data
output reg          pready  , //ready, indicates the slave response
output reg          pslverr , //slave error, 0 -> trans ok | 1 -> ERR

//Registers
output reg [16-1:0] op1_ba  , //base address of opperand one
output reg [16-1:0] op2_ba  , //base address of opperand two
output reg [16-1:0] ba_rez  , //base address of result
output reg [ 4-1:0] no_op   , //number of opperations
output reg [ 4-1:0] op_code , //operation code
output reg [ 3-1:0] ctrl    , //control
input      [ 5-1:0] status  , //status
input      [ 3-1:0] irq     , //interrupt vector
output reg [ 3-1:0] irq_mask  //interrupt mask
);

//internal wires for somplicity
wire apb_active ;
wire error_rsp  ;

assign apb_active  =  psel & penable & pready;

assign error_rsp   = (psel & (paddr > 6'h20 | (|paddr[1:0])));

//-----------------------------WRRITING IN REGISTERS----------------------------//

//op_1 base address
always @(posedge pclk or negedge preset_n)
if (~preset_n)                                        op1_ba <= 16'h0       ; else
if (apb_active & ~status[0] & pwrite & paddr == 6'h0) op1_ba <= pwdata[15:0];

//op_2 base address
always @(posedge pclk or negedge preset_n)
if (~preset_n)                                        op2_ba <= 16'h0       ; else
if (apb_active & ~status[0] & pwrite & paddr == 6'h4) op2_ba <= pwdata[15:0];

//result base address 
always @(posedge pclk or negedge preset_n)
if (~preset_n)                                        ba_rez <= 16'h0       ; else
if (apb_active & ~status[0] & pwrite & paddr == 6'h8) ba_rez <= pwdata[15:0];

//number of opperations
always @(posedge pclk or negedge preset_n)
if (~preset_n)                                        no_op <= 4'h0       ;  else
if (apb_active & ~status[0] & pwrite & paddr == 6'hc) no_op <= pwdata[3:0]; 

//operation code
always @(posedge pclk or negedge preset_n)
if (~preset_n)                                         op_code <= 4'h0       ; else
if (apb_active & ~status[0] & pwrite & paddr == 6'h10) op_code <= pwdata[3:0];

//control
always @(posedge pclk or negedge preset_n)
if (~preset_n)                            ctrl <= 3'h0       ; else
if (|ctrl)                                ctrl <= 3'h0       ; else
if (apb_active & pwrite & paddr == 6'h14) ctrl <= pwdata[2:0]; 

//interrupt mask
always @(posedge pclk or negedge preset_n)
if (~preset_n)                            irq_mask <= 3'h0       ; else
if (apb_active & pwrite & paddr == 6'h18) irq_mask <= pwdata[2:0];


//-----------------------------READING FROM REGISTERS----------------------------//

always @(posedge pclk or negedge preset_n)
if (~preset_n)      prdata <= 0; else
if (psel & ~pwrite)
  case (paddr)
  'h00 : prdata <= op1_ba  ;
  'h04 : prdata <= op2_ba  ;
  'h08 : prdata <= ba_rez  ;
  'h0c : prdata <= no_op   ;
  'h10 : prdata <= op_code ;
  'h14 : prdata <= ctrl    ;
  'h18 : prdata <= status  ;
  'h1c : prdata <= irq     ;
  'h20 : prdata <= irq_mask;
  endcase

//-------------------------------------CONTROL------------------------------------//

//managing the rady signal
always @(posedge pclk or negedge preset_n)
if (~preset_n)  pready <= 0          ; else
if (apb_active) pready <= 0          ; else
                pready <= psel       ;

//manage slave error
always @(posedge pclk or negedge preset_n)
if (~preset_n)  pslverr <= 1'b0; else
if (apb_active) pslverr <= 1'b0; else
if (error_rsp)  pslverr <= 1'b1;

endmodule