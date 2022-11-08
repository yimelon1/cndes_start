`timescale 1ns/1ps

`define FPGA64

`ifdef FPGA32
		`define FPGA_32BITS
`elsif CHIP32
		`define CHIP_32BITS
`elsif FPGA64
		`define FPGA_64BITS
`endif


module share_sram #(
        parameter TBITS = 64 ,
        parameter BBITS = 32 ,
        parameter NOD     =   8,
        parameter DBITS   =   8
)(
        input wire clk ,
        input wire en_k1 ,/*.
        input wire en_k2 ,
        input wire en_k3 ,
        input wire en_k4 ,
        input wire en_k5 ,
        input wire en_k6 ,
        input wire en_k7 ,
        input wire en_k8 ,
        input wire en_k9 ,
		*/
        input wire wea_k1 ,/*
        input wire wea_k2 ,
        input wire wea_k3 ,
        input wire wea_k4 ,
        input wire wea_k5 ,
        input wire wea_k6 ,
        input wire wea_k7 ,
        input wire wea_k8 ,
        input wire wea_k9 ,*/
        input  kernel_addr ,
        input  weights ,
        output  weight1_data_out ,/*
        output  weight2_data_out ,
        output  weight3_data_out ,
        output  weight4_data_out ,
        output  weight5_data_out ,
        output  weight6_data_out ,
        output  weight7_data_out ,
        output  weight8_data_out ,
        output  weight9_data_out ,*/
        
        input wire en_if1 ,
        input wire en_if2 ,
        input wire en_if3 ,/*
        input wire en_if4 ,
        input wire en_if5 ,
        input wire en_if6 ,
        input wire en_if7 ,
        input wire en_if8 ,
        input wire en_if9 ,*/
        input wire wea_if1 ,
        input wire wea_if2 ,
        input wire wea_if3 ,/*
        input wire wea_if4 ,
        input wire wea_if5 ,
        input wire wea_if6 ,
        input wire wea_if7 ,
        input wire wea_if8 ,
        input wire wea_if9 ,*/
        input if1_addr,
        input if2_addr,
        input if3_addr,/*
        input if4_addr,
        input if5_addr,
        input if6_addr,
        input if7_addr,
        input if8_addr,
        input if9_addr,*/
        input datain_fifo ,
        input din_sram_ch0 ,
        input din_sram_ch1 ,
        input din_sram_ch2 ,
        output sram1_data_out ,
        output sram2_data_out ,
        output sram3_data_out ,/*
        output sram4_data_out ,
        output sram5_data_out ,
        output sram6_data_out ,
        output sram7_data_out ,
        output sram8_data_out ,
        output sram9_data_out ,*/
        
        input wire en_bias ,
        input wire wea_bias ,
        input bias_addr ,
        input bias_datain ,
        output bias_dataout ,

        input  en_ofmap ,
        input  wea_ofmap,
        input addr_ofmap,
        input din_ofmap,
        output dout_ofmap/*
        input enb_ofmap ,
        input weab_ofmap,
        input addrb_ofmap,
        input dinb_ofmap,
        output doutb_ofmap*/

);

parameter ADDRESS_BIT = 12;
parameter KERNEL_SRAM_DBIT = 72;

`ifdef FPGA_32BITS
parameter    OABITS  =  13;
`elsif CHIP_32BITS
parameter    OABITS  =  10;
`elsif FPGA_64BITS
parameter    OABITS  =  13;
`endif


wire clk_bram ;
assign clk_bram = clk;



wire [ADDRESS_BIT-3:0] kernel_addr ;
wire [KERNEL_SRAM_DBIT-1:0] weights ;
wire [TBITS+7:0] weight1_data_out    ;
wire [TBITS+7:0] weight2_data_out    ;
wire [TBITS+7:0] weight3_data_out    ;
wire [TBITS+7:0] weight4_data_out    ;
wire [TBITS+7:0] weight5_data_out    ;
wire [TBITS+7:0] weight6_data_out    ;
wire [TBITS+7:0] weight7_data_out    ;
wire [TBITS+7:0] weight8_data_out    ; 
wire [TBITS+7:0] weight9_data_out    ; 

`ifdef FPGA_32BITS
wire [ADDRESS_BIT-2:0] if1_addr;
wire [ADDRESS_BIT-2:0] if2_addr;
wire [ADDRESS_BIT-2:0] if3_addr;
wire [ADDRESS_BIT-2:0] if4_addr;
wire [ADDRESS_BIT-2:0] if5_addr;
wire [ADDRESS_BIT-2:0] if6_addr;
wire [ADDRESS_BIT-2:0] if7_addr;
wire [ADDRESS_BIT-2:0] if8_addr;
wire [ADDRESS_BIT-2:0] if9_addr;
wire [ADDRESS_BIT-3:0] bias_addr;
wire    [OABITS-1 : 0]           addr_ofmap;
wire    [OABITS-1 : 0]           addrb_ofmap;
`elsif CHIP_32BITS
wire [ADDRESS_BIT-4:0] if1_addr;
wire [ADDRESS_BIT-4:0] if2_addr;
wire [ADDRESS_BIT-4:0] if3_addr;
wire [ADDRESS_BIT-4:0] if4_addr;
wire [ADDRESS_BIT-4:0] if5_addr;
wire [ADDRESS_BIT-4:0] if6_addr;
wire [ADDRESS_BIT-4:0] if7_addr;
wire [ADDRESS_BIT-4:0] if8_addr;
wire [ADDRESS_BIT-4:0] if9_addr;
wire [ADDRESS_BIT-5:0] bias_addr;
wire    [OABITS-3 : 0]           addr_ofmap;
wire    [OABITS-3 : 0]           addrb_ofmap;
`elsif FPGA_64BITS
wire [ADDRESS_BIT-2:0] if1_addr;
wire [ADDRESS_BIT-2:0] if2_addr;
wire [ADDRESS_BIT-2:0] if3_addr;
wire [ADDRESS_BIT-2:0] if4_addr;
wire [ADDRESS_BIT-2:0] if5_addr;
wire [ADDRESS_BIT-2:0] if6_addr;
wire [ADDRESS_BIT-2:0] if7_addr;
wire [ADDRESS_BIT-2:0] if8_addr;
wire [ADDRESS_BIT-2:0] if9_addr;
wire [ADDRESS_BIT-3:0] bias_addr;
wire    [OABITS-1 : 0]           addr_ofmap;
wire    [OABITS-1 : 0]           addrb_ofmap;
`endif

wire [TBITS-1:0] datain_fifo ;
wire [TBITS-1 : 0] din_sram_ch0;
wire [TBITS-1 : 0] din_sram_ch1;
wire [TBITS-1 : 0] din_sram_ch2;
wire [TBITS-1:0] sram1_data_out      ;
wire [TBITS-1:0] sram2_data_out      ;
wire [TBITS-1:0] sram3_data_out      ;
wire [TBITS-1:0] sram4_data_out      ;
wire [TBITS-1:0] sram5_data_out      ;
wire [TBITS-1:0] sram6_data_out      ;
wire [TBITS-1:0] sram7_data_out      ;
wire [TBITS-1:0] sram8_data_out      ;
wire [TBITS-1:0] sram9_data_out      ;


wire [BBITS-1 : 0] bias_datain;
wire signed [BBITS-1 : 0] bias_dataout;

wire                             en_ofmap;
wire                             wea_ofmap;
wire    [NOD*DBITS-1 : 0]        din_ofmap;
wire    [NOD*DBITS-1 : 0]        dout_ofmap;

wire                             enb_ofmap;
wire                             web_ofmap;
wire    [NOD*DBITS-1 : 0]        dinb_ofmap;
wire    [NOD*DBITS-1 : 0]        doutb_ofmap;

`ifdef FPGA_32BITS
////// Kernel BRAM / SRAM
BRAM_Weights kernel_sram_1(
            .clka(clk_bram),
            .ena(en_k1), 
            .wea(wea_k1),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight1_data_out)
);

