`ifndef RKV_EFCC_DMA_DUAL_CHANNEL_WORK_TEST_SV
`define RKV_EFCC_DMA_DUAL_CHANNEL_WORK_TEST_SV

class rkv_efcc_dma_dual_channel_work_test extends rkv_efcc_base_test;

  int unsigned src_addr, dst_addr; // packets loaded & stored with SRAM

  function new();
    src_addr[31:28] = 'h1;
    dst_addr[31:28] = 'h2;
  endfunction

  task run();
    bit dual_chnl_mode; // dma_rw_sel, 0 : CH0 Read, CH1 Write, 1: CH0 Write, CH1 Read
    efcc_tr_arr wr_tr_arr, rd_tr_arr;
    int pkt_num;
    super.run();
    // Go into DMA Mode
    set_efcc_enable();
    set_work_mode(DMA);

    repeat(10) begin
      dual_chnl_mode = $urandom_range(0, 1);

      src_addr[27:24] = $urandom();
      dst_addr[27:24] = $urandom();

      // Prepare efcc transaction array
      pkt_num = $urandom_range(1, 8);
      wr_tr_arr = prepare_packet_array(pkt_num, src_addr);

      // Store the packet array into SRAM via backdoor
      bd_write_pkt_array(wr_tr_arr);

      // Require DMA Dual Channel Work, One for Read, the Other for Write
      setup_reg_dma_dual_chnl(dual_chnl_mode, pkt_num, src_addr, dst_addr);
      #2us;

      // Back Read Packet Array
      rd_tr_arr = bd_read_pkt_array(dst_addr, pkt_num);

      // Compare Packet Array
      if(!compare_packet_array(wr_tr_arr, rd_tr_arr))
        $error("Compared Failure! SRAM Write Transaction Array !=  Read Transaction Array");
      else
        $display("Compared Success! SRAM Write Transaction Array ==  Read Transaction Array");
    end
  endtask

endclass

`endif // RKV_EFCC_DMA_DUAL_CHANNEL_WORK_TEST_SV