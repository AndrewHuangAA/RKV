`ifndef RKV_EFCC_WORK_MODE_SWITCH_TEST_SV
`define RKV_EFCC_WORK_MODE_SWITCH_TEST_SV

class rkv_efcc_work_mode_switch_test extends rkv_efcc_base_test;

  int unsigned src_addr, dst_addr; // packets loaded & stored with SRAM

  function new();
    src_addr = 32'h1000;
    dst_addr = 32'h2000;
  endfunction

  task run();
    super.run();
    // Enable EFCC
    set_efcc_enable();

    repeat(10) begin
      pio_mode_test();
      dma_mode_test();
    end
  endtask

  task pio_mode_test();
    rkv_efcc_transaction tx = new();
    rkv_efcc_transaction rx = new();
    // Go into PIO Mode
    set_work_mode(PIO);

    //*****************************************************
    // PIO Write a Packet
    //*****************************************************
    // Prepare a Transmit Packet to PIO
    tx = prepare_packet();
    // Write the Packet into EFCC CSR Transmit-Buffer
    pio_write_packet(tx);
    // Enable EFCC, Select PIO mode and Write Direction
    set_pio_rw_sel(PUSH);
    set_pio_enable();
    // Push and Wait until Transmit Packet Done via tb_ctrl.done field
    pio_tb_push_wait_done();

    //*****************************************************
    // PIO Read a Packet
    //*****************************************************
    // Switch to PIO Read Direction
    set_pio_rw_sel(POP);
    set_pio_enable();
    // Pop and Wait until Receive Buffer Got an Available Packet via rb_ctrl.done field
    pio_rb_pop_wait_done();
    // Recevie the Packet from PIO
    pio_read_packet(rx);

    //*****************************************************
    // Data Compare
    //*****************************************************
    // Compare TX packet and RX packet
    if(!tx.compare(rx)) begin
      err_count++;
      $error("TX packet compared RX packet FAILURE!");
      tx.print();
      rx.print();
    end
    else
      $display("TX packet compared RX packet SUCCESS!");
    cmp_count++;
  endtask

  task dma_mode_test();
    bit ch;
    efcc_tr_arr wr_tr_arr, rd_tr_arr;
    int pkt_num;

    // Set DMA Work Mode
    set_work_mode(DMA);

    // Prepare efcc transaction array
    pkt_num = $urandom_range(1, 8);
    wr_tr_arr = prepare_packet_array(pkt_num, src_addr);

    // Store the packet array into SRAM via backdoor
    bd_write_pkt_array(wr_tr_arr);

    // Select a channel and do data transfer with check
    // Channel Read
    ch = $urandom_range(0, 1);
    setup_reg_dma_mode(PUSH, pkt_num, src_addr, ch);
    #1us;

    // Channel Write
    ch = $urandom_range(0, 1);
    setup_reg_dma_mode(POP, pkt_num, dst_addr, ch);
    #1us;

    // Back Read Packet Array
    rd_tr_arr = bd_read_pkt_array(dst_addr, pkt_num);

    // Compare Packet Array
    if(!compare_packet_array(wr_tr_arr, rd_tr_arr))
      $error("Compared Failure! SRAM Write Transaction Array !=  Read Transaction Array");
    else
      $display("Compared Success! SRAM Write Transaction Array ==  Read Transaction Array");
  endtask

endclass

`endif
