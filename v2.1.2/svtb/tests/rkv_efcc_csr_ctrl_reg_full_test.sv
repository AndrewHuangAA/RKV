`ifndef RKV_EFCC_CSR_CTRL_REG_FULL_TEST
`define RKV_EFCC_CSR_CTRL_REG_FULL_TEST

class rkv_efcc_csr_ctrl_reg_full_test extends rkv_efcc_base_test;

    typedef struct {
        bit [31:0] addr;
        bit [31:0] reset_expd;
        bit [31:0] all_one_tval;
        bit [31:0] all_one_expd;
    } csr_ctrl_reg_test_struct;


    task run();
        csr_ctrl_reg_test_struct ctrl_reg_test_q[$];
        csr_ctrl_reg_test_struct ctrl_reg_test;
        lvc_apb_transfer t = new();
        super.run();
        //-------------------------------------------------------------
        // Specify All Control Registers Test Pattern
        //-------------------------------------------------------------
        // Top Control Reg
        ctrl_reg_test = '{addr:EFCC_TOP_CONTROL_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'h179};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // Filter ID Reg
        ctrl_reg_test = '{addr:EFCC_FILTER_ID_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'hFF_FFFF};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // Filter Mask Reg
        ctrl_reg_test = '{addr:EFCC_FILTER_MASK_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'hFF_FFFF};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // Interrupt Enable Reg
        ctrl_reg_test = '{addr:EFCC_INTR_EN_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'h3F};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // Interreupt Clear Reg
        ctrl_reg_test = '{addr:EFCC_INTR_CLR_REG_ADDR, reset_expd:32'h0, all_one_tval:'1, all_one_expd:'h0};
        ctrl_reg_test_q.push_back(ctrl_reg_test);
        // TODO:: Add Other Control Registers ...
        // ctrl_reg_test = '{addr:, reset_expd:, all_one_tval:'1, all_one_expd:};

        $display("rkv_efcc_csr_ctrl_reg_full_test STARTED!");
        foreach(ctrl_reg_test_q[i]) begin
            // t = '{default:0}; // initialization
            t = new();
            ctrl_reg_test = ctrl_reg_test_q[i];
            t.addr = ctrl_reg_test.addr;
            // Specify read transaction for reset value check
            t.trans_kind = READ;
            apb_drive_transfer(t);
            compare_data(t.data, ctrl_reg_test.reset_expd, "Compare Reset Value");

            // Specify write transaction
            t.trans_kind = WRITE;
            t.data = ctrl_reg_test.all_one_tval;
            apb_drive_transfer(t);

            // Specify read transaction
            t.trans_kind = READ;
            apb_drive_transfer(t);
            compare_data(t.data, ctrl_reg_test.all_one_expd, "Compare Config All-One's Value");

            // Specify write transaction
            t.trans_kind = WRITE;
            t.data = 32'h0;
            apb_drive_transfer(t);

            // Specify read transaction
            t.trans_kind = READ;
            t.idle_cycles = 1;
            apb_drive_transfer(t);
            compare_data(t.data, 0, "Compare Config All-Zero's Value");
        end
        $display("rkv_efcc_csr_ctrl_reg_full_test FINISHED!");
    endtask

endclass

`endif // RKV_EFCC_CSR_CTRL_REG_FULL_TEST