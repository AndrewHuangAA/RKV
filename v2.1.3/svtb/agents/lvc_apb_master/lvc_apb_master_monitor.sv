`ifndef LVC_APB_MASTER_MONITOR_SV
`define LVC_APB_MASTER_MONITOR_SV

class lvc_apb_master_monitor;

  virtual lvc_apb_interface vif;
  lvc_apb_transfer mon_tr;

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
    mon_tr.trans_kind = vif.pwrite ? WRITE : READ;
    #10ps;
    wait(vif.praedy === 1);
    #10ps;
    mon_tr.trans_status = vif.pslverr === 1 ? ERROR : OK;
    if(mon_tr.trans_kind == READ)
      mon_tr.data = vif.prdata;
  endtask

  function write_transfer();
    // TODO
    // Send Monitored Transfers to Other Components
    mon_tr.print();
  endfunction

endclass

`endif // LVC_APB_MASTER_MONITOR_SV