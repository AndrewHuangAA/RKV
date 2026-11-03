`ifndef LVC_SRAM_SLAVE_MONITOR_SV
`define LVC_SRAM_SLAVE_MONITOR_SV

class lvc_sram_slave_monitor;

    virtual lvc_sram_interface vif;

    mailbox #(lvc_sram_transfer) min_porta_mb[$];
    mailbox #(lvc_sram_transfer) min_portb_mb[$];

    task run();
        fork
            monitor_transactions();
        join_none
    endtask

    task monitor_transactions();
        fork 
            collect_transfer_porta();
            collect_transfer_portb();
        join_none
    endtask

    task collect_transfer_porta();
        lvc_sram_transfer tr;
        forever begin
            @(posedge vif.clka);
            if(vif.ena) begin
                if(vif.wea) begin
                    tr = new();
                    tr.cmd = lvc_sram_transfer::WRITE;
                    tr.addr = vif.addra;
                    tr.data = vif.dia;
                    write_porta_transfer(tr);
                end
                else begin
                    fork
                        begin
                            automatic logic [31:0] captured_addr;
                            automatic lvc_sram_transfer r_tr = tr;
                            captured_addr = vif.addra;
                            @(posedge vif.clka);
                            r_tr.cmd = lvc_sram_transfer::READ;
                            r_tr.addr = captured_addr;
                            r_tr.data = vif.doa;
                            write_porta_transfer(r_tr);
                        end
                    join_none
                end
            end
        end
    endtask

    task collect_transfer_portb();
        lvc_sram_transfer tr;
        forever begin
            @(posedge vif.clkb);
            if(vif.enb) begin
                if(vif.web) begin
                    tr = new();
                    tr.cmd = lvc_sram_transfer::WRITE;
                    tr.addr = vif.addrb;
                    tr.data = vif.dib;
                    write_portb_transfer(tr);
                end
                else begin
                    fork
                        begin
                            automatic logic [31:0] captured_addr;
                            automatic lvc_sram_transfer r_tr = tr;
                            captured_addr = vif.addrb;
                            @(posedge vif.clkb);
                            r_tr.cmd = lvc_sram_transfer::READ;
                            r_tr.addr = captured_addr;
                            r_tr.data = vif.dob;
                            write_portb_transfer(r_tr);
                        end
                    join_none
                end
            end
        end
    endtask

    task write_porta_transfer(input lvc_sram_transfer t);
    // TODO
    // Send Monitored Transfers to Other Components
        foreach(mon_porta_mb[i]) begin
            mon_porta_mb[i].put(t);
        end
    endtask

    task write_portb_transfer(input lvc_sram_transfer t);
    // TODO
    // Send Monitored Transfers to Other Components
        foreach(mon_portb_mb[i]) begin
            mon_portb_mb[i].put(t);
        end
    endtask

endclass

`endif // LVC_SRAM_SLAVE_MONITOR_SV