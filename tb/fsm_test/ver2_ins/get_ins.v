// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.09.28
// Ver      : 1.0
// Func     : get instruction or data from dram axi access. use sequence 64 bits data
// 			send before instruction
// 		"efef123abbeeff22" : for instruction
// 		"efef6543dadaff11" : for data 
// ============================================================================



module get_ins (
	clk ,
	reset ,

	fifo_data_din	,
	fifo_strb_din	,
	fifo_last_din	,
	fifo_user_din	,
	fifo_empty_n_din	,
	fifo_read_dout		,

	datald_done	,
	start_reg

);
	
localparam IDLE 		= 3'd0 ;
localparam CH00 		= 3'd1 ;
localparam CH01 		= 3'd2 ;
localparam CHEK 		= 3'd3 ;
localparam INST 		= 3'd4 ;
localparam INST_END		= 3'd5 ;
localparam DATA			= 3'd6 ;


	localparam TBITS = 64 ;
	localparam TBYTE = 8 ;

input wire datald_done	;

input	wire 				clk		;
input	wire 				reset	;
input	wire [TBITS-1: 0 ]	fifo_data_din		;
input	wire [TBYTE-1: 0 ]	fifo_strb_din		;
input	wire 				fifo_last_din		;
input	wire 				fifo_user_din		;
input	wire 				fifo_empty_n_din	;
output	reg 				fifo_read_dout		;

output wire start_reg ;

localparam INST_HEAD = 64'hefef123abbeeff22 ;
localparam DATA_HEAD = 64'hefef6543dadaff11 ;

reg [ 3-1 : 0 ] current_state ;
reg [ 3-1 : 0 ] next_state ;


reg [TBITS-1: 0 ] ck_reg_0 ;
reg [TBITS-1: 0 ] ck_reg_1 ;





//---- state reg ----
reg str_start ;

reg [ 64-1 : 0 ] instr_code00 ;
reg [ 64-1 : 0 ] instr_code01 ;
reg [ 64-1 : 0 ] instr_code02 ;


//-------------------
reg instr_start ;
reg datald_start ;

reg instr_done	;

reg [2:0] ins_cnt ;


assign start_reg = str_start  ;


always@( posedge clk)begin
	if( reset )begin
		str_start <= 1'd0 ;
	end
	else begin
		str_start <= (current_state == INST_END ) ? instr_code00[ 63 -:1 ] : str_start ;
	end
end

always @(*) begin
	instr_done = (ins_cnt == 'd3 ) ? 1'd1 : 1'd0 ;
end

always @(*) begin
	instr_start= (ck_reg_0 == INST_HEAD ) ? (ck_reg_1 == INST_HEAD ) ? 1'd1 : 1'd0   : 1'd0 ;
	datald_start= (ck_reg_0 == DATA_HEAD ) ? (ck_reg_1 == DATA_HEAD ) ? 1'd1 : 1'd0   : 1'd0 ;
end


always@( posedge clk )begin
	if( reset )begin
		current_state <= IDLE ;
	end
	else begin
		current_state <= next_state ;
	end
end


always@( * )begin
	case( current_state )
		IDLE		: next_state = ( fifo_empty_n_din   ) ? CH00 : IDLE ;
		CH00		: next_state =	CH01 ;
		CH01		: next_state =	CHEK ;
		CHEK		: next_state =  ( instr_start ) ? INST : 
								( datald_start ) ? DATA : CHEK;
		INST		: next_state = (instr_done ) ? INST_END : INST ;
		INST_END	: next_state =  IDLE  ;
		DATA		: next_state = (datald_done ) ? IDLE : DATA ;
		default : next_state = IDLE ;
	endcase	
end		

always @(posedge clk ) begin
	if( reset )begin
		fifo_read_dout <= 1'd0 ;
	end
	else begin
		case(current_state)
			CH00 : fifo_read_dout <= ( fifo_empty_n_din   ) ? 1'd1 : 1'd0 ;
			CH01 : fifo_read_dout <= ( fifo_empty_n_din   ) ? 1'd1 : 1'd0 ;
			INST : fifo_read_dout <= ( fifo_empty_n_din   ) ? (ins_cnt <3) ? 1'd1 : 1'd0 : 1'd0 ;
			default : fifo_read_dout <= 1'd0 ;
		endcase
	end
end

always @(posedge clk ) begin
	if (reset) begin
		ck_reg_0 <= 64'd0 ;
		ck_reg_1 <= 64'd0 ;
	end
	else begin
		case (current_state)
			CH00: begin
				ck_reg_0 <= fifo_data_din ;
			end
			CH01:begin
				ck_reg_1 <= fifo_data_din ;
			end
			default: begin
				ck_reg_0 <= ck_reg_0 ;
				ck_reg_1 <= ck_reg_1 ;
			end
		endcase
	end
end

always@( posedge clk )begin
	if( reset )begin
		ins_cnt <= 'd0 ;
	end
	else begin
		if( current_state == INST)begin
			if( ins_cnt <3 )begin
				ins_cnt <= ins_cnt + 'd1 ;
			end
			else begin
				ins_cnt <= 'd0 ;
			end
		end
		else begin
			ins_cnt <= 'd0 ;
		end

	end
end	



always @(posedge clk ) begin
	if (reset) begin
		instr_code00 <= 64'd0;
		instr_code01 <= 64'd0;
		instr_code02 <= 64'd0;
	end
	else begin
		if( current_state == INST)begin
			if (fifo_empty_n_din && fifo_read_dout) begin
				instr_code00 <= ( ins_cnt == 3'd1 )? fifo_data_din : instr_code00 ;
				instr_code01 <= ( ins_cnt == 3'd2 )? fifo_data_din : instr_code01 ;
				instr_code02 <= ( ins_cnt == 3'd3 )? fifo_data_din : instr_code02 ;
			end
			else begin
				instr_code00 <= instr_code00 ;
				instr_code01 <= instr_code01 ;
				instr_code02 <= instr_code02 ;
			end
		end
		else begin
			instr_code00 <= instr_code00 ;
			instr_code01 <= instr_code01 ;
			instr_code02 <= instr_code02 ;
		end
	end
end

endmodule