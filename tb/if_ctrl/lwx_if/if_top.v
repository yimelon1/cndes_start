// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.09
// Ver      : 1.0
// Func     : connect the sram and send data to pe
// 		2022/11/09 : deside sram signal for read or write and which sram buffer 
// ============================================================================

`timescale 1ns/100ps




module ifsram_rw (
	clk,
	reset,

	if_write_data_din		,
	if_write_empty_n_din		,
	if_write_read_dout		,

	if_write_done 		,
	if_write_busy 		,
	if_write_start		,	

	if_read_done 		,
	if_read_busy 		,
	if_read_start		,

	ifsram0_read		,
	ifsram1_read		,
	ifsram0_write		,
	ifsram1_write       ,
	row_finish,
	change_sram,
	current_state



);


//----------------------------------------------------------------------------
//---------------		Parameter		--------------------------------------
//----------------------------------------------------------------------------
localparam IFMAP_SRAM_ADDBITS = 11 ;
localparam IFMAP_SRAM_DATA_WIDTH = 64;
parameter TBITS = 64;
parameter TBYTE = 8;

localparam [2:0] 
    IDLE          = 3'd0,
    LOAD          = 3'd1,
    UP_PADDING    = 3'd2,
    THREEROW      = 3'd3,
    TWOROW        = 3'd4,
    ONEROW        = 3'd5,
    DOWN_PADDING  = 3'd6;

//----------------------------------------------------------------------------
//---------------		I/O			------------------------------------------
//----------------------------------------------------------------------------
input	wire 				clk		;
input	wire 				reset	;

input	wire [TBITS-1: 0 ]	if_write_data_din		;
input	wire 				if_write_empty_n_din		;
output	reg 				if_write_read_dout		;

output 	reg 				if_write_done		;	// make the next state change
output	reg					if_write_busy		;	// when catch start signal make busy signal  "ON"
input	wire				if_write_start			;	// control from get_ins 

output reg	if_read_done 		;
output reg	if_read_busy 		;
input wire	if_read_start		;


input	wire				ifsram0_write			;	// if sram write signal
input	wire				ifsram1_write			;	// if sram write signal
input	wire				ifsram0_read			;	// if sram read signal
input	wire				ifsram1_read			;	// if sram read signal
output wire row_finish;
output wire change_sram;

input wire [2:0] current_state;



wire col_finish;

//---- SRAM_IFMAP --------
wire cen_if0b0 ;
wire cen_if0b1 ;

wire wen_if0b0 ;
wire wen_if0b1 ;

wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if0b0	;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if0b1	;

wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_if0b0	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_if0b1	;

wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_if0b0	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_if0b1	;


//---------
wire cen_write_ifsram ;
wire wen_write_ifsram ;
wire [63:0] data_write_ifsram;
wire [10:0] addr_write_ifsram;

wire cen_reads0_ifsram ;
wire cen_reads1_ifsram ;
wire [10:0] addr_read_ifsram;

reg [63:0] dout;
reg dy_dout_en0;
reg dy_dout_en1;

always @(posedge clk)begin
	if(reset)
		dy_dout_en0 <= 0;
	else if(~cen_if0b0)
		dy_dout_en0 <= 1;
	else
		dy_dout_en0 <= 0;

end

always @(posedge clk)begin
	dy_dout_en1 <= dy_dout_en0;
end


always@(*)begin
	dout = (dy_dout_en1) ? dout_sram_if0b0 : 0;

end

wire cen_read;
assign cen_if0b0			= (ifsram0_write) ? cen_write_ifsram  :	(ifsram0_read) ? cen_read  : 1     ;	// else condition is for read signal
assign wen_if0b0			= (ifsram0_write) ? wen_write_ifsram  :	1	                				  	    ;	// else condition is for read signal
assign addr_sram_if0b0		= (ifsram0_write) ? addr_write_ifsram :	(ifsram0_read) ? addr_read_ifsram	: 11'd0 ;	// else condition is for read signal
assign din_sram_if0b0		= (ifsram0_write) ? data_write_ifsram :	64'd0	                                    ;

assign cen_if0b1			= (ifsram1_write) ? cen_write_ifsram  :	(ifsram1_read) ? cen_read  : 1     ;	// else condition is for read signal
assign wen_if0b1			= (ifsram1_write) ? wen_write_ifsram  :	1	                                        ;	// else condition is for read signal
assign addr_sram_if0b1		= (ifsram1_write) ? addr_write_ifsram :	(ifsram1_read) ? addr_read_ifsram   : 11'd0 ;	// else condition is for read signal
assign din_sram_if0b1		= (ifsram1_write) ? data_write_ifsram :	64'd0	                                    ;





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
ifsram_w  #(
	.TBITS ( 64 ),
	.TBYTE ( 8  )
)ifsig01(
	.clk		(	clk	),
	.reset		(	reset	),

	.ifstore_data_din		(	if_write_data_din			),
	.ifstore_empty_n_din	(	if_write_empty_n_din		),
	.ifstore_read_dout		(	if_write_read_dout		),

	
	.if_store_done	(	if_write_done	),
	.if_store_busy 	(	if_write_busy	),
	.start_if_store	(	if_write_start	),

	.cen_ifsram 		(	cen_write_ifsram	),
	.wen_ifsram 		(	wen_write_ifsram	),
	.data_ifsram		(	data_write_ifsram	),
	.addr_ifsram		(	addr_write_ifsram	)

);



// assign cen_reads0_ifsram = (ifsram0_read) ? cen_read : (ifsram1_read) ? 1 : 1;
// assign cen_reads1_ifsram = (ifsram1_read) ? cen_read : (ifsram0_read) ? 1 : 1;
//--------------------------------------------------
//------	if sram read module instance	--------
//--------------------------------------------------

ifsram_r #(
	.TBITS ( 64 ),
	.TBYTE ( 8  )
) ifr_test (
	.clk		       (clk),
	.reset		       (reset),

	.if_read_start     (if_read_start),
	.if_read_busy      (if_read_busy),
	.if_read_done      (if_read_done),

	.cen_reads_ifsram  (cen_read),
	.addr_read_ifsram  (addr_read_ifsram),
	.change_sram       (change_sram),
	.current_state     (current_state),
	// .col_finish        (col_finish),
	.row_finish 	   (row_finish)

);



endmodule





