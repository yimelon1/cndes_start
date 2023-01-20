// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.16
// Ver      : 1.0
// Func     : bias sram read module
// 		2022.12.06	: 8&16 kernel number case and 8&16 input channel case
// ============================================================================

// ============================================================================
//		2022.12.03 check
//      Verilog model for Synchronous Single-Port Ram
//
//      Instance Name:              BIAS_SRAM
//      Words:                      512
//      Bits:                       32
//      Mux:                        8
//      Drive:                      6
//      Write Mask:                 Off
//      Extra Margin Adjustment:    On
//      Accelerated Retention Test: Off
//      Redundant Rows:             0
//      Redundant Columns:          0
//      Test Muxes                  Off
// ============================================================================

module biassram_r (
	clk,
	reset,


	cen_biasr_0		,	
	wen_biasr_0		,
	addr_biasr_0	,
	dout_biasr_0	,


	cp_ker_num	,
	ker_read_done	,
	en_buf_sw	,

// ====		replace bias reg		====
	bias_reg_curr_0		,
	bias_reg_curr_1		,
	bias_reg_curr_2		,
	bias_reg_curr_3		,
	bias_reg_curr_4		,
	bias_reg_curr_5		,
	bias_reg_curr_6		,
	bias_reg_curr_7		,

	bias_reg_next_0		,
	bias_reg_next_1		,
	bias_reg_next_2		,
	bias_reg_next_3		,
	bias_reg_next_4		,
	bias_reg_next_5		,
	bias_reg_next_6		,
	bias_reg_next_7		,
// ====		Tag of bias reg		====
	tag_bias_curr_0		,
	tag_bias_curr_1		,
	tag_bias_curr_2		,
	tag_bias_curr_3		,
	tag_bias_curr_4		,
	tag_bias_curr_5		,
	tag_bias_curr_6		,
	tag_bias_curr_7		,

	tag_bias_next_0		,
	tag_bias_next_1		,
	tag_bias_next_2		,
	tag_bias_next_3		,
	tag_bias_next_4		,
	tag_bias_next_5		,
	tag_bias_next_6		,
	tag_bias_next_7		,



	bias_rd1st_start	,
	bias_rd1st_busy		,
	bias_rd1st_done		,

	bias_read_done 		,
	bias_read_busy 		,
	start_bias_read		


);

//---------- config parameter -----------------------
parameter ADDR_CNT_BITS = 9;
parameter BIREG_PREPARE = 8;		// BIAS register prepare number. 
									// if (kernel_number <8 ) BIREG_PREPARE = kernel_number ; 
									// else BIREG_PREPARE = 8 ; for every kernel sram.


// ====			declare parameter		====
localparam BUF_TAG_BITS = 8;
localparam BIAS_WORD_LENGTH = 32;


//----------------------------------------


//-------------		I/O		----------------------
	input wire clk ;
	input wire reset ;
//--------		schedule signal		--------------
	output reg 		bias_read_done 		;
	output reg 		bias_read_busy 		;
	input wire 		start_bias_read		;

	output wire cen_biasr_0		;
	output wire wen_biasr_0		;
	output wire [ ADDR_CNT_BITS - 1 : 0 ]	addr_biasr_0	;
	input wire 	[BIAS_WORD_LENGTH-1:0]	dout_biasr_0	;		// dout from bias sram
//--------------------------------------------------
	input wire [BUF_TAG_BITS-1 : 0 ] cp_ker_num ;		// 0~7  
	input wire	ker_read_done ;		// 0~7  
	input wire	en_buf_sw ;		// 0~7  
//--------------------------------------------------
	input wire 				bias_rd1st_start 	;
	output reg 				bias_rd1st_busy 	;
	output reg 				bias_rd1st_done 	;


// ====		replace bias reg		====
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_0	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_1	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_2	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_3	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_4	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_5	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_6	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_7	;

output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_0	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_1	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_2	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_3	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_4	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_5	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_6	;
output reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_7	;
// ====		Tag of bias reg		====
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_0	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_1	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_2	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_3	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_4	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_5	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_6	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_7	;

output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_0	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_1	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_2	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_3	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_4	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_5	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_6	;
output reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_7	;




// =====	busy & done		FSM		======================
reg [2:0] current_state ;
reg [2:0] next_state ;
reg rd_first_done ;	// for done signal !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
reg rd_nxload_done ;	// for done signal !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
reg bias_baserd_busy ;	// for base bias read sram busy cover the sram enable signal

