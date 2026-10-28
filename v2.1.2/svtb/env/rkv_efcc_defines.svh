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
// File        : rkv_efcc_defines.sv
// Created     : 2026-10-21
// Version     : 1.0
//
// Description :
// - EFCC defines.
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef RKV_EFCC_DEFINES_SV
`define RKV_EFCC_DEFINES_SV

// PUSH: external -> EFCC, POP: EFCC -> external (pio、dma)
typedef enum bit      {PUSH = 0   , POP = 1    } trans_kind_e; 
typedef enum bit[1:0] {PIO = 2'b00, DMA = 2'b01} trans_mode_e;

// L1DES (Layer 1 Descriptor) - 32 bits
typedef struct packed {
  logic [31:24] head;   // 8 bits
  logic [23:16] pid;    // 8 bits
  logic [15: 7] rsvd;   // 9 bits
  logic [ 6: 6] layer2; // 1 bit
  logic [ 5: 5] rc4;    // 1 bit
  logic [ 4: 4] crc;    // 1 bit
  logic [ 3: 0] length; // 4 bits
} l1des_t;

// L2DES (Layer 2 Descriptor) - 32 bits
typedef struct packed {
  logic [31:24] head;     // 8 bits
  logic [23:16] fid;      // 8 bits
  logic [15:12] did;      // 4 bits
  logic [11: 8] sid;      // 4 bits
  logic [ 7: 4] rsvd;     // 4 bits
  logic [ 3: 0] pkt_type; // 4 bits
} l2des_t;

// Tail (TL) - 32 bits
typedef struct packed {
  logic [31:16] rsvd;    // 16 bits
  logic [15: 8] crc;     // 8 bits
  logic [ 7: 0] pkt_end; // 8 bits
} tail_t;

typedef class rkv_efcc_transaction;
typedef rkv_efcc_transaction efcc_tr_arr [];

`endif // RKV_EFCC_DEFINES_SV
