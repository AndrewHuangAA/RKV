//==============================================================================
// COPYRIGHT (C) 2018-2026 RockerIC, Ltd.
// This software and the associated documentation are confidential and
// proprietary to RockerIC, Ltd. Your use or disclosure of this software
// is subject to the terms and conditions of a consulting agreement
// between you, or your company, and RockerIC, Ltd. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//
// VisitUs : www.rockeric.com
// Support : support@rockeric.com
//==============================================================================
// File        : rkv_efcc_env.sv
// Created     : 2026-10-21
// Version     : 1.0
//
// Description :
// - EFCC top environment, composed of sub-components
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef RKV_EFCC_ENV_SV
`define RKV_EFCC_ENV_SV

class rkv_efcc_env;

    // lvc_apb_master_initiator apb_init;
    lvc_apb_master_agent apb_mst;
    lvc_sram_slave_agent sram_slv;
    rkv_efcc_scoreboard scb;
    rkv_efcc_config cfg;
    
    function new();
    endfunction

    virtual function void build();
        // apb_init = new();
        apb_mst = new();
        sram_slv = new();
        scb = new();
        apb_mst.build();
        sram_slv.build();
        scb.build();
    endfunction
    
    virtual function void connect();
        scb.cfg = cfg;
        apb_mst.mon.mon_mb.push_back(scb.apb_mb);
        sram_slv.mon.mon_porta_mb.push_back(scb.sram_porta_mb);
        sram_slv.mon.mon_portb_mb.push_back(scb.sram_portb_mb);
    endfunction

    virtual task run();
        fork
            // apb_init.run();
            apb_mst.run();
            sram_slv.run();
            scb.run();
        join_none
    endtask

    virtual function void check();
        scb.check();
    endfunction
endclass

`endif // RKV_EFCC_ENV_SV