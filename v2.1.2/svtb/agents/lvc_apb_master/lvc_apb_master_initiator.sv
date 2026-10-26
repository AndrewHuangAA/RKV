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
// File        : lvc_apb_initiator.sv
// Created     : 2026-10-20
// Version     : 1.0
//
// Description :
// - APB master driver, requesting APB transaction
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef LVC_APB_MASTER_INITIATOR_SV
`define LVC_APB_MASTER_INITIATOR_SV

class lvc_apb_master_initiator;

  virtual lvc_apb_interface vif;
  
  function new();
  endfunction

  function void assign_if(input virtual lvc_apb_interface vif); //默認是input
    this.vif = vif;
  endfunction

  // 不用加automatic，class裡面默認是動態的
  task drive_transfer (input lvc_apb_transfer t);
    case(t.trans_kind)
      IDLE  : do_idle();
      WRITE : do_write(t);
      READ  : do_read(t);
    endcase
    t.print();
  endtask : drive_transfer

  task do_idle();
    @(posedge vif.clk_i);
      vif.psel    <= 0;
      vif.penable <= 0;
      vif.pwdata  <= 0;
  endtask: do_idle

  task do_write(input lvc_apb_transfer t);
    @(posedge vif.clk_i);
      vif.paddr   <= t.addr;
      vif.pwrite  <= 1;
      vif.psel    <= 1;
      vif.penable <= 0;
      vif.pwdata  <= t.data;
    @(posedge vif.clk_i);
      vif.penable <= 1;
      #10ps;
      wait(vif.pready === 1);
      #10ps;
      t.trans_status = vif.pslverr === 1 ? ERROR : OK;
      repeat(t.idle_cycles) do_idle();
  endtask

  task do_read(input lvc_apb_transfer t);
    @(posedge vif.clk_i);
      vif.paddr   <= t.addr;
      vif.pwrite  <= 0;
      vif.psel    <= 1;
      vif.penable <= 0;
    @(posedge vif.clk_i);
      vif.penable <= 1;
      #10ps;
      wait(vif.pready === 1);
      #10ps;
      t.trans_status = vif.pslverr === 1 ? ERROR : OK;
      t.data = vif.prdata;
      repeat(t.idle_cycles) do_idle();
  endtask

  task do_reset();
    @(negedge vif.rstn_i);
      vif.paddr   <= 0;
      vif.pwrite  <= 0;
      vif.psel    <= 0;
      vif.penable <= 0;
      vif.pwdata  <= 0;
  endtask


endclass

`endif // LVC_APB_MASTER_INITIATOR_SV