// IF MAPs BRAM / SRAM
BRAM_IFmaps if_sram_1(
            .clka(clk_bram),
            .ena(en_if1), 
            .wea(wea_if1),
            .addra(if1_addr),
            .dina(din_sram_ch0),
            .douta(sram1_data_out)
);

BRAM_IFmaps if_sram_2(
            .clka(clk_bram),
            .ena(en_if2), 
            .wea(wea_if2),
            .addra(if2_addr),
            .dina(din_sram_ch1),
            .douta(sram2_data_out)
);

BRAM_IFmaps if_sram_3(
            .clka(clk_bram),
            .ena(en_if3), 
            .wea(wea_if3),
            .addra(if3_addr),
            .dina(din_sram_ch2),
            .douta(sram3_data_out)
);

//bias BRAM/SRAM
BRAM_Bias inst_bias(
            .clka(clk_bram),
            .ena(en_bias), 
            .wea(wea_bias),
            .addra(bias_addr),
            .dina(bias_datain),
            .douta(bias_dataout)
);

BRAM_OFmaps inst_ofmap (
  .clka(clk_bram),    // input wire clka
  .ena(en_ofmap),      // input wire ena
  .wea(wea_ofmap),      // input wire [0 : 0] wea
  .addra(addr_ofmap),  // input wire [12 : 0] addra
  .dina(din_ofmap),    // input wire [63 : 0] dina
  .douta(dout_ofmap)
);
`elsif CHIP_32BITS
////// Kernel BRAM / SRAM
BRAM_Weights kernel_sram_1(
			.CENY(),.WENY(),.AY(),.DY(),.EMA(3'b0),.EMAW(2'b0),.EMAS(1'b0),
			.TEN(1'b1),.BEN(1'b1),.TCEN(1'b0),.TWEN(1'b0),
			.TA(10'b0),.TD(72'b0),.TQ(72'b0),.RET1N(1'b1),.STOV(1'b0),
            .CLK(clk_bram),
            .CEN(~en_k1), 
            .WEN(~wea_k1),
            .A(kernel_addr),
            .D(weights),
            .Q(weight1_data_out)
);

// IF MAPs BRAM / SRAM
BRAM_IFmaps if_sram_1(
			.CENY(),.WENY(),.AY(),.DY(),.EMA(3'b0),.EMAW(2'b0),.EMAS(1'b0),
			.TEN(1'b1),.BEN(1'b1),.TCEN(1'b0),.TWEN(1'b0),
			.TA(9'b0),.TD(64'b0),.TQ(64'b0),.RET1N(1'b1),.STOV(1'b0),
            .CLK(clk_bram),
            .CEN(~en_if1), 
            .WEN(~wea_if1),
            .A(if1_addr),
            .D(din_sram_ch0),
            .Q(sram1_data_out)
);

BRAM_IFmaps if_sram_2(
			.CENY(),.WENY(),.AY(),.DY(),.EMA(3'b0),.EMAW(2'b0),.EMAS(1'b0),
			.TEN(1'b1),.BEN(1'b1),.TCEN(1'b0),.TWEN(1'b0),
			.TA(9'b0),.TD(64'b0),.TQ(64'b0),.RET1N(1'b1),.STOV(1'b0),
            .CLK(clk_bram),
            .CEN(~en_if2), 
            .WEN(~wea_if2),
            .A(if2_addr),
            .D(din_sram_ch1),
            .Q(sram2_data_out)
);

BRAM_IFmaps if_sram_3(
			.CENY(),.WENY(),.AY(),.DY(),.EMA(3'b0),.EMAW(2'b0),.EMAS(1'b0),
			.TEN(1'b1),.BEN(1'b1),.TCEN(1'b0),.TWEN(1'b0),
			.TA(9'b0),.TD(64'b0),.TQ(64'b0),.RET1N(1'b1),.STOV(1'b0),
            .CLK(clk_bram),
            .CEN(~en_if3), 
            .WEN(~wea_if3),
            .A(if3_addr),
            .D(din_sram_ch2),
            .Q(sram3_data_out)
);


//bias BRAM/SRAM
BRAM_Bias inst_bias(
			.CENY(),.WENY(),.AY(),.DY(),.EMA(3'b0),.EMAW(2'b0),.EMAS(1'b0),
			.TEN(1'b1),.BEN(1'b1),.TCEN(1'b0),.TWEN(1'b0),
			.TA(8'b0),.TD(32'b0),.TQ(32'b0),.RET1N(1'b1),.STOV(1'b0),
            .CLK(clk_bram),
            .CEN(~en_bias), 
            .WEN(~wea_bias),
            .A(bias_addr),
            .D(bias_datain),
            .Q(bias_dataout)
);

BRAM_OFmaps inst_ofmap (
			.CENY(),.WENY(),.AY(),.DY(),.EMA(3'b0),.EMAW(2'b0),.EMAS(1'b0),
			.TEN(1'b1),.BEN(1'b1),.TCEN(1'b0),.TWEN(1'b0),
			.TA(8'b0),.TD(64'b0),.TQ(64'b0),.RET1N(1'b1),.STOV(1'b0),
			.CLK(clk_bram),    // input wire clka
			
			.CEN(~en_ofmap),      // input wire ena
			.WEN(~wea_ofmap),      // input wire [0 : 0] wea
			.A(addr_ofmap),  // input wire [12 : 0] addra
			.D(din_ofmap),    // input wire [63 : 0] dina
			.Q(dout_ofmap)
);
`elsif FPGA_64BITS
////// Kernel BRAM / SRAM
BRAM_Weights kernel_sram_1(
            .clka(clk_bram),
            .ena(en_k1), 
            .wea(wea_k1),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight1_data_out)
);

