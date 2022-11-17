// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.16
// Ver      : 1.0
// Func     : kernel sram read module
// ============================================================================



module kersram_r (
	clk,
	reset,


	//----generate by ker_r_io.py 
	//----signal for sram read module io port start------ 
	cen_kersr_0 ,wen_kersr_0 ,addr_kersr_0 ,valid_0 ,final_0 ,  //----signal for SRAM_0---------
	cen_kersr_1 ,wen_kersr_1 ,addr_kersr_1 ,valid_1 ,final_1 ,  //----signal for SRAM_1---------
	cen_kersr_2 ,wen_kersr_2 ,addr_kersr_2 ,valid_2 ,final_2 ,  //----signal for SRAM_2---------
	cen_kersr_3 ,wen_kersr_3 ,addr_kersr_3 ,valid_3 ,final_3 ,  //----signal for SRAM_3---------
	cen_kersr_4 ,wen_kersr_4 ,addr_kersr_4 ,valid_4 ,final_4 ,  //----signal for SRAM_4---------
	cen_kersr_5 ,wen_kersr_5 ,addr_kersr_5 ,valid_5 ,final_5 ,  //----signal for SRAM_5---------
	cen_kersr_6 ,wen_kersr_6 ,addr_kersr_6 ,valid_6 ,final_6 ,  //----signal for SRAM_6---------
	cen_kersr_7 ,wen_kersr_7 ,addr_kersr_7 ,valid_7 ,final_7 ,  //----signal for SRAM_7---------
	//----signal for sram read dec io port  end------ 



	ker_read_done 		,
	ker_read_busy 		,
	start_ker_read		


);

//---------- config parameter -----------------------
parameter ADDR_CNT_BITS = 11;
parameter KER_ST_LENGTH = 288;		// every layer has different kernel number and channels
// ====	config	sram address counter		====
localparam CH_ADDR = 4	;	// input channel / 8 = 4
localparam CP_PIX = 9	;	// 3x3 base convolution
localparam KER_NUM = 8 ;	// number of kernels 64 /8 = 8  need config
localparam COLOUT_NUM = 10'd20 ;
//----------------------------------------

// ==== 	kernel sram read FSM	====
localparam RD_IDLE = 4'd0;
localparam RD_BASE = 4'd1;

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
output reg wen_kersr_0 ,wen_kersr_1 ,wen_kersr_2 ,wen_kersr_3 ,wen_kersr_4 ,wen_kersr_5 ,wen_kersr_6 ,wen_kersr_7 ; 
output reg [ 11 -1 : 0 ] addr_kersr_0 ,addr_kersr_1 ,addr_kersr_2 ,addr_kersr_3 ,addr_kersr_4 ,addr_kersr_5 ,addr_kersr_6 ,addr_kersr_7 ; 
output reg valid_0 ,valid_1 ,valid_2 ,valid_3 ,valid_4 ,valid_5 ,valid_6 ,valid_7 ; 
output reg final_0 ,final_1 ,final_2 ,final_3 ,final_4 ,final_5 ,final_6 ,final_7 ; 


// =====	busy & done		FSM		======================
reg [1:0] current_state ;
reg [1:0] next_state ;
reg rd_sram_done ;	// for done signal !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// ==== 	kernel sram read FSM	====
reg [3:0] rd_current_state ;
reg [3:0] rd_next_state ;


// ====		sram address counter		====
wire enable_once_cp ;
wire enable_ker_cnt ;
wire enable_cnt_colout ;
wire [9:0] cnt_once_cp ;
wire [9:0] cnt_ker ;
wire [9:0] cnt_colout ;
wire [10:0] sram_address   ;	// sram address
reg [9:0] once_cp_cycle;


// ====		sram signal delay		====
reg cen_dly0,cen_dly1,cen_dly2,cen_dly3,cen_dly4,cen_dly5,cen_dly6,cen_dly7;
reg wen_dly0 , wen_dly1 , wen_dly2 , wen_dly3 , wen_dly4 , wen_dly5 , wen_dly6 , wen_dly7 ;
reg [ 10 : 0 ] addr_sr_dly0 , addr_sr_dly1 , addr_sr_dly2 , addr_sr_dly3 , addr_sr_dly4 , addr_sr_dly5 , addr_sr_dly6 , addr_sr_dly7 ;
reg ker_read_busy_dly0 , ker_read_busy_dly1 , ker_read_busy_dly2 , ker_read_busy_dly3 , ker_read_busy_dly4 , ker_read_busy_dly5 , ker_read_busy_dly6 , ker_read_busy_dly7 ;
reg valid_dly0 , valid_dly1 , valid_dly2 , valid_dly3 , valid_dly4 , valid_dly5 , valid_dly6 , valid_dly7 , valid_dly8 , valid_dly9;
reg final_dly0 , final_dly1 , final_dly2 , final_dly3 , final_dly4 , final_dly5 , final_dly6 , final_dly7 , final_dly8 , final_dly9;
wire valid_check ;
wire final_check ;
reg [9:0] cnt_once_cp_dly0 , cnt_once_cp_dly1 , cnt_once_cp_dly2 , cnt_once_cp_dly3 ;
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
		RD_IDLE : rd_next_state = ( ker_read_busy ) ? RD_BASE : RD_IDLE ;
		RD_BASE : rd_next_state = ( rd_sram_done ) ? RD_IDLE : RD_BASE ;
		default: rd_next_state = RD_IDLE ;
	endcase
