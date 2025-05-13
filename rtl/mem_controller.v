module mem_controler (
//System
  input                clk        , //system clock
  input                rst_n      , //async reset active low

//Address configurations
  input      [16-1:0]  op1_ba     , //base address of operrand one
  input      [16-1:0]  op2_ba     , //base address of operrand two
  input      [16-1:0]  ba_rez     , //base address of the result

//operation number
  input      [ 4-1:0]  no_op      , //number of operations to be executed
  input      [ 4-1:0]  op_type    ,
 
//control
  input                start      , //star initiated by cpu
  input                sw_reset   , //reset initiated by cpu

//status
  output reg           busy       , //operations in progress
  output reg [ 4-1:0]  op_cnt     , //number of operations executed

//interrupt triger
  output reg           op_done    , //operations done executing
  output reg           address_ovf, //address reached max value and operations are not done
  output reg           address_ovr, //address overriden while incrementing

//alu interface
  
  output reg [ 8-1:0]  op1        , //operand one
  output reg [ 8-1:0]  op2        , //operand two
  input      [ 8-1:0]  rez        , //rezult
  output reg           start_alu  , //start alu operation
  input                done_alu   , //alu done executing operation

//memory interface
  output               ce         , //memory chip enable
  output               we         , //memory write enable
  output reg [16-1:0]  addr       , //address`
  output     [ 8-1:0]  wdata      , //write data
  input      [ 8-1:0]  rdata        //read data
);

// Definirea starilor FSM
localparam IDLE   = 'd0;            // Stare de asteptare
localparam READ_0 = 'd1;            // Citire primul operand
localparam READ_1 = 'd2;            // Citire al doilea operand
localparam START  = 'd3;            // Initiere operație ALU
localparam WRITE  = 'd4;            // Scriere rezultat

// Registre pentru FSM
reg [3-1:0] prev_state    ;         // Starea anterioara
reg [3-1:0] current_state ;         // Starea curenta
reg [3-1:0] next_state    ;         // Starea urmatoare
reg [8-1:0] op_ct         ;         // Contor operatii
wire        single_operand;         // Indicator operatie cu un singur operand


// Determinarea operatiilor cu un singur operand (transfer si not)
assign single_operand = (op_type == 4'h4) || (op_type == 4'h8);


// Actualizarea starii curente
always @(posedge clk or negedge rst_n)
if (~rst_n) current_state <= IDLE      ; else
            current_state <= next_state;
            
            
// Generarea semnalului op_done. Se activeaza cand ultima operatie este scrisa            
always @(posedge clk or negedge rst_n)
if (~rst_n) op_done <= 0; else
            op_done <= (current_state == WRITE) & (op_cnt == no_op - 1);


// Logica pentru determinarea starii urmatoare
always @(*) begin
if (sw_reset | address_ovf | address_ovr) next_state <= IDLE; else                 // Reset software sau erori de adresa duc la IDLE
case (current_state)                                                               
    IDLE  : next_state = start                                   ? READ_0 : IDLE ; // Din IDLE, se trece la READ_0 la start
    READ_0: next_state = sw_reset ? IDLE :  single_operand       ? START : READ_1; // Din READ_0, la START sau READ_1
    READ_1: next_state = sw_reset ? IDLE :  START                                ; // Din READ_1, la START
    START : next_state = sw_reset ? IDLE :  done_alu             ? WRITE : START ; // Din START, la WRITE cand ALU termina
    WRITE : next_state = sw_reset ? IDLE : (op_cnt == no_op - 1) ? IDLE  : READ_0; // Din WRITE, la IDLE sau READ_0
    default:next_state = IDLE;                                                     // Stare implicita este IDLE
endcase
end



//assign ce = ^current_state  & ~(current_state == WRITE & (addr < ba_rez)) & ~((addr > op1_ba & addr < op1_ba+op_cnt) | (addr > op2_ba & addr < op2_ba+op_cnt));
assign ce = ^current_state;   // Activat cand starea curenta nu este IDLE (XOR-ul bitilor)
assign we = current_state[2]; // Activat in starile cu bitul 2 setat (START si WRITE)


// Determinarea adresei în funcție de starea curentă
always @(*)
case (current_state)
  READ_0:  addr <= op1_ba + op_cnt; // Adresa pentru citirea primului operand
  READ_1:  addr <= op2_ba + op_cnt; // Adresa pentru citirea celui de-al doilea operand
  WRITE :  addr <= ba_rez + op_cnt; // Adresa pentru scrierea rezultatului
  default: addr <= 0;               // Adresa implicita este 0
endcase



assign wdata = rez; // Datele de scris sunt rezultatul de la ALU


// Gestionarea contorului de operatii
always @(posedge clk or negedge rst_n)
if (~rst_n)           op_cnt <= 0         ; else
if (start)            op_cnt <= 0         ; else
if (current_state[2]) op_cnt <= op_cnt + 1;


// Memorarea starii anterioare
always @(posedge clk or negedge rst_n)
if (~rst_n) prev_state <= 0            ; else
            prev_state <= current_state;


// incarcarea primului operand din memorie
always @(posedge clk or negedge rst_n)
if (~rst_n)               op1 <= 0    ; else
if (prev_state == READ_0) op1 <= rdata;


// incarcarea celui de-al doilea operand din memorie
always @(posedge clk or negedge rst_n)
if (~rst_n)               op2 <= 0    ; else
if (prev_state == READ_1) op2 <= rdata;


// Gestionarea semnalului busy
always @(posedge clk or negedge rst_n)
if (~rst_n)  busy <= 0; else
if (start)   busy <= 1; else
if (op_done) busy <= 0;


// Detectarea address overflow
always @(posedge clk or negedge rst_n)
if (~rst_n)                  address_ovf <= 0            ; else
if (start)                   address_ovf <= 0            ; else
if (current_state == READ_0) address_ovf <= addr < op1_ba; else
if (current_state == READ_1) address_ovf <= addr < op2_ba; else
if (current_state == WRITE ) address_ovf <= addr < ba_rez;


// Detectarea suprascrierii adresei (address overrun)
always @(posedge clk or negedge rst_n)
if (~rst_n)                 address_ovr <= 0; else
if (start)                  address_ovr <= 0; else
if (current_state == WRITE) address_ovr <= ((addr > op1_ba & addr < op1_ba+op_cnt) | (addr > op2_ba & addr < op2_ba+op_cnt));


// Generarea semnalului start_alu
always @(posedge clk or negedge rst_n)
if (~rst_n) start_alu  <= 0                                             ; else
            start_alu  <= (current_state == START & prev_state != START);

endmodule