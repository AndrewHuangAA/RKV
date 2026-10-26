`ifndef MCDF_RGM__SV
`define MCDF_RGM__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

//---------------------------------------------------------
// 1. 控制暫存器: ctrl_reg
//---------------------------------------------------------
class ctrl_reg extends uvm_reg;
  `uvm_object_utils(ctrl_reg)

  uvm_reg_field      reserved;
  rand uvm_reg_field pkt_len;
  rand uvm_reg_field prio_level;
  rand uvm_reg_field chnl_en;

  function new(string name = "ctrl_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    reserved   = uvm_reg_field::type_id::create("reserved");
    pkt_len    = uvm_reg_field::type_id::create("pkt_len");
    prio_level = uvm_reg_field::type_id::create("prio_level");
    chnl_en    = uvm_reg_field::type_id::create("chnl_en");

    // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
    reserved.configure  (this, 26, 6, "RO", 0, 26'h0, 1, 0, 0);
    pkt_len.configure   (this,  3, 3, "RW", 0,  3'h0, 1, 1, 0);
    prio_level.configure(this,  2, 1, "RW", 0,  2'h3, 1, 1, 0);
    chnl_en.configure   (this,  1, 0, "RW", 0,  1'h0, 1, 1, 0);
  endfunction
endclass: ctrl_reg

//---------------------------------------------------------
// 2. 狀態暫存器: stat_reg
//---------------------------------------------------------
class stat_reg extends uvm_reg;
  `uvm_object_utils(stat_reg)

  uvm_reg_field      reserved;
  rand uvm_reg_field fifo_avail;

  function new(string name = "stat_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    reserved   = uvm_reg_field::type_id::create("reserved");
    fifo_avail = uvm_reg_field::type_id::create("fifo_avail");

    // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
    reserved.configure  (this, 24, 8, "RO", 0, 24'h0, 1, 0, 0);
    fifo_avail.configure(this,  8, 0, "RO", 0,  8'h0, 1, 1, 0);
  endfunction
endclass: stat_reg

//---------------------------------------------------------
// 3. 暫存器區塊: mcdf_rgm
//---------------------------------------------------------
class mcdf_rgm extends uvm_reg_block;
  `uvm_object_utils(mcdf_rgm)

  rand ctrl_reg chnl0_ctrl_reg;
  rand ctrl_reg chnl1_ctrl_reg;
  rand ctrl_reg chnl2_ctrl_reg;
  rand stat_reg chnl0_stat_reg;
  rand stat_reg chnl1_stat_reg;
  rand stat_reg chnl2_stat_reg;

  uvm_reg_map map;

  function new(string name = "mcdf_rgm");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // 實例化並建立控制暫存器
    chnl0_ctrl_reg = ctrl_reg::type_id::create("chnl0_ctrl_reg");
    chnl0_ctrl_reg.configure(this);
    chnl0_ctrl_reg.build();

    chnl1_ctrl_reg = ctrl_reg::type_id::create("chnl1_ctrl_reg");
    chnl1_ctrl_reg.configure(this);
    chnl1_ctrl_reg.build();

    chnl2_ctrl_reg = ctrl_reg::type_id::create("chnl2_ctrl_reg");
    chnl2_ctrl_reg.configure(this);
    chnl2_ctrl_reg.build();

    // 實例化並建立狀態暫存器
    chnl0_stat_reg = stat_reg::type_id::create("chnl0_stat_reg");
    chnl0_stat_reg.configure(this);
    chnl0_stat_reg.build();

    chnl1_stat_reg = stat_reg::type_id::create("chnl1_stat_reg");
    chnl1_stat_reg.configure(this);
    chnl1_stat_reg.build();

    chnl2_stat_reg = stat_reg::type_id::create("chnl2_stat_reg");
    chnl2_stat_reg.configure(this);
    chnl2_stat_reg.build();

    // 建立位址映射 (name, base_address, n_bytes, endian)
    map = create_map("map", 'h0, 4, UVM_LITTLE_ENDIAN);

    // 加入暫存器對應至記憶體位址
    map.add_reg(chnl0_ctrl_reg, 32'h00000000, "RW");
    map.add_reg(chnl1_ctrl_reg, 32'h00000004, "RW");
    map.add_reg(chnl2_ctrl_reg, 32'h00000008, "RW");
    map.add_reg(chnl0_stat_reg, 32'h00000010, "RO");
    map.add_reg(chnl1_stat_reg, 32'h00000014, "RO");
    map.add_reg(chnl2_stat_reg, 32'h00000018, "RO");

    // 鎖定暫存器模型結構
    lock_model();
  endfunction
endclass: mcdf_rgm

`endif // MCDF_RGM__SV