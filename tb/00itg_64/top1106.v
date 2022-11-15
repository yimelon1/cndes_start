
// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.07.28
// Ver      : 1.0
// Func     : top module of channel major DLA64
// 2022/11/07 : take store function in to top_module
// 2022/11/15 : remove ifstore function , take fsm64,get_ins,schedule module in
// ============================================================================
`timescale 1 ns / 1 ps

module dla64_top
#(
	parameter TBITS = 64 ,		// parameter match with vivado demo project
	parameter TBYTE = 8 		// parameter match with vivado demo project

) (

	input  wire             S_AXIS_MM2S_TVALID	,	// default
	output wire             S_AXIS_MM2S_TREADY	,	// default
	input  wire [TBITS-1:0] S_AXIS_MM2S_TDATA	,	// default
	input  wire [TBYTE-1:0] S_AXIS_MM2S_TKEEP	,	// default
	input  wire [1-1:0]     S_AXIS_MM2S_TLAST	,	// default

	output wire             M_AXIS_S2MM_TVALID	,	// default
	input  wire             M_AXIS_S2MM_TREADY	,	// default
	output wire [TBITS-1:0] M_AXIS_S2MM_TDATA	,	// default
	output wire [TBYTE-1:0] M_AXIS_S2MM_TKEEP	,	// default
	output wire [1-1:0]     M_AXIS_S2MM_TLAST	,	// default     

	// input  wire             	S_AXIS_MM2S_ACLK	,	//default
	// input  wire             	M_AXIS_S2MM_ACLK	,	//default
	input  wire             	aclk				,	//default
	input  wire             	aresetn					//default

);
localparam RESET_ACTIVE_LOW = 1;		//default
wire ap_rst;						//default with reset module

wire [TBITS-1: 0 ]	isif_data_dout			;
wire 				isif_last_dout			;
wire 				isif_empty_n			;
wire [TBYTE-1: 0 ]	isif_strb_dout			;
wire 				isif_user_dout			;
wire 				isif_read				;
wire 				osif_full_n				;
wire 				osif_write				;
wire [TBITS-1: 0 ]	osif_data_din			;
wire 				osif_last_din			;
wire [TBYTE-1: 0 ]	osif_strb_din			;
wire 				osif_user_din			;





ifsram_rw ifbank0(
	.clk		(	clk	),
	.reset		(	reset	),

	.ifstore_data_din		(	isif_data_dout		),
	.ifstore_empty_n_din	(	ds_empty_n			),
	.ifstore_read_dout		(	ifstore_read_dout	),

	if_store_done 		(	ifstore_done	)	,
	if_store_busy 		(	ifstore_busy	)	,
	start_if_store		(	ifstore_start	)	,

	ifsramb0_read		(	sche_ifsramb0_read		),
	ifsramb1_read		(	sche_ifsramb1_read		),
	ifsramb0_write		(	sche_ifsramb0_write		),
	ifsramb1_write		(	sche_ifsramb1_write		)

);


schedule_ctrl sch_mod(
	.clk		(	clk	),
	.reset		(	reset	),

	.mast_curr_state	(	fsm_mast_state	),

	// .if_store_done 	(		),
	// .ker_store_done 	(		),
	// .bias_store_done (		),

	// .if_store_busy 	(		),
	// .ker_store_busy 	(		),
	// .bias_store_busy (		),

	// .start_if_store		(		),
	// .start_ker_store 	(		),
	// .start_bias_store	(		),


	// .flag_master_done 	(		),
	// .flag_fsld_end 	(		)


	//-----------------------------------
	.if_store_done 		(	ifstore_done	),
	.ker_store_done 	(	kerstore_done	),
	.bias_store_done 	(	biasstore_done	),

	.if_store_busy 		(	ifstore_busy	),
	.ker_store_busy 	(	kerstore_busy	),
	.bias_store_busy 	(	biasstore_busy	),

	.start_if_store		(	ifstore_start	),
	.start_ker_store 	(	kerstore_start	),
	.start_bias_store	(	biasstore_start	),


	.flag_fsld_end		(	flag_fsld_end_sche	)

);



	
fsm64 fs01(
	.clk		(	clk	),
	.reset		(	reset	),


	.flag_fsld_end 	(	flag_fsld_end_sche		),	// from schedule
	.start			(	gi_start				),
	.master_done 	(	tb_master_done			),

	.outmast_curr_state (	fsm_mast_state	)


);


	

get_ins gi01(
	.clk 	(	clk	),
	.reset 	(	reset	),

	.fifo_data_din		(	isif_data_dout		),
	.fifo_strb_din		(	isif_strb_dout		),
	.fifo_last_din		(	isif_last_dout		),
	.fifo_user_din		(	isif_user_dout		),
	.fifo_empty_n_din	(	isif_empty_n		),
	.fifo_read_dout		(	isif_read			),	//send to fifo_in module



	.ds_empty_n			(	ds_empty_n			),	// output
	.ds_read			(	tb_ctrl_ds_read		),	// input : get read signal from which module need data

	.instr_code00	(	config_param00	),
	.instr_code01	(	config_param01	),
	.instr_code02	(	config_param02	),

	.start_reg		(	gi_start	)			// turn on FSM


);









INPUT_STREAM_if #(
        .TBITS (TBITS) ,	// parameter match with vivado demo project
        .TBYTE (TBYTE)		// parameter match with vivado demo project
)
INPUT_STREAM_if_U (

		.ACLK ( aclk ) ,
		.ARESETN ( aresetn ) ,
		.TVALID ( S_AXIS_MM2S_TVALID ) ,
		.TREADY ( S_AXIS_MM2S_TREADY ) ,
		.TDATA ( S_AXIS_MM2S_TDATA ) ,
		.TKEEP ( S_AXIS_MM2S_TKEEP ) ,
		.TLAST ( S_AXIS_MM2S_TLAST ) ,      
		.TUSER ( 1'b0 ) ,

		.isif_data_dout ( isif_data_dout ) ,
		.isif_last_dout ( isif_last_dout ) ,
		.isif_strb_dout ( isif_strb_dout ) ,
		.isif_user_dout ( isif_user_dout ) ,
		.isif_empty_n ( isif_empty_n ) ,
		.isif_read ( isif_read )
);  // input_stream_if_U

OUTPUT_STREAM_if #(
        .TBITS (TBITS) ,	// parameter match with vivado demo project
        .TBYTE (TBYTE)		// parameter match with vivado demo project
)
OUTPUT_STREAM_if_U (

		.ACLK ( aclk ) ,
		.ARESETN ( aresetn ) ,
		.TVALID ( M_AXIS_S2MM_TVALID ) ,
		.TREADY ( M_AXIS_S2MM_TREADY ) ,
		.TDATA ( M_AXIS_S2MM_TDATA ) ,
		.TKEEP ( M_AXIS_S2MM_TKEEP ) ,
		.TLAST ( M_AXIS_S2MM_TLAST ) ,      
		.TUSER (  ) ,

		.osif_data_din ( osif_data_din ) ,
		.osif_last_din ( osif_last_din ) ,
		.osif_strb_din ( osif_strb_din ) ,
		.osif_user_din ( osif_user_din ) ,
		.osif_full_n ( osif_full_n ) ,
		.osif_write ( osif_write )
);  // output_stream_if_U

// reset module
yolo_rst_if #(
        .RESET_ACTIVE_LOW ( RESET_ACTIVE_LOW ) )
yolo_rst_if_U(
        .dout ( ap_rst ) ,
        .din ( aresetn ) );  // yolo_rst_if_U



endmodule

