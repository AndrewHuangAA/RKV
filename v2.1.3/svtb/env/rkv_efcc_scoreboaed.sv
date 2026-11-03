`ifndef RKV_EFCC_SCOREBOARD_SV
`define RKV_EFCC_SCOREBOARD_SV

class rkv_efcc_scoreboard extends rkv_efcc_reference_model;

  function new();
    super.new();
  endfunction

  task run();
    super.run();
    fork
      compare_packet();
    join_none
  endtask

  task compare_packet();
    rkv_efcc_transaction exp_tr, act_tr;
    forever begin
      fork
        efcc_out_exp_mb.get(exp_tr);
        efcc_out_act_mb.get(act_tr);
      join
      if(!act_tr.compare(exp_tr)) begin
        cfg.scb_check_error++;
        $error("Actual packet compared expected packet FAILURE!");
        act_tr.print();
        exp_tr.print();
      end
      else
        $display("Actual packet compared expected packet SUCCESS!");
      cfg.scb_check_count++;
    end
  endtask

  function bit check_out_exp_mb_empty();
    bit is_empty = efcc_out_exp_mb.num() == 0 ? 1 : 0;
    return is_empty;
  endfunction

  function bit check_out_act_mb_empty();
    bit is_empty = efcc_out_act_mb.num() == 0 ? 1 : 0;
    return is_empty;
  endfunction

  virtual function void check();
    if(cfg.scb_check_enable) begin
      if(cfg.scb_packet_number_check) begin
        if(packet_act_cnt != packet_exp_cnt) begin
          $error("Scoreboard: packet_act_cnt [%0d] != packet_exp_cnt [%0d]", packet_act_cnt, packet_exp_cnt);
          cfg.scb_check_error++;
        end
        cfg.scb_check_count++;
      end

      if(cfg.scb_packet_buffer_empty_check) begin
        if(!check_out_exp_mb_empty) begin
          $error("Scoreboard: efcc_out_exp_mb is NOT Empty at Simulation End");
          cfg.scb_check_error++;
        end
        cfg.scb_check_count++;
        if(!check_out_act_mb_empty) begin
          $error("Scoreboard: efcc_out_act_mb is NOT Empty at Simulation End");
          cfg.scb_check_error++;
        end
        cfg.scb_check_count++;
      end

      if(cfg.scb_packet_desired_number != 0) begin
        if(cfg.scb_packet_desired_number != packet_act_cnt) begin
          $error("Scoreboard: packet_dsr_cnt [%0d] != packet_act_cnt [%0d]", cfg.scb_packet_desired_number, packet_act_cnt);
          cfg.scb_check_error++;
        end
        cfg.scb_check_count++;
      end
    end
  endfunction

endclass

`endif