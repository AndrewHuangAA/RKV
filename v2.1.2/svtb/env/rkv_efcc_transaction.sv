//==============================================================================
// COPYRIGHT (C) 2018-2026 RockerIC, Ltd.
// This software and the associated documentation are confidential and
// proprietary to RockerIC, Ltd. Your use or disclosure of this software
// is subject to the terms and conditions of a consulting agreement
// between you, or your company, and RockerIC, Ltd. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//
// VisitUs : www.rockeric.com
// Support : support@rockeric.com
//==============================================================================
// File        : rkv_efcc_transaction.sv
// Created     : 2026-10-21
// Version     : 1.0
//
// Description :
// 
//
// Revision History:
// Date        Version    Change Description
//------------------------------------------------------------------------------
//             |          |
//==============================================================================
`ifndef RKV_EFCC_TRANSACTION_SV
`define RKV_EFCC_TRANSACTION_SV

class rkv_efcc_transaction;

    trans_kind_e trans_kind;
    trans_mode_o trans_mode;
    l1des_t l1des;
    l2des_t l2des;
    tail_t tail;
    bit [31:0] data_array[];
    // bit [31:0] addr;
    // bit [ 3:0] pkt_num;

    function new();
        // L1DES default/random value
        l1des.head      = 8'hD1;
        l1des.pid       = 0;
        l1des.rsvd      = 0;
        l1des.layer2    = 0;
        l1des.rc4       = 0;
        l1des.crc       = 0;
        l1des.length    = $urandom_range(0, 14); // 0~14
        
        // L2DES default/random value
        l2des.head      = 8'hD2;
        l2des.fid       = 0;
        l2des.did       = 0;
        l2des.sid       = 0;
        l2des.rsvd      = 0;
        l2des.pkt_typed = 0;

        // TAIL default value
        tail.rsvd       = 0;
        tail.crc        = 0;     
        tail.pkt_end    = 8'hED;
    endfunction

    function bit compare(rkv_efcc_transaction t);
        // if(trans_kind != t.trans_kind) return 0;
        // if(trans_mode != t.trans_mode) return 0;
        if(l1des != t.l1des)           return 0;
        if(l2des != t.l2des)           return 0;
        if(tail != t.tail)             return 0;
        if(data_array != t.data_array) return 0;
        return 1;
    endfunction

    function void print();
        string msg = "********APB Transfer Content is *********\n";
        msg = {msg, $sformatf("trans_kind = %s \n", trans_kind.name())};
        msg = {msg, $sformatf("trans_mode = %s \n", trans_mode.name())};
        msg = {msg, $sformatf("l1des = 32'h%8x \n", l1des)};
        msg = {msg, $sformatf("l2des = 32'h%8x \n", l2des)};
        msg = {msg, $sformatf("tail  = 32'h%8x \n", tail)};
        foreach(data_array[i])begin
            msg = {msg, $sformatf("data_array[%0d] = 32'h%8x \n", i, data_array[i])};
        end
        msg = {msg, "*****************************************\n"};
        $display(msg);
    endfunction

    function void generate_payload(bit pl_rand = 0);
        // 若封包內含L2DES，總長度為 length + 1(L1) + 1(L2) + 1(TAIL) = length + 3
        int dsize = l1des.layer2 == 1 ? l1des.length + 3 : l1des.length + 2;
        data_array = new[dsize];
        foreach(data_array[i]) begin
            case(i)
                0       : data_array[i] = l1des;      // L1DES
                1       : data_array[i] = l1des.layer2 == 1 ? l2des : (pl_rand ? $urandom() : 0);// layer2為1此位就是l2des，否則看pl_rand為1自己隨機當作dw1，pl_rand為0就設定為0
                dsize-1 : data_array[i] = tail        // TAIL
                default : data_array[i] = pl_rand ? $urandom() : 0; // PL
            endcase
        end
    endfunction

endclass

`endif // RKV_EFCC_TRANSACTION_SV