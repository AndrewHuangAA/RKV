`ifndef RKV_EFCC_REG_DEFINES_SVH
`define RKV_EFCC_REG_DEFINES_SVH

// Top Registers
parameter int unsigned EFCC_TOP_CONTROL_REG_ADDR  = 32'h0000;
parameter int unsigned EFCC_TOP_STATUS_REG_ADDR   = 32'h0004;
parameter int unsigned EFCC_FILTER_ID_REG_ADDR    = 32'h0008;
parameter int unsigned EFCC_FILTER_MASK_REG_ADDR  = 32'h000C;
parameter int unsigned EFCC_FIFO_IN_REG_ADDR      = 32'h0010;
parameter int unsigned EFCC_FIFO_OUT_REG_ADDR     = 32'h0014;
parameter int unsigned EFCC_INTR_STATUS_REG_ADDR  = 32'h0018;
parameter int unsigned EFCC_INTR_EN_REG_ADDR      = 32'h001C;
parameter int unsigned EFCC_INTR_CLR_REG_ADDR     = 32'h0020;

// 0x0000: top_control register (32-bit RW)
typedef struct packed {
    bit [31:9] reserved  ; // Reserved bits to pad to 32 bits
    bit [ 8:8] pio_rw_sel; // PIO read/write selection
    bit [ 7:7] pio_en_we ; // PIO enable write enable
    bit [ 6:6] dma_rw_sel; // DMA read/write selection
    bit [ 5:4] work_mode ; // Work mode (2'b00: PIO, 2'b01: DMA)
    bit [ 3:3] intr_en   ; // Interrupt enable
    bit [ 2:2] ch1_en_we ; // Channel 1 enable write enable
    bit [ 1:1] ch0_en_we ; // Channel 0 enable write enable
    bit [ 0:0] efcc_en   ; // EFCC module enable
} efcc_top_control_reg_struct;

// 0x0004: top_status register (32-bit RO)
typedef struct packed {
    bit [31:3] reserved;   // Reserved bits to pad to 32 bits
    bit [ 2:2] crc_err ;   // CRC check error flag[cite: 4]
    bit [ 1:1] ch1_en  ;   // Channel 1 active status (1: busy, cleared upon completion)[cite: 4]
    bit [ 0:0] ch0_en  ;   // Channel 0 active status (1: busy, cleared upon completion)[cite: 4]
} efcc_top_status_reg_struct;

// 0x0008: filter_id register (32-bit WR)
typedef struct packed {
    bit [31:24] reserved;  // Reserved bits to pad to 32 bits
    bit [23:16] fid     ;  // Packet L2DES FID for filtering[cite: 4]
    bit [15:12] did     ;  // Packet L2DES DID for filtering[cite: 4]
    bit [11: 8] sid     ;  // Packet L2DES SID for filtering[cite: 4]
    bit [ 7: 0] pid     ;  // Packet L1DES PID for filtering[cite: 4]
} efcc_top_filter_id_reg_struct;