// ==== 	bias sram read FSM	====
reg [3:0] rd_current_state ;
reg [3:0] rd_next_state ;
reg rd_first1_done ;	// for done signal !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
reg rd_first2_done ;	// for done signal !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

// ====		sram address counter		====
wire [ADDR_CNT_BITS-1:0]cnt_inbias;
reg [BUF_TAG_BITS-1:0]cpker_p1;
wire en_in_cnt ;
wire cnt_inbias_last ;
reg en_in_cnt_dly0 ;
reg en_in_cnt_dly1 ;
wire valid_read_data ;

// ====		sram signal delay		====
reg signed [32-1 : 0 ] dout_biasr_0_dly0 ;
reg [9-1 : 0 ] srrd_addr_dly0 ;
reg [9-1 : 0 ] srrd_addr_dly1 ;

// ====		check kernel computed number		====
reg [ 9 : 0 ] cp_bias_curr ;



// // ====		replace bias reg		====
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_0	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_1	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_2	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_3	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_4	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_5	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_6	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_curr_7	;

// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_0	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_1	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_2	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_3	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_4	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_5	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_6	;
// reg signed [ BIAS_WORD_LENGTH -1 : 0 ] bias_reg_next_7	;
// // ====		Tag of bias reg		====
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_0	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_1	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_2	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_3	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_4	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_5	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_6	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_curr_7	;

// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_0	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_1	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_2	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_3	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_4	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_5	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_6	;
// reg [BUF_TAG_BITS-1 : 0 ] tag_bias_next_7	;


// ============================================================================
// ===== busy & done
// ============================================================================
localparam IDLE = 3'd0 ;
localparam FIR_BUSY = 3'd1 ;
localparam BASE_BUSY = 3'd2 ;

always @(posedge clk ) begin
	if( reset )begin
		current_state <= IDLE ;
	end
	else begin
		current_state <= next_state ;
	end
end
always@( * )begin
	case (current_state)
		IDLE: 		next_state = ( start_bias_read ) ? BASE_BUSY : 
								 ( bias_rd1st_start ) ?	FIR_BUSY : IDLE ;
		BASE_BUSY: 	next_state = ( bias_read_done ) ? IDLE : BASE_BUSY ;
		FIR_BUSY:	next_state = ( bias_rd1st_done ) ? IDLE : FIR_BUSY ;
		3'd3: next_state =  IDLE  ;
		default: next_state =  IDLE   ;
	endcase
end
always @(*) begin
	bias_baserd_busy = ( current_state == BASE_BUSY ) ? 1'd1 : 1'd0 ;
	bias_rd1st_busy = ( current_state == FIR_BUSY ) ? 1'd1 : 1'd0 ;
	bias_read_busy = bias_baserd_busy | bias_rd1st_busy ;	// output busy for schedule
end
// first read done
always @(posedge clk ) begin
	if(reset)begin
		bias_rd1st_done <= 1'd0 ;
	end
	else begin
		if ( bias_rd1st_busy )begin
			if( rd_first_done )begin
				bias_rd1st_done <= 1'd1 ;
			end
			else begin
				bias_rd1st_done <= 1'd0 ;
			end
		end
		else begin
			bias_rd1st_done <= 1'd0 ;
		end
	end
end

always @(posedge clk ) begin
	if(reset)begin
		bias_read_done <= 1'd0 ;
	end
	else begin
		if(bias_baserd_busy)begin
			if( ker_read_done)begin		// test
				bias_read_done <= 1'd1 ;
			end
			else begin
				bias_read_done <= 1'd0;
			end
		end
		else begin
			bias_read_done <= 1'd0;
		end
	end
end

// ============================================================================
// =====		FSM for CONV mode	
// ============================================================================


