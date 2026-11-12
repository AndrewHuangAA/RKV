//=============================================================================
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
//=============================================================================
// File        : rkv_efcc_if.sv
// Created     : 2026-03-15
// Version     : 1.0
//
// Description :
// - EFCC top interface
//
// Revision History:
// Date        Version     Change Description
// ---------------------------------------------------------------------------
//             |           |
//=============================================================================

interface rkv_efcc_if(input clk_i);

  bit rstn;
  bit clk_en;

  initial begin
    set_clk_en();
    do_reset();
  end

  task automatic do_reset();
    rstn <= 1'b1;
    #13ns rstn <= 1'b0;
    repeat(10) @(posedge clk_i);
    rstn <= 1'b1;
  endtask

  task automatic set_clk_en(bit en = 1);
    @(posedge clk_i);
    clk_en = en;
  endtask

endinterface