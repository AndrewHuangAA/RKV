`ifndef LVC_APB_MASTER_AGENT_SV
`define LVC_APB_MASTER_AGENT_SV

class lvc_apb_master_agent;
  lvc_apb_master_initiator init;
  lvc_apb_master_monitor mon;

  function new();

  endfunction

  function void build();
    init = new();
    mon = new();
  endfunction

  task run();
   fork
    init.run();
    mon.run();
   join_none
  endtask

  function void assign_if(input virtual lvc_apb_interface vif); //默認是input
    init.vif = vif;
    mon.vif = vif;
  endfunction 

endclass

`endif // LVC_APB_MASTER_AGENT_SV