/*
BRAM_Weights kernel_sram_2(
            .clka(clk_bram),
            .ena(en_k2), 
            .wea(wea_k2),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight2_data_out)
);

BRAM_Weights kernel_sram_3(
            .clka(clk_bram),
            .ena(en_k3), 
            .wea(wea_k3),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight3_data_out)
);

BRAM_Weights kernel_sram_4(
            .clka(clk_bram),
            .ena(en_k4), 
            .wea(wea_k4),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight4_data_out)
);

BRAM_Weights kernel_sram_5(
            .clka(clk_bram),
            .ena(en_k5), 
            .wea(wea_k5),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight5_data_out)
);

BRAM_Weights kernel_sram_6(
            .clka(clk_bram),
            .ena(en_k6), 
            .wea(wea_k6),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight6_data_out)
);

BRAM_Weights kernel_sram_7(
            .clka(clk_bram),
            .ena(en_k7), 
            .wea(wea_k7),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight7_data_out)
);

BRAM_Weights kernel_sram_8(
            .clka(clk_bram),
            .ena(en_k8), 
            .wea(wea_k8),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight8_data_out)
);

BRAM_Weights kernel_sram_9(
            .clka(clk_bram),
            .ena(en_k9), 
            .wea(wea_k9),
            .addra(kernel_addr),
            .dina(weights),
            .douta(weight9_data_out)
);
*/

