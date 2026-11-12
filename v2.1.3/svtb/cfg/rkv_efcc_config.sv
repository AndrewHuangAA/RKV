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
// File        : rkv_efcc_config.sv
// Created     : 2026-03-15
// Version     : 1.0
//
// Description :
// - EFCC top config, responsbile for environment control and variables
//   share.
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef RKV_EFCC_CONFIG_SV
`define RKV_EFCC_CONFIG_SV

class rkv_efcc_config;

  int scb_check_count;                   // Count the number of times the scoreboard comparison pass
  int scb_check_error;                   // Count the number of times the scoreboard comparison fails
  int seq_check_count;                   // Count the number of times the sequence comparison pass
  int seq_check_error;                   // Count the number of times the sequence comparison fails

  int scb_packet_desired_number = 0;     // Desired Packet Number Given from Test/Sequence
  bit scb_check_enable = 1;              // Overall Enable scoreboard;
  bit scb_packet_number_check = 1;       // Check Actual and Expected Packet Number Match
  bit scb_packet_buffer_empty_check = 1; // Check NO Left Packets at Simulation End

  time drain_time = 1us;                 // Simulation Drain Time after Test Finished

endclass

`endif