// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.20
// Ver      : 1.0
// Func     : kernel sram read module
// 			after all kernel and activation compute done 
// 			both read&write module will IDLE and busy="0"
// ============================================================================

module bias_top (
	clk,
	reset,

	bias_write_data_din		,
	bias_write_empty_n_din	,
	bias_write_read_dout		,

	bias_write_done 		,
	bias_write_busy 		,
	start_bias_write		,

	bias_read_done 		,
	bias_read_busy 		,
	start_bias_read		,


	tst_cp_ker_num		,
	tst_ker_read_done		,
	tst_en_ker_num		,
	tst_sram_rw		
	
);

	input wire clk ;
	input wire reset ;


	input wire [ 63 : 0 ] bias_write_data_din	;
	input wire		bias_write_empty_n_din	;
	output reg		bias_write_read_dout		;

	output reg 		bias_write_done 		;
	output reg 		bias_write_busy 		;
	input wire 		start_bias_write		;

	output wire 	bias_read_done 		;
	output wire 	bias_read_busy 		;
	input wire 		start_bias_read		;


//----ker w test input declare start------ 
    input wire tst_sram_rw ;	// scheduler control 
    input wire [9:0] tst_cp_ker_num ;	// testbench simulate ker_r module
    input wire 	tst_ker_read_done ;	// testbench simulate ker_r module
    input wire 	tst_en_ker_num ;	// testbench simulate ker_r module


//-----------------------------------------------------------------------------
//----generated by bias_top_mod.py------ 
//---- bias top declare BIAS_SRAM start------ 
wire cen_biassr_0 ; 
wire wen_biassr_0 ; 
wire [ 9 -1 : 0 ] addr_biassr_0 ; 
wire [ 32 -1 : 0 ] din_biassr_0 ; 
wire [ 32 -1 : 0 ] dout_biassr_0 ; 
//---- bias top declare BIAS_SRAM end------ 

//----declare bias_top sram read signal start------ 
wire bsr_cen_biassr_0 ; 
wire bsr_wen_biassr_0 ; 
wire [ 9 -1 : 0 ] bsr_addr_biassr_0 ; 
//----declare bias_top sram read signal  end------ 

//----declare bias_top sram write signal start------ 
wire bsw_cen_biassr_0 ; 
wire bsw_wen_biassr_0 ; 
wire [ 9 -1 : 0 ] bsw_addr_biassr_0 ; 
wire [ 32 -1 : 0 ] bsw_din_biassr_0 ; 
//----declare bias_top sram write signal  end------ 


//----generated by bias_top_mod.py------ 
//----bias_top assign start------ 
// //----bias_top assign cen ------ 
//     assign cen_biassr_0 = ( tst_sram_rw )? bsw_cen_biassr_0 : bsr_cen_biassr_0 ;
// //----bias_top assign wen ------ 
//     assign wen_biassr_0 = ( tst_sram_rw )? bsw_wen_biassr_0 : bsr_wen_biassr_0 ;
// //----bias_top assign addr ------ 
//     assign addr_biassr_0 =  ( tst_sram_rw )? bsw_addr_biassr_0 : bsr_addr_biassr_0 ;
// //----bias_top assign din ------ 
//     assign din_biassr_0 =  ( tst_sram_rw )? bsw_din_biassr_0  : 32'd0 ;
// //----bias_top assign end------ 

    assign cen_biassr_0 = 	( bias_write_busy )? bsw_cen_biassr_0 	: bsr_cen_biassr_0 ;
    assign wen_biassr_0 =	( bias_write_busy )? bsw_wen_biassr_0 	: bsr_wen_biassr_0 ;
    assign addr_biassr_0 =	( bias_write_busy )? bsw_addr_biassr_0 	: bsr_addr_biassr_0 ;
    assign din_biassr_0 =	( bias_write_busy )? bsw_din_biassr_0  	: 32'd0 ;


//-----------------------------------------------------------------------------
//----generated by bias_top_mod.py------ 
//----instance BIAS_SRAM start------ 
BIAS_SRAM bias_0(.Q(	dout_biassr_0 ),	.CLK( clk ),.CEN( cen_biassr_0 ),.WEN( wen_biassr_0 ),.A( addr_biassr_0 ),.D( din_biassr_0 ),.EMA( 3'b0 ));//----instance KER SRAM_0---------
//----instance BIAS_SRAM end------ 


//-------------- test -------------------
wire bias_rd1st_start ;
wire bias_rd1st_done ;
wire bias_rd1st_busy ;
//-------------- test -------------------




//-------------------------------------------------------------------
//----------------		kernel sram write module		-------------
//-------------------------------------------------------------------
biassram_w  bias_write01	(
	.clk	(	clk		),
	.reset	(	reset	),

//----bias_top write module sram signal instanse------ 
    .cen_biasr_0    ( bsw_cen_biassr_0 ),
    .wen_biasr_0    ( bsw_wen_biassr_0 ),
    .addr_biasr_0    ( bsw_addr_biassr_0 ),
    .din_biasr_0    ( bsw_din_biassr_0 ),
//----bias_top write module sram signal instanse end------ 


	.bias_write_data_din	(	bias_write_data_din		),
	.bias_write_empty_n_din	(	bias_write_empty_n_din	),
	.bias_write_read_dout	(	bias_write_read_dout		),

	.bias_rd1st_start 		(	bias_rd1st_start	),		// read first bias value to reg buffer
	.bias_rd1st_busy 		(	bias_rd1st_busy		),		// read first bias value to reg buffer
	.bias_rd1st_done 		(	bias_rd1st_done		),		// read first bias value to reg buffer

	.bias_write_done 		(	bias_write_done 	),
	.bias_write_busy 		(	bias_write_busy 	),
	.start_bias_write		(	start_bias_write	)
	
);

//-------------------------------------------------------------------
//----------------		kernel sram read module		-------------
//-------------------------------------------------------------------

biassram_r bias_read01(
	.clk	(	clk		),
	.reset	(	reset	),

	.cen_biasr_0	(	bsr_cen_biassr_0	),	
	.wen_biasr_0	(	bsr_wen_biassr_0	),
	.addr_biasr_0	(	bsr_addr_biassr_0	),
	.dout_biasr_0	(	dout_biassr_0	),

	.cp_ker_num		(	tst_cp_ker_num	),		// testbench simulate ker_r module
	.ker_read_done		(	tst_ker_read_done	),		// testbench simulate ker_r module
	.en_ker_num		(	tst_en_ker_num	),		// testbench simulate ker_r module


	.bias_rd1st_start 		(	bias_rd1st_start	),
	.bias_rd1st_busy 		(	bias_rd1st_busy		),
	.bias_rd1st_done 		(	bias_rd1st_done		),


	.bias_read_done 		(	bias_read_done 		),
	.bias_read_busy 		(	bias_read_busy 		),
	.start_bias_read		(	start_bias_read		)

);



endmodule


