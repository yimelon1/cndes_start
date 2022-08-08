




`define SDFFILE    "./dla_top_SYN.sdf"	  // Modify your sdf file name
`define RTL
`define GATE
`define End_CYCLE  10000      // Modify cycle times once your design need more cycle times!
`ifdef RTL
	`timescale 1ns/100ps
    `define CYCLE 10
	`include "pe_8v"
    
`endif
`ifdef GATE
	`timescale 1ns/1ps
    `define CYCLE 3.3
    
`endif
//-----------------------------------------------------------------------------------------------------------

logic               clk = 0;              //input  
logic reset = 0;

always begin #(`CYCLE/2) clk = ~clk; end




pe_8e p0 #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(				) ,
	.act_1(				) ,
	.act_2(				) ,
	.act_3(				) ,
	.act_4(				) ,
	.act_5(				) ,
	.act_6(				) ,
	.act_7(				) ,
	.valid_in(			) ,
	.final_in(			) ,
	//---- kernel ----//
	.ker_0(				) ,
	.ker_1(				) ,
	.ker_2(				) ,
	.ker_3(				) ,
	.ker_4(				) ,
	.ker_5(				) ,
	.ker_6(				) ,
	.ker_7(				) ,
	//-----------------------------------------//
	.valid_out	(				) ,
	.out_sum	(				)

);







initial begin
	`ifdef RTL
		$fsdbDumpfile("dla_top.fsdb");
		$fsdbDumpvars(0,"+mda");
	`endif
	`ifdef GATE
		$sdf_annotate(`SDFFILE,top_U);
		$fsdbDumpfile("dla_top_SYN.fsdb");
		$fsdbDumpvars();
	`endif
end

// E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT
`define KER_DAT "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/2_w.dat"

`define KSR_0 "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/w_sr/wsram_pat_0.dat"
`define KSR_1 "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/w_sr/wsram_pat_1.dat"
`define KSR_2 "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/w_sr/wsram_pat_2.dat"
`define KSR_3 "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/w_sr/wsram_pat_3.dat"
`define KSR_4 "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/w_sr/wsram_pat_4.dat"
`define KSR_5 "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/w_sr/wsram_pat_5.dat"
`define KSR_6 "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/w_sr/wsram_pat_6.dat"
`define KSR_7 "E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/w_sr/wsram_pat_7.dat"

logic [63:0] ker_sram_0 [0:2047];
logic [63:0] ker_sram_1 [0:2047];
logic [63:0] ker_sram_2 [0:2047];
logic [63:0] ker_sram_3 [0:2047];
logic [63:0] ker_sram_4 [0:2047];
logic [63:0] ker_sram_5 [0:2047];
logic [63:0] ker_sram_6 [0:2047];
logic [63:0] ker_sram_7 [0:2047];




initial begin // initial pattern and expected result
	wait(reset==1);
	$readmemh(`PAT, PAT);
	$readmemh(`KSR_0, ker_sram_0);
	$readmemh(`KSR_1, ker_sram_1);
	$readmemh(`KSR_2, ker_sram_2);
	$readmemh(`KSR_3, ker_sram_3);
	$readmemh(`KSR_4, ker_sram_4);
	$readmemh(`KSR_5, ker_sram_5);
	$readmemh(`KSR_6, ker_sram_6);
	$readmemh(`KSR_7, ker_sram_7);
	$readmemh(`L1_EXP1, L1_EXP1);
	$readmemh(`L1_EXP1, L1_EXP1);
	$readmemh(`L1_EXP1, L1_EXP1);
	$readmemh(`L1_EXP1, L1_EXP1);

	
end



