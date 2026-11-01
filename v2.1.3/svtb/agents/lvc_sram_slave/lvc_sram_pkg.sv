`ifndef LVC_SRAM_PKG_SV
`define LVC_SRAM_PKG_SV
package

  `include "lvc_mem.sv"
  `include "lvc_sram_transfer.sv"
  `include "lvc_sram_slave_target.sv"
  `include "lvc_sram_slave_monitor.sv"
  `include "lvc_sram_slave_agent.sv"

endpackage

`endif // LVC_SRAM_PKG_SV