// IF MAPs BRAM / SRAM
BRAM_IFmaps if_sram_1(
            .clka(clk_bram),
            .ena(en_if1), 
            .wea(wea_if1),
            .addra(if1_addr),
            .dina(din_sram_ch0),
            .douta(sram1_data_out)
);

BRAM_IFmaps if_sram_2(
            .clka(clk_bram),
            .ena(en_if2), 
            .wea(wea_if2),
            .addra(if2_addr),
            .dina(din_sram_ch1),
            .douta(sram2_data_out)
);

BRAM_IFmaps if_sram_3(
            .clka(clk_bram),
            .ena(en_if3), 
            .wea(wea_if3),
            .addra(if3_addr),
            .dina(din_sram_ch2),
            .douta(sram3_data_out)
);

/*
BRAM_IFmaps if_sram_4(
            .clka(clk_bram),
            .ena(en_if4), 
            .wea(wea_if4),
            .addra(if4_addr),
            .dina(datain_fifo),
            .douta(sram4_data_out)
);

BRAM_IFmaps if_sram_5(
            .clka(clk_bram),
            .ena(en_if5), 
            .wea(wea_if5),
            .addra(if5_addr),
            .dina(datain_fifo),
            .douta(sram5_data_out)
);

BRAM_IFmaps if_sram_6(
            .clka(clk_bram),
            .ena(en_if6), 
            .wea(wea_if6),
            .addra(if6_addr),
            .dina(datain_fifo),
            .douta(sram6_data_out)
);

BRAM_IFmaps if_sram_7(
            .clka(clk_bram),
            .ena(en_if7), 
            .wea(wea_if7),
            .addra(if7_addr),
            .dina(datain_fifo),
            .douta(sram7_data_out)
);

BRAM_IFmaps if_sram_8(
            .clka(clk_bram),
            .ena(en_if8), 
            .wea(wea_if8),
            .addra(if8_addr),
            .dina(datain_fifo),
            .douta(sram8_data_out)
);

BRAM_IFmaps if_sram_9(
            .clka(clk_bram),
            .ena(en_if9), 
            .wea(wea_if9),
            .addra(if9_addr),
            .dina(datain_fifo),
            .douta(sram9_data_out)
);
*/
//bias BRAM/SRAM
BRAM_Bias inst_bias(
            .clka(clk_bram),
            .ena(en_bias), 
            .wea(wea_bias),
            .addra(bias_addr),
            .dina(bias_datain),
            .douta(bias_dataout)
);

BRAM_OFmaps inst_ofmap (
  .clka(clk_bram),    // input wire clka
  .ena(en_ofmap),      // input wire ena
  .wea(wea_ofmap),      // input wire [0 : 0] wea
  .addra(addr_ofmap),  // input wire [12 : 0] addra
  .dina(din_ofmap),    // input wire [63 : 0] dina
  .douta(dout_ofmap)/*,  // output wire [63 : 0] douta

  .clkb(clk_bram),    // input wire clka
  .enb(enb_ofmap),      // input wire ena
  .web(web_ofmap),      // input wire [0 : 0] wea
  .addrb(addrb_ofmap),  // input wire [12 : 0] addra
  .dinb(dinb_ofmap),    // input wire [63 : 0] dina
  .doutb(doutb_ofmap) */
);
`endif

endmodule  

