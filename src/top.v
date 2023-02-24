// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.01.30
// Ver      : 1.0
// Func     : DLA_512MAC top module 
//  	----parameter reset active low -- https://youtu.be/KyQuVydW1n8
//  	----high fanout pin fixed by DC synthesis, do not code buffer.
//  	----get_ins module : distinguish data or instruction for this time.
//  	----signal port naming : should not use common port name for every top module port naming.
//  	----output signal tips : should not use output signal for flow controlling like "busy".
// Log		: 
// 		2023.01.30 : integrate before PE computing module.
// 		2023.02.22 : git server update, add padding module
// ============================================================================


module dla512_top #(
		parameter TBITS = 64	
	,	parameter TBYTE = 8		

)
(	clk	
	,	reset	
	,	S_AXIS_MM2S_TVALID	
	,	S_AXIS_MM2S_TREADY	
	,	S_AXIS_MM2S_TDATA	
	,	S_AXIS_MM2S_TKEEP	
	,	S_AXIS_MM2S_TLAST	

	//----tb top instance start------ 
	,	valid_to_pe_0 ,	final_to_pe_0 ,	dout_if_0 , dout_ke_0 ,	dout_bi_0 //-- PE block -0-
	,	valid_to_pe_1 ,	final_to_pe_1 ,	dout_if_1 , dout_ke_1 ,	dout_bi_1 //-- PE block -1-
	,	valid_to_pe_2 ,	final_to_pe_2 ,	dout_if_2 , dout_ke_2 ,	dout_bi_2 //-- PE block -2-
	,	valid_to_pe_3 ,	final_to_pe_3 ,	dout_if_3 , dout_ke_3 ,	dout_bi_3 //-- PE block -3-
	,	valid_to_pe_4 ,	final_to_pe_4 ,	dout_if_4 , dout_ke_4 ,	dout_bi_4 //-- PE block -4-
	,	valid_to_pe_5 ,	final_to_pe_5 ,	dout_if_5 , dout_ke_5 ,	dout_bi_5 //-- PE block -5-
	,	valid_to_pe_6 ,	final_to_pe_6 ,	dout_if_6 , dout_ke_6 ,	dout_bi_6 //-- PE block -6-
	,	valid_to_pe_7 ,	final_to_pe_7 ,	dout_if_7 , dout_ke_7 ,	dout_bi_7 //-- PE block -7-
);

localparam BUF_TAG_BITS = 8;
localparam BIAS_WORD_LENGTH = 32;

parameter RESET_ACTIVE_LOW = 1;
wire ap_rst;


	input wire clk	;
	input wire reset	;

	input wire 	S_AXIS_MM2S_TVALID	;
	output wire S_AXIS_MM2S_TREADY	;
	input wire 	[TBITS-1:0]S_AXIS_MM2S_TDATA	;
	input wire 	[TBYTE-1:0]S_AXIS_MM2S_TKEEP	;
	input wire 	S_AXIS_MM2S_TLAST	;

//---- Temporary I/O for test -------

output wire valid_to_pe_0 ,	valid_to_pe_1 ,	valid_to_pe_2 ,	valid_to_pe_3 ,	valid_to_pe_4 ,	valid_to_pe_5 ,	valid_to_pe_6 ,	valid_to_pe_7 ;

output wire final_to_pe_0 , final_to_pe_1 , final_to_pe_2 , final_to_pe_3 , final_to_pe_4 , final_to_pe_5 , final_to_pe_6 , final_to_pe_7 ;
output wire [64-1:0]dout_if_0 , dout_if_1 , dout_if_2 , dout_if_3 , dout_if_4 , dout_if_5 , dout_if_6 , dout_if_7 ;
output wire [64-1:0]dout_ke_0 , dout_ke_1 , dout_ke_2 , dout_ke_3 , dout_ke_4 , dout_ke_5 , dout_ke_6 , dout_ke_7 ;
output wire [32-1:0]dout_bi_0 , dout_bi_1 , dout_bi_2 , dout_bi_3 , dout_bi_4 , dout_bi_5 , dout_bi_6 , dout_bi_7 ;


//-- input fifo signal --
wire [TBITS-1: 0 ]	isif_data_dout			;
wire 				isif_last_dout			;
wire 				isif_empty_n			;
wire [TBYTE-1: 0 ]	isif_strb_dout			;
wire 				isif_user_dout			;
wire 				isif_read				;
//-- output fifo signal --
wire 				osif_full_n				;
wire 				osif_write				;
wire [TBITS-1: 0 ]	osif_data_din			;
wire 				osif_last_din			;
wire [TBYTE-1: 0 ]	osif_strb_din			;
wire 				osif_user_din			;


