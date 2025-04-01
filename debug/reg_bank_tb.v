module reg_bank_tb;

reg           clk     ;
reg           rst_n   ;

reg           psel    ;
reg           penable ;
reg           pwrite  ;
reg  [ 6-1:0] paddr   ;
reg  [32-1:0] pwdata  ;
wire [32-1:0] prdata  ;
wire          pready  ;
wire          pslverr ;

wire [16-1:0] op1_ba  ;
wire [16-1:0] op2_ba  ;
wire [16-1:0] ba_rez  ;
wire [ 4-1:0] no_op   ;
wire [ 4-1:0] op_code ;
wire [ 3-1:0] ctrl    ;
reg  [ 5-1:0] status  ;
reg  [ 3-1:0] irq     ;
wire [ 3-1:0] irq_mask;

initial begin
    clk <= 0;
  forever #5 clk <= ~clk;
end

initial begin
  rst_n <= 0;
  #17;
  rst_n <= 1;
end

initial begin
  psel    <= 0;
  penable <= 0;
  paddr   <= 0;
  pwdata  <= 0;
  pwrite  <= 0;
  status  <= 0;
  irq     <= 0;
  @(posedge rst_n);
  @(posedge clk);

  apb('h00,'hffff,1,2);
  apb('h04,'hffff,1,2);
  apb('h08,'hffff,1,2);
  apb('h0c,'hffff,1,2);
  apb('h10,'hffff,1,2);
  apb('h14,'hffff,1,2);
  apb('h18,'hffff,1,2);
  apb('h1c,'hffff,1,2);
  apb('h20,'hffff,1,2);

  apb('h00,'hffff,0,2);
  apb('h04,'hffff,0,2);
  apb('h08,'hffff,0,2);
  apb('h0c,'hffff,0,2);
  apb('h10,'hffff,0,2);
  apb('h14,'hffff,0,2);
  apb('h18,'hffff,0,2);
  apb('h1c,'hffff,0,2);
  apb('h20,'hffff,0,2);

  apb('h2,'hffff,1,2);
  apb('h2,'hffff,0,2);

  $stop;  
end

task apb (input [6-1:0] addr, input [32-1:0] data, input rw, input [2:0] delay) ;begin

  psel   <= 1   ;
  paddr  <= addr;
  pwdata <= data;
  pwrite <= rw  ;
  @(posedge clk);

  penable <= 1;
  @(posedge clk);

  while (~pready) @(posedge clk);
  penable <= 0;
  psel <= 0;

  repeat (delay) @(posedge clk);
end
endtask

reg_bank i_reg_bank(
.pclk     (clk     ),
.preset_n (rst_n   ),

.psel    (psel    ),
.penable (penable ),
.pwrite  (pwrite  ),
.paddr   (paddr   ),
.pwdata  (pwdata  ),
.prdata  (prdata  ),
.pready  (pready  ),
.pslverr (pslverr ),

.op1_ba  (op1_ba  ),
.op2_ba  (op2_ba  ),
.ba_rez  (ba_rez  ),
.no_op   (no_op   ),
.op_code (op_code ),
.ctrl    (ctrl    ),
.status  (status  ),
.irq     (irq     ),
.irq_mask(irq_mask)
);

endmodule