// PIO Registers
parameter int unsigned EFCC_TB_L1DES_REG_ADDR     = 32'h0100;
parameter int unsigned EFCC_TB_DW1_REG_ADDR       = 32'h0104;
parameter int unsigned EFCC_TB_DW2_REG_ADDR       = 32'h0108;
parameter int unsigned EFCC_TB_DW3_REG_ADDR       = 32'h010C;
parameter int unsigned EFCC_TB_DW4_REG_ADDR       = 32'h0110;
parameter int unsigned EFCC_TB_DW5_REG_ADDR       = 32'h0114;
parameter int unsigned EFCC_TB_DW6_REG_ADDR       = 32'h0118;
parameter int unsigned EFCC_TB_DW7_REG_ADDR       = 32'h011C;
parameter int unsigned EFCC_TB_DW8_REG_ADDR       = 32'h0120;
parameter int unsigned EFCC_TB_DW9_REG_ADDR       = 32'h0124;
parameter int unsigned EFCC_TB_DW10_REG_ADDR      = 32'h0128;
parameter int unsigned EFCC_TB_DW11_REG_ADDR      = 32'h012C;
parameter int unsigned EFCC_TB_DW12_REG_ADDR      = 32'h0130;
parameter int unsigned EFCC_TB_DW13_REG_ADDR      = 32'h0134;
parameter int unsigned EFCC_TB_DW14_REG_ADDR      = 32'h0138;
parameter int unsigned EFCC_TB_TAIL_REG_ADDR      = 32'h013C;
parameter int unsigned EFCC_TB_CTRL_REG_ADDR      = 32'h0140;
parameter int unsigned EFCC_RB_L1DES_REG_ADDR     = 32'h0150;
parameter int unsigned EFCC_RB_DW1_REG_ADDR       = 32'h0154;
parameter int unsigned EFCC_RB_DW2_REG_ADDR       = 32'h0158;
parameter int unsigned EFCC_RB_DW3_REG_ADDR       = 32'h015C;
parameter int unsigned EFCC_RB_DW4_REG_ADDR       = 32'h0160;
parameter int unsigned EFCC_RB_DW5_REG_ADDR       = 32'h0164;
parameter int unsigned EFCC_RB_DW6_REG_ADDR       = 32'h0168;
parameter int unsigned EFCC_RB_DW7_REG_ADDR       = 32'h016C;
parameter int unsigned EFCC_RB_DW8_REG_ADDR       = 32'h0170;
parameter int unsigned EFCC_RB_DW9_REG_ADDR       = 32'h0174;
parameter int unsigned EFCC_RB_DW10_REG_ADDR      = 32'h0178;
parameter int unsigned EFCC_RB_DW11_REG_ADDR      = 32'h017C;
parameter int unsigned EFCC_RB_DW12_REG_ADDR      = 32'h0180;
parameter int unsigned EFCC_RB_DW13_REG_ADDR      = 32'h0184;
parameter int unsigned EFCC_RB_DW14_REG_ADDR      = 32'h0188;
parameter int unsigned EFCC_RB_TAIL_REG_ADDR      = 32'h018C;
parameter int unsigned EFCC_RB_CTRL_REG_ADDR      = 32'h0190;

typedef struct packed{
    bit [31: 2] reserved;
    bit [ 1: 1] done    ; // Write completion status
    bit [ 0: 0] push    ; // Push trigger (pulse)
} efcc_tb_ctrl_reg_struct;

typedef struct packed{
    bit [31: 2] reserved;
    bit [ 1: 1]     done; // Read completion status
    bit [ 0: 0]      pop; // Pop trigger (pulse)
} efcc_rb_ctrl_reg_struct;

// DMA Registers
parameter int unsigned EFCC_CH0_SADDR_REG_ADDR    = 32'h0200;
parameter int unsigned EFCC_CH0_DADDR_REG_ADDR    = 32'h0204;
parameter int unsigned EFCC_CH0_CTRL_REG_ADDR     = 32'h0208;
parameter int unsigned EFCC_CH0_STAT_REG_ADDR     = 32'h020C;
parameter int unsigned EFCC_CH1_SADDR_REG_ADDR    = 32'h0210;
parameter int unsigned EFCC_CH1_DADDR_REG_ADDR    = 32'h0214;
parameter int unsigned EFCC_CH1_CTRL_REG_ADDR     = 32'h0218;
parameter int unsigned EFCC_CH1_STAT_REG_ADDR     = 32'h021C;

// DP Registers
parameter int unsigned EFCC_DP_CONTROL_REG_ADDR   = 32'h0300;
parameter int unsigned EFCC_DP_STATUS_REG_ADDR    = 32'h0304;
parameter int unsigned EFCC_DP_RC4_REG_ADDR       = 32'h0308;
parameter int unsigned EFCC_DP_FMT_REG_ADDR       = 32'h030C;


`endif // RKV_EFCC_REG_DEFINES_SVH