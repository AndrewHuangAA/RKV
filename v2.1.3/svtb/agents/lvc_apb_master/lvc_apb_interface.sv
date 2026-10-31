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
// File        : lvc_apb_interface.sv
// Created     : 2026-10-20
// Version     : 1.0
//
// Description :
// - APB bus interface.
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
interface lvc_apb_interface (input clk_i, input rstn_i);
    logic        psel        ;
    logic        penable     ;
    logic [31:0] paddr       ;
    logic [31:0] pwdata      ;
    logic [31:0] prdata      ;
    logic        pwrite      ;
    logic        pready      ;
    logic        pslverr     ;
endinterface