// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.09.19
// Ver      : 2.0
// Func     : master and slave FSM, use curr_of_row control, only FSLD and LEFT
// 				for 64 MACs version DLA.
// 		2022.11.15 : remove slav fsm, 
// ============================================================================
// finite state machine

`timescale 1ns/100ps
module fsm64 (
	clk,
	reset,

	flag_fsld_end 	,
	start 	,
	master_done 	,

	outmast_curr_state	

);
// 
localparam MAST_FSM_BITS 	= 3;
localparam M_IDLE 	= 3'd0;
localparam LEFT 	= 3'd1;
localparam BASE 	= 3'd2;
localparam RIGHT 	= 3'd3;
localparam FSLD 	= 3'd7;	// First load sram0



output wire  [ MAST_FSM_BITS -1 : 0 ] outmast_curr_state ;


input wire clk ;
input wire reset ;

input wire flag_fsld_end ;
input wire start ;
input wire master_done ;


reg [ MAST_FSM_BITS -1 : 0 ] mast_curr_state ;
reg [ MAST_FSM_BITS -1 : 0 ] mast_next_state ;



assign outmast_curr_state = mast_curr_state ;


always@(*)begin
	case( mast_curr_state )
		M_IDLE 	:	mast_next_state = ( start )? FSLD : M_IDLE ;
		LEFT 	:	mast_next_state = ( master_done )? M_IDLE : LEFT ;
		// BASE 	:	mast_next_state = ( master_done )? RIGHT : BASE ;
		// RIGHT 	:	mast_next_state = ( master_done )? M_IDLE : RIGHT ;
		FSLD 	:	mast_next_state = ( flag_fsld_end )? LEFT : FSLD ;
	default : mast_next_state = M_IDLE ;
	endcase	
end


always@( posedge clk )begin
	if( reset )begin
		mast_curr_state <= M_IDLE	;
	end 
	else begin
		mast_curr_state <= mast_next_state	;
	end
end




endmodule