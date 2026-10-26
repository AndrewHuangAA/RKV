`ifndef RKV_EFCC_CSR_CTRL_REG_TEST
`define RKV_EFCC_CSR_CTRL_REG_TEST

class rkv_efcc_csr_ctrl_reg_test extends rkv_efcc_base_test;
    // task apb_drive_transfer(input lvc_apb_transfer t);
    //     env.apn_init.drive_transfer(t);
    // endtask
    
    task run();
        lvc_apb_transfer t = new(); 
        
        super.run();

        $display("rkv_efcc_csr_ctrl_reg_test STARTED!");
        t.addr = EFCC_TOP_CONTROL_REG_ADDR;
        // Specify read transaction for reset value check
        t.trans_kind = READ;
        apb_drive_transfer(t);
        compare_data(t.data, 0, "Compare Top Control Reg Reset Value");

        // Specify write transaction
        t.trans_kind = WRITE;
        t.data = 32'h1;
        apb_drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        apb_drive_transfer(t);
        compare_data(t.data, 32'h1, "Compare Top Control Reg Config Value");

        // Specify write reserved field transaction
        t.trans_kind = WRITE;
        t.data[31:9] = '1;
        t.data[ 8:0] = 0;
        apb_drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        apb_drive_transfer(t);
        compare_data(t.data, 32'h0, "Compare Top Control Reg Config Value");

        // Specify write write-clear field transaction
        // t = '{addr:EFCC_TOP_CONTROL_REG_ADDR, trans_kind:WRITE, default:0};
        t = new(); // 重新new就是都歸零，新對象
        t.addr = EFCC_TOP_CONTROL_REG_ADDR;
        t.trans_kind = WRITE;
        t.data[1] = 1'b1;
        t.data[2] = 1'b1;
        apb_drive_transfer(t);

        // Specify read transaction
        t.trans_kind = READ;
        apb_drive_transfer(t);
        compare_data(t.data, 32'h0, "Compare Top Control Reg Config Value");

        t.trans_kind = IDLE;
        apb_drive_transfer(t);
        $display("rkv_efcc_csr_ctrl_reg_test FINISHED!");
    endtask

endclass

`endif // RKV_EFCC_CSR_CTRL_REG_TEST