module alu(
input              clk      ,          // Semnal de ceas
input              rst_n    ,          // Semnal de reset activ pe nivel scazut
                                       
input      [4-1:0] op_code  ,          // Codul operatiei (16 operatii posibile)
input      [8-1:0] op0      ,          // Primul operand (8 biti)
input      [8-1:0] op1      ,          // Al doilea operand (8 biti)
output reg [8-1:0] rez      ,          // Rezultatul operatiei (8 biti)
                                       
input              start_alu,          // Semnal de start pentru ALU
output reg         done_alu ,          // Semnal care indica finalizarea operatiei ALU
                                       
output             start_mul,          // Semnal de start pentru modulul de inmultire
input              done_mul ,          // Semnal care indica finalizarea inmultirii
                                       
output             start_div,          // Semnal de start pentru modulul de impartire
input              done_div            // Semnal care indica finalizarea impartirii
);


// Semnale pentru rezultatele operatiilor de inmultire și impartire
wire [8-1:0] rez_mul;
wire [8-1:0] rez_div;


// Selectarea operatiei si calculul rezultatului
always @(posedge clk or negedge rst_n)
if (~rst_n) rez <= 0; else
case(op_code)
  'h0 : rez <=  (op0  + op1)                     ;
  'h1 : rez <=  (op0  - op1)                     ;
  'h2 : rez <=   rez_mul                         ;
  'h3 : rez <=   rez_div                         ;
  'h4 : rez <=  (op0       )                     ;                     
  'h5 : rez <=  (op0  & op1)                     ;
  'h6 : rez <=  (op0  | op1)                     ;
  'h7 : rez <=  (op0  ^ op1)                     ;
  'h8 : rez <= ~(op0       )                     ;
  'h9 : rez <=  (op0 ~& op1)                     ;
  'ha : rez <=  (op0 ~| op1)                     ;
  'hb : rez <=  (op0 ~^ op1)                     ;
  'hc : rez <=  (op0 << op1)                     ;
  'hd : rez <=  (op0 >> op1)                     ;
  'he : rez <=  (op0 << op1) + ((1   << op1) - 1);
  'hf : rez <=  (op0 << op1) + (('hf << op1)    );
endcase


// Generarea semnalului done_alu
always @(posedge clk or negedge rst_n)
if (~rst_n)       done_alu <= 0        ; else
if (op_code == 2) done_alu <= done_mul ; else
if (op_code == 3) done_alu <= done_div ; else
                  done_alu <= start_alu;


// Generarea semnalelor de start pentru modulele de inmultire si impartire
assign start_mul = (op_code == 2) ? start_alu : 0;
assign start_div = (op_code == 3) ? start_alu : 0;


// Instantierea modulului de inmultire
multiplier i_multiplier(
.clk   (clk      ),
.rst_n (rst_n    ),
.op1   (op0      ),
.op2   (op1      ),
.rez   (rez_mul  ),
.start (start_mul),
.done  (done_mul ),
);


// Instantierea modulului de impartire
divider i_divider(
.clk   (clk      ),
.rst_n (rst_n    ),
.op1   (op0      ),
.op2   (op1      ),
.cat   (rez_div  ),
.start (start_div),
.done  (done_div ),
);

endmodule