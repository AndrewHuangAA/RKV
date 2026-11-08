`ifndef RKV_EFCC_SUBSCRIBER_SV
`define RKV_EFCC_SUBSCRIBER_SV

class rkv_efcc_subscriber;

    // 這些都要給reference_model的mb
    mailbox #(lvc_apb_transfer) apb_mb;

    mailbox #(rkv_efcc_transaction) efcc_pio_mb;

    mailbox #(rkv_efcc_transaction) efcc_dma_mb;

    mailbox #(lvc_sram_transfer) sram_porta_mb;

    mailbox #(lvc_sram_transfer) sram_portb_mb;

    rkv_efcc_config cfg;

    function new();
        apb_mb        = new();
        efcc_pio_mb   = new();
        efcc_dma_mb   = new();
        sram_porta_mb = new();
        sram_portb_mb = new();
    endfunction

    virtual function build();
    endfunction

    virtual task run();
        fork
            write_apb();
            write_sram(sram_porta_mb);
            write_sram(sram_portb_mb);
        join_none
    endtask

    virtual task write_apb();
        lvc_apb_transfer apb_tr;
        rkv_efcc_transaction efcc_tr;
        forever begin
            // Get a APB transfer
            apb_mb.get(apb_tr);
            // Recognize a PIO TB/RB packet
            apb_trans_format_packet(apb_tr, efcc_tr);
        end
    endtask

    // Formatting a EFCC Packet from APB Transfers 注意efcc_tr是inout!!
    // Monitor由信箱接收多個"lvc_apb_transfer apb_tr"然後逐一把他們放入"rkv_efcc_transaction efcc_tr"
    virtual task apb_trans_format_packet(input lvc_apb_transfer apb_tr, inout rkv_efcc_transaction efcc_tr);
        if(apb_tr.trans_kind == lvc_apb_transfer::WRITE && apb_tr.addr inside {[EFCC_TB_L1DES_REG_ADDR:EFCC_TB_TAIL_REG_ADDR]} ||
           apb_tr.trans_kind == lvc_apb_transfer::READ  && apb_tr.addr inside {[EFCC_RB_L1DES_REG_ADDR:EFCC_RB_TAIL_REG_ADDR]}
          ) begin
            case(apb_tr.addr)
                EFCC_TB_L1DES_REG_ADDR : begin // TB L1DES
                    efcc_tr = new();
                    if(!efcc_tr.randomize() with {l1des == apb_tr.data;
                                                  trans_kind == PUSH;
                                                  trans_mode == PIO;
                                                  addr == EFCC_TB_L1DES_REG_ADDR;
                                                 })
                        $error("rkv_efcc_transaction object randomize failure!");
                end
                EFCC_RB_L1DES_REG_ADDR : begin // RB L1DES
                    efcc_tr = new();
                    if(!efcc_tr.randomize() with {l1des == apb_tr.data;
                                                  trans_kind == POP;
                                                  trans_mode == PIO;
                                                  addr == EFCC_RB_L1DES_REG_ADDR;
                                                 })
                        $error("rkv_efcc_transaction object randomize failure!");
                end
                EFCC_TB_TAIL_REG_ADDR, EFCC_RB_TAIL_REG_ADDR : begin // TB/RB TAIL
                    efcc_tr.tail = apb_tr.data;
                    efcc_tr.data_array[efcc_tr.data_array.size() - 1] = efcc_tr.tail;
                    if(efcc_tr.l1des.layer2) // tail出來後代表這包已經完成，再去設定有沒有l2des，這時候data_array[1]一定有東西
                      efcc_tr.l2des = efcc_tr.data_array[1];
                    efcc_pio_mb.put(efcc_tr);
                end
                default : begin // TB/RB Payload
                    if(apb_tr.addr inside {[EFCC_TB_L1DES_REG_ADDR:EFCC_TB_TAIL_REG_ADDR]}) begin
                    efcc_tr.data_array[(apb_tr.addr - EFCC_TB_L1DES_REG_ADDR)/4] = apb_tr.data;
                    end
                    else if(apb_tr.addr inside {[EFCC_RB_L1DES_REG_ADDR:EFCC_RB_TAIL_REG_ADDR]}) begin
                    efcc_tr.data_array[(apb_tr.addr - EFCC_RB_L1DES_REG_ADDR)/4] = apb_tr.data;
                    end
                end
            endcase
        end
    endtask

    virtual task write_sram(mailbox #(lvc_sram_transfer) mb);
        lvc_sram_transfer sram_tr;
        rkv_efcc_transaction efcc_tr;
        forever begin
            // Get a SRAM transfer
            mb.get(sram_tr);
            // Recognize a PIO TB/RB packet
            sram_trans_format_packet(sram_tr, efcc_tr);
        end
        endtask

    virtual task sram_trans_format_packet(input lvc_sram_transfer sram_tr, inout rkv_efcc_transaction efcc_tr);
        if(efcc_tr == null) begin // L1DES
            if(sram_tr.data[31:24] == 'hD1) begin
                efcc_tr = new();
                if(!efcc_tr.randomize() with {  l1des == sram_tr.data;
                                                sram_tr.cmd == lvc_sram_transfer::READ -> trans_kind == PUSH;
                                                sram_tr.cmd == lvc_sram_transfer::WRITE -> trans_kind == POP;
                                                trans_mode == DMA;
                                                addr == sram_tr.addr;
                                             })
                    $error("rkv_efcc_transaction object randomize failure!");
            end
        end
        else if(sram_tr.data[7:0] == 'hED && sram_tr.data[31:16] == 0) begin // TAIL
            efcc_tr.tail = sram_tr.data;
            efcc_tr.data_array[efcc_tr.data_array.size() - 1] = efcc_tr.tail;
            if(efcc_tr.l1des.layer2)
                efcc_tr.l2des = efcc_tr.data_array[1];
            efcc_dma_mb.put(efcc_tr);
            efcc_tr = null;
        end
        else begin // Payload
            efcc_tr.data_array[(sram_tr.addr - efcc_tr.addr)/4] = sram_tr.data;
        end
    endtask

endclass

`endif