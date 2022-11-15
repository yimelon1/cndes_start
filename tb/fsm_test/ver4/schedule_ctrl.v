
// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.10.24
// Ver      : 1.0
// Func     : schedule control, generate start signal for sram r/w module
// ============================================================================


module schedule_ctrl (
	clk,
	reset,

	mast_curr_state	,

	if_store_done ,
	ker_store_done ,
	bias_store_done ,

	if_store_busy 	,
	ker_store_busy 	,
	bias_store_busy ,

	start_if_store		,
	start_ker_store 	,
	start_bias_store	,

	// flag_master_done	,
	flag_fsld_end

);


localparam MAST_FSM_BITS 	= 3;
localparam M_IDLE 	= 3'd0;
localparam LEFT 	= 3'd1;
localparam BASE 	= 3'd2;
localparam RIGHT 	= 3'd3;
localparam FSLD 	= 3'd7;	// First load sram0



input wire clk		;
input wire reset	;

input wire [ MAST_FSM_BITS -1 : 0 ] mast_curr_state	;

//-----------------buffer ctrl io -----------------------------
// input wire 	if_store_done 		;
// input wire 	ker_store_done 		;
// input wire 	bias_store_done 	;


// input wire 	if_store_busy 		;
// input wire 	ker_store_busy 		;
// input wire 	bias_store_busy 	;


// output reg 	start_if_store		;
// output reg 	start_ker_store 	;
// output reg 	start_bias_store 	;


// output reg 	flag_fsld_end 		;
// output wire 	flag_master_done 		;

	//-----------------test  IF store----------------------------
	input wire 	if_store_done 		;
	input wire 	ker_store_done 		;
	input wire 	bias_store_done 	;


	input wire 	if_store_busy 		;
	input wire 	ker_store_busy 		;
	input wire 	bias_store_busy 	;


	output reg 	start_if_store		;
	output reg 	start_ker_store 	;
	output reg 	start_bias_store 	;
	output reg 	flag_fsld_end 		;
	//-----------------test -----------------------------
//-----------------buffer ctrl io -----------------------------

//-------------------   done flag    --------------------------------
reg [0:0]	sche_if_done ;
reg [0:0]	sche_ker_done ;
reg [0:0]	sche_bias_done ;

//--------------- master state = fsld -------------------------------
	reg [3:0] fsld_current_state ;
	reg [3:0] fsld_next_state ;
	localparam FS_IDLE 	= 3'd0;
	localparam FS_KER 	= 3'd1;
	localparam FS_BIAS 	= 3'd2;
	localparam FS_IF 	= 3'd3;
//--------------- master state = LEFT -------------------------------
	reg [3:0] left_current_state ;
	reg [3:0] left_next_state ;
	localparam LF_IDLE 	= 3'd0;
	localparam LF_00	= 3'd1;
	localparam LF_01	= 3'd2;
	localparam LF_02	= 3'd3;
	localparam LF_03	= 3'd3;
	localparam LF_04	= 3'd3;
	localparam LF_05	= 3'd3;
	localparam LF_06	= 3'd3;
//-------------------------------------------------------------------

always @(posedge clk ) begin
	if ( reset ) begin
		fsld_current_state <= 3'd0 ;
	end
	else begin
		fsld_current_state <= fsld_next_state ;
	end
end


always @(*) begin
	case (fsld_current_state)
		FS_IDLE 	:	fsld_next_state = ( mast_curr_state == FSLD )? FS_KER : FS_IDLE ;
		FS_KER 		:	fsld_next_state = ( ker_store_done )? FS_BIAS : FS_KER ;
		FS_BIAS 	:	fsld_next_state = ( bias_store_done )? FS_IDLE : FS_BIAS ;
		// FS_IF 		:	fsld_next_state = ( if_store_done )? FS_IDLE : FS_IF ;	// FSLD IF move to left state 
		default: fsld_next_state = FS_IDLE ; 
	endcase
end

//---------- first load end flag for Master FSM ---------------------
always @(posedge clk ) begin
	if( reset )begin
		flag_fsld_end <= 1'd0;
	end
	else begin
		if (mast_curr_state == FSLD ) begin
			if ( (fsld_current_state ==FS_BIAS) && bias_store_done )begin
				flag_fsld_end <= 1'd1;
			end
			else begin
				flag_fsld_end <= 1'd0;
			end
		end
		else begin
			flag_fsld_end <= 1'd0;
		end
	end
end




// ---------------- start signal for write module -------------------
always @(posedge clk ) begin
	if (reset) begin start_if_store<= 1'd0 ; end
	else begin
		if( fsld_next_state == FS_IF  )begin
			start_if_store<= ~if_store_busy & ~if_store_done ;
		end
		else begin
			start_if_store<= 1'd0;
		end
	end
end

always @(posedge clk ) begin
	if (reset) begin start_ker_store<= 1'd0 ; end
	else begin
		if( fsld_current_state == FS_KER  )begin
			start_ker_store<= ~ker_store_busy & ~ker_store_done ;
		end
		else begin
			start_ker_store<= 1'd0;
		end
	end
end


always @(posedge clk ) begin
	if (reset) begin start_bias_store<= 1'd0 ; end
	else begin
		if( fsld_current_state == FS_BIAS  )begin
			start_bias_store<= ~bias_store_busy & ~bias_store_done ;
		end
		else begin
			start_bias_store<= 1'd0;
		end
	end
end

endmodule