// ==== 	BIAS sram read FSM	====
localparam RD_IDLE 			=	4'd0;
localparam RD_FIRST_RS_1 	=	4'd1;	// first read bias form bias sram 
localparam RD_FIRST_HD_1 	=	4'd2;	// hold on for bias reg buffer store
localparam RD_FIRST_RS_2 	=	4'd3;
localparam RD_FIRST_HD_2 	=	4'd4;
localparam RD_BASE 			=	4'd5;
localparam RD_BASE_DL0		=	4'd6;	// check final kernel number is coming, delay for cpker_p1 stable.
localparam RD_NXLOAD_SW 	=	4'd7;
localparam RD_NXLOAD_RS 	=	4'd8;
localparam RD_NXLOAD_HD 	=	4'd9;
localparam RD_DONE 			=	4'd10;

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
		RD_IDLE : rd_next_state = ( bias_baserd_busy ) ? 			RD_BASE	: 
										(bias_rd1st_busy) ?		RD_FIRST_RS_1	:	RD_IDLE ;	// not yet 

		RD_FIRST_RS_1 : rd_next_state = ( cnt_inbias_last  ) ? RD_FIRST_HD_1 : RD_FIRST_RS_1 ;	// control read address counter "cnt_inbias"
		RD_FIRST_HD_1 : rd_next_state = ( rd_first1_done ) ? RD_FIRST_RS_2 : RD_FIRST_HD_1 ;

		RD_FIRST_RS_2 : rd_next_state = ( cnt_inbias_last  ) ? RD_FIRST_HD_2 : RD_FIRST_RS_2 ;	// control read address counter "cnt_inbias"
		RD_FIRST_HD_2 : rd_next_state = ( rd_first2_done ) ? RD_DONE : RD_FIRST_HD_2 ;

		RD_BASE : rd_next_state = ( ker_read_done ) ? 	RD_DONE 	: 
										(en_buf_sw)? 	RD_BASE_DL0	:	// till bias_select_ot_7 select next tag
															RD_BASE ;	// till conv done take kernel module read done 

		RD_BASE_DL0 : rd_next_state = RD_NXLOAD_SW ;	// delay for cpker_p1 stable, next state will check final kernel number is coming or not.
		RD_NXLOAD_SW : rd_next_state = ( cpker_p1 > BIREG_PREPARE-1 )? RD_BASE : 			// if final kernel number is coming, cause it's no longer necessary to read bias sram. just sw.
																			RD_NXLOAD_RS ;	// before next num bias read switch current bias buffer value 
		RD_NXLOAD_RS : rd_next_state = ( cnt_inbias_last ) ? RD_NXLOAD_HD : RD_NXLOAD_RS ;	// control read address counter "cnt_inbias"
		RD_NXLOAD_HD : rd_next_state = ( rd_nxload_done ) ? RD_BASE : RD_NXLOAD_HD ;	 
		RD_DONE : rd_next_state = RD_IDLE ;	// till conv done take kernel module read done 
		default: rd_next_state = RD_IDLE ;
	endcase
end	


always @(*) begin
	rd_first1_done = ( (rd_current_state== RD_FIRST_HD_1) & (srrd_addr_dly1 == BIREG_PREPARE-1 )) ? 1'd1 : 1'd0;
	rd_first2_done = ( (rd_current_state== RD_FIRST_HD_2) & (srrd_addr_dly1 == BIREG_PREPARE-1 )) ? 1'd1 : 1'd0;
	rd_nxload_done = ( (rd_current_state== RD_NXLOAD_HD) & (srrd_addr_dly1 == BIREG_PREPARE-1 )) ? 1'd1 : 1'd0;
	rd_first_done = rd_first2_done	;
end

// -------------------------
// If kernel number <8 then change 



count_yi_v3 #(    .BITS_OF_END_NUMBER( ADDR_CNT_BITS  ) 
    ) rebias_cnt00(.clk ( clk ), .reset ( reset ), .enable ( en_in_cnt ), .cnt_q ( cnt_inbias ),	
    .final_number(	BIREG_PREPARE	)	// it will count to final_num-1 then goes to zero
);

assign cnt_inbias_last = (  cnt_inbias == BIREG_PREPARE-1 )? 1'd1 : 1'd0 ;
assign en_in_cnt = ( (rd_current_state== RD_FIRST_RS_1) & (cnt_inbias <= BIREG_PREPARE-1 )) ? 				1'd1	:	
					( (rd_current_state== RD_FIRST_RS_2) & (cnt_inbias <= BIREG_PREPARE-1 )) ? 				1'd1	:	
						( (rd_current_state== RD_NXLOAD_RS) & (cnt_inbias <= BIREG_PREPARE-1 )  ) ?  1'd1	: 1'd0 ;

assign cen_biasr_0 = ( (rd_current_state== RD_FIRST_RS_1)  | (rd_current_state== RD_NXLOAD_RS ) | (rd_current_state== RD_FIRST_RS_2) ) ? ~en_in_cnt : 1'd1		;

