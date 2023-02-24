// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.16
// Ver      : 2.0
// Func     : kernel sram read module use pad and normal 
// ============================================================================



module kersram_r (
	clk,
	reset,


	//----generate by ker_r_io.py 
	//----signal for sram read module io port start------ 
	cen_kersr_0 ,addr_kersr_0 ,valid_0 ,final_0 ,  //----signal for SRAM_0---------
	cen_kersr_1 ,addr_kersr_1 ,valid_1 ,final_1 ,  //----signal for SRAM_1---------
	cen_kersr_2 ,addr_kersr_2 ,valid_2 ,final_2 ,  //----signal for SRAM_2---------
	cen_kersr_3 ,addr_kersr_3 ,valid_3 ,final_3 ,  //----signal for SRAM_3---------
	cen_kersr_4 ,addr_kersr_4 ,valid_4 ,final_4 ,  //----signal for SRAM_4---------
	cen_kersr_5 ,addr_kersr_5 ,valid_5 ,final_5 ,  //----signal for SRAM_5---------
	cen_kersr_6 ,addr_kersr_6 ,valid_6 ,final_6 ,  //----signal for SRAM_6---------
	cen_kersr_7 ,addr_kersr_7 ,valid_7 ,final_7 ,  //----signal for SRAM_7---------
	//----signal for sram read dec io port  end------ 

	output_of_cnt_ker 			,
	output_of_enable_ker_cnt 	,

	ker_read_done 		,
	ker_read_busy 		,
	start_ker_read		


);

//---------- config parameter -----------------------
parameter ADDR_CNT_BITS = 10;
parameter KER_ST_LENGTH = 288;		// every layer has different kernel number and channels
parameter BUF_TAG_BITS = 8		;
// ====	config	sram address counter		====
localparam CH_ADDR = 4	;	// input channel / 8 = 4
localparam CP_PIX = 9	;	// 3x3 base convolution
localparam KER_NUM = 8 ;	// number of kernels 64 /8 = 8  need config
localparam COLOUT_NUM = 10'd9 ;
//----------------------------------------
// ==== local parameter of declare ====



// ==== 	kernel sram read FSM	====
localparam RD_IDLE = 4'd0;


//---------------------------------------------------

input wire clk ;
input wire reset ;

//-------- schedule signal -------------------------
output reg 		ker_read_done 		;
output reg 		ker_read_busy 		;
input wire 		start_ker_read		;

//----generate by ker_r_io.py 
//----declare KER_SRAM read output signal start------ 
output reg cen_kersr_0 ,cen_kersr_1 ,cen_kersr_2 ,cen_kersr_3 ,cen_kersr_4 ,cen_kersr_5 ,cen_kersr_6 ,cen_kersr_7 ; 
// output reg wen_kersr_0 ,wen_kersr_1 ,wen_kersr_2 ,wen_kersr_3 ,wen_kersr_4 ,wen_kersr_5 ,wen_kersr_6 ,wen_kersr_7 ; 
output reg [ ADDR_CNT_BITS -1 : 0 ] addr_kersr_0 ,addr_kersr_1 ,addr_kersr_2 ,addr_kersr_3 ,addr_kersr_4 ,addr_kersr_5 ,addr_kersr_6 ,addr_kersr_7 ; 
output wire valid_0 ,valid_1 ,valid_2 ,valid_3 ,valid_4 ,valid_5 ,valid_6 ,valid_7 ; 
output wire final_0 ,final_1 ,final_2 ,final_3 ,final_4 ,final_5 ,final_6 ,final_7 ; 

// ---- declare signal for bias read module ----
output wire [BUF_TAG_BITS-1:0] 	output_of_cnt_ker 			;
output wire 		output_of_enable_ker_cnt 	;



// =====	busy & done		FSM		======================
reg [1:0] current_state ;
reg [1:0] next_state ;
reg rd_sram_done ;	// for done signal !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// ==== 	kernel sram read FSM	====
reg [3:0] rd_current_state ;
reg [3:0] rd_next_state ;


// ====		sram address counter		====
reg enable_ker_cnt ;

