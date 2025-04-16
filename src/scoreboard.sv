`ifndef SCOREBOARD_GUARD
`define SCOREBOARD_GUARD

class scoreboard;

  //mailboxes
  mailbox apb_2_scb;
  mailbox iqr_2_scb;
  mailbox mem_2_scb;

  apb_trans apb_t;
  mem_trans mem_t;
  irq_trans irq_t;

  //registers
  bit [32-1:0] ba_op1  ;
  bit [32-1:0] ba_op2  ;
  bit [32-1:0] ba_rez  ;
  bit [32-1:0] no_op   ;
  bit [32-1:0] op_code ;
  bit [32-1:0] ctrl    ;
  bit [32-1:0] status  ;
  bit [32-1:0] irq     ;
  bit [32-1:0] irq_mask;

  bit [32-1:0] reg_cmp;
  bit [32-1:0] predict_val;

  bit [ 8-1:0] op1;
  bit [ 8-1:0] op2;
  bit [ 8-1:0] rez;

  int error_counter;
  int op_cnt;
  bit bsy_cmp;

  function new();
    error_counter = 0;
  endfunction
  
  task run();
    fork
      check_apb();
      check_mem();
      check_irq();
    join
  endtask

  task check_apb();
    forever begin
      apb_2_scb.get(apb_t);
      if (apb_t.kind == APB_WRITE) begin
        case (apb_t.addr)
          'h0 : ba_op1   = apb_t.data;
          'h4 : ba_op2   = apb_t.data;
          'h8 : ba_rez   = apb_t.data;
          'hc : no_op    = apb_t.data;
          'h10: op_code  = apb_t.data;
          'h14: clear()              ;
          //'h18: status   = apb_t.data;
          //'h1c: irq      = apb_t.data;
          'h20: irq_mask = apb_t.data; 
        endcase
      end
      else begin
        case (apb_t.addr)
          'h0 : reg_cmp = ba_op1     ;
          'h4 : reg_cmp = ba_op2     ;
          'h8 : reg_cmp = ba_rez     ;
          'hc : reg_cmp = no_op      ;
          'h10: reg_cmp = op_code    ;
          //'h14: reg_cmp = predict_val;
          'h18: reg_cmp = {op_cnt,bsy_cmp};
          'h1c: reg_cmp = predict_val;
          'h20: reg_cmp = irq_mask   ; 
        endcase

        if (apb_t.data != reg_cmp) begin $error("DATA MISMATCH ON REGISTERS: ADDR:%2h | ACTUAL: %4h | EXPECTED: %4h",apb_t.addr,apb_t.data,reg_cmp); error_counter++; end
      end
    end
  endtask

  task check_mem();
    forever begin
      fork
        @(ctrl_register_e);
        forever begin
          mem_2_scb.get(mem_t);
          bsy_cmp = 1;
          if (mem_t.kind != MEM_READ) begin $error("EXPECTED A READ FROM MEMORY AND RECEIVED A WRITE"); error_counter++; end
          op1 = mem_t.data; 

          mem_2_scb.get(mem_t);
          if (mem_t.kind != MEM_READ) begin $error("EXPECTED A READ FROM MEMORY AND RECEIVED A WRITE"); error_counter++; end
          op2 = mem_t.data;   

          mem_2_scb.get(mem_t);
          if (mem_t.kind == MEM_READ) begin $error("EXPECTED A WRITE FROM MEMORY AND RECEIVED A READ"); error_counter++; end 

          case(op_code)
                0 : rez_cmp = op1  + op2;
                1 : rez_cmp = op1  - op2;
                2 : rez_cmp = op1  * op2;
                3 : rez_cmp = op1  / op2;
                4 : rez_cmp = op1       ;
                5 : rez_cmp = op1  & op2;
                6 : rez_cmp = op1  | op2;
                7 : rez_cmp = op1  ^ op2;
                8 : rez_cmp = ~op1      ;
                9 : rez_cmp = op1 ~& op2;
                10: rez_cmp = op1 ~| op2;
                11: rez_cmp = op1 ~^ op2;
                12: rez_cmp = op1 << op2;
                13: rez_cmp = op1 >> op2;
                14: rez_cmp = (op0 << op1) + ((1   << op1) - 1);
                15: rez_cmp = (op0 >> op1) + ('hff << op1);
          endcase   
          if (mem_t.data != rez_cmp) begin $error("OPERATION ERROR, DATA MISMATCH | ACTUAL RESULT: %0d | EXPECTED RESULT: %0d ",mem_t.data,rez_cmp); error_counter++; end  
          bsy_cmp = 0;
          op_cnt++;
        end  
      join_any
      disable fork;
      bsy_cmp = 0;
    end
  endtask

  task check_irq();
    forever begin
      iqr_2_scb.get(irq_t);
      bsy_cmp = 0;
      if (irq_mask == 0) begin $error("INTERRUP ASSERTED WHILE IT WAS MASKED"); error_counter++; end
    end
  endtask

  task clear();
    op_cnt = 0;
    ->ctrl_register_e;
  endtask

endclass

`endif