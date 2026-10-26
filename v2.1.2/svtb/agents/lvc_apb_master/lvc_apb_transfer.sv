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
// File        : lvc_apb_transfer.sv
// Created     : 2026-10-20
// Version     : 1.0
//
// Description :
// - APB transaction
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef LVC_APB_TRANSFER_SV
`define LVC_APB_TRANSFER_SV

typedef enum {IDLE, WRITE, READ} apb_trans_kind;
typedef enum {OK, ERROR} apb_trans_status;

class lvc_apb_transfer;
  bit [31:0]        addr;
  bit [31:0]        data;
  apb_trans_kind    trans_kind;
  apb_trans_status  trans_status;
  int               idle_cycles;
  bit [31:0]        expd; // Expected Data

  // function_description
  function void new();
  endfunction : new

  function void print();
    string msg = "********APB Transfer Content is *********\n";
    msg = {msg, $sformatf("addr = 32'h%8x \n", addr)};
    msg = {msg, $sformatf("data = 32'h%8x \n", data)};
    msg = {msg, $sformatf("trans_kind = %s \n", trans_kind)};
    msg = {msg, $sformatf("trans_status = %s \n", trans_status)};
    msg = {msg, $sformatf("idle_cycles = %0d \n", idle_cycles)};
    msg = {msg, "*****************************************\n"};
    $display(msg);
  endfunction : print
endclass

`endif // LVC_APB_TRANSFER_SV