// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.12.04
// Ver      : 1.0
// Func     : testbench for kernel and bias module read and write 
// ============================================================================


// `define VIVA
`define End_CYCLE  10000      // Modify cycle times once your design need more cycle times!
`define NI_DELAY  2		// NONIDEAL delay latency
`define AFPOS_DELAY  0.5		// NONIDEAL delay latency

`ifdef RTL
	`timescale 1ns/100ps
    `define CYCLE 5	// 100MHz  1ns*`CYCLE = 10ns / cycle
`endif
`ifdef GATE
	`timescale 1ns/1ps
    `define CYCLE 3.3
`endif
`ifdef VIVA
	`timescale 1ns/100ps
    `define CYCLE 10	// 100MHz
`endif


//-- pattern path --
`ifdef RTL
	`define KER_PAT_0	"../../../PAT/w_sr/wsram_pat_0.dat"
	`define KER_PAT_1	"../../../PAT/w_sr/wsram_pat_1.dat"
	`define KER_PAT_2	"../../../PAT/w_sr/wsram_pat_2.dat"
	`define KER_PAT_3	"../../../PAT/w_sr/wsram_pat_3.dat"
	`define KER_PAT_4	"../../../PAT/w_sr/wsram_pat_4.dat"
	`define KER_PAT_5	"../../../PAT/w_sr/wsram_pat_5.dat"
	`define KER_PAT_6	"../../../PAT/w_sr/wsram_pat_6.dat"
	`define KER_PAT_7	"../../../PAT/w_sr/wsram_pat_7.dat"
	`define BIAS_DAT	"../../../PAT/2_bias.dat"

`endif




module kbtest ( );

	parameter TBITS = 64;
	parameter TBYTE = 8;

// ---- local parameter declare ----
	localparam BUF_TAG_BITS = 8;
	localparam BIAS_WORD_LENGTH = 32;

//----------------------------------------------------s


	reg [30:0] cycle=0;

	reg  clk;         
	reg  reset;       


	logic rstn = 1;
	wire [TBITS-1: 0 ]	isif_data_dout			;
	wire [TBYTE-1: 0 ]	isif_strb_dout			;
	wire 				isif_last_dout			;
	wire 				isif_user_dout			;
	logic 				isif_empty_n			;
	logic 				isif_read				;

	reg              S_AXIS_MM2S_TVALID = 0;
	wire             S_AXIS_MM2S_TREADY;
	reg  [TBITS-1:0] S_AXIS_MM2S_TDATA = 0;
	reg  [TBYTE-1:0] S_AXIS_MM2S_TKEEP = 0;
	reg  [1-1:0]     S_AXIS_MM2S_TLAST = 0;



//---------- pattern declare-----------------
logic tb_memread_done ;

logic [63:0] ker_sram_0 [0:2047];
logic [63:0] ker_sram_1 [0:2047];
logic [63:0] ker_sram_2 [0:2047];
logic [63:0] ker_sram_3 [0:2047];
logic [63:0] ker_sram_4 [0:2047];
logic [63:0] ker_sram_5 [0:2047];
logic [63:0] ker_sram_6 [0:2047];
logic [63:0] ker_sram_7 [0:2047];

logic [63:0] ker_sram_bus [0:7][0:512-1];
logic [64-1:0]	bias_array [ 0 : 1024];

// =============================================================================
//---- bias test signal ----
    logic tst_ker_read_done ;	
    logic tst_en_buf_sw ;	
    logic [9:0] tst_cp_ker_num ;	// testbench simulate ker_r module
//----------- test bias write module ------------------------
	logic bias_write_done;
	logic bias_write_busy;
	logic start_bias_write;
	logic tst_bwr_empty_n ;
	logic tst_bwr_read ;
//--------------------------------------------------------------
//----------- test bias read module ------------------------
	logic bias_read_done;
	logic bias_read_busy;
	logic start_bias_read;

//----------- bias output signal -----------------------------
// ====		replace bias reg		====
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_0	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_1	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_2	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_3	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_4	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_5	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_6	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_7	;

	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_0	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_1	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_2	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_3	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_4	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_5	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_6	;
	wire signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_7	;
