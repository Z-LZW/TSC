module irq_handler(

input      clk             ,
input      rst_n           ,

input      address_ovf     ,
input      address_ovr     ,
input      op_done         ,

input      address_ovf_mask,
input      address_ovr_mask,
input      op_done_mask    ,

output reg irq             ,
input      ira             

);

wire irq_trigger;

assign irq_trigger = (address_ovf & address_ovf_mask) | 
                     (address_ovr & address_ovr_mask) | 
                     (op_done     & op_done_mask    ) ;

always @(posedge clk or negedge rst_n)
if (~rst_n)      irq <= 0; else
if (ira)         irq <= 0; else
if (irq_trigger) irq <= 1;

endmodule