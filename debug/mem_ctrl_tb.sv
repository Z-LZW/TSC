module mem_ctrl_tb;

  reg          clk        ; //system clock
  reg          rst_n      ; //async reset active lowreg

  reg[16-1:0]  op1_ba     ; //base address of operrand one
  reg[16-1:0]  op2_ba     ; //base address of operrand two
  reg[16-1:0]  ba_rez     ; //base address of the resultreg

  reg[ 4-1:0]  no_op      ; //number of operations to be executed
  reg[ 4-1:0]  op_type    ;

  reg          start      ; //star initiated by cpu
  reg          sw_reset   ; //reset initiated by cpureg

  wire          busy       ; //operations in progress
  wire          op_cnt     ; //number of operations executedreg

  wire          op_done    ; //operations done executing
  wire          address_ovf; //address reached max value and operations are not done
  wire          address_ovr; //address overriden while incrementingreg

  wire[ 8-1:0]  op1        ; //operand one
  wire[ 8-1:0]  op2        ; //operand two
  reg [ 8-1:0]  rez        ; //rezult
  wire          start_alu  ; //start alu operation
  reg           done_alu   ; //alu done executing operationreg

  wire           ce         ; //memory chip enable
  wire           we         ; //memory write enable
  wire           addr       ; //address`
  wire [ 8-1:0]  wdata      ; //write data
  reg  [ 8-1:0]  rdata        //read data


  initial begin
    clk <= 0;
    forever clk <= ~clk;
  end

  initial begin
    rst_n <= 0;
    #17;
    rst_n <= 1;
  end

  initial begin
    done_alu <= 0;
    @(posedge rst_n);
    @(posedge clk);
    forever begin
      while(~start_alu) @(posedge clk);
      @(posedge clk);
      done_alu <= 1;
      @(posedge clk);
      done_alu <= 0;
    end
  end

  initial begin
    @(posedge rst_n);
    @(posedge clk);
    forever begin
      while(~(ce & ~we)) @(posedge clk);
      rdata <= $urandom_range(0,255);
      @(posedge clk);
    end
  end

  initial begin
    @(posedge rst_n);
    @(posedge clk);

    fork
      run();
      repeat(20) @(posedge clk);
    join_any

    @(posedge clk);
    $stop;

  end

  task run();
    op1_ba <= $urandom_range(0,2**16-1);
    op2_ba <= $urandom_range(0,2**16-1);
    ba_rez <= $urandom_range(0,2**16-1);
    no_op  <= $urandom_range(0,15);
    rez    <= $urandom_range(0,255);

    start <= 1;
    @(posedge clk);
    start <= 0;

    while(~op_done) @(posedge clk);

    @(posedge clk);
  endtask

me_controller DUT(
.clk        (clk        ),
.rst_n      (rst_n      ),
.op1_ba     (op1_ba     ),
.op2_ba     (op2_ba     ),
.ba_rez     (ba_rez     ),
.no_op      (no_op      ),
.op_type    (op_type    ),
.start      (start      ),
.sw_reset   (sw_reset   ),
.busy       ( busy      ),
.op_cnt     ( op_cnt    ),
.op_done    ( op_done   ),
.address_ov ( address_ov),
.address_ov ( address_ov),
.op1        ( op1       ),
.op2        ( op2       ),
.rez        ( rez       ),
.start_alu  ( start_alu ),
.done_alu   ( done_alu  ),
.ce         (  ce       ),
.we         (  we       ),
.addr       (  addr     ),
.wdata      (  wdata    ),
.rdata      (  rdata    )
);

endmodule