wire enable_once_cp ;
wire enable_cnt_colout ;
wire [9:0] cnt_once_cp ;
wire [ BUF_TAG_BITS-1 : 0 ] cnt_ker ;
wire [9:0] cnt_colout ;
reg [ADDR_CNT_BITS-1:0] sram_address   ;	// sram address
reg [9:0] once_cp_cycle;


// ====		sram signal delay		====
reg cen_dly0,cen_dly1,cen_dly2,cen_dly3,cen_dly4,cen_dly5,cen_dly6,cen_dly7;
reg wen_dly0 , wen_dly1 , wen_dly2 , wen_dly3 , wen_dly4 , wen_dly5 , wen_dly6 , wen_dly7 ;
reg [ ADDR_CNT_BITS-1 : 0 ] addr_sr_dly0 , addr_sr_dly1 , addr_sr_dly2 , addr_sr_dly3 , addr_sr_dly4 , addr_sr_dly5 , addr_sr_dly6 , addr_sr_dly7 ;
reg ker_read_busy_dly0 , ker_read_busy_dly1 , ker_read_busy_dly2 , ker_read_busy_dly3 , ker_read_busy_dly4 , ker_read_busy_dly5 , ker_read_busy_dly6 , ker_read_busy_dly7 ;
reg valid_dly0 , valid_dly1 , valid_dly2 , valid_dly3 , valid_dly4 , valid_dly5 , valid_dly6 , valid_dly7 , valid_dly8 , valid_dly9;
reg final_dly0 , final_dly1 , final_dly2 , final_dly3 , final_dly4 , final_dly5 , final_dly6 , final_dly7 , final_dly8 , final_dly9;
wire valid_check ;
wire final_check ;
reg [9:0] cnt_once_cp_dly0 , cnt_once_cp_dly1 , cnt_once_cp_dly2 , cnt_once_cp_dly3 ;


// ============================================================================
// ====		Net connection		====
// ============================================================================
assign output_of_cnt_ker 			= cnt_ker 		;
assign output_of_enable_ker_cnt 	= enable_ker_cnt 	;


// ============================================================================
// ===== busy & done
// ============================================================================
always @(posedge clk ) begin
	if( reset )begin
		current_state <= 2'd0 ;
	end
	else begin
		current_state <= next_state ;
	end
end
always@( * )begin
	case (current_state)
		2'd0: next_state = ( start_ker_read ) ? 2'd1 : 2'd0 ;
		2'd1: next_state = ( ker_read_done ) ? 2'd2 : 2'd1 ;
		2'd2: next_state =  2'd0   ;
		default: next_state =  2'd0   ;
	endcase
