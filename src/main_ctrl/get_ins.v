// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.09.28
// Ver      : 1.0
// Func     : get instruction or data from dram axi access. use sequence 64 bits data
// 			send before instruction. connect the MEM_store module for storing, tell
//			that can take data from fifo_in.
// 		"efef123abbeeff22" : for instruction
// 		"efef6543dadaff11" : for data 
// 2022/10/19 : need to detect fifo_last for every dma transfer. make state go to IDLE
// 			and show HW still need data or not when report instruction is comming.
// ============================================================================

`timescale 1ns/100ps

module get_ins (
	clk ,
	reset ,

	fifo_data_din	,
	fifo_strb_din	,
	fifo_last_din	,
	fifo_user_din	,
	fifo_empty_n_din	,
	fifo_read_dout		,	// output

	ds_empty_n	,	// output data store empty_n
	ds_read	,		// input

	instr_code00	,
	instr_code01	,
	instr_code02	, 

	start_reg

);
	
	parameter TBITS = 64;
	parameter TBYTE = 8;

//----------------------------------------------


localparam IDLE = 3'd0 ;
localparam CH00 = 3'd1 ;
localparam CH01 = 3'd2 ;
localparam CHEK = 3'd3 ;
localparam INST = 3'd4 ;
localparam DATA = 3'd5 ;



//---------- input / output -----------------

input	wire 				clk		;
input	wire 				reset	;
input	wire [TBITS-1: 0 ]	fifo_data_din		;
input	wire [TBYTE-1: 0 ]	fifo_strb_din		;
input	wire 				fifo_last_din		;
input	wire 				fifo_user_din		;
input	wire 				fifo_empty_n_din	;
output	reg 				fifo_read_dout		;


output wire	ds_empty_n	;		// data load -state output empty_n
input wire	ds_read		;		// data load -state input read

output wire start_reg ;			// start the total finite state machine

output reg [ 64-1 : 0 ] instr_code00 ;	//config code
output reg [ 64-1 : 0 ] instr_code01 ;
output reg [ 64-1 : 0 ] instr_code02 ;
//---------- input / output -----------------


localparam INST_HEAD = 64'hefef123abbeeff22 ;
localparam DATA_HEAD = 64'hefef6543dadaff11 ;

reg [ 3-1 : 0 ] current_state ;
reg [ 3-1 : 0 ] next_state ;


reg [TBITS-1: 0 ] ck_reg_0 ;
reg [TBITS-1: 0 ] ck_reg_1 ;



//---- state reg ----
reg str_start ;

reg ins_read ;

//-------------------
reg instr_start ;
reg datald_start ;

reg instr_done	;
reg headins_done	;

reg [2:0] head_cnt ;
reg [2:0] ins_cnt ;


assign start_reg = str_start  ;

assign ds_empty_n = ( current_state == DATA) ? fifo_empty_n_din : 1'd0 ;

always @(*) begin
	case ( current_state )
		CH00 : fifo_read_dout = ins_read	;
		CH01 : fifo_read_dout = ins_read	;
		INST : fifo_read_dout = ins_read	;
		DATA : fifo_read_dout = ds_read	;		// from data store module
		default: fifo_read_dout = 1'd0	;
	endcase
end

always@(*)begin
	str_start = instr_code00[ 63 -:1 ];
end

always @(*) begin
	headins_done =  (current_state == CH00) ? (head_cnt == 'd2 ) ? 1'd1 : 1'd0  : 1'd0 ;
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
		IDLE : next_state = ( fifo_empty_n_din   ) ? CH00 : IDLE ;
		CH00 : next_state =	( headins_done ) ? CHEK : CH00 ;
		// CH01 : next_state =	CHEK ;
		CHEK : next_state =  ( instr_start ) ? INST : 
								( datald_start ) ? DATA : CHEK;
		INST : next_state = (instr_done ) ? IDLE : INST ;
		DATA : next_state = ( fifo_empty_n_din   ) ? (fifo_last_din ) ? IDLE : DATA  : DATA  ;
		default : next_state = IDLE ;
	endcase	
end		

always @(posedge clk ) begin
	if( reset )begin
		ins_read <= 1'd0 ;
	end
	else begin
		case(current_state)
			CH00 : ins_read <= ( fifo_empty_n_din   ) ?		(head_cnt <2) ? 1'd1 : 1'd0 	: 1'd0 ;
			// CH01 : ins_read <= ( fifo_empty_n_din   ) ? 1'd1 : 1'd0 ;
			INST : ins_read <= ( fifo_empty_n_din   ) ?		(ins_cnt <3) ? 1'd1 : 1'd0		: 1'd0 ;
			
			default : ins_read <= 1'd0 ;
		endcase
	end
end



//---- head count ----
always@( posedge clk )begin
	if( reset )begin
		head_cnt <= 'd0 ;
	end
	else begin
		if( current_state == CH00)begin
			if( head_cnt <2 )begin
				head_cnt <= head_cnt + 'd1 ;
			end
			else begin
				head_cnt <= 'd0 ;
			end
		end
		else begin
			head_cnt <= 'd0 ;
		end

	end
end	

always @(posedge clk ) begin
	if (reset) begin
		ck_reg_0 <= 64'd0 ;
		ck_reg_1 <= 64'd0 ;
	end
	else begin
		if( current_state == CH00 )begin
			if (fifo_empty_n_din && fifo_read_dout) begin
				ck_reg_0 <= ( head_cnt == 3'd1 )? fifo_data_din : ck_reg_0 ;
				ck_reg_1 <= ( head_cnt == 3'd2 )? fifo_data_din : ck_reg_1 ;
			end
			else begin
				ck_reg_0 <= ck_reg_0 ;
				ck_reg_1 <= ck_reg_1 ;
			end
		end
		else begin
			ck_reg_0 <= ck_reg_0 ;
			ck_reg_1 <= ck_reg_1 ;
		end
	end
end


//-----------  ins taker ----------------
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