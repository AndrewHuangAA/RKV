`ifndef RKV_EFCC_REFERENCE_MODEL_SV
`define RKV_EFCC_REFERENCE_MODEL_SV

class rkv_efcc_reference_model extends rkv_efcc_subscriber;

  mailbox #(rkv_efcc_transaction) efcc_in_mb;
  mailbox #(rkv_efcc_transaction) efcc_out_exp_mb; // expected output
  mailbox #(rkv_efcc_transaction) efcc_out_act_mb; // actual output

  mailbox #(rkv_efcc_transaction) flt_mb;
  mailbox #(rkv_efcc_transaction) crc_mb;
  mailbox #(rkv_efcc_transaction) rc4_mb;
  mailbox #(rkv_efcc_transaction) fmt_mb;

  int unsigned packet_act_cnt = 0;
  int unsigned packet_exp_cnt = 0;

  function new();
    super.new();
    efcc_in_mb      = new();
    efcc_out_exp_mb = new();
    efcc_out_act_mb = new();
    flt_mb          = new();
    crc_mb          = new();
    rc4_mb          = new();
    fmt_mb          = new();
  endfunction

  task run();
    super.run();
    fork
      dispatch_mon_efcc(efcc_pio_mb);
      dispatch_mon_efcc(efcc_dma_mb);
      ref_flt();
      ref_dp();
      ref_sel();
    join_none
  endtask

  task dispatch_mon_efcc(mailbox #(rkv_efcc_transaction) mb);
    rkv_efcc_transaction tr;
    forever begin
      mb.get(tr);
      case(tr.trans_kind)
        PUSH : efcc_in_mb.put(tr);
        POP  : begin efcc_out_act_mb.put(tr); packet_act_cnt++; end
      endcase
    end
  endtask

  // Filter Function Reference
  task ref_flt();
    rkv_efcc_transaction tr;
    forever begin
      efcc_in_mb.get(tr);
      // TODO
      // Add Filter Function
      // 1> Error Packet
      // 2> ID Filter
      flt_mb.put(tr);
    end
  endtask

  // Data Process Reference (CRC/RC4/FMT)
  task ref_dp();
    fork
      ref_crc();
      ref_rc4();
      ref_fmt();
    join_none
  endtask

  task ref_crc();
    rkv_efcc_transaction tr;
    forever begin
      flt_mb.get(tr);
      // TODO
      // Add CRC Function
      crc_mb.put(tr);
    end
  endtask

  task ref_rc4();
    rkv_efcc_transaction tr;
    forever begin
      crc_mb.get(tr);
      // TODO
      // Add RC4 Function
      rc4_mb.put(tr);
    end
  endtask

  task ref_fmt();
    rkv_efcc_transaction tr;
    forever begin
      rc4_mb.get(tr);
      // TODO
      // Add FMT Function
      fmt_mb.put(tr);
    end
  endtask

  task ref_sel();
    rkv_efcc_transaction tr;
    forever begin
      fmt_mb.get(tr);
      // TODO
      // Add SEL Function
      // To PIO or DMA regards of control bit set
      efcc_out_exp_mb.put(tr);
      packet_exp_cnt++;
    end
  endtask

endclass

`endif