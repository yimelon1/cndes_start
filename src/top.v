
// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.07.28
// Ver      : 1.0
// Func     : top module of channel major DLA
// ============================================================================
`timescale 1 ns / 1 ps

module yolo_top
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


core #(
	.TRANS_BYTE_SIZE ( TBYTE ),
	.TRANS_BITS (TBITS )
)   conv_core (
	.clk		(		aclk		),
	.reset		(		ap_rst		),

	.din_isif_data			(		isif_data_dout		),
	.din_isif_last			(		isif_last_dout		),
	.din_isif_empty_n		(		isif_empty_n		),
	.din_isif_strb			(		isif_strb_dout		),		//can't be none
	.din_isif_user			(		isif_user_dout		),		//can't be none

	.dout_isif_read			(		isif_read		),		// convertor wanna read

	.din_osif_full_n		(		osif_full_n		),

	.dout_osif_data			(		osif_data_din		),
	.dout_osif_last			(		osif_last_din		),	// the last output data 
	.dout_osif_strb			(		osif_strb_din		),		//can't be none
	.dout_osif_user			(		osif_user_din		),		//can't be none
	.dout_osif_write		(		osif_write		) 	// convertor wanna write
  );

endmodule

