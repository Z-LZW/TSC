module system(
  input           clk     ,
  input           rst_n   ,

  input           psel    ,
  input           penable ,
  input           pwrite  ,
  input  [ 6-1:0] paddr   ,
  input  [32-1:0] pwdata  ,
  output [32-1:0] prdata  ,
  output          pready  ,
  output          pslverr ,

  output           ce     ,
  output           we     ,
  output [16-1:0]  addr   ,
  output [ 8-1:0]  wdata  ,
  input  [ 8-1:0]  rdata  ,

  output           irq    
);

wire [16-1:0] op1_ba  ;
wire [16-1:0] op2_ba  ;
wire [16-1:0] ba_rez  ;
wire [ 4-1:0] no_op   ;
wire [ 4-1:0] op_code ;
wire [ 3-1:0] ctrl    ;
wire [ 5-1:0] status  ;
wire [ 3-1:0] irq_reg ;
wire [ 3-1:0] irq_mask;

wire [8-1:0] op1      ;
wire [8-1:0] op2      ;
wire [8-1:0] rez      ;
wire         start_alu;
wire         done_alu ;

reg_bank i_reg_bank(
.pclk     (clk    ),
.preset_n (rst_n  ),

.psel    (psel   ),
.penable (penable),
.pwrite  (pwrite ),
.paddr   (paddr  ),
.pwdata  (pwdata ),
.prdata  (prdata ),
.pready  (pready ),
.pslverr (pslverr),

.op1_ba  (op1_ba  ),
.op2_ba  (op2_ba  ),
.ba_rez  (ba_rez  ),
.no_op   (no_op   ),
.op_code (op_code ),
.ctrl    (ctrl    ),
.status  (status  ),
.irq     (irq_reg ),
.irq_mask(irq_mask)
);

irq_handler i_irq_handler(
.clk             (clk        ),
.rst_n           (rst_n      ),
.address_ovf     (irq_reg[1] ),
.address_ovr     (irq_reg[2] ),
.op_done         (irq_reg[0] ),
.address_ovf_mask(irq_mask[1]),
.address_ovr_mask(irq_mask[2]),
.op_done_mask    (irq_mask[0]),
.irq             (irq        )
);

mem_controler i_mem_controler(
.clk         (clk        ),
.rst_n       (rst_n      ),

.op1_ba      (op1_ba     ),
.op2_ba      (op2_ba     ),
.ba_rez      (ba_rez     ),

.no_op       (no_op      ),
.op_type     (op_code    ),
.start       (ctrl[0]    ),
.sw_reset    (ctrl[1]    ),
.busy        (status[0]  ),
.op_cnt      (status[4:1]),
.op_done     (irq_reg[0] ),
.address_ovf (irq_reg[1] ),
.address_ovr (irq_reg[2] ),

.op1         (op1        ),
.op2         (op2        ),
.rez         (rez        ),
.start_alu   (start_alu  ),
.done_alu    (done_alu   ),

.ce          (ce         ),
.we          (we         ),
.addr        (addr       ),
.wdata       (wdata      ),
.rdata       (rdata      )
);

alu i_alu(
.clk       (clk      ),
.rst_n     (rst_n    ),

.op_code   (op_code  ),
.op0       (op1      ),
.op1       (op2      ),
.rez       (rez      ),
.start_alu (start_alu),
.done_alu  (done_alu ),

.start_mul (start_mul),
.done_mul  (done_mul ),
.start_div (start_div),
.done_div  (done_div )
);

endmodule