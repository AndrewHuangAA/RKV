`ifndef LVC_SRAM_TRANSFER_SV
`define LVC_SRAM_TRANSFER_SV

class lvc_sram_transfer;
  
  typedef enum bit {READ = 0, WRITE = 1} kind_e;

  kind_e cmd;
  bit[31:0] addr;
  bit[31:0] data;


endclass

`endif // LVC_SRAM_TRANSFER_SV