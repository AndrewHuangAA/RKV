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
// Created     : 2026-02-25
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

parameter int unsigned EFCC_TOP_CONTROL_REG_ADDR  = 32'h0000;
parameter int unsigned EFCC_TOP_STATUS_REG_ADDR   = 32'h0004;
parameter int unsigned EFCC_FILTER_ID_REG_ADDR    = 32'h0008;
parameter int unsigned EFCC_FILTER_MASK_REG_ADDR  = 32'h000C;
parameter int unsigned EFCC_FIFO_IN_REG_ADDR      = 32'h0010;
parameter int unsigned EFCC_FIFO_OUT_REG_ADDR     = 32'h0014;
parameter int unsigned EFCC_INTR_STATUS_REG_ADDR  = 32'h0018;
parameter int unsigned EFCC_INTR_EN_REG_ADDR      = 32'h001C;
parameter int unsigned EFCC_INTR_CLR_REG_ADDR     = 32'h0020;

typedef enum {IDLE, WRITE, READ} apb_trans_kind;
typedef enum {OK, ERROR} apb_trans_status;

typedef struct {
  bit [31:0]        addr;
  bit [31:0]        data;
  apb_trans_kind    trans_kind;
  apb_trans_status  trans_status;
  int               idle_cycles;
  bit [31:0]        expd; // Expected Data
} apb_transfer;

function automatic void print_apb_transfer(const ref apb_transfer t);
  string msg = "********APB Transfer Content is *********\n";
  msg = {msg, $sformatf("addr = 32'h%8x \n", t.addr)};
  msg = {msg, $sformatf("data = 32'h%8x \n", t.data)};
  msg = {msg, $sformatf("trans_kind = %s \n", t.trans_kind.name())};
  msg = {msg, $sformatf("trans_status = %s \n", t.trans_status.name())};
  msg = {msg, $sformatf("idle_cycles = %0d \n", t.idle_cycles)};
  msg = {msg, "*****************************************\n"};
  $display(msg);
endfunction

module apb_master_initiator(
  input               clk_i,
  input               rstn_i,
  output logic        psel_o,
  output logic        penable_o,
  output logic [31:0] paddr_o,
  output logic [31:0] pwdata_o,
  output logic        pwrite_o,
  input        [31:0] prdata_i,
  input               pready_i,
  input               pslverr_i
);

task automatic drive_transfer (ref apb_transfer t);
  case(t.trans_kind)
    IDLE  : do_idle();
    WRITE : do_write(t);
    READ  : do_read(t);
  endcase
  print_apb_transfer(t);
endtask : drive_transfer

task automatic do_idle();
  @(posedge clk_i);
    psel_o    <= 0;
    penable_o <= 0;
    pwdata_o  <= 0;
endtask: do_idle

task automatic do_write(ref apb_transfer t);
  @(posedge clk_i);
    paddr_o   <= t.addr;
    pwrite_o  <= 1;
    psel_o    <= 1;
    penable_o <= 0;
    pwdata_o  <= t.data;
  @(posedge clk_i);
    penable_o <= 1;
    #10ps;
    wait(pready_i === 1);
    #10ps;
    t.trans_status = pslverr_i === 1 ? ERROR : OK;
    repeat(t.idle_cycles) do_idle();
endtask

task automatic do_read(ref apb_transfer t);
  @(posedge clk_i);
    paddr_o   <= t.addr;
    pwrite_o  <= 0;
    psel_o    <= 1;
    penable_o <= 0;
  @(posedge clk_i);
    penable_o <= 1;
    #10ps;
    wait(pready_i === 1);
    #10ps;
    t.trans_status = pslverr_i === 1 ? ERROR : OK;
    t.data = prdata_i;
    repeat(t.idle_cycles) do_idle();
endtask

task automatic do_reset();
  @(negedge rstn_i);
    paddr_o   <= 0;
    pwrite_o  <= 0;
    psel_o    <= 0;
    penable_o <= 0;
    pwdata_o  <= 0;
endtask
endmodule

