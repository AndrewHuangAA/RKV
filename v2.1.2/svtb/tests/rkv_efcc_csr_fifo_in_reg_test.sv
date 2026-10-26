`ifndef RKV_EFCC_CSR_FIFO_IN_REG_TEST
`define RKV_EFCC_CSR_FIFO_IN_REG_TEST

class rkv_efcc_csr_fifo_in_reg_test extends rkv_efcc_base_test;

    task run();
        lvc_apb_transfer t = new();
        super.run();

        $display("rkv_efcc_csr_fifo_in_reg_test STARTED!");
        t.addr = EFCC_FIFO_IN_REG_ADDR;

        // Specify read transaction for reset value check
        t.trans_kind = READ;
        apb_drive_transfer(t);
        compare_data(t.data, 'h82, "Compare Top Control Reg Reset Value");

        // Specify write transaction for RO fields test
        t.trans_kind = WRITE;
        t.data = '1;
        t.data[10] = 0;
        apb_drive_transfer(t);

        // Specify read transaction for RO value check
        t.trans_kind = READ;
        apb_drive_transfer(t);
        compare_data(t.data, 'h82, "Compare Top Control Reg Reset Value");

        // Specify read transaction for status fields update check
        // Force FIFO-IN submodule output for connection & update check
        force rkv_efcc_tb.dut.fifo_in.margin_o = 'h15;
        // release rkv_efcc_tb.dut.fifo_in.margin_o;
        t.trans_kind = READ;
        t.idle_cycles = 1;
        apb_drive_transfer(t);
        compare_data(t.data, ((8'h15 << 2) | (1'b1 << 1)), "Compare Top Control Reg Reset Value");

        $display("rkv_efcc_csr_fifo_in_reg_test FINISHED!");
    endtask

endclass


`endif // RKV_EFCC_CSR_FIFO_IN_REG_TEST