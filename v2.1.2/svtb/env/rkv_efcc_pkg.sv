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
// File        : rkv_efcc_pkg.sv
// Created     : 2026-10-21
// Version     : 1.0
//
// Description :
// - EFCC verification package.
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef RKV_EFCC_PKG_SV
`define RKV_EFCC_PKG_SV

package rkv_efcc_pkg;

    import lvc_apb_pkg::*;
    `include "rkv_efcc_env.sv"
    `include "rkv_efcc_tests.svh"
    `include "rkv_efcc_reg_defines.svh"
    // `include "rkv_efcc_defines.svh"

endpackage


`endif // RKV_EFCC_PKG_SV