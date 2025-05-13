module irq_handler(

input      clk             , // Semnal de ceas
input      rst_n           , // Semnal de reset activ pe front scazator
                             
input      address_ovf     , // Semnal de depasire a adresei (overflow)
input      address_ovr     , // Semnal de depasire a adresei (overrun)
input      op_done         , // Semnal de finalizare a operatiei
                             
input      address_ovf_mask, // Masca pentru semnalul de depasire a adresei (overflow)
input      address_ovr_mask, // Masca pentru semnalul de depasire a adresei (overrun)
input      op_done_mask    , // Masca pentru semnalul de finalizare a operatiei
                             
output reg irq             , // Semnal de întrerupere (Interrupt Request)
input      ira               // Semnal de recunoaștere a întreruperii (Interrupt Acknowledge)

);

wire irq_trigger;            // Semnal intern pentru declansarea intreruperii


// Generarea semnalului de declansare a intreruperii
// Se activeaza daca cel putin una dintre conditiile mascate este indeplinita
assign irq_trigger = (address_ovf & address_ovf_mask) | 
                     (address_ovr & address_ovr_mask) | 
                     (op_done     & op_done_mask    ) ;

always @(posedge clk or negedge rst_n)
if (~rst_n)      irq <= 0; else    // La reset, dezactiveaza intreruperea
if (ira)         irq <= 0; else    // La recunoasterea intreruperii, dezactiveaza intreruperea
if (irq_trigger) irq <= 1;         // Activează intreruperea cand este declansata

endmodule