//---- schedule ctrl ----
wire if_write_done		;
wire if_write_busy		;
wire if_write_start		;
wire if_read_done		;
wire if_read_busy		;
wire if_read_start		;
wire if_pad_done 		;
wire if_pad_busy 		;
wire if_pad_start		;

wire ker_write_start	;
wire ker_write_busy		;
wire ker_write_done		;
wire bias_write_start	;
wire bias_write_busy	;
wire bias_write_done	;

wire ker_read_start	;
wire ker_read_busy		;
wire ker_read_done		;
wire bias_read_start	;
wire bias_read_busy	;
wire bias_read_done	;

wire sche_fsld_end 		;
wire sche_left_done 	;
wire[3-1:0] sche_fsld_curr_state ;

//----fsm----
wire [3-1:0] fsm_mast_state;

//---- get instruction ----
wire empty_n_from_gi	;
wire read_for_gi		;
wire gi_start ;

wire [64-1:0] config_param00	;
wire [64-1:0] config_param01	;
wire [64-1:0] config_param02	;

//---- if_rw ----
wire [TBITS-1:0]	if_write_data_din		;
wire if_write_empty_n		;
wire if_write_read			;

wire ifsram0_write		;	//schedule -> if_rw
wire ifsram1_write		;	//schedule -> if_rw
wire ifsram0_read		;	//schedule -> if_rw
wire ifsram1_read		;	//schedule -> if_rw
wire if_row_finish		;	//if_rw -> schedule
wire if_change_sram		;	//if_rw -> schedule    
wire [2:0] if_read_current_state;  //schedule -> if_rw


//---- kernel_rw ----
wire ker_write_empty_n	 ;
wire ker_write_read		 ;
reg ker_read_en_ker_cnt ;
reg [8-1:0]ker_read_cnt_ker ;
//---- bias_rw ----
wire bias_write_empty_n		;
wire bias_write_read		;


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


	wire signed [32-1 : 0 ] bias_sel_ot_0 ;
	wire signed [32-1 : 0 ] bias_sel_ot_1 ;
	wire signed [32-1 : 0 ] bias_sel_ot_2 ;
	wire signed [32-1 : 0 ] bias_sel_ot_3 ;
	wire signed [32-1 : 0 ] bias_sel_ot_4 ;
	wire signed [32-1 : 0 ] bias_sel_ot_5 ;
	wire signed [32-1 : 0 ] bias_sel_ot_6 ;
	wire signed [32-1 : 0 ] bias_sel_ot_7 ;

	reg [BUF_TAG_BITS -1 : 0 ] otker_align_dly0 , otker_align_dly1 , otker_align_dly2 , otker_align_dly3,
		otker_align_dly4 , otker_align_dly5 , otker_align_dly6 , otker_align_dly7,
		otker_align_dly8 , otker_align_dly9 , otker_align_dly10		;
	reg otenker_align_dly0 , otenker_align_dly1 , otenker_align_dly2 , otenker_align_dly3 , otenker_align_dly4 , otenker_align_dly5 , 
 	otenker_align_dly6 , otenker_align_dly7 , otenker_align_dly8 , otenker_align_dly9 , otenker_align_dly10	;

	wire bias_read_en_buf_sw ;
//----------------------------------------------------------------------------

// ===========================================================================
// =======		instance 	==================================================
// ===========================================================================




	fsm64 fs01(
		.clk	(	clk	)
		,	.reset		(	reset		)
		,	.start		(	gi_start	)
		,	.outmast_curr_state (	fsm_mast_state	)
		,	.flag_fsld_end 	(	sche_fsld_end		)
		,	.left_done 		(	sche_left_done		)

	);

	get_ins gi01(	.clk 	(	clk	)
	,	.reset 	(	reset	)

	,	.fifo_data_din		(	isif_data_dout		)
	,	.fifo_strb_din		(	isif_strb_dout		)
	,	.fifo_last_din		(	isif_last_dout		)
	,	.fifo_user_din		(	isif_user_dout		)
	,	.fifo_empty_n_din	(	isif_empty_n		)
	,	.fifo_read_dout		(	isif_read			)

	,	.ds_empty_n			(	empty_n_from_gi		)	// output
	,	.ds_read			(	read_for_gi			)		// input

	,	.instr_code00	(	config_param00		)
	,	.instr_code01	(	config_param01		)
	,	.instr_code02	(	config_param02		)

	,	.start_reg		(	gi_start	)

	);