// ====		Tag of bias reg		====
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_0	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_1	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_2	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_3	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_4	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_5	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_6	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_7	;

	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_next_0	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_next_1	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_next_2	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_next_3	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_next_4	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_next_5	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_next_6	;
	wire [BUF_TAG_BITS-1 : 0 ] tag_bias_next_7	;
// =============================================================================



// =============================================================================
//---- kernel test signal ----
//----------- test kernel write module ------------------------
	logic ker_write_done;
	logic ker_write_busy;
	logic start_ker_write;
	logic tst_kwr_empty_n ;
	logic tst_kwr_read ;
//--------------------------------------------------------------
//----------- test kernel read module ------------------------
	logic ker_read_done;
	logic ker_read_busy;
	logic start_ker_read;
//--------------------------------------------------------------
	logic [63:0] dout_kersr_0 , dout_kersr_1 , dout_kersr_2 , dout_kersr_3 , dout_kersr_4 , dout_kersr_5 , dout_kersr_6 , dout_kersr_7 ;
	logic ksr_valid_0 , ksr_valid_1 , ksr_valid_2 , ksr_valid_3 , ksr_valid_4 , ksr_valid_5 , ksr_valid_6 , ksr_valid_7 ;
	logic ksr_final_0 , ksr_final_1 , ksr_final_2 , ksr_final_3 , ksr_final_4 , ksr_final_5 , ksr_final_6 , ksr_final_7 ;

// testbench data collect
	logic [63:0] dout_kersr_0_dly0 , dout_kersr_1_dly0 , dout_kersr_2_dly0 , dout_kersr_3_dly0 , dout_kersr_4_dly0 , dout_kersr_5_dly0 , dout_kersr_6_dly0 , dout_kersr_7_dly0 ;
	logic ksr_valid_0_dly0 , ksr_valid_1_dly0 , ksr_valid_2_dly0 , ksr_valid_3_dly0 , ksr_valid_4_dly0 , ksr_valid_5_dly0 , ksr_valid_6_dly0 , ksr_valid_7_dly0		;
	logic ksr_final_0_dly0 , ksr_final_1_dly0 , ksr_final_2_dly0 , ksr_final_3_dly0 , ksr_final_4_dly0 , ksr_final_5_dly0 , ksr_final_6_dly0 , ksr_final_7_dly0		;
// =============================================================================

//---- sharing test signal ----
	reg tst_sram_rw  ;
	integer i0 , i1 ;
	logic tst_kwring = 0;
	logic tst_bwring = 0;

	logic [BUF_TAG_BITS -1 : 0 ] otker_align_dly0 , otker_align_dly1 , otker_align_dly2 , otker_align_dly3,
		otker_align_dly4 , otker_align_dly5 , otker_align_dly6 , otker_align_dly7,
		otker_align_dly8 , otker_align_dly9 , otker_align_dly10		;
	logic otenker_align_dly0 , otenker_align_dly1 , otenker_align_dly2 , otenker_align_dly3 , otenker_align_dly4 , otenker_align_dly5 , 
 	otenker_align_dly6 , otenker_align_dly7 , otenker_align_dly8 , otenker_align_dly9 , otenker_align_dly10	;

	wire signed [32-1 : 0 ] bias_sel_ot_0 ;
	wire signed [32-1 : 0 ] bias_sel_ot_1 ;
	wire signed [32-1 : 0 ] bias_sel_ot_2 ;
	wire signed [32-1 : 0 ] bias_sel_ot_3 ;
	wire signed [32-1 : 0 ] bias_sel_ot_4 ;
	wire signed [32-1 : 0 ] bias_sel_ot_5 ;
	wire signed [32-1 : 0 ] bias_sel_ot_6 ;
	wire signed [32-1 : 0 ] bias_sel_ot_7 ;
// ---- declare signal for bias read module ----
	wire [BUF_TAG_BITS-1:0] 	output_of_cnt_ker 			;
	wire					output_of_enable_ker_cnt 	;



