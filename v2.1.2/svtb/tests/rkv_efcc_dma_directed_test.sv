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
      // Channel 0/1 PUSH
      ch = $urandom_range(0, 1);
      setup_reg_dma_mode(PUSH, pkt_num, src_addr, ch);
      #1us;

      // Channel 0/1 POP
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
    efcc_tr_arr tr_arr[] = new[array_size];  // new a object array
    foreach (tr_arr[i]) begin
      tr_arr[i] = new();                     // new a object in object array
      tr_arr[i].generate_payload(1); 
      if(i==0)
        tr_arr[i].addr = src_addr;
      else
        // data_array.size()是總共有幾筆資料，一筆資料是4byte(32 bits)，所以下個位置是幾筆資料*4個位置後
        tr_arr[i].addr = tr_arr[i-1].addr + tr_arr[i-1].get_size();
    end
    return tr_arr;
  endfunction

endclass

`endif // RKV_EFCC_DMA_DIRECTED_TEST_SV 