end	

always @(*) begin
	rd_sram_done = ( (cnt_once_cp == once_cp_cycle-1 ) & (cnt_colout == COLOUT_NUM-1 ) & ( cnt_ker == KER_NUM-1 ) ) ? 1'd1 : 1'd0;
end


// ============================================================================
// =====		sram address count 	
// ============================================================================

// config one round convolution address number
always @(posedge clk ) begin
	if( reset )begin
		once_cp_cycle <= 10'd0;
	end
	else begin
		once_cp_cycle <= CH_ADDR * CP_PIX ;
	end
end

assign enable_once_cp = ( (rd_current_state == RD_BASE) & ker_read_busy )? 1'd1 : 1'd0 ;
assign enable_cnt_colout = ( (rd_current_state == RD_BASE) & (cnt_once_cp == once_cp_cycle-1 ) )? 1'd1 : 1'd0 ;
assign enable_ker_cnt = ( (rd_current_state == RD_BASE) & (cnt_colout == COLOUT_NUM-1 )  & (cnt_once_cp == once_cp_cycle-1 ) )? 1'd1 : 1'd0 ;

assign sram_address = cnt_once_cp + cnt_ker*once_cp_cycle ;	// sram address



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
    .BITS_OF_END_NUMBER (10)
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

	// cen_kersr_0 ,wen_kersr_0 ,addr_kersr_0 ,dout_kersr_0 ,valid_0 ,final_0 ,  //----signal for SRAM_0---------
	// cen_kersr_1 ,wen_kersr_1 ,addr_kersr_1 ,dout_kersr_1 ,valid_1 ,final_1 ,  //----signal for SRAM_1---------
	// cen_kersr_2 ,wen_kersr_2 ,addr_kersr_2 ,dout_kersr_2 ,valid_2 ,final_2 ,  //----signal for SRAM_2---------
	// cen_kersr_3 ,wen_kersr_3 ,addr_kersr_3 ,dout_kersr_3 ,valid_3 ,final_3 ,  //----signal for SRAM_3---------
	// cen_kersr_4 ,wen_kersr_4 ,addr_kersr_4 ,dout_kersr_4 ,valid_4 ,final_4 ,  //----signal for SRAM_4---------
	// cen_kersr_5 ,wen_kersr_5 ,addr_kersr_5 ,dout_kersr_5 ,valid_5 ,final_5 ,  //----signal for SRAM_5---------
	// cen_kersr_6 ,wen_kersr_6 ,addr_kersr_6 ,dout_kersr_6 ,valid_6 ,final_6 ,  //----signal for SRAM_6---------
	// cen_kersr_7 ,wen_kersr_7 ,addr_kersr_7 ,dout_kersr_7 ,valid_7 ,final_7 ,  //----signal for SRAM_7---------

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
	cnt_once_cp_dly0 = cnt_once_cp ;
	cnt_once_cp_dly1 = cnt_once_cp_dly0 ;
	cnt_once_cp_dly2 = cnt_once_cp_dly1 ;
	cnt_once_cp_dly3 = cnt_once_cp_dly2 ;
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

assign cen_kersr_0 = ( ker_read_busy_dly0 )? cen_dly0 : 1'd1 ;
assign cen_kersr_1 = ( ker_read_busy_dly1 )? cen_dly1 : 1'd1 ;
assign cen_kersr_2 = ( ker_read_busy_dly2 )? cen_dly2 : 1'd1 ;
assign cen_kersr_3 = ( ker_read_busy_dly3 )? cen_dly3 : 1'd1 ;
assign cen_kersr_4 = ( ker_read_busy_dly4 )? cen_dly4 : 1'd1 ;
assign cen_kersr_5 = ( ker_read_busy_dly5 )? cen_dly5 : 1'd1 ;
assign cen_kersr_6 = ( ker_read_busy_dly6 )? cen_dly6 : 1'd1 ;
assign cen_kersr_7 = ( ker_read_busy_dly7 )? cen_dly7 : 1'd1 ;


assign wen_kersr_0 =  1'd1 ;
assign wen_kersr_1 =  1'd1 ;
assign wen_kersr_2 =  1'd1 ;
assign wen_kersr_3 =  1'd1 ;
assign wen_kersr_4 =  1'd1 ;
assign wen_kersr_5 =  1'd1 ;
assign wen_kersr_6 =  1'd1 ;
assign wen_kersr_7 =  1'd1 ;


assign addr_kersr_0 = ( ker_read_busy_dly0 )? addr_sr_dly0 : 11'd0  ;  
assign addr_kersr_1 = ( ker_read_busy_dly1 )? addr_sr_dly1 : 11'd0  ;  
assign addr_kersr_2 = ( ker_read_busy_dly2 )? addr_sr_dly2 : 11'd0  ;  
assign addr_kersr_3 = ( ker_read_busy_dly3 )? addr_sr_dly3 : 11'd0  ;  
assign addr_kersr_4 = ( ker_read_busy_dly4 )? addr_sr_dly4 : 11'd0  ;  
assign addr_kersr_5 = ( ker_read_busy_dly5 )? addr_sr_dly5 : 11'd0  ;  
assign addr_kersr_6 = ( ker_read_busy_dly6 )? addr_sr_dly6 : 11'd0  ;  
assign addr_kersr_7 = ( ker_read_busy_dly7 )? addr_sr_dly7 : 11'd0  ;  


// =========================================



endmodule