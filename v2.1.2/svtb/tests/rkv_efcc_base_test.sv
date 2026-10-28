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
// File        : rkv_efcc_base_test.sv
// Created     : 2026-10-21
// Version     : 1.0
//
// Description :
// - EFCC base test.
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef RKV_EFCC_BASE_TEST_SV
`define RKV_EFCC_BASE_TEST_SV

class rkv_efcc_base_test;

    rkv_efcc_env env;
    lvc_mem mem;
    int unsigned cmp_count, err_count;
    virtual lvc_apb_interface apb_vif;
    virtual lvc_sram_interface sram_vif;

    virtual function void build();
        env = new();
        env.build(); //會去例化apb_init
    endfunction
    
    virtual function void connect(input virtual lvc_apb_interface   apb_vif
                                  input virtual lvc_ssram_interface sram_vif);
        this.apb_vif = apb_vif;
        this.sram_vif = sram_vif;
        env.apb_init.assign_if(apb_vif);
        env.sram_trgt.assign_if(sram_vif);
        mem = env.sram_trgt.mem; 
    endfunction

    virtual task post_run();
        #1us;
    endtask

    virtual task run();
        env.apb_init.do_reset();
        @(posedge apb_vif.rstn_i);
        repeat(5) @(posedge apb_vif.clk_i);
    endtask

    virtual task apb_drive_transfer(input lvc_apb_transfer t);
        env.apn_init.drive_transfer(t);
    endtask

    virtual task apb_write(input bit[31:0] addr, input bit[31:0] data, int unsigned idle_cycle = 1);
        lvc_apb_transfer t = new();
        t.addr = addr;
        t.data = data;
        t.trans_kind = WRITE;
        t.idle_cycle = idle_cycle;
        apb_drive_transfer(t);
        if(t.trans_status == ERROR) $error("APB Bus Got an Error Response!");
    endtask

    virtual task apb_read(input bit[31:0] addr, output bit[31:0] data, int unsigned idle_cycle = 1);
        lvc_apb_transfer t = new();
        t.addr = addr;
        t.trans_kind = READ;
        t.idle_cycle = idle_cycle;
        apb_drive_transfer(t);
        data = t.data;
        if(t.trans_status == ERROR) $error("APB Bus Got an Error Response!");
    endtask

    virtual function bit compare_data(int unsigned d1, int unsigned d2, string tag = "CMPDAT");
        compare_data = (d1 === d2);
        cmp_count++;
        if(!compare_data) begin
            $error("%s: compare failure! data1 'h%0x != data2 'h%0x", tag, d1, d2);
            err_count++;
            $stop();
        end else
            $display("%s: compare success! data1 'h%0x == data2 'h%0x", tag, d1, d2);
    endfunction

    virtual function void report();
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

    virtual task void set_efcc_enable(input bit en = 1);
        efcc_top_control_reg_struct top_control;
        apb_read(EFCC_TOP_CONTROL_REG_ADDR, top_control);
        top_control.efcc_en = en;
        apb_write(EFCC_TOP_CONTROL_REG_ADDR, top_control);
    endtask

    virtual task void set_work_mode(input trans_mode_e mode);
        efcc_top_control_reg_struct top_control;
        apb_read(EFCC_TOP_CONTROL_REG_ADDR, top_control);
        top_control.work_mode = mode;
        apb_write(EFCC_TOP_CONTROL_REG_ADDR, top_control);
    endtask

    virtual task void set_pio_enable(input bit en = 1);
        efcc_top_control_reg_struct top_control;
        apb_read(EFCC_TOP_CONTROL_REG_ADDR, top_control);
        top_control.pio_en_we = en;
        apb_write(EFCC_TOP_CONTROL_REG_ADDR, top_control);
    endtask

    virtual task void set_pio_rw_sel(input trans_kind_e rw);
        efcc_top_control_reg_struct top_control;
        apb_read(EFCC_TOP_CONTROL_REG_ADDR, top_control);
        top_control.pio_rw_sel = rw;
        apb_write(EFCC_TOP_CONTROL_REG_ADDR, top_control);
    endtask

    virtual task pio_write_packet(input rkv_efcc_transaction t);
        foreach(t.data_array[i]) begin
          case(i)
            t.data_array().size-1 : apb_write(EFCC_TB_TAIL_REG_ADDR , t.data_array[i]); // 怕TAIL被誤寫入DW
            0                     : apb_write(EFCC_TB_L1DES_REG_ADDR, t.data_array[i]);
            1                     : apb_write(EFCC_TB_DW1_REG_ADDR  , t.data_array[i]);
            2                     : apb_write(EFCC_TB_DW2_REG_ADDR  , t.data_array[i]);
            3                     : apb_write(EFCC_TB_DW3_REG_ADDR  , t.data_array[i]);
            4                     : apb_write(EFCC_TB_DW4_REG_ADDR  , t.data_array[i]);
            5                     : apb_write(EFCC_TB_DW5_REG_ADDR  , t.data_array[i]);
            6                     : apb_write(EFCC_TB_DW6_REG_ADDR  , t.data_array[i]);
            7                     : apb_write(EFCC_TB_DW7_REG_ADDR  , t.data_array[i]);
            8                     : apb_write(EFCC_TB_DW8_REG_ADDR  , t.data_array[i]);
            9                     : apb_write(EFCC_TB_DW9_REG_ADDR  , t.data_array[i]);
            10                    : apb_write(EFCC_TB_DW10_REG_ADDR , t.data_array[i]);
            11                    : apb_write(EFCC_TB_DW11_REG_ADDR , t.data_array[i]);
            12                    : apb_write(EFCC_TB_DW12_REG_ADDR , t.data_array[i]);
            13                    : apb_write(EFCC_TB_DW13_REG_ADDR , t.data_array[i]);
            14                    : apb_write(EFCC_TB_DW14_REG_ADDR , t.data_array[i]);
            default               : $error("EFCC Transaction Data Array Index [%0d] NOT Recognized!", i);
          endcase
        end
    endtask

    virtual task pio_read_packet(input rkv_efcc_transaction t);
        apb_read(EFCC_RB_L1DES_REG_ADDR, t.l1des);
        t.generate_payload(); // 先把pl清0，讓後面foreach的data_array能裝讀出來的pl
        foreach(t.data_array[i]) begin
          case(i)
            t.data_array().size-1 : apb_read(EFCC_RB_TAIL_REG_ADDR , t.data_array[i]);
            0                     : apb_read(EFCC_RB_L1DES_REG_ADDR, t.data_array[i]);
            1                     : apb_read(EFCC_RB_DW1_REG_ADDR  , t.data_array[i]);
            2                     : apb_read(EFCC_RB_DW2_REG_ADDR  , t.data_array[i]);
            3                     : apb_read(EFCC_RB_DW3_REG_ADDR  , t.data_array[i]);
            4                     : apb_read(EFCC_RB_DW4_REG_ADDR  , t.data_array[i]);
            5                     : apb_read(EFCC_RB_DW5_REG_ADDR  , t.data_array[i]);
            6                     : apb_read(EFCC_RB_DW6_REG_ADDR  , t.data_array[i]);
            7                     : apb_read(EFCC_RB_DW7_REG_ADDR  , t.data_array[i]);
            8                     : apb_read(EFCC_RB_DW8_REG_ADDR  , t.data_array[i]);
            9                     : apb_read(EFCC_RB_DW9_REG_ADDR  , t.data_array[i]);
            10                    : apb_read(EFCC_RB_DW10_REG_ADDR , t.data_array[i]);
            11                    : apb_read(EFCC_RB_DW11_REG_ADDR , t.data_array[i]);
            12                    : apb_read(EFCC_RB_DW12_REG_ADDR , t.data_array[i]);
            13                    : apb_read(EFCC_RB_DW13_REG_ADDR , t.data_array[i]);
            14                    : apb_read(EFCC_RB_DW14_REG_ADDR , t.data_array[i]);
            default               : $error("EFCC Transaction Data Array Index [%0d] NOT Recogonized!", i);
          endcase
        end
        if(t.l1des.layer2) t.l2des = t.data_array[1];
        t.tail = t.data_array[t.data_array.size() - 1];
    endtask

    // PUSH是脈衝訊號，觸發的時候就開始動作把DONE=1
    // 直到完成後DONE為0
    virtual task pio_tb_push_wait_done(input rkv_efcc_transaction t);
        efcc_tb_ctrl_reg_struct tb_ctrl;
        tb_ctrl.push = 1;
        apb_write(EFCC_TB_CTRL_REG_ADDR, tb_ctrl); // 給PUSH訊號用write
        do begin    // do...while他設定為至少必須讀取一次
            apb_read(EFCC_TB_CTRL_REG_ADDR, tb_ctrl);
            wait_cycles(100);
        end while(!tb_ctrl.done);
    endtask

    virtual task pio_rb_pop_wait_done(input rkv_efcc_transaction t);
        efcc_rb_ctrl_reg_struct rb_ctrl;
        rb_ctrl.pop = 1;
        apb_write(EFCC_RB_CTRL_REG_ADDR, rb_ctrl); // 給POP訊號用write
        do begin
            apb_read(EFCC_RB_CTRL_REG_ADDR, rb_ctrl);
            wait_cycles(100);
        end while(!rb_ctrl.done);
    endtask

    virtual task wait_cycles(input n);
        repeat(n) @(posedge apb_vif.clk_i);
    endtask

    virtual function void bd_write_pkt_array(efcc_tr_arr tr_arr);
      foreach(tr_arr[i])
        foreach(tr_arr[i].data_array[j])
          // 第1個addr就是l1des，第2個就是pl/l2des...
          bd_write_word(tr_arr[i].addr + j*4, tr_arr[i].data_array[j]);
    endfunction

    virtual function efcc_tr_arr bd_read_pkt_array(int unsigned addr, int unsigned pkt_num);
      int data_arr_size;
      efcc_tr_arr tr_arr = new[pkt_num];

      foreach(tr_arr[i]) begin
        tr_arr[i] = new();
        if(i == 0)
          tr_arr[i].addr = addr;
        else
          tr_arr[i].addr = tr_arr[i-1].addr + tr_arr[i-1].get_size();
        tr_arr[i].l1des = bd_read_word(tr_arr[i].addr);
        data_arr_size = tr_arr[i].l1des.layer2 ? tr_arr[i].l1des.length + 3 : tr_arr[i].l1des.length + 2;
        tr_arr[i].data_array = new[data_arr_size];
        foreach(tr_arr[i].data_array[j])
          tr_arr[i].data_array[j] = bd_read_word(tr_arr[i].addr + 4*j);
        if(tr_arr[i].l1des.layer2)
          tr_arr[i].l2des = tr_arr[i].data_array[1];
        tr_arr[i].tail = tr_arr[i].data_array[data_arr_size - 1];
      end
      return tr_arr;
    endfunction

    virtual function void bd_write_word(bit [31:0] addr, bit [31:0] data);
      mem.write(addr, data);
    endfunction

    virtual function bit [31:0] bd_read_word(bit [31:0] addr);
      return mem.read(addr);
    endfunction

    virtual function void setup_reg_dma_mode(trans_kind_e kind, bit[3:0] pkt_num, bit[31:0] addr, bit ch);
        efcc_ch_ctrl_reg_struct ch_ctrl;
        efcc_top_control_reg_struct top_control;
        efcc_intr_en_reg_struct intr_en;

        // Enable DMA Interrupt
        intr_en.ch0_done_en = 1;
        intr_en.ch1_done_en = 1;
        apb_write(EFCC_INTR_EN_REG_ADDR, intr_en);

        // Get Top Control Reg Value
        apb_read(EFCC_TOP_CONTROL_REG_ADDR, top_control);

        case(kind)
          POP : begin // 硬體處理完後，要將資料POP From Sel to SRAM，所以要給他目的位址
            top_control.dma_rw_sel = ch == 0 ? 1 : 0;
            ch_ctrl.dst_pkt_num = pkt_num - 1;
            if(ch == 0) begin // 選擇要用ch0/ch1讀出來
              apb_write(EFCC_CH0_CTRL_REG_ADDR, ch_ctrl);
              apb_write(EFCC_CH0_DADDR_REG_ADDR, addr);
            end
            else begin
              apb_write(EFCC_CH1_CTRL_REG_ADDR, ch_ctrl);
              apb_write(EFCC_CH1_DADDR_REG_ADDR, addr);
            end
          end
          PUSH : begin // 把資料從SRAM PUSH to FLT，那應該是給他SRAM的來源地址
            top_control.dma_rw_sel = ch == 0 ? 0 : 1;
            ch_ctrl.src_pkt_num = pkt_num - 1;
            if(ch == 0) begin // 選擇要用ch0/ch1寫進去
              apb_write(EFCC_CH0_CTRL_REG_ADDR, ch_ctrl);
              apb_write(EFCC_CH0_SADDR_REG_ADDR, addr);
            end
            else begin
              apb_write(EFCC_CH1_CTRL_REG_ADDR, ch_ctrl);
              apb_write(EFCC_CH1_SADDR_REG_ADDR, addr);
            end
          end
        endcase
    endfunction

    function bit compare_packet_array(efcc_tr_arr arr1, efcc_tr_arr arr2);
      cmp_count++; //compare size
      if(arr1.size() != arr2.size()) begin
        err_count++;
        $error("Compared Packet Array Size Mismatch, Array1 Size [%0d], Array2 Size [%0d]", arr1.size(), arr2.size());
        return 0;
      end
      else begin
        foreach(arr1[i]) begin
          cmp_count++;
          if(!arr1[i].compare(arr2[i])) begin
            err_count++;
            $error("TX packet compared RX packet FAILURE!");
            arr1[i].print();
            arr2[i].print();
            return 0;
          end
          else
            $display("TX packet compared RX packet SUCCESS!");
        end
      end
      return 1;
    endfunction

endclass


`endif // RKV_EFCC_BASE_TEST_SV