module rkv_efcc_tb;
    bit clk;
    bit rstn;
    int unsigned clk_peroid = 10; // ns, 100MHz
    static int unsigned cmp_count, err_count;

    // APB bus
    logic        psel;
    logic        penable;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic        pwrite;
    logic [31:0] prdata;
    logic        pready;
    logic        pslverr;

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
    .clk_i                (clk    ),
    .rstn_i               (rstn   ),
    // apb signals
    .psel_i               (psel   ),
    .penable_i            (penable),
    .paddr_i              (paddr  ),
    .pwdata_i             (pwdata ),
    .pwrite_i             (pwrite ),
    .prdata_o             (prdata ),
    .pready_o             (pready ),
    .pslverr_o            (pslverr),
    // sram signals
    .efcc_sram2dma_doa_i  ('0     ),
    .efcc_sram2dma_dob_i  ('0     ),
    .efcc_dma2sram_ena_o  (       ),
    .efcc_dma2sram_wea_o  (       ),
    .efcc_dma2sram_addra_o(       ),
    .efcc_dma2sram_dia_o  (       ),
    .efcc_dma2sram_enb_o  (       ),
    .efcc_dma2sram_web_o  (       ),
    .efcc_dma2sram_addrb_o(       ),
    .efcc_dma2sram_dib_o  (       )
    );

    apb_master_initiator apb_init(
    .clk_i     (clk    ),
    .rstn_i    (rstn   ),
    .psel_o    (psel   ),
    .penable_o (penable),
    .paddr_o   (paddr  ),
    .pwdata_o  (pwdata ),
    .pwrite_o  (pwrite ),
    .prdata_i  (prdata ),
    .pready_i  (pready ),
    .pslverr_i (pslverr)
    );

    initial begin
        string testname;
        $value$plusargs("TESTNAME=%s", testname);
        apb_init.do_reset();
        @(posedge rstn);
        repeat(5) @(posedge clk);
        // Select a Testcase
        case(testname)
            "rkv_efcc_csr_ctrl_reg_test": rkv_efcc_csr_ctrl_reg_test();
            "rkv_efcc_csr_stat_reg_test": rkv_efcc_csr_stat_reg_test();
            "rkv_efcc_csr_top_control_reg_test": rkv_efcc_csr_top_control_reg_test();
            "rkv_efcc_csr_fifo_in_reg_test": rkv_efcc_csr_fifo_in_reg_test();
            "rkv_efcc_csr_ctrl_reg_full_test": rkv_efcc_csr_ctrl_reg_full_test();
            default: $fatal("Test Name [%s] Unrecognized!", testname);
        endcase
        #1us;
        report();
        $finish();
    end

    task automatic rkv_efcc_csr_ctrl_reg_test();
        apb_transfer t;
        $display("rkv_efcc_csr_ctrl_reg_test STARTED!");
        t.addr = EFCC_TOP_CONTROL_REG_ADDR;
        // Specify read transaction for reset value check
        t.trans_kind = READ;
        apb_init.drive_transfer(t);
        compare_data(t.data, 0, "Compare Top Control Reg Reset Value");

        // Specify write transaction
        t.trans_kind = WRITE;
        t.data = 32'h1;
        apb_init.drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        apb_init.drive_transfer(t);
        compare_data(t.data, 32'h1, "Compare Top Control Reg Config Value");

        // Specify write reserved field transaction
        t.trans_kind = WRITE;
        t.data[31:9] = '1;
        t.data[ 8:0] = 0;
        apb_init.drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        apb_init.drive_transfer(t);
        compare_data(t.data, 32'h0, "Compare Top Control Reg Config Value");

        // Specify write write-clear field transaction
        t = '{addr:EFCC_TOP_CONTROL_REG_ADDR, trans_kind:WRITE, default:0};
        //t.addr = EFCC_TOP_CONTROL_REG_ADDR;
        //t.trans_kind = WRITE;
        t.data[1] = 1'b1;
        t.data[2] = 1'b1;
        apb_init.drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        apb_init.drive_transfer(t);
        compare_data(t.data, 32'h0, "Compare Top Control Reg Config Value");

        t.trans_kind = IDLE;
        apb_init.drive_transfer(t);
        $display("rkv_efcc_csr_ctrl_reg_test FINISHED!");
        endtask

        task automatic rkv_efcc_csr_stat_reg_test();
        apb_transfer t;
        apb_transfer tq[$];
        $display("rkv_efcc_csr_stat_reg_test STARTED!");
        // Specify a Read Operation
        t.addr = EFCC_FIFO_IN_REG_ADDR;
        t.trans_kind = READ;
        t.expd = 'h82;
        tq.push_back(t);
        // Specify a Write Operation
        t.trans_kind = WRITE;
        t.data = 'h10;
        tq.push_back(t);
        // Specify a Read Operation
        t.addr = EFCC_FIFO_IN_REG_ADDR;
        t.trans_kind = READ;
        t.expd = 'h82;
        t.idle_cycles = 1;
        tq.push_back(t);

        while(tq.size() != 0) begin
        t = tq.pop_front();
        apb_init.drive_transfer(t);
        if(t.trans_kind == READ)
            compare_data(t.data, t.expd, "CMP_STAT_REG");
        end
        $display("rkv_efcc_csr_stat_reg_test FINISHED!");
    endtask

    task automatic rkv_efcc_csr_stat_reg_test();
        apb_transfer t;
        apb_transfer tq[$];
        $display("rkv_efcc_csr_stat_reg_test STARTED!");
        // Specify a Read Operation
        t.addr = EFCC_FIFO_IN_REG_ADDR;
        t.trans_kind = READ;
        t.expd = 'h82;
        tq.push_back(t);
        // Specify a Write Operation
        t.trans_kind = WRITE;
        t.data = 'h10;
        tq.push_back(t);
        // Specify a Read Operation
        t.addr = EFCC_FIFO_IN_REG_ADDR;
        t.trans_kind = READ;
        t.expd = 'h82;
        t.idle_cycles = 1;
        tq.push_back(t);

        while(tq.size() != 0) begin
            t = tq.pop_front();
            apb_init.drive_transfer(t);
            if(t.trans_kind == READ)
                compare_data(t.data, t.expd, "CMP_STAT_REG");
        end
        $display("rkv_efcc_csr_stat_reg_test FINISHED!");
    endtask

    function automatic bit compare_data(int unsigned d1, int unsigned d2, string tag = "CMPDAT");
        compare_data = (d1 === d2);
        cmp_count++;
        if(!compare_data) begin
        $error("%s: compare failure! data1 'h%0x != data2 'h%0x", tag, d1, d2);
        err_count++;
        $stop();
        end
        else
        $display("%s: compare success! data1 'h%0x == data2 'h%0x", tag, d1, d2);
    endfunction

    function automatic void report();
        string msg = "************ Test Report ************ \n";
        msg = {msg, $sformatf("Compre Count = %0d \n", cmp_count)};
        msg = {msg, $sformatf("Error Count = %0d \n", err_count)};
        if(err_count != 0)
        msg = {msg, "Test Failed \n"};
        else
        msg = {msg, "Test Passed \n"};
        msg = {msg, "************************************* \n"};
        $display(msg);
    endfunction

    task automatic rkv_efcc_csr_top_control_reg_test();
        apb_transfer t;
        $display("rkv_efcc_csr_top_contorl_reg_test STARTED!");
        t.addr = EFCC_TOP_CONTROL_REG_ADDR;
        // Specify read transaction for reset value check
        t.trans_kind = READ;
        apb_init.drive_transfer(t);
        compare_data(t.data, 0, "Compare Top Control Reg Reset Value");

        // Specify write transaction
        t.trans_kind = WRITE;
        t.data = 32'hFFFF_FFFF;
        apb_init.drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        apb_init.drive_transfer(t);
        compare_data(t.data, 32'h0000_0179, "Compare Top Control Reg Config Value");

        // Specify write transaction
        t.trans_kind = WRITE;
        t.data = 32'h0;
        apb_init.drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        t.idle_cycles = 1;
        apb_init.drive_transfer(t);
        compare_data(t.data, 0, "Compare Top Control Reg Config Value");

        $display("rkv_efcc_csr_top_control_reg_test FINISHED!");
    endtask
    
    task automatic rkv_efcc_csr_fifo_in_reg_test();
        apb_transfer t;
        $display("rkv_efcc_csr_fifo_in_reg_test STARTED!");
        t.addr = EFCC_FIFO_IN_REG_ADDR;

        // Specify read transaction for reset value check
        t.trans_kind = READ;
        apb_init.drive_transfer(t);
        compare_data(t.data, 'h82, "Compare Top Control Reg Reset Value");

        // Specify write transaction for RO fields test
        t.trans_kind = WRITE;
        t.data = '1;
        t.data[10] = 0;
        apb_init.drive_transfer(t);

        // Specify read transaction for RO value check
        t.trans_kind = READ;
        apb_init.drive_transfer(t);
        compare_data(t.data, 'h82, "Compare Top Control Reg Reset Value");

        // Specify read transaction for status fields update check
        // Force FIFO-IN submodule output for connection & update check
        force rkv_efcc_tb.dut.fifo_in.margin_o = 'h15;
        // release rkv_efcc_tb.dut.fifo_in.margin_o;
        t.trans_kind = READ;
        t.idle_cycles = 1;
        apb_init.drive_transfer(t);
        compare_data(t.data, ((8'h15 << 2) | (1'b1 << 1)), "Compare Top Control Reg Reset Value");

        $display("rkv_efcc_csr_fifo_in_reg_test FINISHED!");
    endtask
    
    typedef struct {
        bit [31:0] addr;
        bit [31:0] reset_expd;
        bit [31:0] all_one_tval;
        bit [31:0] all_one_expd;
    } csr_ctrl_reg_test_struct;

    task automatic rkv_efcc_csr_ctrl_reg_full_test;
        csr_ctrl_reg_test_struct ctrl_reg_test_q[$];
        csr_ctrl_reg_test_struct ctrl_reg_test;
        apb_transfer t;
        //-------------------------------------------------------------
        // Specify All Control Registers Test Pattern
        //-------------------------------------------------------------
        // Top Control Reg
        ctrl_reg_test = '{addr:EFCC_TOP_CONTROL_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'h179};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // Filter ID Reg
        ctrl_reg_test = '{addr:EFCC_FILTER_ID_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'hFF_FFFF};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // Filter Mask Reg
        ctrl_reg_test = '{addr:EFCC_FILTER_MASK_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'hFF_FFFF};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // Interrupt Enable Reg
        ctrl_reg_test = '{addr:EFCC_INTR_EN_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'h3F};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // Interreupt Clear Reg
        ctrl_reg_test = '{addr:EFCC_INTR_CLR_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'h0};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // TODO:: Add Other Control Registers ...
        // ctrl_reg_test = '{addr:, reset_expd:, all_one_tval:'1, all_one_expd:};

        $display("rkv_efcc_csr_ctrl_reg_full_test STARTED!");
        foreach(ctrl_reg_test_q[i]) begin
            t = '{default:0}; // initialization
            ctrl_reg_test = ctrl_reg_test_q[i];
            t.addr = ctrl_reg_test.addr;
            // Specify read transaction for reset value check
            t.trans_kind = READ;
            apb_init.drive_transfer(t);
            compare_data(t.data, ctrl_reg_test.reset_expd, "Compare Reset Value");

            // Specify write transaction
            t.trans_kind = WRITE;
            t.data = ctrl_reg_test.all_one_tval;
            apb_init.drive_transfer(t);

            // Specify read transaction
            t.trans_kind = READ;
            apb_init.drive_transfer(t);
            compare_data(t.data, ctrl_reg_test.all_one_expd, "Compare Config All-One's Value");

            // Specify write transaction
            t.trans_kind = WRITE;
            t.data = 32'h0;
            apb_init.drive_transfer(t);

            // Specify read transaction
            t.trans_kind = READ;
            t.idle_cycles = 1;
            apb_init.drive_transfer(t);
            compare_data(t.data, 0, "Compare Config All-Zero's Value");
        end
        $display("rkv_efcc_csr_ctrl_reg_full_test FINISHED!");
    endtask
endmodule