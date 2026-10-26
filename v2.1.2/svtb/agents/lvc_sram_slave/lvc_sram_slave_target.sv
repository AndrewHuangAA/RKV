`ifndef LVC_SRAM_SLAVE_TARGET_SV
`define LVC_SRAM_SLAVE_TARGET_SV

class lvc_apb_slave_target;

  virtual lvc_sram_interface vif;
  lvc_mem mem;
  
  function new();
    mem = new();
  endfunction

  function void assign_if(input virtual lvc_sram_interface vif); //默認是input
    this.vif = vif;
  endfunction

  task run();
    fork
      response_handler();
    join_none
  endtask

  task response_handler();
    // ------------------------- Port A -------------------------
    fork
      begin
        forever begin
          @(posedge vif.clka);
          if (vif.ena && vif.wea) begin
            mem.write(vif.addra, vif.dia);
            $display("PORT_A WRITE: addr=0x%08h, data=0x%08h", vif.addra, vif.dia);
          end
          if (vif.ena && !vif.wea) begin
            logic [31:0] rdata_a;
            rdata_a = mem.read(vif.addra);
            vif.doa <= rdata_a;
            $display("PORT_A READ: addr=0x%08h -> data=0x%08h", vif.addra, rdata_a)
          end
        end
      end
      // ------------------------- Port B -------------------------
      begin
        forever begin
          @(posedge vif.clkb);
          if (vif.enb && vif.web) begin
            mem.write(vif.addrb, vif.dib);
            $display("PORT_B WRITE: addr=0x%08h, data=0x%08h", vif.addrb, vif.dib);
          end
          if (vif.enb && !vif.web) begin
            logic [31:0] rdata_b;
            rdata_b = mem.read(vif.addrb);
            vif.dob <= rdata_b;
            $display("PORT_B READ: addr=0x%08h -> data=0x%08h", vif.addrb, rdata_b);
          end
        end
      end
    join_none
  endtask
  
  
endclass


`endif // LVC_SRAM_SLAVE_TARGET_SV