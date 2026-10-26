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
// - EFCC top environment, composed of sub-components(apb/sram/scoreboard/...).
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef RKV_EFCC_TESTS_SVH
`define RKV_EFCC_TESTS_SVH

`include "rkv_efcc_base_test.sv"
`include "rkv_efcc_csr_ctrl_reg_test.sv"
`include "rkv_efcc_csr_stat_reg_test.sv"
`include "rkv_efcc_csr_top_control_reg_test.sv"
`include "rkv_efcc_csr_fifo_in_reg_test.sv"
`include "rkv_efcc_csr_ctrl_reg_full_test.sv"
`include "rkv_efcc_pio_directed_test.sv"

`endif // RKV_EFCC_TESTS_SVH