schedule_ctrl sche00(.clk 	(	clk	)
	,	.reset 	(	reset	)

	,	.mast_curr_state 		(	fsm_mast_state	)			

	,	.if_write_start			(	if_write_start		)
	,	.if_write_busy			(	if_write_busy		)
	,	.if_write_done			(	if_write_done		)

	,	.if_pad_done 			(	if_pad_done 	)
	,	.if_pad_busy 			(	if_pad_busy 	)
	,	.if_pad_start			(	if_pad_start	)

	,	.ker_write_start		(	ker_write_start		)
	,	.ker_write_busy			(	ker_write_busy		)
	,	.ker_write_done			(	ker_write_done		)

	,	.bias_write_start		(	bias_write_start	)
	,	.bias_write_busy		(	bias_write_busy		)
	,	.bias_write_done		(	bias_write_done		)

	,	.if_read_done 			(	if_read_done		)	//if_rw -> schedule
	,	.if_read_busy 			(	if_read_busy		)	//if_rw -> schedule
	,	.if_read_start			(	if_read_start		)	//schedule -> if_rw

	// //--------------Read sram I/O------------
	,	.ifsram0_write		(	ifsram0_write	)	//schedule -> if_rw
	,	.ifsram1_write		(	ifsram1_write	)	//schedule -> if_rw
	,	.ifsram0_read		(	ifsram0_read	)	//schedule -> if_rw
	,	.ifsram1_read		(	ifsram1_read	)	//schedule -> if_rw
	,	.if_row_finish		(	if_row_finish	)	//if_rw -> schedule
	,	.if_change_sram		(	if_change_sram	)	//if_rw -> schedule    
	,	.if_read_current_state		(	if_read_current_state	)	//schedule -> if_rw
	//-------------------------------------------------
	,	.flag_fsld_end		(	sche_fsld_end		)
	,	.left_done			(	sche_left_done		)

	//----testing ----
	,	.sche_fsld_curr_state			(	sche_fsld_curr_state	)

	//---------------------------------------------


);



//----


d_empn_rd_mux der_0(
		.if_write_empty_n		(	if_write_empty_n	)	// input feature write module empty_n signal
	,	.ker_write_empty_n		(	ker_write_empty_n	)	// kernel write module empty_n signal
	,	.bias_write_empty_n		(	bias_write_empty_n	)	// bias write module empty_n signal
	,	.if_write_read			(	if_write_read		)	// input feature write module read signal
	,	.ker_write_read			(	ker_write_read		)	// kernel write module read signal
	,	.bias_write_read		(	bias_write_read		)	// bias write module read signal

	,	.empty_n_from_gi		(	empty_n_from_gi		)
	,	.read_for_gi			(	read_for_gi			)

	,	.mast_current_state		(	fsm_mast_state	)
	,	.fsld_current_state		(	sche_fsld_curr_state	)
	,	.if_write_busy			(	if_write_busy	)
	,	.ker_write_busy			(	ker_write_busy	)
	,	.bias_write_busy		(	bias_write_busy	)

);


ifsram_rw if_rw(
		.clk	(	clk		)
	,	.reset	(	reset	)

	,	.if_write_data_din		(	isif_data_dout		)			
	,	.if_write_empty_n_din	(	if_write_empty_n	)		
	,	.if_write_read_dout		(	if_write_read		)		

	,	.if_write_done			(	if_write_done	)	
	,	.if_write_busy			(	if_write_busy	)	
	,	.if_write_start			(	if_write_start	)	

	,	.if_read_done			(	if_read_done	) 		
	,	.if_read_busy			(	if_read_busy	) 		
	,	.if_read_start			(	if_read_start	)		

	,	.if_pad_done 			(	if_pad_done 	)
	,	.if_pad_busy 			(	if_pad_busy 	)
	,	.if_pad_start			(	if_pad_start	)

	,	.ifsram0_read			(	ifsram0_read		)		
	,	.ifsram1_read			(	ifsram1_read		)		
	,	.ifsram0_write			(	ifsram0_write		)	
	,	.ifsram1_write			(	ifsram1_write		)   
	,	.row_finish				(	if_row_finish			)
	,	.change_sram			(	if_change_sram			)
	,	.if_read_current_state	(	if_read_current_state	)   

);


