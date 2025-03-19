module divider#(
parameter DW = 8
) (

//System
input               clk   , //cead
input               rst_n , //reset active low

//Cale de date
input      [DW-1:0] op1   , //operand 1
input      [DW-1:0] op2   , //operand 2
output reg [DW-1:0] cat   , //rezultat
output reg [DW-1:0] rest  , //rezultat

//Control
input               start , //pulse de pornire 
output reg          done    //pulse de terminare
);

reg [DW  :0] P;
reg [DW-1:0] A;
reg [DW-1:0] B;

reg idle;

reg [$clog2(DW):0] counter;

wire [DW  :0] p_shifted;
wire [DW-1:0] a_shifted;
wire [DW  :0] p_next   ;

assign p_shifted = {P[DW-1:0],A[DW-1]       };
assign a_shifted = {A[DW-2:0],~p_shifted[DW]};
assign p_next    = p_shifted[DW] ? p_shifted + B : p_shifted - B;

always @(posedge clk or negedge rst_n)
if (~rst_n)    idle <= 1; else
if (start)     idle <= 0; else
if (~|counter) idle <= 1;

always @(posedge clk or negedge rst_n)
if (~rst_n)   counter <= DW         ; else
if (start)    counter <= DW         ; else
if (|counter) counter <= counter - 1;

always @(posedge clk or negedge rst_n)
if (~rst_n) B <= 0  ; else
if (start)  B <= op2;

always @(posedge clk or negedge rst_n)
if (~rst_n)   A <= 0        ; else
if (start)    A <= op1      ; else
if (|counter) A <= a_shifted;

always @(posedge clk or negedge rst_n)
if (~rst_n) P <= 0            ; else
if (start)  P <= 0            ; else
            P <= p_next       ;

always @(posedge clk or negedge rst_n)
if (~rst_n)             done <= 0; else
if (counter==0 & ~idle) done <= 1; else
                        done <= 0;

always @(posedge clk or negedge rst_n)
if (~rst_n)            rest <= 0    ; else
if (counter==0 & ~idle)
  if (P[DW])           rest <= P + B; else
                       rest <= P    ;

always @(posedge clk or negedge rst_n)
if (~rst_n)             cat <= 0        ; else
if (counter==0 & ~idle) cat <= a_shifted;

endmodule