assign wen_biasr_0 = 1'd1		;
assign addr_biasr_0 = ( (rd_current_state== RD_FIRST_RS_1)  ) ? cnt_inbias : 
						( (rd_current_state== RD_FIRST_RS_2)  ) ? cnt_inbias + 9'd8 : 
									(rd_current_state== RD_NXLOAD_RS ) ?  cnt_inbias + cpker_p1*BIREG_PREPARE : 9'd0		;


always @(posedge clk ) begin
	if(reset )begin
		cpker_p1 <= 9'd0;
	end
	else begin
		cpker_p1 <= cp_ker_num+1 ;
	end
end


assign valid_read_data = en_in_cnt_dly1 ;

always @(posedge clk ) begin
	en_in_cnt_dly0 <= en_in_cnt ;
	en_in_cnt_dly1 <= en_in_cnt_dly0 ;
end


// ============================================================================
// =====		sram signal delay for refresh bias_reg
// ============================================================================
always @(posedge clk ) begin
	if(reset)begin
		dout_biasr_0_dly0 <= 32'd0;
		srrd_addr_dly0	<= 9'd0 ;
		srrd_addr_dly1	<= 9'd0 ;	// synchronize with sram output data
	end
	else begin
		dout_biasr_0_dly0 <= dout_biasr_0 ;
		srrd_addr_dly0 <= cnt_inbias ;
		srrd_addr_dly1 <= srrd_addr_dly0 ;
	end
end



//-----------------------------------------------------------------------------"80"
//-----------------------------------------------------------------------------"80"
//-----------------------------------------------------------------------------"80"


//---- bias tag ----
//----generated by bias_read_tag.py------ 
//----bias current tag_0---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_0<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_0<=tag_bias_next_0;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_0 <= 7'd0 ;
            default: tag_bias_curr_0<=tag_bias_curr_0;
        endcase
    end
end
//----bias current tag_1---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_1<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_1<=tag_bias_next_1;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_1 <= 7'd0 ;
            default: tag_bias_curr_1<=tag_bias_curr_1;
        endcase
    end
end
//----bias current tag_2---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_2<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_2<=tag_bias_next_2;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_2 <= 7'd0 ;
            default: tag_bias_curr_2<=tag_bias_curr_2;
        endcase
    end
end
//----bias current tag_3---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_3<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_3<=tag_bias_next_3;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_3 <= 7'd0 ;
            default: tag_bias_curr_3<=tag_bias_curr_3;
        endcase
    end
end
//----bias current tag_4---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_4<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_4<=tag_bias_next_4;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_4 <= 7'd0 ;
            default: tag_bias_curr_4<=tag_bias_curr_4;
        endcase
    end
end
//----bias current tag_5---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_5<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_5<=tag_bias_next_5;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_5 <= 7'd0 ;
            default: tag_bias_curr_5<=tag_bias_curr_5;
        endcase
    end
end
//----bias current tag_6---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_6<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_6<=tag_bias_next_6;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_6 <= 7'd0 ;
            default: tag_bias_curr_6<=tag_bias_curr_6;
        endcase
    end
end
//----bias current tag_7---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_7<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_7<=tag_bias_next_7;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_7 <= 7'd0 ;
            default: tag_bias_curr_7<=tag_bias_curr_7;
        endcase
    end
end
//----bias next tag_0---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_0<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 0)tag_bias_next_0 <= cpker_p1 ;
                else tag_bias_next_0 <= tag_bias_next_0 ;
            end
            default: tag_bias_next_0 <= tag_bias_next_0;
        endcase
    end
end
//----bias next tag_1---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_1<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 1)tag_bias_next_1 <= cpker_p1 ;
                else tag_bias_next_1 <= tag_bias_next_1 ;
            end
            default: tag_bias_next_1 <= tag_bias_next_1;
        endcase
    end
end
//----bias next tag_2---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_2<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 2)tag_bias_next_2 <= cpker_p1 ;
                else tag_bias_next_2 <= tag_bias_next_2 ;
            end
            default: tag_bias_next_2 <= tag_bias_next_2;
        endcase
    end
end
//----bias next tag_3---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_3<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 3)tag_bias_next_3 <= cpker_p1 ;
                else tag_bias_next_3 <= tag_bias_next_3 ;
            end
            default: tag_bias_next_3 <= tag_bias_next_3;
        endcase
    end
