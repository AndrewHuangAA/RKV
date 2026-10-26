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
// File        : rkv_efcc_tb.sv
// Created     : 2026-10-16
// Version     : 1.0
//
// Description :
// - EFCC module top testbench.
// - Instantied EFCC, stimulus drive
// - DUT signals probe.
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
module rkv_efcc_tb;

  import lvc_apb_pkg::*;
  import lvc_sram_pkg::*;
  import rkv_efcc_pkg::*;
  `include "rkv_efcc_defines.svh" // 因為 rkv_efcc_csr_fifo_in_reg_test.sv 裡面的force，所有造成pkg跟test暫時分開編譯

  bit clk;
  bit rstn;
  int unsigned clk_peroid = 10; // ns, 100MHz

  initial begin : clk_gen
  forever #((clk_peroid/2.0) * 1ns) clk <= !clk;
  end

  initial begin : rstn_gen
  rstn <= 1'b1;
  #13ns rstn <= 1'b0;
  repeat(10) @(posedge clk);
  rstn <= 1'b1;
  end

  rkv_efcc_top dut(
  // system signals
  .clk_i                (clk            ),
  .rstn_i               (rstn           ),
  // apb signals
  .psel_i               (apb_if.psel    ),
  .penable_i            (apb_if.penable ),
  .paddr_i              (apb_if.paddr   ),
  .pwdata_i             (apb_if.pwdata  ),
  .pwrite_i             (apb_if.pwrite  ),
  .prdata_o             (apb_if.prdata  ),
  .pready_o             (apb_if.pready  ),
  .pslverr_o            (apb_if.pslverr ),
  // sram signals
  .efcc_sram2dma_doa_i  (sram_if.doa    ),
  .efcc_sram2dma_dob_i  (sram_if.dob    ),
  .efcc_dma2sram_ena_o  (sram_if.ena    ),
  .efcc_dma2sram_wea_o  (sram_if.wea    ),
  .efcc_dma2sram_addra_o(sram_if.addra  ),
  .efcc_dma2sram_dia_o  (sram_if.dia    ),
  .efcc_dma2sram_enb_o  (sram_if.enb    ),
  .efcc_dma2sram_web_o  (sram_if.web    ),
  .efcc_dma2sram_addrb_o(sram_if.addrb  ),
  .efcc_dma2sram_dib_o  (sram_if.dib    )
  );

  lvc_apb_interface apb_if(clk, rstn);
  lvc_sram_interface sram_if(clk, clk);

  lvc_apb_master_initiator apb_init;

  initial begin
    string testname;
    // rkv_efcc_base_test test[string];
    rkv_efcc_base_test base_test;
    $value$plusargs("TESTNAME=%s", testname);
    // Select a Testcase
    case(testname)
      "rkv_efcc_csr_ctrl_reg_test"        : begin 
                                            rkv_efcc_csr_ctrl_reg_test        test = new();
                                            base_test = test; 
                                            end

      "rkv_efcc_csr_stat_reg_test"        : begin 
                                            rkv_efcc_csr_stat_reg_test        test = new();
                                            base_test = test;
                                            end

      "rkv_efcc_csr_top_control_reg_test" : begin 
                                            rkv_efcc_csr_top_control_reg_test test = new();
                                            base_test = test;
                                            end

      "rkv_efcc_csr_fifo_in_reg_test"     : begin 
                                            rkv_efcc_csr_fifo_in_reg_test     test = new();
                                            base_test = test;
                                            end

      "rkv_efcc_csr_ctrl_reg_full_test"   : begin 
                                            rkv_efcc_csr_ctrl_reg_full_test   test = new();
                                            base_test = test;
                                            end

      "rkv_efcc_pio_directed_test"        : begin 
                                            rkv_efcc_pio_directed_test        test = new();
                                            base_test = test;
                                            end
      "rkv_efcc_dma_directed_test"        : begin 
                                            rkv_efcc_dma_directed_test        test = new();
                                            base_test = test;
                                            end
      default: $fatal("Test Name [%s] Unrecognized!", testname);
    endcase
    base_test.build();
    // base_test.apb_vif = apb_if;  // 頂部傳下來給test，test再connect
    base_test.connect(apb_if, sram_if);      // 頂部傳下來給test，test再connect
    base_test.run();
    base_test.post_run();  // 就等1us
    base_test.report();
    $finish();
  end



endmodule