end
always @(*) begin
	ker_read_busy = ( current_state == 2'd1 ) ? 1'd1 : 1'd0 ;
end
always @(posedge clk ) begin
	if(reset)begin
		ker_read_done <= 1'd0 ;
	end
	else begin
		if(ker_read_busy)begin
			if( rd_sram_done )begin
				ker_read_done <= 1'd1 ;
			end
			else begin
				ker_read_done <= 1'd0;
			end
		end
		else begin
			ker_read_done <= 1'd0;
		end
	end
end

// ============================================================================
// =====		FSM for CONV mode	
// ============================================================================
// address generate mode
localparam PAD_MODE = 4'd1;
localparam NOR_MODE = 4'd2;
localparam RD_DONE 	= 4'd3;

localparam C3_MODE = 0;		// compute 3x3
localparam C5_MODE = 1;		// compute 5x5
localparam C7_MODE = 2;		// compute 7x7

localparam MAS_LEFT = 0 ;
localparam MAS_BASE = 1 ;
localparam MAS_RIGT = 2 ;
localparam TOP = 0 ;
localparam MID = 1 ;
localparam BOT = 2 ;

localparam PAD_FINCHO = 3'd1;
reg [2-1 : 0 ] row_pad_condi 	;	// row level padding condition
reg [2-1 : 0 ] mas_state_condi 	;	// master current state condition : LEFT , BASE , RIGHT
reg [2-1 : 0 ] ker_conv_condi 	;	// master current state condition : LEFT , BASE , RIGHT

reg padding_done ;
reg nor_read_done ;

reg [ 10-1 : 0 ] pdad_top_array [ 0 : 5-1 ];	// config for top 
reg [ 10-1 : 0 ] pdad_bot_array [ 0 : 5-1 ];	// config for bottom 


wire [3-1 : 0 ] cnt_pdcho ;


reg [ 4-1 : 0 ] pd_start	;
reg [ 4-1 : 0 ] pd_end		;
reg [ 4-1 : 0 ] pd_cnt_ad	;
wire en_pdcho ;


//-----------------------------------------------------------------------------
// config register
//-----------------------------------------------------------------------------
integer i ;
reg [8-1:0] cfg_top_starter		[0:4];
reg [8-1:0] cfg_botpad_length	[0:4];
reg [8-1:0] cfg_toppad_length		[0:4];
reg [10-1:0] cfg_normal_length	;
reg [10-1:0] cfg_ker_shifter		;

always @( posedge clk ) begin
	if( reset )begin
		for( i=0 ; i<5 ; i=i+1 )begin
			cfg_top_starter[i] <= 8'd0 ;
			cfg_toppad_length[i] <= 8'd0 ;
			cfg_botpad_length[i] <= 8'd0 ;
			
		end
	end
	else begin
		//3x3
		cfg_top_starter		[0] <= 8'd12	;
		cfg_toppad_length	[0] <= 8'd24	;
		cfg_botpad_length	[0] <= 8'd24	;
		

		//5x5
		// cfg_top_starter		[0] <= 8'd40	;
		// cfg_toppad_length	[0] <= 8'd60	;
		// cfg_botpad_length	[0] <= 8'd40	;
		// cfg_top_starter		[1] <= 8'd20	;
		// cfg_toppad_length	[1] <= 8'd80	;
		// cfg_botpad_length	[1] <= 8'd80	;
	end
end

always @(*) begin
	cfg_normal_length	= ( reset ) ? 10'd0 :10'd36 ;
	cfg_ker_shifter		= ( reset ) ? 10'd0 :10'd36 ;
end


// just for 
// always @( * ) begin
// 	case (mas_state_condi)
// 		MAS_LEFT : pdad_choose = ( row_pad_condi == TOP ) ? pdad_top_array [ cnt_pdcho ] : 
// 									( row_pad_condi == BOT ) ? pdad_bot_array [ cnt_pdcho ] : 10'd0 ;
// 		MAS_RIGT : pdad_choose = ( row_pad_condi == TOP ) ? pdad_top_array [ cnt_pdcho ] : 
// 									( row_pad_condi == BOT ) ? pdad_bot_array [ cnt_pdcho ] : 10'd0 ;
// 		default: pdad_choose = 10'd0 ;
// 	endcase
// end

always @(*) begin
	row_pad_condi 		= 	( reset ) ? MID 		: TOP		;
	mas_state_condi 	= 	( reset ) ? MAS_BASE 	: MAS_BASE	;
	ker_conv_condi 		= 	( reset ) ? C3_MODE 	: C3_MODE	;
end

always @(*) begin
	// padding_done = ( (cnt_once_cp == once_cp_cycle-1 ) & (cnt_colout == COLOUT_NUM-1 ) ) ? 1'd1 :1'd0 ;
	// nor_read_done = ( (cnt_once_cp == once_cp_cycle-1 ) & (cnt_colout == COLOUT_NUM-1 ) & ( cnt_ker == KER_NUM-1 ) ) ? 1'd1 : 1'd0;
	nor_read_done = ( (cnt_once_cp == once_cp_cycle-1 ) & (cnt_colout == COLOUT_NUM-1 ) & ( cnt_ker == KER_NUM-1 ) ) ? 1'd1 : 1'd0;
end
always @(*) begin
	if( row_pad_condi == TOP)
		padding_done = ( (cnt_once_cp == once_cp_cycle-1 ) & (cnt_colout == COLOUT_NUM-1 ) & ( cnt_ker == KER_NUM-1 )) ? 1'd1 :1'd0 ;
	else if( row_pad_condi == BOT	)
		padding_done = ( (cnt_once_cp == once_cp_cycle-1 ) & (cnt_colout == COLOUT_NUM-1 ) & ( cnt_ker == KER_NUM-1 )) ? 1'd1 :1'd0 ;
	else 
		padding_done = 1'd0 ;
end

// assign en_pdcho = ( (rd_current_state == PAD_MODE)&(pd_cnt_ad == pd_end)  )? 1'd1 : 1'd0 ;

// always @(posedge clk ) begin
// 	if(reset) pd_start 	<= 4'd0 ; else pd_start <= 4'd1 ;
// 	if(reset) pd_end 	<= 4'd0 ; else pd_end 	<= 4'd7 ;	// config
// end
// always @(posedge clk ) begin
// 	if(reset)begin
// 		pd_cnt_ad <= 4'd0 ;
// 	end
// 	else begin
// 		if( rd_current_state == PAD_MODE )begin
// 			if( pd_cnt_ad >= pd_end)begin
// 				pd_cnt_ad <= 4'd0 ;
// 			end
// 			else begin
// 				pd_cnt_ad <= pd_cnt_ad + 4'd1  ;
// 			end
// 		end
// 		else begin
// 			pd_cnt_ad <= 4'd0 ;
// 		end
// 	end
// end



// count_yi_v3 #(
//     .BITS_OF_END_NUMBER (3)
// )pdad_cho_01(
// 	.clk	(	clk		),
// 	.reset	(	reset	),
//     .enable (	en_pdcho	), 
// 	.final_number(	PAD_FINCHO + 1	),		// config
//     .cnt_q	(	cnt_pdcho	)
// );


always @(posedge clk ) begin
	if(reset )begin
		rd_current_state <= 4'd0 ;
	end
	else begin
		rd_current_state <= rd_next_state ;
	end
end
always @(*) begin
	case (rd_current_state)
		RD_IDLE : rd_next_state = ( !ker_read_busy ) ? 								RD_IDLE 	:
									( (row_pad_condi == MID) )?		NOR_MODE 	:	PAD_MODE ;

		PAD_MODE : rd_next_state = ( !padding_done ) ? 								PAD_MODE : RD_DONE ;

		NOR_MODE : rd_next_state = ( !nor_read_done ) ? 							NOR_MODE : RD_DONE ;

		RD_DONE	: rd_next_state = RD_IDLE ;
		default: rd_next_state = RD_IDLE ;
	endcase
end	

always @(*) begin
	// rd_sram_done = ( (cnt_once_cp == once_cp_cycle-1 ) & (cnt_colout == COLOUT_NUM-1 ) & ( cnt_ker == KER_NUM-1 ) ) ? 1'd1 : 1'd0;
	rd_sram_done = ( rd_current_state == RD_DONE ) ? 1'd1 : 1'd0;
end


// ============================================================================
// =====		sram address count 	
// ============================================================================

// config one round convolution address number
// always @(posedge clk ) begin
// 	if( reset )begin
// 		once_cp_cycle <= 10'd0;
// 	end
// 	else begin
// 		once_cp_cycle <= cfg_normal_length ;
// 	end
// end

always @(*) begin
	if ( rd_current_state == PAD_MODE )begin
		if( row_pad_condi == TOP)
			once_cp_cycle = cfg_toppad_length [0];
		else if( row_pad_condi == BOT	)
			once_cp_cycle = cfg_toppad_length [0];
		else 
			once_cp_cycle = cfg_normal_length;
	end
	else begin
		once_cp_cycle = cfg_normal_length;
	end

end


assign enable_once_cp = ( (rd_current_state == NOR_MODE) & ker_read_busy )? 1'd1 : 
							( (rd_current_state == PAD_MODE) & ker_read_busy )? 1'd1 : 1'd0 ;
assign enable_cnt_colout = ( (rd_current_state == NOR_MODE) & (cnt_once_cp == once_cp_cycle-1 ) )? 1'd1 :
								( (rd_current_state == PAD_MODE) & (cnt_once_cp == once_cp_cycle-1 ) )? 1'd1 : 1'd0 ;

// assign enable_ker_cnt = ( (rd_current_state == NOR_MODE) & (cnt_colout == COLOUT_NUM-1 )  & (cnt_once_cp == once_cp_cycle-1 ) )? 1'd1 : 
// 							( (rd_current_state == PAD_MODE) & padding_done )? 1'd1 : 1'd0 ;

// assign sram_address = ( rd_current_state == PAD_MODE ) ? 	(cnt_ker*once_cp_cycle)+cnt_once_cp+cfg_top_starter  :
// 															cnt_ker*once_cp_cycle + cnt_once_cp ;	// sram address
always @(*) begin
	if(  rd_current_state == PAD_MODE  )
		sram_address = cnt_once_cp + cfg_top_starter[0] + cnt_ker*cfg_normal_length;
	else 
		sram_address = cnt_ker*once_cp_cycle + cnt_once_cp ;
end

always @( * ) begin
	// case (mas_state_condi)
	// 	MAS_LEFT , MAS_BASE : 
	// 		enable_ker_cnt = ((rd_current_state == NOR_MODE) & nor_read_done) ? 1'd1 : 1'd0 ;

	// 	MAS_RIGT : enable_ker_cnt = ((rd_current_state == PAD_MODE) & padding_done) ? 1'd1 : 1'd0 ;
	// 	default: enable_ker_cnt = 1'd0 ;
	// endcase
	enable_ker_cnt = ((rd_current_state == NOR_MODE) & (cnt_colout == COLOUT_NUM-1 ) & (cnt_once_cp == once_cp_cycle-1 )) ? 1'd1 :
						((rd_current_state == PAD_MODE) & (cnt_colout == COLOUT_NUM-1 ) & (cnt_once_cp == once_cp_cycle-1 ) ) ? 1'd1 : 1'd0 ;
end


count_yi_v3 #(
    .BITS_OF_END_NUMBER (10)
)cp_once0(
	.clk	(	clk		),
	.reset	(	reset	),
    .enable (	enable_once_cp	), 
	.final_number(	once_cp_cycle	),
    .cnt_q	(	cnt_once_cp	)
);

