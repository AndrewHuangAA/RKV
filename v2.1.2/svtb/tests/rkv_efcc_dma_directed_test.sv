`ifndef RKV_EFCC_DMA_DIRECTED_TEST_SV
`define RKV_EFCC_DMA_DIRECTED_TEST_SV

class rkv_efcc_dma_directed_test extends rkv_efcc_base_test;
  
  int unsigned src_addr, dst_addr; // packets loaded & stored with SRAM

  function new();
    src_addr = 32'h1000;
    dst_addr = 32'h2000;
  endfunction

  task run();
    bit ch;
    efcc_tr_arr wr_tr_arr, rd_tr_arr;
    int pkt_num;
    super.run();
    // Go into DMA Mode
    set_efcc_enable();
    set_work_mode(DMA);

    repeat(10) begin
      // Prepare efcc transaction array
      pkt_num = $urandom_range(1, 8);
      wr_tr_arr = prepare_packet_array(pkt_num);

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
        $error("Compared Failure! SRAM Write Transaction Array != Read Transaction Array");
      else
        $display("Compared Success! SRAM Write Transaction Array == Read Transaction Array");
    end
  endtask
  
  function efcc_tr_arr prepare_packet_array(int unsigned size = 0);
    int array_size = (size == 0) ? $urandom_range(1, 8) : size ;
    efcc_tr_arr tr_arr[] = new[array_size];
    foreach (tr_arr[i]) begin
      tr_arr[i] = new();
      tr_arr[i].generate_playload(1); 
      if(i=0)
        tr_arr[i].addr = src_addr;
      else
        tr_arr[i].addr = tr_arr[i-1].addr + tr_arr[i-1].get_size();
    end
    return tr_arr;
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

`endif // RKV_EFCC_DMA_DIRECTED_TEST_SV 