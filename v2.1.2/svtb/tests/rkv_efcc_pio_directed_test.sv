`ifndef RKV_EFCC_PIO_DIRECTED_TEST_SV
`define RKV_EFCC_PIO_DIRECTED_TEST_SV

class rkv_efcc_pio_directed_test extends rkv_efcc_base_test;

  task run();
    rkv_efcc_transaction tx = new();
    rkv_efcc_transaction rx = new();
    super.run();
    // Go into PIO Mode
    set_efcc_enable();
    set_work_mode(PIO);

    repeat(10) begin
      //***************************************************
      // PIO Write a Packet
      //***************************************************
      // Prepare a "Random Transmit Packet" to PIO
      tx = prepare_packet();
      // Write the Packet into EFCC CSR Transmit-Buffer
      pio_write_packet(tx);
      // Enable EFCC, Select PIO mode and Write Direction
      set_pio_rw_sel(PUSH); // PUSH=0 (CSR to FLT)
      set_pio_enable();
      // Push and Wait until Transmit Packet Done via tb_ctrl.done field
      pio_tb_push_wait_done();

      //***************************************************
      // PIO Read a Packet
      //***************************************************
      // Switch to PIO Read Direction
      set_pio_rw_sel(POP);
      set_pio_enable();
      // Pop and Wait until Receive Buffer Got an Available Packet via rb_ctrl.done field
      pio_rb_pop_wait_done();
      // Recevie the Packet from PIO
      pio_read_packet(rx);

      //***************************************************
      // Data Compare
      //***************************************************
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
    end
  endtask

  function rkv_efcc_transaction prepare_packet();
    rkv_efcc_transaction t = new();
    t.generate_payload(1); // Random Payload Generated
    return t;
  endfunction

endclass

`endif // RKV_EFCC_PIO_DIRECTED_TEST_SV