end
//----bias next tag_4---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_4<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 4)tag_bias_next_4 <= cpker_p1 ;
                else tag_bias_next_4 <= tag_bias_next_4 ;
            end
            default: tag_bias_next_4 <= tag_bias_next_4;
        endcase
    end
end
//----bias next tag_5---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_5<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 5)tag_bias_next_5 <= cpker_p1 ;
                else tag_bias_next_5 <= tag_bias_next_5 ;
            end
            default: tag_bias_next_5 <= tag_bias_next_5;
        endcase
    end
end
//----bias next tag_6---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_6<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 6)tag_bias_next_6 <= cpker_p1 ;
                else tag_bias_next_6 <= tag_bias_next_6 ;
            end
            default: tag_bias_next_6 <= tag_bias_next_6;
        endcase
    end
end
//----bias next tag_7---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_7<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 7)tag_bias_next_7 <= cpker_p1 ;
                else tag_bias_next_7 <= tag_bias_next_7 ;
            end
            default: tag_bias_next_7 <= tag_bias_next_7;
        endcase
    end
end
//----python generate end------ 




//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//----generated by bias_read_buf.py------ 
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_curr_0<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	bias_reg_curr_0<=bias_reg_next_0;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin
                if( en_in_cnt_dly1 & (srrd_addr_dly1 == 0)) bias_reg_curr_0 <= dout_biasr_0_dly0 ;
                else bias_reg_curr_0 <= bias_reg_curr_0 ;
            end
            default: bias_reg_curr_0<=bias_reg_curr_0;
        endcase
    end
end
//----bias current buffer_0---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_curr_1<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	bias_reg_curr_1<=bias_reg_next_1;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin
                if( srrd_addr_dly1 == 1)bias_reg_curr_1 <= dout_biasr_0_dly0 ;
                else bias_reg_curr_1 <= bias_reg_curr_1 ;
            end
            default: bias_reg_curr_1<=bias_reg_curr_1;
        endcase
    end
end
//----bias current buffer_1---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_curr_2<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	bias_reg_curr_2<=bias_reg_next_2;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin
                if( srrd_addr_dly1 == 2)bias_reg_curr_2 <= dout_biasr_0_dly0 ;
                else bias_reg_curr_2 <= bias_reg_curr_2 ;
            end
            default: bias_reg_curr_2<=bias_reg_curr_2;
        endcase
    end
end
//----bias current buffer_2---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_curr_3<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	bias_reg_curr_3<=bias_reg_next_3;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin
                if( srrd_addr_dly1 == 3)bias_reg_curr_3 <= dout_biasr_0_dly0 ;
                else bias_reg_curr_3 <= bias_reg_curr_3 ;
            end
            default: bias_reg_curr_3<=bias_reg_curr_3;
        endcase
    end
end
//----bias current buffer_3---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_curr_4<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	bias_reg_curr_4<=bias_reg_next_4;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin
                if( srrd_addr_dly1 == 4)bias_reg_curr_4 <= dout_biasr_0_dly0 ;
                else bias_reg_curr_4 <= bias_reg_curr_4 ;
            end
            default: bias_reg_curr_4<=bias_reg_curr_4;
        endcase
    end
end
//----bias current buffer_4---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_curr_5<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	bias_reg_curr_5<=bias_reg_next_5;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin
                if( srrd_addr_dly1 == 5)bias_reg_curr_5 <= dout_biasr_0_dly0 ;
                else bias_reg_curr_5 <= bias_reg_curr_5 ;
            end
            default: bias_reg_curr_5<=bias_reg_curr_5;
        endcase
    end
end
//----bias current buffer_5---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_curr_6<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	bias_reg_curr_6<=bias_reg_next_6;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin
                if( srrd_addr_dly1 == 6)bias_reg_curr_6 <= dout_biasr_0_dly0 ;
                else bias_reg_curr_6 <= bias_reg_curr_6 ;
            end
            default: bias_reg_curr_6<=bias_reg_curr_6;
        endcase
    end
end
//----bias current buffer_6---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_curr_7<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	bias_reg_curr_7<=bias_reg_next_7;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin
                if( srrd_addr_dly1 == 7)bias_reg_curr_7 <= dout_biasr_0_dly0 ;
                else bias_reg_curr_7 <= bias_reg_curr_7 ;
            end
            default: bias_reg_curr_7<=bias_reg_curr_7;
        endcase
    end