count_yi_v3 #(
    .BITS_OF_END_NUMBER ( BUF_TAG_BITS )
)cp_kernum0(
	.clk	(	clk		),
	.reset	(	reset	),
    .enable (	enable_ker_cnt	), 
	.final_number(	KER_NUM	),
    .cnt_q	(	cnt_ker	)
);

count_yi_v3 #(
    .BITS_OF_END_NUMBER (10)
)cp_colout0(
	.clk	(	clk		),
	.reset	(	reset	),
    .enable (	enable_cnt_colout	), 
	.final_number(	COLOUT_NUM	),
    .cnt_q	(	cnt_colout	)
);


// ============================================================================
// =====		assign sram signal		==== 	
// ============================================================================
always@(posedge clk )begin
	cen_dly0 <= ~enable_once_cp ;
	cen_dly1 <= cen_dly0 ;
	cen_dly2 <= cen_dly1 ;
	cen_dly3 <= cen_dly2 ;
	cen_dly4 <= cen_dly3 ;
	cen_dly5 <= cen_dly4 ;
	cen_dly6 <= cen_dly5 ;
	cen_dly7 <= cen_dly6 ;
end
always@(posedge clk )begin
	wen_dly0 = ~enable_once_cp ;
	wen_dly1 = wen_dly0 ;
	wen_dly2 = wen_dly1 ;
	wen_dly3 = wen_dly2 ;
	wen_dly4 = wen_dly3 ;
	wen_dly5 = wen_dly4 ;
	wen_dly6 = wen_dly5 ;
	wen_dly7 = wen_dly6 ;
