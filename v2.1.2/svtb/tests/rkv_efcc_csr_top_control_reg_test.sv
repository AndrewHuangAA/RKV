`ifndef RKV_EFCC_CSR_TOP_CONTROL_REG_TEST
`define RKV_EFCC_CSR_TOP_CONTROL_REG_TEST

class rkv_efcc_csr_top_control_reg_test extends rkv_efcc_base_test;
    task run();
        lvc_apb_transfer t = new();
        super.run();

        $display("rkv_efcc_csr_top_contorl_reg_test STARTED!");
        t.addr = EFCC_TOP_CONTROL_REG_ADDR;
        // Specify read transaction for reset value check
        t.trans_kind = READ;
        apb_drive_transfer(t);
        compare_data(t.data, 0, "Compare Top Control Reg Reset Value");

        // Specify write transaction
        t.trans_kind = WRITE;
        t.data = 32'hFFFF_FFFF;
        apb_drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        apb_drive_transfer(t);
        compare_data(t.data, 32'h0000_0179, "Compare Top Control Reg Config Value");

        // Specify write transaction
        t.trans_kind = WRITE;
        t.data = 32'h0;
        apb_drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        t.idle_cycles = 1;
        apb_drive_transfer(t);
        compare_data(t.data, 0, "Compare Top Control Reg Config Value");

        $display("rkv_efcc_csr_top_control_reg_test FINISHED!");
    endtask
    

endclass


`endif // RKV_EFCC_CSR_TOP_CONTROL_REG_TEST