end
//----bias current buffer_7---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_next_0<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
                if( en_in_cnt_dly1 & (srrd_addr_dly1 == 0))bias_reg_next_0 <= dout_biasr_0_dly0 ;
                else bias_reg_next_0 <= bias_reg_next_0 ;
            end
            RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin
                if( en_in_cnt_dly1 & (srrd_addr_dly1 == 0))bias_reg_next_0 <= dout_biasr_0_dly0 ;
                else bias_reg_next_0 <= bias_reg_next_0 ;
            end
            default: bias_reg_next_0 <= bias_reg_next_0;
        endcase
    end
end
//----bias next buffer_0---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_next_1<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
                if( srrd_addr_dly1 == 1)bias_reg_next_1 <= dout_biasr_0_dly0 ;
                else bias_reg_next_1 <= bias_reg_next_1 ;
            end
            RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin
                if( srrd_addr_dly1 == 1)bias_reg_next_1 <= dout_biasr_0_dly0 ;
                else bias_reg_next_1 <= bias_reg_next_1 ;
            end
            default: bias_reg_next_1 <= bias_reg_next_1;
        endcase
    end
end
//----bias next buffer_1---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_next_2<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
                if( srrd_addr_dly1 == 2)bias_reg_next_2 <= dout_biasr_0_dly0 ;
                else bias_reg_next_2 <= bias_reg_next_2 ;
            end
            RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin
                if( srrd_addr_dly1 == 2)bias_reg_next_2 <= dout_biasr_0_dly0 ;
                else bias_reg_next_2 <= bias_reg_next_2 ;
            end
            default: bias_reg_next_2 <= bias_reg_next_2;
        endcase
    end
end
//----bias next buffer_2---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_next_3<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
                if( srrd_addr_dly1 == 3)bias_reg_next_3 <= dout_biasr_0_dly0 ;
                else bias_reg_next_3 <= bias_reg_next_3 ;
            end
            RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin
                if( srrd_addr_dly1 == 3)bias_reg_next_3 <= dout_biasr_0_dly0 ;
                else bias_reg_next_3 <= bias_reg_next_3 ;
            end
            default: bias_reg_next_3 <= bias_reg_next_3;
        endcase
    end
end
//----bias next buffer_3---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_next_4<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
                if( srrd_addr_dly1 == 4)bias_reg_next_4 <= dout_biasr_0_dly0 ;
                else bias_reg_next_4 <= bias_reg_next_4 ;
            end
            RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin
                if( srrd_addr_dly1 == 4)bias_reg_next_4 <= dout_biasr_0_dly0 ;
                else bias_reg_next_4 <= bias_reg_next_4 ;
            end
            default: bias_reg_next_4 <= bias_reg_next_4;
        endcase
    end
end
//----bias next buffer_4---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_next_5<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
                if( srrd_addr_dly1 == 5)bias_reg_next_5 <= dout_biasr_0_dly0 ;
                else bias_reg_next_5 <= bias_reg_next_5 ;
            end
            RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin
                if( srrd_addr_dly1 == 5)bias_reg_next_5 <= dout_biasr_0_dly0 ;
                else bias_reg_next_5 <= bias_reg_next_5 ;
            end
            default: bias_reg_next_5 <= bias_reg_next_5;
        endcase
    end
end
//----bias next buffer_5---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_next_6<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
                if( srrd_addr_dly1 == 6)bias_reg_next_6 <= dout_biasr_0_dly0 ;
                else bias_reg_next_6 <= bias_reg_next_6 ;
            end
            RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin
                if( srrd_addr_dly1 == 6)bias_reg_next_6 <= dout_biasr_0_dly0 ;
                else bias_reg_next_6 <= bias_reg_next_6 ;
            end
            default: bias_reg_next_6 <= bias_reg_next_6;
        endcase
    end
end
//----bias next buffer_6---------
always @( posedge clk ) begin
    if(reset)begin
        bias_reg_next_7<= 32'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
                if( srrd_addr_dly1 == 7)bias_reg_next_7 <= dout_biasr_0_dly0 ;
                else bias_reg_next_7 <= bias_reg_next_7 ;
            end
            RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin
                if( srrd_addr_dly1 == 7)bias_reg_next_7 <= dout_biasr_0_dly0 ;
                else bias_reg_next_7 <= bias_reg_next_7 ;
            end
            default: bias_reg_next_7 <= bias_reg_next_7;
        endcase
    end
end
//----bias next buffer_7---------
//----python generate end------ 




//-----------------------------------------------------------------------------

endmodule


