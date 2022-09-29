

module fsm (
	clk,
	reset,
	auto ,
	start ,
	man_reset ,

	flag_firstload_end	,
	flag_cpb0_end		,
	flag_cpb1_end		,
	flag_cpb2_end		,
	flag_cpbldnew_end	,
	flag_cpb3_end		,
	flag_cpb4_end		,
	busy ,

	out_current_state ,
	out_prev_state 
);
	localparam FSM_BITS 	= 5;
	localparam IDLE 		= 5'd0;
	localparam FIRST_LOAD 	= 5'd1;
	localparam CPB_0 		= 5'd2;
	localparam CPB_1 		= 5'd3;
	localparam CPB_2 		= 5'd4;
	localparam CPB_LOADNEW 	= 5'd5;
	localparam CPB_3 		= 5'd6;
	localparam CPB_4 		= 5'd7;

input wire clk			;
input wire reset		;
input wire auto 		;
input wire start 		;
input wire man_reset 	;
input wire flag_firstload_end	;
input wire flag_cpb0_end		;
input wire flag_cpb1_end		;
input wire flag_cpb2_end		;
input wire flag_cpbldnew_end	;
input wire flag_cpb3_end		;
input wire flag_cpb4_end		;

output wire busy ;
output wire [FSM_BITS-1 : 0] out_current_state ;
output wire [FSM_BITS-1 : 0] out_prev_state ;

reg [ FSM_BITS-1 : 0 ] current_state ;
reg [ FSM_BITS-1 : 0 ] next_state ;
reg [ FSM_BITS-1 : 0 ] prev_state ;
reg [ FSM_BITS-1 : 0 ] standby_reg ;


wire auto_run_start ;

assign out_current_state 	= current_state ;
assign out_prev_state 		= prev_state ;

assign auto_run_start = ( auto | start )? 1'd1 : 1'd0 ;

assign busy = ( current_state == IDLE )? 1'd0  : 1'd1 ; 

always@( posedge clk )begin
	if( reset )current_state <= IDLE ;
	else current_state <= next_state ;
end

always@( posedge clk )begin
	if( reset ) begin
		prev_state <= FIRST_LOAD ;
	end
	else begin
		if( next_state !== current_state )begin
			prev_state <= current_state ;
		end
		else begin
			prev_state <= prev_state ;
		end
	end
end

always@( * )begin
	case(current_state)
		IDLE :			next_state = (auto_run_start) ? standby_reg : IDLE ;

		FIRST_LOAD :	next_state = ( ! flag_firstload_end ) ?		FIRST_LOAD	: 
											(auto_run_start) ? 			CPB_0	: IDLE ;

		CPB_0 :			next_state = ( ! flag_cpb0_end ) ?	CPB_0 : 
										(auto_run_start) ?	CPB_1 : IDLE ;

		CPB_1 :			next_state = ( ! flag_cpb1_end ) ?	CPB_1 :
										(auto_run_start) ?	CPB_2 : IDLE ;

		CPB_2 :			next_state = ( ! flag_cpb2_end ) ?	CPB_2 :
										(auto_run_start) ?	CPB_LOADNEW : IDLE ;

		CPB_LOADNEW :	next_state = ( ! flag_cpbldnew_end ) ?		CPB_LOADNEW	: 
										(auto_run_start) ?			CPB_3		: IDLE ;

		CPB_3 :			next_state = ( ! flag_cpb3_end ) ?	CPB_3: 
										(auto_run_start) ? 	CPB_4 : IDLE ;

		CPB_4 :			next_state = ( ! flag_cpb4_end ) ?	CPB_4 :
										(auto_run_start) ?	CPB_0 : IDLE ;

	default : next_state = IDLE ;
	endcase
end


always@(posedge clk )begin
	if(reset) begin
		standby_reg <= IDLE ;
	end
	else begin
		case(current_state)
		IDLE : 			standby_reg <= 	(	standby_reg == IDLE ) ?		FIRST_LOAD	: standby_reg ;
		FIRST_LOAD : 	standby_reg <=  (	flag_firstload_end 	) ?  	CPB_0		: standby_reg ;
		CPB_0 : 		standby_reg <=  (	flag_cpb0_end 		) ?  	CPB_1		: standby_reg ;
		CPB_1 : 		standby_reg <=  (	flag_cpb1_end		) ?  	CPB_2		: standby_reg ;
		CPB_2 : 		standby_reg <=  (	flag_cpb2_end		) ?  	CPB_LOADNEW	: standby_reg ;
		CPB_LOADNEW :	standby_reg <=  (	flag_cpbldnew_end	) ?  	CPB_3		: standby_reg ;
		CPB_3 : 		standby_reg <=  (	flag_cpb3_end		) ?  	CPB_4		: standby_reg ;
		CPB_4 : 		standby_reg <=  (	flag_cpb4_end		) ?  	CPB_0		: standby_reg ;
		default : standby_reg <= standby_reg ;
		endcase
	end
end


endmodule