module system_tb;

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

wire           ce   ;
wire           we   ;
wire [16-1:0]  addr ;
wire [ 8-1:0]  wdata;
reg  [ 8-1:0]  rdata;

wire           irq  ;

assign ira = 0;

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
  @(posedge rst_n);
  @(posedge clk);

  apb('h00,'h00,'h1,'h1);
  apb('h04,'h0a,'h1,'h1);
  apb('h08,'h14,'h1,'h1);

  apb('h0c,'h02,'h1,'h1);
  apb('h10,'h03,'h1,'h1);

  apb('h20,'h0f,'h1,'h1);

  apb('h14,'h01,'h1,'h1);

  wait(irq);
  repeat(5) @(posedge clk);

  apb('h14,'h02,'h1,'h1);
  repeat(5) @(posedge clk);

  $stop;  
end

initial begin
  @(posedge rst_n);
  @(posedge clk);
  forever begin
    while (~(ce & ~we)) @(posedge clk);
    rdata <= $urandom_range(0,10);
    @(posedge clk);
  end
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

system DUT(
.clk    (clk    ),
.rst_n  (rst_n  ),
.psel   (psel   ),
.penable(penable),
.pwrite (pwrite ),
.paddr  (paddr  ),
.pwdata (pwdata ),
.prdata (prdata ),
.pready (pready ),
.pslverr(pslverr),
.ce     (ce     ),
.we     (we     ),
.addr   (addr   ),
.wdata  (wdata  ),
.rdata  (rdata  ),
.irq    (irq    )
);


endmodule