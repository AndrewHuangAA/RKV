//====================================================================
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
// VisitUs  : www.rockeric.com
// Support  : support@rockeric.com
//====================================================================
// File             : rkv_efcc_reset_test.sv
// Created          : 2026-03-15
// Version          : 1.0
//
// Description :
// - Test EFCC could work after reset.
//
// Revision History:
// Date         Version     Change Description
//--------------------------------------------------------------------
//
//====================================================================
`ifndef RKV_EFCC_RESET_TEST_SV
`define RKV_EFCC_RESET_TEST_SV

class rkv_efcc_reset_test extends rkv_efcc_base_test;

  int unsigned src_addr, dst_addr; // packets loaded & stored with SRAM

  function new();
    super.new();
    name = "rkv_efcc_reset_test";
    src_addr = 32'h1000;
    dst_addr = 32'h2000;
  endfunction

  task run();
    super.run();
    repeat(10) begin
      efcc_vif.do_reset();
      pio_mode_test();

      efcc_vif.do_reset();
      dma_mode_test();
    end
  endtask

  task pio_mode_test();
    rkv_efcc_transaction tx = new();
    rkv_efcc_transaction rx = new();
    set_efcc_enable();
    // Go into PIO Mode
    set_work_mode(PIO);

    //****************************************************************
    // PIO Write a Packet
    //****************************************************************
    // Prepare a Transmit Packet to PIO
    tx = prepare_packet();
    // Write the Packet into EFCC CSR Transmit-Buffer
    pio_write_packet(tx);
    // Enable EFCC, Select PIO mode and Write Direction
    set_pio_rw_sel(PUSH);
    set_pio_enable();
    // Push and Wait until Transmit Packet Done via tb_ctrl.done field
    pio_tb_push_wait_done();

    //****************************************************************
    // PIO Read a Packet
    //****************************************************************
    // Switch to PIO Read Direction
    set_pio_rw_sel(POP);
    set_pio_enable();
    // Pop and Wait until Receive Buffer Got an Available Packet via rb_ctrl.done field
    pio_rb_pop_wait_done();
    // Recevie the Packet from PIO
    pio_read_packet(rx);

  endtask

  task dma_mode_test();
    bit ch;
    efcc_tr_arr wr_tr_arr, rd_tr_arr;
    int pkt_num;
    intr_kind_e intr_kind;
    // Reset Memory
    mem.reset();

    set_efcc_enable();
    // Set DMA Work Mode
    set_work_mode(DMA);
    // Enable DMA Interrupt
    set_intr_en(CH0_DONE);
    set_intr_en(CH1_DONE);

    // Prepare efcc transaction array
    pkt_num = $urandom_range(1, 8);
    wr_tr_arr = prepare_packet_array(pkt_num, src_addr);

    // Store the packet array into SRAM via backdoor
    bd_write_pkt_array(wr_tr_arr);

    // Select a channel and do data transfer with check
    // Channel Read
    ch = $urandom_range(0, 1);
    setup_reg_dma_mode(PUSH, pkt_num, src_addr, ch);
    intr_kind = ch == 0 ? CH0_DONE : CH1_DONE;
    wait_intr_stat(intr_kind); // Wait Until Channle Work Done
    set_intr_clr(intr_kind); // Clear Interrupt

    // Channel Write
    ch = $urandom_range(0, 1);
    setup_reg_dma_mode(POP, pkt_num, dst_addr, ch);
    intr_kind = ch == 0 ? CH0_DONE : CH1_DONE;
    wait_intr_stat(intr_kind); // Wait Until Channle Work Done
    set_intr_clr(intr_kind); // Clear Interrupt

    // Back Read Packet Array
    rd_tr_arr = bd_read_pkt_array(dst_addr, pkt_num);
  endtask

endclass

`endif