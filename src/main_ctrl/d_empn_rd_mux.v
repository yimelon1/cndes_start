// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.01.31
// Ver      : 1.0
// Func     : mutiplexor for input_fifo signal empty_n and read
// Log		: 
// 		2023.01.31 : from now using state switch empty_n signal path. 
// 				maybe use busy signal for judgment.
// ============================================================================

module d_empn_rd_mux (	



		if_write_empty_n	// input feature write module empty_n signal
	,	ker_write_empty_n	// kernel write module empty_n signal
	,	bias_write_empty_n	// bias write module empty_n signal
	,	if_write_read		// input feature write module read signal
	,	ker_write_read		// kernel write module read signal
	,	bias_write_read		// bias write module read signal

	,	empty_n_from_gi		
	,	read_for_gi			

	,	fsld_current_state	
	,	mast_current_state	
	,	if_write_busy		
	,	ker_write_busy		
	,	bias_write_busy		

);

//------- master FSM parameter -----------
localparam MAST_FSM_BITS 	= 3;
localparam M_IDLE 	= 3'd0;
localparam LEFT 	= 3'd1;
localparam BASE 	= 3'd2;
localparam RIGHT 	= 3'd3;
localparam FSLD 	= 3'd7;	// First load sram0
//---------------------------------------------
//---------------When master state = fsld ---------
localparam FS_IDLE 	= 3'd0;
localparam FS_KER 	= 3'd1;
localparam FS_BIAS 	= 3'd2;
localparam FS_IF 	= 3'd3;

//----necessary I/O -----

	output reg	if_write_empty_n 	;
	output wire	ker_write_empty_n 	;
	output wire	bias_write_empty_n 		;
	input wire	if_write_read			;	// input feature write module read signal
	input wire	ker_write_read			;
	input wire	bias_write_read				;

	input wire	empty_n_from_gi		;
	output reg	read_for_gi 		;
//-----------------------------------------------------------------------------	
//----testing I/O -----
	input wire	[ MAST_FSM_BITS-1 :0]	fsld_current_state			;
	input wire	[ MAST_FSM_BITS-1 :0]	mast_current_state			;
	input wire	if_write_busy			;
	input wire	ker_write_busy			;
	input wire	bias_write_busy			;
//-----------------------------------------------------------------------------



//-----------------------------------------------------------------------------
//------------			empty_n signal			-------------------------------
//-----------------------------------------------------------------------------

//----testing busy mux not fsld current state -----
assign	ker_write_empty_n 	= ( mast_current_state !== FSLD )?		1'd0 : 
								// ( fsld_current_state == FS_KER )?	empty_n_from_gi : 1'd0 ;
								( ker_write_busy )?	empty_n_from_gi : 1'd0 ;

assign	bias_write_empty_n 		= ( mast_current_state !== FSLD )?		1'd0 : 
								// ( fsld_current_state == FS_BIAS )?	empty_n_from_gi : 1'd0 ;
								( bias_write_busy )?	empty_n_from_gi : 1'd0 ;
//-----------------------------------------------------------------------------

always @(*) begin
	case (mast_current_state)
		M_IDLE :	if_write_empty_n = 1'd0 ;
		LEFT :		if_write_empty_n = empty_n_from_gi ;
		default: if_write_empty_n = 1'd0 ;
	endcase
end


//-----------------------------------------------------------------------------
//--------------------    read signal    --------------------------------------
//-----------------------------------------------------------------------------

always @(*) begin
	case (mast_current_state)
		M_IDLE :	read_for_gi = 1'd0 ;
		LEFT :		read_for_gi = if_write_read ;

		FSLD :	begin
			if( ker_write_busy ) read_for_gi = ker_write_read ;
			else if ( bias_write_busy ) read_for_gi = bias_write_read ;
			else read_for_gi = 1'd0 ;
			// if( fsld_current_state == FS_KER ) read_for_gi = ker_write_read ;
			// else if ( fsld_current_state == FS_BIAS ) read_for_gi = bias_write_read ;
			// else read_for_gi = 1'd0 ;
		end
		default: read_for_gi = 1'd0 ;
	endcase
end



endmodule