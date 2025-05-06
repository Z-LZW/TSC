module irq_handler(

input      clk             ,
input      rst_n           ,

input      address_ovf     ,
input      address_ovr     ,
input      op_done         ,

input      address_ovf_mask,
input      address_ovr_mask,
input      op_done_mask    ,

output     irq             
);

assign irq = (address_ovf & address_ovf_mask) | 
             (address_ovr & address_ovr_mask) | 
             (op_done     & op_done_mask    ) ;



endmodule