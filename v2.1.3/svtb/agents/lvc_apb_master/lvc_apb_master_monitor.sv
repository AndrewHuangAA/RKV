`ifndef LVC_APB_MASTER_MONITOR_SV
`define LVC_APB_MASTER_MONITOR_SV

class lvc_apb_master_monitor;

  virtual lvc_apb_interface vif;
  lvc_apb_transfer mon_tr;

  mailbox #(lvc_apb_transfer) mon_mb[$];

  task run();
    fork
      monitor_transactions();
    join_none
  endtask

  task monitor_transactions();
    forever begin
      collect_transfer();
      write_transfer();
    end
  endtask

  task collect_transfer();
    @(posedge clk_i iff (vif.psel === 1 && vif.penable === 0))
    mon_tr = new();
    mon_tr.addr = vif.paddr;
    mon_tr.trans_kind = vif.pwrite ? lvc_apb_transfer::WRITE : lvc_apb_transfer::READ;
    // @(posedge vif.clk_i);
    #10ps;
    wait(vif.pready === 1);
    // @(posedge vif.clk_i iff vif.pready === 1);
    #10ps;
    mon_tr.trans_status = vif.pslverr === 1 ? lvc_apb_transfer::ERROR : lvc_apb_transfer::OK;
    mon_tr.data = (mon_tr.trans_kind == lvc_apb_transfer::WRITE) ? vif.pwdata : vif.prdata;
  endtask

  task write_transfer();
    // TODO
    // Send Monitored Transfers to Other Components
    foreach(mon_mb[i]) begin
      mon_mb[i].put(mon_tr);
      mon_tr.print();
    end
  endtask

endclass

`endif // LVC_APB_MASTER_MONITOR_SV