end
always @(posedge clk ) begin
	addr_sr_dly0 <= sram_address ;
	addr_sr_dly1 <= addr_sr_dly0 ;
	addr_sr_dly2 <= addr_sr_dly1 ;
	addr_sr_dly3 <= addr_sr_dly2 ;
	addr_sr_dly4 <= addr_sr_dly3 ;
	addr_sr_dly5 <= addr_sr_dly4 ;
	addr_sr_dly6 <= addr_sr_dly5 ;
	addr_sr_dly7 <= addr_sr_dly6 ;
end


always @(posedge clk ) begin
	ker_read_busy_dly0 <= ker_read_busy;
	ker_read_busy_dly1 <= ker_read_busy_dly0 ;
	ker_read_busy_dly2 <= ker_read_busy_dly1 ;
	ker_read_busy_dly3 <= ker_read_busy_dly2 ;
	ker_read_busy_dly4 <= ker_read_busy_dly3 ;
	ker_read_busy_dly5 <= ker_read_busy_dly4 ;
	ker_read_busy_dly6 <= ker_read_busy_dly5 ;
	ker_read_busy_dly7 <= ker_read_busy_dly6 ;
end


assign valid_check = enable_once_cp;
assign final_check = ( cnt_once_cp_dly1 == once_cp_cycle-1 ) ? 1'd1 : 1'd0 ;


