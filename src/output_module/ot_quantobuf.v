// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.12.20
// Ver      : 1.0
// Func     : quantization module to output buffer gather
// ============================================================================

module ot_qtbuf (
	clk				
	,	reset			
	
	,	q_result_din	
	,	q_valid_din		
	
	,	out64bits		
	,	valid_out		

);


localparam FSM_BITS = 2 ;
localparam IDLE = 2'd0 ;
localparam OTPT = 2'd1 ;

//==============================================================================
//========    I/O Signal Declare    ========
//==============================================================================
	input clk			;
	input reset			;
	
	input q_valid_din		;
	input [ 8-1:0 ]	q_result_din	;	//from quantize module

	output wire [ 64-1:0 ] out64bits ;
	output wire valid_out ;

//-----------------------------------------------------------------------------

integer i ;
//---- delay buf ----
reg [8-1:0] q_result_dly0 ;
reg [8-1:0] q_result_dly1 ;
reg [8-1:0] q_result_dly2 ;

reg [3-1:0] cnt_d ;
reg [8-1:0] array [0:7];
reg [64-1 : 0 ] out64result ;
reg [64-1 :0 ] out64result_dly0 ;

reg final_cnt_dly0 ;
reg final_cnt_dly1 ;

wire final_cnt ;




reg [8-1:0] q8_data_fetch;
reg q8_valid_fetch;

//---- declare FSM ----
reg [ FSM_BITS -1 : 0 ] qb_curr_state ;
reg [ FSM_BITS -1 : 0 ] qb_next_state ;


//-----------------------------------------------------------------------------
//---- FSM ----
always @(posedge clk ) begin
	if( reset ) qb_curr_state <= IDLE ;
	else qb_curr_state <= qb_next_state ;
end
always @(*) begin
	case (qb_curr_state)
		IDLE	: qb_next_state = ( final_cnt_dly1 )? OTPT : IDLE ;
		OTPT	: qb_next_state = IDLE ;
		default: qb_next_state = IDLE ;
	endcase
end
//-----------------------------------------------------------------------------



assign valid_out = ( qb_curr_state == OTPT ) ? 1'd1 : 1'd0  ;
assign out64bits = out64result_dly0  ;

assign final_cnt = (cnt_d == 7)? q8_valid_fetch : 1'd0;

//---- fetch data and valid ---------------------------------------------------
always @(posedge clk ) begin
	if(reset )begin
		q8_data_fetch <= 8'd0 ;
	end
	else begin
		if( q_valid_din )begin
			q8_data_fetch <= q_result_din ;
		end
		else begin
			q8_data_fetch <= q8_data_fetch ;
		end
	end
end
always @(posedge clk ) begin
	q8_valid_fetch <= q_valid_din ;
end
//-----------------------------------------------------------------------------



always @(posedge clk ) begin
	if( reset )begin
		cnt_d <= 'd0 ;
	end
	else begin
		if( q8_valid_fetch )begin
			if( cnt_d > 7 )begin
				cnt_d <= 'd0 ;
			end
			else begin
				cnt_d <= cnt_d + 'd1;
			end
		end
		else begin
			cnt_d <= cnt_d  ;
		end
	end
end

always @(posedge clk ) begin
	if(reset )begin
		for(i=0; i<8; i=i+1 )begin
			array[i]<= 8'd0;
		end
	end
	else begin
		if( q8_valid_fetch )begin
			case (cnt_d)
				3'd0	: array[0]<= q8_data_fetch ;
				3'd1	: array[1]<= q8_data_fetch ;
				3'd2	: array[2]<= q8_data_fetch ;
				3'd3	: array[3]<= q8_data_fetch ;
				3'd4	: array[4]<= q8_data_fetch ;
				3'd5	: array[5]<= q8_data_fetch ;
				3'd6	: array[6]<= q8_data_fetch ;
				3'd7	: array[7]<= q8_data_fetch ;
				default: begin
					for(i=0; i<8; i=i+1 )begin
						array[i]<= array[i];
					end
					// array[0]<= array[0] ;
					// array[1]<= array[1] ;
					// array[2]<= array[2] ;
					// array[3]<= array[3] ;
					// array[4]<= array[4] ;
					// array[5]<= array[5] ;
					// array[6]<= array[6] ;
					// array[7]<= array[7] ;
				end
			endcase
		end
		else begin
			for(i=0; i<8; i=i+1 )begin
						array[i]<= array[i];
			end
		end
	end
end

always @(posedge clk ) begin
	if( reset )begin
		out64result <= 64'd0 ;
	end
	else begin
		if( final_cnt_dly0 )begin
			out64result <= {
				array[0],
				array[1],
				array[2],
				array[3],
				array[4],
				array[5],
				array[6],
				array[7]		};
		end
		else begin
			out64result <= out64result ;
		end
	end
end


always @(posedge clk ) begin
	q_result_dly0 <= q_result_din ;
	q_result_dly1 <= q_result_dly0 ;
	q_result_dly2 <= q_result_dly1 ;

	final_cnt_dly0 <=  final_cnt ;
	final_cnt_dly1 <=  final_cnt_dly0 ;

	out64result_dly0 <= out64result ;
end




endmodule