// =============================================================================
// =====================		instance 		================================
// =============================================================================
	bias_top bit001 (
		.clk	(	clk		),
		.reset	(	reset	),

		.bias_write_data_din		(	isif_data_dout	),
		.bias_write_empty_n_din	(	tst_bwr_empty_n	),
		.bias_write_read_dout	(	tst_bwr_read		),

		.bias_write_done 		(	bias_write_done	),
		.bias_write_busy 		(	bias_write_busy	),
		.start_bias_write		(	start_bias_write	),

		.bias_read_done 			(	bias_read_done 	),
		.bias_read_busy 			(	bias_read_busy 	),
		.start_bias_read			(	start_bias_read	),

	// ====		replace bias reg		====
		.bias_reg_curr_0		(		bias_reg_curr_0		),
		.bias_reg_curr_1		(		bias_reg_curr_1		),
		.bias_reg_curr_2		(		bias_reg_curr_2		),
		.bias_reg_curr_3		(		bias_reg_curr_3		),
		.bias_reg_curr_4		(		bias_reg_curr_4		),
		.bias_reg_curr_5		(		bias_reg_curr_5		),
		.bias_reg_curr_6		(		bias_reg_curr_6		),
		.bias_reg_curr_7		(		bias_reg_curr_7		),

		.bias_reg_next_0		(		bias_reg_next_0		),
		.bias_reg_next_1		(		bias_reg_next_1		),
		.bias_reg_next_2		(		bias_reg_next_2		),
		.bias_reg_next_3		(		bias_reg_next_3		),
		.bias_reg_next_4		(		bias_reg_next_4		),
		.bias_reg_next_5		(		bias_reg_next_5		),
		.bias_reg_next_6		(		bias_reg_next_6		),
		.bias_reg_next_7		(		bias_reg_next_7		),
	// ====		Tag of bias reg	(				)	====
		.tag_bias_curr_0		(		tag_bias_curr_0		),
		.tag_bias_curr_1		(		tag_bias_curr_1		),
		.tag_bias_curr_2		(		tag_bias_curr_2		),
		.tag_bias_curr_3		(		tag_bias_curr_3		),
		.tag_bias_curr_4		(		tag_bias_curr_4		),
		.tag_bias_curr_5		(		tag_bias_curr_5		),
		.tag_bias_curr_6		(		tag_bias_curr_6		),
		.tag_bias_curr_7		(		tag_bias_curr_7		),

		.tag_bias_next_0		(		tag_bias_next_0		),
		.tag_bias_next_1		(		tag_bias_next_1		),
		.tag_bias_next_2		(		tag_bias_next_2		),
		.tag_bias_next_3		(		tag_bias_next_3		),
		.tag_bias_next_4		(		tag_bias_next_4		),
		.tag_bias_next_5		(		tag_bias_next_5		),
		.tag_bias_next_6		(		tag_bias_next_6		),
		.tag_bias_next_7		(		tag_bias_next_7		),

		.tst_cp_ker_num			(	otker_align_dly2		),
		.tst_en_buf_sw			(	tst_en_buf_sw		),
		.tst_ker_read_done			(	ker_read_done		),
		.tst_sram_rw			(	tst_sram_rw		)
	
	);

	
	ker_top kt001 (
		.clk	(	clk		),
		.reset	(	reset	),

		.ker_write_data_din		(	isif_data_dout	),
		.ker_write_empty_n_din	(	tst_kwr_empty_n	),
		.ker_write_read_dout	(	tst_kwr_read		),

		.ker_write_done 		(	ker_write_done	),
		.ker_write_busy 		(	ker_write_busy	),
		.start_ker_write		(	start_ker_write	),

		.ker_read_done 			(	ker_read_done 	),
		.ker_read_busy 			(	ker_read_busy 	),
		.start_ker_read			(	start_ker_read	),

		//----generated by ker_top_mod.py------ 
		//----top port list for other module instance------ 
		.dout_kersr_0 ( dout_kersr_0 ), .ksr_valid_0  ( ksr_valid_0 ), .ksr_final_0  ( ksr_final_0 ), //----instance KER top_0---------
		.dout_kersr_1 ( dout_kersr_1 ), .ksr_valid_1  ( ksr_valid_1 ), .ksr_final_1  ( ksr_final_1 ), //----instance KER top_1---------
		.dout_kersr_2 ( dout_kersr_2 ), .ksr_valid_2  ( ksr_valid_2 ), .ksr_final_2  ( ksr_final_2 ), //----instance KER top_2---------
		.dout_kersr_3 ( dout_kersr_3 ), .ksr_valid_3  ( ksr_valid_3 ), .ksr_final_3  ( ksr_final_3 ), //----instance KER top_3---------
		.dout_kersr_4 ( dout_kersr_4 ), .ksr_valid_4  ( ksr_valid_4 ), .ksr_final_4  ( ksr_final_4 ), //----instance KER top_4---------
		.dout_kersr_5 ( dout_kersr_5 ), .ksr_valid_5  ( ksr_valid_5 ), .ksr_final_5  ( ksr_final_5 ), //----instance KER top_5---------
		.dout_kersr_6 ( dout_kersr_6 ), .ksr_valid_6  ( ksr_valid_6 ), .ksr_final_6  ( ksr_final_6 ), //----instance KER top_6---------
		.dout_kersr_7 ( dout_kersr_7 ), .ksr_valid_7  ( ksr_valid_7 ), .ksr_final_7  ( ksr_final_7 ), //----instance KER top_7---------

		.output_of_cnt_ker 			(	output_of_cnt_ker 				),
		.output_of_enable_ker_cnt 	(	output_of_enable_ker_cnt 		),

		.tst_sram_rw			(	tst_sram_rw		)
	
	);

	INPUT_STREAM_if		#(
		.TBITS	(	TBITS	),
		.TBYTE	(	TBYTE	)
	)
	axififo_in (
		// AXI4-Stream singals
		.ACLK       (	clk	),
		.ARESETN    (	rstn	),
		.TVALID     (	S_AXIS_MM2S_TVALID	),
		.TREADY     (	S_AXIS_MM2S_TREADY	),
		.TDATA      (	S_AXIS_MM2S_TDATA	),
		.TKEEP      (	S_AXIS_MM2S_TKEEP	),
		.TLAST      (	S_AXIS_MM2S_TLAST	),
		.TUSER      ( 1'b0 ),

		// User signals
		.isif_data_dout         (	isif_data_dout		),
		.isif_strb_dout         (	isif_strb_dout		),
		.isif_last_dout         (	isif_last_dout		),
		.isif_user_dout         (	isif_user_dout		),
		.isif_empty_n           (	isif_empty_n		),
		.isif_read				(	isif_read			)
	);


// =============================================================================
// ================		clock generate & end cycle		========================
// =============================================================================

	initial clk = 1;

	always begin #(`CYCLE / 2) clk = ~clk; end
	always@(*)begin
		rstn = ~reset;
	end
	
	always @(posedge clk) begin
		cycle <= cycle+1;
		if (cycle > `End_CYCLE) begin
			$display("********************************************************************");
			$display("**  Failed waiting Valid signal, Simulation STOP at cycle %d **",cycle);
			$display("**  If needed, You can increase End_CYCLE value in tp.v           **");
			$display("********************************************************************");
			$finish;
		end
	end
// =============================================================
// =============================================================================
// ================		fsdb dump +mda+packedmda		========================
// ================		Kernel data load readmemh		========================
// =============================================================================

	initial begin
		`ifdef RTL
			$fsdbDumpfile("tb_sim000.fsdb");
			$fsdbDumpvars(0,"+mda","+packedmda");		//++
			$fsdbDumpMDA();
		`elsif GATE
			$sdf_annotate(`SDFFILE,bias_top);	//  $sdf_annotate("sdf_file"[,module_instance][,"sdf_configfile"][,"sdf_logfile"][,"mtm_spec"][,"scale_factors"][,"scale_type"]);
			$fsdbDumpfile("dla_top_SYN.fsdb");	
			$fsdbDumpvars();
		`else 
		`endif
	end

	initial begin // initial pattern and expected result
		wait(reset==1);
		tb_memread_done = 0; 
		//--------- pattern reading start -----------
		$readmemh(`KER_PAT_0, ker_sram_0);
		$readmemh(`KER_PAT_1, ker_sram_1);
		$readmemh(`KER_PAT_2, ker_sram_2);
		$readmemh(`KER_PAT_3, ker_sram_3);
		$readmemh(`KER_PAT_4, ker_sram_4);
		$readmemh(`KER_PAT_5, ker_sram_5);
		$readmemh(`KER_PAT_6, ker_sram_6);
		$readmemh(`KER_PAT_7, ker_sram_7);



		$readmemh(`BIAS_DAT, bias_array);
		//--------- pattern reading end -----------	
		#1;
		tb_memread_done = 1;

	end

// =============================================================


assign isif_read = ( tst_kwring ) ? tst_kwr_read :
						( tst_bwring ) ? tst_bwr_read :
									1'd0 ;

assign tst_kwr_empty_n = ( tst_kwring ) ? isif_empty_n : 1'd0 ;
assign tst_bwr_empty_n = ( tst_bwring ) ? isif_empty_n : 1'd0 ;
// =============================================================================
// ====			initial control write kernel and bias		====================
// =============================================================================
	initial begin
		#1;
		reset = 0;
		#( `CYCLE*3 ) ;
		reset = 1;
		//-----------reset signal start ------------------
		S_AXIS_MM2S_TKEEP = 'hff;
		S_AXIS_MM2S_TLAST = 0 ;
		start_ker_write = 0;
		start_ker_read = 0 ;
		start_bias_write = 0;
		start_bias_read = 0;
		tst_kwring = 0;
		tst_bwring = 0;
		//-----------reset signal end ------------------
		#( `CYCLE*4 + `NI_DELAY ) ;
		reset = 0;
		#( `CYCLE*5 ) ;

		//----- wait mem read --------------
		wait(tb_memread_done) ;
		#( `CYCLE*5 ) ;


		//----- kernel write --------------
		wait( ker_write_busy==1'd0 );
		tst_sram_rw = 1 ;
		tst_kwring = 1;
		tst_bwring = 0;

		@( posedge clk );
		start_ker_write = 1;
		#( `CYCLE*3 ) ;
		@( posedge clk );
		start_ker_write = 0;
		

		@( posedge clk ); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1= 0 ;
		for( i1=0 ; i1<288 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = ker_sram_0[ i1  ]	;
				if(  (i1==287)   ) S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		end
		@( posedge clk ); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1= 0 ;
		for( i1=0 ; i1<288 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = ker_sram_1[ i1  ]	;
				if(  (i1==287)   ) S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		end
		@( posedge clk ); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1= 0 ;
		for( i1=0 ; i1<288 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = ker_sram_2[ i1  ]	;
				if(  (i1==287)   ) S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		end
		@( posedge clk ); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1= 0 ;
		for( i1=0 ; i1<288 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = ker_sram_3[ i1  ]	;
				if(  (i1==287)   ) S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		end
		@( posedge clk ); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1= 0 ;
		for( i1=0 ; i1<288 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = ker_sram_4[ i1  ]	;
				if(  (i1==287)   ) S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		end
		@( posedge clk ); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1= 0 ;
		for( i1=0 ; i1<288 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = ker_sram_5[ i1  ]	;
				if(  (i1==287)   ) S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		end
		@( posedge clk ); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1= 0 ;
		for( i1=0 ; i1<288 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = ker_sram_6[ i1  ]	;
				if(  (i1==287)   ) S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		end
		@( posedge clk ); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1= 0 ;
		for( i1=0 ; i1<288 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = ker_sram_7[ i1  ]	;
				if(  (i1==287)   ) S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		end


		@(posedge clk); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
		wait( ker_write_done==1'd1 );

		//----- kernel write end--------------
		//....
		//..
		//....
		//----- bias write --------------
		wait( bias_write_busy ==1'd0 );
		tst_sram_rw = 1 ;
		tst_kwring = 0;
		tst_bwring = 1;
		@(posedge clk); #(`AFPOS_DELAY) ;
		start_bias_write = 1;
		#( `CYCLE*3 ) ;
		@(posedge clk); #(`AFPOS_DELAY) ;
		start_bias_write = 0;

		@(posedge clk); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1=0 ;
		for( i1=0 ; i1<64 ; i1=i1+1 )begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = bias_array[ i1  ]	;
				if(  (i1==63)    )begin
					S_AXIS_MM2S_TLAST = 1 ;
				end
				wait(S_AXIS_MM2S_TREADY);
		end
		@(posedge clk); #(`AFPOS_DELAY) ;
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			i1=0 ;
			
		wait( bias_write_done ==1'd1 );
		tst_kwring = 0;
		tst_bwring = 0;
		//----- bias write end--------------
		//....
		//..
		//....
		//----- synchronize kernel and bias read--------------
		@(posedge clk); #(`AFPOS_DELAY) ;
			tst_sram_rw = 0 ;
		wait( bias_read_busy ==1'd0 );
		wait( ker_read_busy ==1'd0 );
		@(posedge clk); #(`AFPOS_DELAY) ;
			start_bias_read = 1;
			start_ker_read = 1;
			#( `CYCLE*3 ) ;
		@(posedge clk); #(`AFPOS_DELAY) ;
			start_bias_read = 0;
			start_ker_read 	= 0;

		wait( bias_read_done == 1'd1 );
		wait( ker_read_done == 1'd1 );

		//----- synchronize kernel and bias read end--------------



	end



// =============================================================================
// ================		kernel sram read data check		========================
// =============================================================================
	always @(posedge clk ) begin
		dout_kersr_0_dly0 <= dout_kersr_0 ;
		dout_kersr_1_dly0 <= dout_kersr_1 ;
		dout_kersr_2_dly0 <= dout_kersr_2 ;
		dout_kersr_3_dly0 <= dout_kersr_3 ;
		dout_kersr_4_dly0 <= dout_kersr_4 ;
		dout_kersr_5_dly0 <= dout_kersr_5 ;
		dout_kersr_6_dly0 <= dout_kersr_6 ;
		dout_kersr_7_dly0 <= dout_kersr_7 ;

		ksr_valid_0_dly0 <= ksr_valid_0 ;
		ksr_valid_1_dly0 <= ksr_valid_1 ;
		ksr_valid_2_dly0 <= ksr_valid_2 ;
		ksr_valid_3_dly0 <= ksr_valid_3 ;
		ksr_valid_4_dly0 <= ksr_valid_4 ;
		ksr_valid_5_dly0 <= ksr_valid_5 ;
		ksr_valid_6_dly0 <= ksr_valid_6 ;
		ksr_valid_7_dly0 <= ksr_valid_7 ;

		ksr_final_0_dly0 <= ksr_final_0 ;
		ksr_final_1_dly0 <= ksr_final_1 ;
		ksr_final_2_dly0 <= ksr_final_2 ;
		ksr_final_3_dly0 <= ksr_final_3 ;
		ksr_final_4_dly0 <= ksr_final_4 ;
		ksr_final_5_dly0 <= ksr_final_5 ;
		ksr_final_6_dly0 <= ksr_final_6 ;
		ksr_final_7_dly0 <= ksr_final_7 ;
	end



	always @(posedge clk ) begin
		otker_align_dly0	<= output_of_cnt_ker ;
		otker_align_dly1	<= otker_align_dly0 ;
		otker_align_dly2	<= otker_align_dly1 ;
		otker_align_dly3	<= otker_align_dly2 ;
		otker_align_dly4	<= otker_align_dly3 ;
		otker_align_dly5	<= otker_align_dly4 ;
		otker_align_dly6	<= otker_align_dly5 ;
		otker_align_dly7	<= otker_align_dly6 ;
		otker_align_dly8	<= otker_align_dly7 ;
		otker_align_dly9	<= otker_align_dly8 ;
		otker_align_dly10	<= otker_align_dly9 ;



		otenker_align_dly0	<= output_of_enable_ker_cnt ;
		otenker_align_dly1	<= otenker_align_dly0 ;
		otenker_align_dly2	<= otenker_align_dly1 ;
		otenker_align_dly3	<= otenker_align_dly2 ;
		otenker_align_dly4	<= otenker_align_dly3 ;
		otenker_align_dly5	<= otenker_align_dly4 ;
		otenker_align_dly6	<= otenker_align_dly5 ;
		otenker_align_dly7	<= otenker_align_dly6 ;
		otenker_align_dly8	<= otenker_align_dly7 ;
		otenker_align_dly9	<= otenker_align_dly8 ;
		otenker_align_dly10	<= otenker_align_dly9 ;


	end


// =========================================================================
// ================		valid kerbias output		========================
// =========================================================================


//---- bias select by tag version 1 : 2022.12.05 ----
// assign bias_sel_ot_0 = ( otker_align_dly2 == tag_bias_curr_0 ) ? bias_reg_curr_0 : bias_reg_next_0 ;
// assign bias_sel_ot_1 = ( otker_align_dly3 == tag_bias_curr_1 ) ? bias_reg_curr_1 : bias_reg_next_1 ;
// assign bias_sel_ot_2 = ( otker_align_dly4 == tag_bias_curr_2 ) ? bias_reg_curr_2 : bias_reg_next_2 ;
// assign bias_sel_ot_3 = ( otker_align_dly5 == tag_bias_curr_3 ) ? bias_reg_curr_3 : bias_reg_next_3 ;
// assign bias_sel_ot_4 = ( otker_align_dly6 == tag_bias_curr_4 ) ? bias_reg_curr_4 : bias_reg_next_4 ;
// assign bias_sel_ot_5 = ( otker_align_dly7 == tag_bias_curr_5 ) ? bias_reg_curr_5 : bias_reg_next_5 ;
// assign bias_sel_ot_6 = ( otker_align_dly8 == tag_bias_curr_6 ) ? bias_reg_curr_6 : bias_reg_next_6 ;
// assign bias_sel_ot_7 = ( otker_align_dly9 == tag_bias_curr_7 ) ? bias_reg_curr_7 : bias_reg_next_7 ;

//---- bias select by tag version 2 : 2022.12.05 ----
assign bias_sel_ot_0 = ( otker_align_dly2 == tag_bias_curr_0 ) ? bias_reg_curr_0 : ( otker_align_dly2 == tag_bias_next_0 ) ? bias_reg_next_0 : 32'hx ;
assign bias_sel_ot_1 = ( otker_align_dly3 == tag_bias_curr_1 ) ? bias_reg_curr_1 : ( otker_align_dly3 == tag_bias_next_1 ) ? bias_reg_next_1 : 32'hx ;
assign bias_sel_ot_2 = ( otker_align_dly4 == tag_bias_curr_2 ) ? bias_reg_curr_2 : ( otker_align_dly4 == tag_bias_next_2 ) ? bias_reg_next_2 : 32'hx ;
assign bias_sel_ot_3 = ( otker_align_dly5 == tag_bias_curr_3 ) ? bias_reg_curr_3 : ( otker_align_dly5 == tag_bias_next_3 ) ? bias_reg_next_3 : 32'hx ;
assign bias_sel_ot_4 = ( otker_align_dly6 == tag_bias_curr_4 ) ? bias_reg_curr_4 : ( otker_align_dly6 == tag_bias_next_4 ) ? bias_reg_next_4 : 32'hx ;
assign bias_sel_ot_5 = ( otker_align_dly7 == tag_bias_curr_5 ) ? bias_reg_curr_5 : ( otker_align_dly7 == tag_bias_next_5 ) ? bias_reg_next_5 : 32'hx ;
assign bias_sel_ot_6 = ( otker_align_dly8 == tag_bias_curr_6 ) ? bias_reg_curr_6 : ( otker_align_dly8 == tag_bias_next_6 ) ? bias_reg_next_6 : 32'hx ;
assign bias_sel_ot_7 = ( otker_align_dly9 == tag_bias_curr_7 ) ? bias_reg_curr_7 : ( otker_align_dly9 == tag_bias_next_7 ) ? bias_reg_next_7 : 32'hx ;

assign tst_en_buf_sw = otenker_align_dly9 ;



endmodule
