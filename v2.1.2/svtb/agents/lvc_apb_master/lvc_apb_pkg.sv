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
// File        : lvc_apb_pkg.sv
// Created     : 2026-10-20
// Version     : 1.0
//
// Description :
// - APB package.
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================

`ifndef LVC_APB_PKG_SV
`define LVC_APB_PKG_SV

package lvc_apb_pkg;
  
  `include "lvc_apb_transfer.sv"
  `include "lvc_apb_master_initiator.sv.sv"

endpackage


`endif // LVC_APB_PKG_SV