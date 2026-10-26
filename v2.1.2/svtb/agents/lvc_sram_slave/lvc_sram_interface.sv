interface lvc_sram_interface(input logic clka, input logic clkb);

  logic [31:0] doa;
  logic [31:0] dob;
  logic [31:0] dia;
  logic [31:0] dib;
  logic [31:0] addra;
  logic [31:0] addrb;
  logic        ena;
  logic        enb;
  logic        wea;
  logic        web;

endinterface