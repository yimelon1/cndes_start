// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.09.19
// Ver      : 2.0
// Func     : master and slave FSM, use curr_of_row control
// ============================================================================
// finite state machine
// -----------------------------------------------------------------
//     LEFT  --....-->  BASE  --....-->  RIGHT
//      |            /    |             /   |            
//      v           /     v            /    v            
//      TOP        /      TOP         /     TOP
//      |         /       |          /      |            
//      v        /        v         /       v
//      MID     /         MID      /        MID 
//      |      /          |       /         |            
//      v     /           v      /          v    
//      BOTT /            BOTT  /           BOTT
// -----------------------------------------------------------------

module fsm (
	clk,
	reset,

	sl_top_done 	,
	sl_mid_done 	,
	sl_bott_done 	,
	flag_fsld_end 	,
	flag_base_end 	,
	start 	,

	outmast_curr_state	,
	outslav_curr_state	

);
// 
localparam MAST_FSM_BITS 	= 3;
localparam M_IDLE 	= 3'd0;
localparam LEFT 	= 3'd1;
localparam BASE 	= 3'd2;
localparam RIGHT 	= 3'd3;
localparam FSLD 	= 3'd7;	// First load sram0


localparam SLAV_FSM_BITS 	= 3;
localparam S_IDLE 	= 3'd0;
localparam TOP 		= 3'd1;
localparam MID 		= 3'd2;
localparam BOTT 	= 3'd3;



output wire  [ MAST_FSM_BITS -1 : 0 ] outmast_curr_state ;
output wire  [ SLAV_FSM_BITS -1 : 0 ] outslav_curr_state ;

input wire clk ;
input wire reset ;
input wire sl_top_done ;
input wire sl_mid_done ;
input wire sl_bott_done ;
input wire flag_fsld_end ;
input wire flag_base_end ;
input wire start ;



reg [ MAST_FSM_BITS -1 : 0 ] mast_curr_state ;
reg [ MAST_FSM_BITS -1 : 0 ] mast_next_state ;
reg [ SLAV_FSM_BITS -1 : 0 ] slav_curr_state ;
reg [ SLAV_FSM_BITS -1 : 0 ] slav_next_state ;



reg [ 9-1 : 0 ] now_of_row ;		// which row is compute now , need to set final row number for count
wire now_of_row_done ;				// make counter of row enable

assign outmast_curr_state = mast_curr_state ;
assign outslav_curr_state = slav_curr_state ;

always@(*)begin
	case( mast_curr_state )
		M_IDLE 	:	mast_next_state = ( start )? FSLD : M_IDLE ;
		LEFT 	:	mast_next_state = ( sl_bott_done )? BASE : LEFT ;
		BASE 	:	mast_next_state = ( sl_bott_done & flag_base_end )? RIGHT : BASE ;
		RIGHT 	:	mast_next_state = ( sl_bott_done )? M_IDLE : RIGHT ;
		FSLD 	:	mast_next_state = ( flag_fsld_end )? LEFT : FSLD ;
	default : mast_next_state = M_IDLE ;
	endcase	
end

always@(*)begin
	case( slav_curr_state )
		S_IDLE 	:	slav_next_state = (		mast_curr_state == M_IDLE ) ?  			S_IDLE:
											( 	mast_curr_state == FSLD	 )? 		S_IDLE : TOP ;	// only for first load 

		TOP 	:	slav_next_state = (		mast_curr_state == M_IDLE ) ? 			S_IDLE : 
														( 	sl_top_done	 )? 		MID : TOP ;

		MID 	:	slav_next_state = (		mast_curr_state == M_IDLE ) ? 			S_IDLE : 
														( 	sl_mid_done	 )? 		BOTT : MID ;

		BOTT 	:	slav_next_state = (		mast_curr_state == M_IDLE ) ? 			S_IDLE : 
														( 	sl_bott_done	 )? 	TOP : BOTT ;
	default : slav_next_state = S_IDLE ;
	endcase	
end


always@( posedge clk )begin
	if( reset )begin
		mast_curr_state <= M_IDLE	;
		slav_curr_state <= S_IDLE	;
	end 
	else begin
		mast_curr_state <= mast_next_state	;
		slav_curr_state <= slav_next_state	;
	end
end




endmodule