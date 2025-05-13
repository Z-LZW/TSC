module multiplier (
//system
input              clk  ,  // Semnal de ceas
input              rst_n,  // Semnal de reset activ pe front scazator
                          
//operands                
input      [8-1:0] op1  ,  // Primul operand (multiplicand)
input      [8-1:0] op2  ,  // Al doilea operand (multiplicator)
output reg [8-1:0] rez  ,  // Rezultatul inmultirii
                          
//control                 
input              start,  // Semnal pentru inceperea operaiiei
output reg         done    // Semnal care indica finalizarea operatiei

);

// Registre interne pentru algoritmul de inmultire
reg [16-1:0] P;        // Registru pentru acumularea rezultatului partial (16 biti pentru a stoca rezultatul complet)
reg [ 8-1:0] A;        // Registru pentru stocarea multiplicandului
reg [ 8-1:0] B;        // Registru pentru stocarea multiplicatorului
reg [ 3-1:0] counter;  // Contor pentru iteratii (proceseaza cei 8 biti ai multiplicandului)
                      
reg idle;              // Flag care indica starea de inactivitate a modulului


// Gestionarea starii idle - controleaza cand modulul este activ sau inactiv
always @(posedge clk or negedge rst_n)
if (~rst_n)    idle <= 1; else         
if (start)     idle <= 0; else         
if (~|counter) idle <= 1;              


// Gestionarea contorului de biti - numara bitii procesati
always @(posedge clk or negedge rst_n)
if (~rst_n) counter <= 7          ; else
if (~idle)  counter <= counter - 1; else


// Generarea semnalului done - indica finalizarea operatiei
always @(posedge clk or negedge rst_n)
if (~rst_n) done <= 0        ; else
            done <= ~|counter;


// incarca multiplicatorul in registrul B
always @(posedge clk or negedge rst_n)
if (~rst_n) B <= 0  ; else
if (start)  B <= op2;


// incarca multiplicatorul in registrul A
always @(posedge clk or negedge rst_n)
if (~rst_n) A <= 0  ; else
if (start)  A <= op1;


// Implementarea algoritmului de inmultire shift-and-add
always @(posedge clk or negedge rst_n)
if (~rst_n) P <= 0                               ; else
if (~idle)  P <= A[counter] ? (P<<1) + B : (P<<1); // Daca bitul curent din A este 1, adauga B la P deplasat


// Setarea rezultatului final
always @(posedge clk or negedge rst_n)
if (~rst_n)    rez <= 0                               ; else
if (~|counter) rez <= A[counter] ? (P<<1) + B : (P<<1); // Setarea rezultatului final

endmodule