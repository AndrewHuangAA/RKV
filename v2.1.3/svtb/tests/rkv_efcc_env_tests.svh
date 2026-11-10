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
`include "rkv_efcc_pio_directed_test.sv"
`include "rkv_efcc_dma_directed_test.sv"
`include "rkv_efcc_work_mode_switch_test.sv"
`include "rkv_efcc_dma_dual_channel_work_test.sv"
`include "rkv_efcc_disable_test.sv"
`include "rkv_efcc_dma_interrupt_test.sv"
`include "rkv_efcc_reset_test.sv"
`include "rkv_efcc_clk_gating_test.sv"

`endif // RKV_EFCC_TESTS_SVH