ker_top kt001 (		.clk	(	clk		)
	,	.reset	(	reset	)

	,	.ker_write_data_din		(	isif_data_dout		)
	,	.ker_write_empty_n_din	(	ker_write_empty_n		)
	,	.ker_write_read_dout	(	ker_write_read		)

	,	.ker_write_done 		(	ker_write_done	)
	,	.ker_write_busy 		(	ker_write_busy	)
	,	.start_ker_write		(	ker_write_start	)

	,	.ker_read_done 			(	ker_read_done 	)
	,	.ker_read_busy 			(	ker_read_busy 	)
	,	.start_ker_read			(	if_read_start	)

	//----generated by ker_top_mod.py------ 
	//----top port list for other module instance------ 
	,	.dout_kersr_0 ( dout_ke_0 ), .ksr_valid_0  ( ksr_valid_0 ), .ksr_final_0  ( ksr_final_0 ) //----instance KER top_0---------
	,	.dout_kersr_1 ( dout_ke_1 ), .ksr_valid_1  ( ksr_valid_1 ), .ksr_final_1  ( ksr_final_1 ) //----instance KER top_1---------
	,	.dout_kersr_2 ( dout_ke_2 ), .ksr_valid_2  ( ksr_valid_2 ), .ksr_final_2  ( ksr_final_2 ) //----instance KER top_2---------
	,	.dout_kersr_3 ( dout_ke_3 ), .ksr_valid_3  ( ksr_valid_3 ), .ksr_final_3  ( ksr_final_3 ) //----instance KER top_3---------
	,	.dout_kersr_4 ( dout_ke_4 ), .ksr_valid_4  ( ksr_valid_4 ), .ksr_final_4  ( ksr_final_4 ) //----instance KER top_4---------
	,	.dout_kersr_5 ( dout_ke_5 ), .ksr_valid_5  ( ksr_valid_5 ), .ksr_final_5  ( ksr_final_5 ) //----instance KER top_5---------
	,	.dout_kersr_6 ( dout_ke_6 ), .ksr_valid_6  ( ksr_valid_6 ), .ksr_final_6  ( ksr_final_6 ) //----instance KER top_6---------
	,	.dout_kersr_7 ( dout_ke_7 ), .ksr_valid_7  ( ksr_valid_7 ), .ksr_final_7  ( ksr_final_7 ) //----instance KER top_7---------

	,	.output_of_cnt_ker 			(	ker_read_cnt_ker 		)
	,	.output_of_enable_ker_cnt 	(	ker_read_en_ker_cnt 	)

	// ,	.tst_sram_rw			(	tst_sram_rw		)
	
	);



	bias_top bit001 (
		.clk	(	clk		)
		,	.reset	(	reset	)

		,	.bias_write_data_din	(	isif_data_dout		)
		,	.bias_write_empty_n_din	(	bias_write_empty_n		)
		,	.bias_write_read_dout	(	bias_write_read			)

		,	.bias_write_done 		(	bias_write_done		)
		,	.bias_write_busy 		(	bias_write_busy		)
		,	.start_bias_write		(	bias_write_start	)

		,	.bias_read_done 		(	bias_read_done 	)
		,	.bias_read_busy 		(	bias_read_busy 	)
		,	.start_bias_read		(	if_read_start	)

	// ====		replace bias reg		====
		,	.bias_reg_curr_0		(	bias_reg_curr_0		)
		,	.bias_reg_curr_1		(	bias_reg_curr_1		)
		,	.bias_reg_curr_2		(	bias_reg_curr_2		)
		,	.bias_reg_curr_3		(	bias_reg_curr_3		)
		,	.bias_reg_curr_4		(	bias_reg_curr_4		)
		,	.bias_reg_curr_5		(	bias_reg_curr_5		)
		,	.bias_reg_curr_6		(	bias_reg_curr_6		)
		,	.bias_reg_curr_7		(	bias_reg_curr_7		)

		,	.bias_reg_next_0		(	bias_reg_next_0		)
		,	.bias_reg_next_1		(	bias_reg_next_1		)
		,	.bias_reg_next_2		(	bias_reg_next_2		)
		,	.bias_reg_next_3		(	bias_reg_next_3		)
		,	.bias_reg_next_4		(	bias_reg_next_4		)
		,	.bias_reg_next_5		(	bias_reg_next_5		)
		,	.bias_reg_next_6		(	bias_reg_next_6		)
		,	.bias_reg_next_7		(	bias_reg_next_7		)
	// ====		Tag of bias reg	(				)	====
		,	.tag_bias_curr_0		(	tag_bias_curr_0		)
		,	.tag_bias_curr_1		(	tag_bias_curr_1		)
		,	.tag_bias_curr_2		(	tag_bias_curr_2		)
		,	.tag_bias_curr_3		(	tag_bias_curr_3		)
		,	.tag_bias_curr_4		(	tag_bias_curr_4		)
		,	.tag_bias_curr_5		(	tag_bias_curr_5		)
		,	.tag_bias_curr_6		(	tag_bias_curr_6		)
		,	.tag_bias_curr_7		(	tag_bias_curr_7		)

		,	.tag_bias_next_0		(	tag_bias_next_0		)
		,	.tag_bias_next_1		(	tag_bias_next_1		)
		,	.tag_bias_next_2		(	tag_bias_next_2		)
		,	.tag_bias_next_3		(	tag_bias_next_3		)
		,	.tag_bias_next_4		(	tag_bias_next_4		)
		,	.tag_bias_next_5		(	tag_bias_next_5		)
		,	.tag_bias_next_6		(	tag_bias_next_6		)
		,	.tag_bias_next_7		(	tag_bias_next_7		)

		,	.tst_cp_ker_num			(	otker_align_dly2	)
		,	.tst_en_buf_sw			(	bias_read_en_buf_sw		)
		,	.tst_ker_read_done		(	ker_read_done		)
		// ,	.tst_sram_rw			(	tst_sram_rw		)
	
	);

	INPUT_STREAM_if		#(
		.TBITS	(	TBITS	),
		.TBYTE	(	TBYTE	)
	)
	axififo_in (
		// AXI4-Stream singals
		.ACLK       (	clk	),
		.ARESETN    (	ap_rst	),
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

	yolo_rst_if #(
			.RESET_ACTIVE_LOW ( RESET_ACTIVE_LOW ) )
	yolo_rst_if_U(
			.dout ( ap_rst ) ,
			.din ( reset ) );  // yolo_rst_if_U

