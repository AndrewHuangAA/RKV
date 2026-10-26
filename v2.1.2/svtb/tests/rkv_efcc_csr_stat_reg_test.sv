`ifndef RKV_EFCC_CSR_STAT_REG_TEST
`define RKV_EFCC_CSR_STAT_REG_TEST

class rkv_efcc_csr_stat_reg_test extends rkv_efcc_base_test;
    task run();
        lvc_apb_transfer t;
        lvc_apb_transfer tq[$];
        super.run();

        $display("rkv_efcc_csr_stat_reg_test STARTED!");
        // Specify a Read Operation
        t = new();
        t.addr = EFCC_FIFO_IN_REG_ADDR;
        t.trans_kind = READ;
        t.expd = 'h82;
        tq.push_back(t);
        // Specify a Write Operation
        t = new();
        t.trans_kind = WRITE;
        t.data = 'h10;
        tq.push_back(t);
        // Specify a Read Operation
        t = new();
        t.addr = EFCC_FIFO_IN_REG_ADDR;
        t.trans_kind = READ;
        t.expd = 'h82;
        t.idle_cycles = 1;
        tq.push_back(t);
        while(tq.size() != 0) begin
            t = tq.pop_front();
            apb_drive_transfer(t);
            if(t.trans_kind == READ)
                compare_data(t.data, t.expd, "CMP_STAT_REG");
        end
        $display("rkv_efcc_csr_stat_reg_test FINISHED!");
    endtask
    

endclass


`endif // RKV_EFCC_CSR_STAT_REG_TEST