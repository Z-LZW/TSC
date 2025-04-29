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

  bit irq_asserted;

  event apb_e;
  event mem_e;
  event irq_e;

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
        ->apb_e;
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
          ->mem_e;
          bsy_cmp = 1;
          if (mem_t.kind != MEM_READ) begin $error("EXPECTED A READ FROM MEMORY AND RECEIVED A WRITE"); error_counter++; end
          op1 = mem_t.data; 

          mem_2_scb.get(mem_t);
          ->mem_e
          if (mem_t.kind != MEM_READ) begin $error("EXPECTED A READ FROM MEMORY AND RECEIVED A WRITE"); error_counter++; end
          op2 = mem_t.data;   

          mem_2_scb.get(mem_t);
          ->mem_e;
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
      ->irq_e;
      irq_asserted = 1;
      bsy_cmp = 0;
      if (irq_mask == 0) begin $error("INTERRUP ASSERTED WHILE IT WAS MASKED"); error_counter++; end
    end
  endtask

  task clear();
    op_cnt = 0;
    irq_asserted = 0;
    ->ctrl_register_e;
  endtask

  //-----------------------------------------coverage-------------------------------------

  covergroup functional_coverage @(apb_e);
    op1_ba_cov: coverpoint ba_op1 {
      bins range[10] = {[0:16'hffff]};
    }

    op2_ba_cov: coverpoint ba_op2 {
      bins range[10] = {[0:16'hffff]};
    }

    rez_ba_cov: coverpoint ba_rez {
      bins range[10] = {[0:16'hffff]};
    }

    no_op_cov: coverpoint no_op {
      bins value[16] = {[0:15]}
    }

    op_code_cov: coverpoint op_code {
      bins value[16] = {[0:15]}
    }

    ctrl_cov: coverpoint ctrl{
      bins start = {0};
      bins sw_reset = {1};
    }

    bsy_cov: coverpoint status[0]{
      bins busy = {1};
      bins idle = {0};
    }

    op_cnt_cov: coverpoint status[4:1]{
      bins range[4] = {[0:16]}
    }

    irq_cov: coverpoint irq{
      wildcard bins op_done = {??1};
      wildcard bins address_ovf = {?1?};
      wildcard bins address_ovr = {1??};
    }

    irq_mask_cov: coverpoint irq_mask{
      bins all_masked      = {0};
      bins all_visible     = {7};
      bins combinations[6] = {[1:6]};
    }

    no_op_x_op_code_cross: cross no_op_cov,op_code_cov;

    op_code_x_bsy_cross: cross op_code_cov,bsy_cov;

    op_done_x_irq:  cross irq[0],irq_asserted;
    addr_ovf_x_irq: cross irq[1],irq_asserted;
    addr_ovr_x_irq: cross irq[2],irq_asserted;
  endgroup

endclass

`endif