always @(posedge clk ) begin
	cnt_once_cp_dly0 <= cnt_once_cp ;
	cnt_once_cp_dly1 <= cnt_once_cp_dly0 ;
	cnt_once_cp_dly2 <= cnt_once_cp_dly1 ;
	cnt_once_cp_dly3 <= cnt_once_cp_dly2 ;
end

always @(posedge clk ) begin
	valid_dly0 <= valid_check ;
	valid_dly1 <= valid_dly0 ;
	valid_dly2 <= valid_dly1 ;
	valid_dly3 <= valid_dly2 ;
	valid_dly4 <= valid_dly3 ;
	valid_dly5 <= valid_dly4 ;
	valid_dly6 <= valid_dly5 ;
	valid_dly7 <= valid_dly6 ;
	valid_dly8 <= valid_dly7 ;
	valid_dly9 <= valid_dly8 ;
end
always @(posedge clk ) begin
	final_dly0 <= final_check ;
	final_dly1 <= final_dly0 ;
	final_dly2 <= final_dly1 ;
	final_dly3 <= final_dly2 ;
	final_dly4 <= final_dly3 ;
	final_dly5 <= final_dly4 ;
	final_dly6 <= final_dly5 ;
	final_dly7 <= final_dly6 ;
	final_dly8 <= final_dly7 ;
	final_dly9 <= final_dly8 ;
end

assign valid_0 = valid_dly1 ;
assign valid_1 = valid_dly2 ;
assign valid_2 = valid_dly3 ;
assign valid_3 = valid_dly4 ;
assign valid_4 = valid_dly5 ;
assign valid_5 = valid_dly6 ;
assign valid_6 = valid_dly7 ;
assign valid_7 = valid_dly8 ;

assign final_0 = final_dly1 ;
assign final_1 = final_dly2 ;
assign final_2 = final_dly3 ;
assign final_3 = final_dly4 ;
assign final_4 = final_dly5 ;
assign final_5 = final_dly6 ;
assign final_6 = final_dly7 ;
assign final_7 = final_dly8 ;



always @(*) begin
	cen_kersr_0 = ( ker_read_busy_dly0 )? cen_dly0 : 1'd1 ;
	cen_kersr_1 = ( ker_read_busy_dly1 )? cen_dly1 : 1'd1 ;
	cen_kersr_2 = ( ker_read_busy_dly2 )? cen_dly2 : 1'd1 ;
	cen_kersr_3 = ( ker_read_busy_dly3 )? cen_dly3 : 1'd1 ;
	cen_kersr_4 = ( ker_read_busy_dly4 )? cen_dly4 : 1'd1 ;
	cen_kersr_5 = ( ker_read_busy_dly5 )? cen_dly5 : 1'd1 ;
	cen_kersr_6 = ( ker_read_busy_dly6 )? cen_dly6 : 1'd1 ;
	cen_kersr_7 = ( ker_read_busy_dly7 )? cen_dly7 : 1'd1 ;
end




always @(*) begin
	addr_kersr_0 = ( ker_read_busy_dly0 )? addr_sr_dly0 : 11'd0  ;  
	addr_kersr_1 = ( ker_read_busy_dly1 )? addr_sr_dly1 : 11'd0  ;  
	addr_kersr_2 = ( ker_read_busy_dly2 )? addr_sr_dly2 : 11'd0  ;  
	addr_kersr_3 = ( ker_read_busy_dly3 )? addr_sr_dly3 : 11'd0  ;  
	addr_kersr_4 = ( ker_read_busy_dly4 )? addr_sr_dly4 : 11'd0  ;  
	addr_kersr_5 = ( ker_read_busy_dly5 )? addr_sr_dly5 : 11'd0  ;  
	addr_kersr_6 = ( ker_read_busy_dly6 )? addr_sr_dly6 : 11'd0  ;  
	addr_kersr_7 = ( ker_read_busy_dly7 )? addr_sr_dly7 : 11'd0  ;  
end





// =========================================



endmodule