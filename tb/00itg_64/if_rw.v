// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.09
// Ver      : 1.0
// Func     : connect the sram and send data to pe
// 		2022/11/09 : deside sram signal for read or write and which sram buffer 
// ============================================================================

`timescale 1ns/100ps


// `include "./count_yi_v3.v"

module ifsram_rw (
	clk,
	reset,
	ifstore_data_din		,
	ifstore_empty_n_din		,
	ifstore_read_dout		,

	if_store_done 		,
	if_store_busy 		,
	start_if_store		,	

	ifsramb0_read		,
	ifsramb1_read		,
	ifsramb0_write		,
	ifsramb1_write 

);


//----------------------------------------------------------------------------
//---------------		Parameter		--------------------------------------
//----------------------------------------------------------------------------
localparam IFMAP_SRAM_ADDBITS = 11 ;
localparam IFMAP_SRAM_DATA_WIDTH = 64;




//----------------------------------------------------------------------------
//---------------		I/O			------------------------------------------
//----------------------------------------------------------------------------
input	wire 				clk		;
input	wire 				reset	;
input	wire [TBITS-1: 0 ]	ifstore_data_din		;
input	wire 				ifstore_empty_n_din		;
output	reg 				ifstore_read_dout		;

output 	reg 				if_store_done		;	// make the next state change
output	reg					if_store_busy		;	// when catch start signal make busy signal  "ON"
input	wire				start_if_store			;	// control from get_ins 


input	wire				ifsramif0b0_read			;	// if sram read signal
input	wire				ifsramif0b1_read			;	// if sram read signal
input	wire				ifsramif0b0_write			;	// if sram write signal
input	wire				ifsramif0b1_write			;	// if sram write signal



//---- SRAM_IFMAP --------
wire cen_if0b0 ;
wire cen_if0b1 ;

wire wen_if0b0 ;
wire wen_if0b1 ;

wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if0b0	;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if0b1	;

wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_if0b0		;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_if0b1		;

wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_if0b0	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_if0b1	;


//---------
wire cen_write_ifsram ;
wire wen_write_ifsram ;
wire [63:0] data_write_ifsram;
wire [10:0] addr_write_ifsram;


assign cen_if0b0			= (ifsramif0b0_write) ? cen_write_ifsram	:	1'd1	;	// else condition is for read signal
assign wen_if0b0			= (ifsramif0b0_write) ? wen_write_ifsram	:	1'd1	;	// else condition is for read signal
assign addr_sram_if0b0		= (ifsramif0b0_write) ? addr_write_ifsram	:	11'd0	;	// else condition is for read signal
assign din_sram_if0b0		= (ifsramif0b0_write) ? data_write_ifsram	:	64'd0	;

assign cen_if0b1			= (ifsramif0b1_write) ? cen_write_ifsram	:	1'd1	;	// else condition is for read signal
assign wen_if0b1			= (ifsramif0b1_write) ? wen_write_ifsram	:	1'd1	;	// else condition is for read signal
assign addr_sram_if0b1		= (ifsramif0b1_write) ? addr_write_ifsram	:	11'd0	;	// else condition is for read signal
assign din_sram_if0b1		= (ifsramif0b1_write) ? data_write_ifsram	:	64'd0	;


// ============================================================================
// =========================    instance sram    ==============================
// ============================================================================
IF_SRAM if0b0 (
	.Q		(	dout_sram_if0b0		),	// output data
	.CLK	(	clk					),	//
	.CEN	(	cen_if0b0			),	// Chip Enable (active low)
	.WEN	(	wen_if0b0			),	// Write Enable (active low)
	.A		(	addr_sram_if0b0		),	// Addresses (A[0] = LSB)
	.D		(	din_sram_if0b0		),	// Data Inputs (D[0] = LSB)
	.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
);
IF_SRAM if0b1 (
	.Q		(	dout_sram_if0b1		),	// output data
	.CLK	(	clk					),	//
	.CEN	(	cen_if0b1			),	// Chip Enable (active low)
	.WEN	(	wen_if0b1			),	// Write Enable (active low)
	.A		(	addr_sram_if0b1		),	// Addresses (A[0] = LSB)
	.D		(	din_sram_if0b1		),	// Data Inputs (D[0] = LSB)
	.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
);



//--------------------------------------------------
//------	if sram write module instance	--------
//--------------------------------------------------
ifsignal_gen  ifsig01 (
	.TBITS ( 64 ),
	.TBYTE ( 8  )
)#(
	.clk		(	clk	),
	.reset		(	reset	),

	.ifstore_data_din		(	isif_data_dout			),
	.ifstore_empty_n_din	(	ifstore_empty_n_din		),
	.ifstore_read_dout		(	ifstore_read_dout		),

	
	.if_store_done	(	ifstore_done	),
	.if_store_busy 	(	ifstore_busy	),
	.start_if_store	(	ifstore_start	),

	.cen_ifsram 		(	cen_write_ifsram	),
	.wen_ifsram 		(	wen_write_ifsram	),
	.data_ifsram		(	data_write_ifsram	),
	.addr_ifsram		(	addr_write_ifsram	)

);


//--------------------------------------------------
//------	if sram read module instance	--------
//--------------------------------------------------





endmodule





