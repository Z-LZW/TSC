module divider#(
parameter DW = 8            // Parametru care defineste latimea de date (implicit 8 biti)
) (

//System
input               clk   , // Semnal de ceas
input               rst_n , // Semnal de reset activ pefront scazator
                            
//Cale de date              
input      [DW-1:0] op1   , // Primul operand (deimpartitul)
input      [DW-1:0] op2   , // Al doilea operand (impartitorul)
output reg [DW-1:0] cat   , // Rezultatul impartirii (câtul)
output reg [DW-1:0] rest  , // Restul impartirii
                            
//Control                   
input               start , // Semnal de pornire a operatiei (impuls)
output reg          done    // Semnal care indica finalizarea operatiei (impuls)
);


// Registre interne pentru algoritmul de impartire
reg [DW  :0] P;             // Registru pentru rest parțial (are un bit în plus)
reg [DW-1:0] A;             // Registru pentru acumularea catului
reg [DW-1:0] B;             // Registru pentru stocarea impartitorul
                            
reg idle;                   // Flag care indica starea de inactivitate

reg [$clog2(DW):0] counter; // Contor pentru numarul de biti procesati


// Fire pentru operatiile intermediare
wire [DW  :0] p_shifted;    // P deplasat la stanga cu un bit
wire [DW-1:0] a_shifted;    // A deplasat la stanga cu un bit
wire [DW  :0] p_next   ;    // Urmatoarea valoare a lui P



// Implementarea algoritmului de impartire cu restaurare

assign p_shifted = {P[DW-1:0],A[DW-1]       };                    // Deplaseaza P la stanga și adauga bitul MSB din A
assign a_shifted = {A[DW-2:0],~p_shifted[DW]};                    // Deplaseaza A la stanga și adauga complementul bitului MSB din p_shifted
assign p_next    = p_shifted[DW] ? p_shifted + B : p_shifted - B; // Calculeaza p_next in functie de bitul de semn al lui p_shifted


// Gestionarea stării idle
always @(posedge clk or negedge rst_n)
if (~rst_n)    idle <= 1; else              // La reset, setează idle = 1
if (start)     idle <= 0; else              // La start, incepe operaaia (idle = 0)
if (~|counter) idle <= 1;                   // Cand contorul ajunge la 0, revine an stare idle


// Gestionarea contorului de biti
always @(posedge clk or negedge rst_n)
if (~rst_n)   counter <= DW         ; else  // La reset, initializeaza contorul cu DW
if (start)    counter <= DW         ; else  // La start, reinitializeaza contorul
if (|counter) counter <= counter - 1;       // Decrementeaza contorul cat timp nu e zero


// incarca impariitorul in registrul B
always @(posedge clk or negedge rst_n)
if (~rst_n) B <= 0  ; else                  // La reset, B = 0
if (start)  B <= op2;                       // La start, incarca op2 in B


// Gestionarea registrului A pentru acumularea catului
always @(posedge clk or negedge rst_n)      
if (~rst_n)   A <= 0        ; else          // La reset, A = 0
if (start)    A <= op1      ; else          // La start, incarca op1 in A
if (|counter) A <= a_shifted;               // Actualizeaza A cu valoarea deplasatăa


// Gestionarea registrului P pentru restul partial
always @(posedge clk or negedge rst_n)
if (~rst_n) P <= 0            ; else        // La reset, P = 0
if (start)  P <= 0            ; else        // La start, inițializeaza P = 0
            P <= p_next       ;             // Actualizeaza P cu valoarea calculata


// Generarea semnalului done
always @(posedge clk or negedge rst_n)
if (~rst_n)             done <= 0; else     // La reset, done = 0
if (counter==0 & ~idle) done <= 1; else     // Activează done cand operaaia e completa
                        done <= 0;          // in rest, done = 0


// Calculul restului final
always @(posedge clk or negedge rst_n)
if (~rst_n)            rest <= 0    ; else  // La reset, rest = 0
if (counter==0 & ~idle)                     // Cand operaaia e completa
  if (P[DW])           rest <= P + B; else  // Dacă P e negativ, adauga B pentru a restaura
                       rest <= P    ;       // Altfel, P este deja restul corect


// Setarea rezultatului (catul)
always @(posedge clk or negedge rst_n)
if (~rst_n)             cat <= 0        ; else // La reset, cat = 0
if (counter==0 & ~idle) cat <= a_shifted;      // Când operația e completa, seteaza rezultatul

endmodule