//---- bias select by tag version 1 : 2022.12.05 ----
assign bias_sel_ot_0 = ( otker_align_dly2 == tag_bias_curr_0 ) ? bias_reg_curr_0 : bias_reg_next_0 ;
assign bias_sel_ot_1 = ( otker_align_dly3 == tag_bias_curr_1 ) ? bias_reg_curr_1 : bias_reg_next_1 ;
assign bias_sel_ot_2 = ( otker_align_dly4 == tag_bias_curr_2 ) ? bias_reg_curr_2 : bias_reg_next_2 ;
assign bias_sel_ot_3 = ( otker_align_dly5 == tag_bias_curr_3 ) ? bias_reg_curr_3 : bias_reg_next_3 ;
assign bias_sel_ot_4 = ( otker_align_dly6 == tag_bias_curr_4 ) ? bias_reg_curr_4 : bias_reg_next_4 ;
assign bias_sel_ot_5 = ( otker_align_dly7 == tag_bias_curr_5 ) ? bias_reg_curr_5 : bias_reg_next_5 ;
assign bias_sel_ot_6 = ( otker_align_dly8 == tag_bias_curr_6 ) ? bias_reg_curr_6 : bias_reg_next_6 ;
assign bias_sel_ot_7 = ( otker_align_dly9 == tag_bias_curr_7 ) ? bias_reg_curr_7 : bias_reg_next_7 ;


	always @(posedge clk ) begin
		otker_align_dly0	<= ker_read_cnt_ker ;
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



		otenker_align_dly0	<= ker_read_en_ker_cnt ;
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

//---- I/O Port assignment ----
assign dout_bi_0 = bias_sel_ot_0 ;
assign dout_bi_1 = bias_sel_ot_1 ;
assign dout_bi_2 = bias_sel_ot_2 ;
assign dout_bi_3 = bias_sel_ot_3 ;
assign dout_bi_4 = bias_sel_ot_4 ;
assign dout_bi_5 = bias_sel_ot_5 ;
assign dout_bi_6 = bias_sel_ot_6 ;
assign dout_bi_7 = bias_sel_ot_7 ;

assign bias_read_en_buf_sw = otenker_align_dly9 ;

endmodule