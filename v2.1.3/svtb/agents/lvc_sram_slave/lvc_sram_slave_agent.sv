`ifndef LVC_SRAM_SLAVE_AGENT_SV
`define LVC_SRAM_SLAVE_AGENT_SV

class lvc_sram_slave_agent;

    lvc_sram_slave_target trgt;
    lvc_sram_slave_monitor mon;

    function void build();
        trgt = new();
        mon = new();
    endfunction

    task run();
        fork
            trgt.run();
            mon.run();
        join_none
    endtask

    function void assign_if(input virtual lvc_sram_interface vif); //默認是input
        init.vif = vif;
        mon.vif = vif;
    endfunction 



endclass

`endif // LVC_SRAM_SLAVE_AGENT_SV