`ifndef LVC_MEM_SV
`define LVC_MEM_SV

class lvc_mem;

  protected logic [31:0] mem [bit [31:0]]; // 左邊括號為32bit data，右邊資料為32bit 記憶體位置
  protected logic [31:0] default_val = 32'hDEADBEEF;

  function new(string name = "lvc_mem");
    super.new(name);
  endfunction

  function void write(bit [31:0] addr, logic [31:0] data);
    mem[addr] = data;
  endfunction

  function logic [31:0] read(bit [31:0] addr);
    if (mem.exists(addr)) begin
      return mem[addr];
    end else begin
      return default_val;
    end
  endfunction

  function void reset();
    mem.delete();
  endfunction

endclass

`endif // LVC_MEM_SV
