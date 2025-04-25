module multiplier (
//system
input              clk  ,
input              rst_n,

//operands
input      [8-1:0] op1  ,
input      [8-1:0] op2  ,
output reg [8-1:0] rez  ,

//control
input              start,
output reg         done

);

reg [16-1:0] P;
reg [ 8-1:0] A;
reg [ 8-1:0] B;
reg [ 3-1:0] counter;

reg idle;

always @(posedge clk or negedge rst_n)
if (~rst_n)    idle <= 1; else
if (start)     idle <= 0; else
if (~|counter) idle <= 1;

always @(posedge clk or negedge rst_n)
if (~rst_n) counter <= 7          ; else
if (~idle)  counter <= counter - 1;

always @(posedge clk or negedge rst_n)
if (~rst_n) done <= 0        ; else
            done <= ~|counter;

always @(posedge clk or negedge rst_n)
if (~rst_n) B <= 0  ; else
if (start)  B <= op2;

always @(posedge clk or negedge rst_n)
if (~rst_n) A <= 0  ; else
if (start)  A <= op1;

always @(posedge clk or negedge rst_n)
if (~rst_n) P <= 0                               ; else
if (~idle)  P <= A[counter] ? (P<<1) + B : (P<<1);

always @(posedge clk or negedge rst_n)
if (~rst_n)    rez <= 0                               ; else
if (~|counter) rez <= A[counter] ? (P<<1) + B : (P<<1);

endmodule