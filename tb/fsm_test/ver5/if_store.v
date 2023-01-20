// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.09
// Ver      : 1.0
// Func     : just generate if sram signel
// 		2022.11.09 : move sram to outside 
// 		2022.12.06 : modify drdata and drnum
// ============================================================================

module ifstore_gen
#(
	parameter TBITS = 64 ,
	parameter TBYTE = 8
)(
	clk,
	reset,

	ifstore_data_din		,
	ifstore_empty_n_din		,
	ifstore_read_dout		,

	if_store_done 		,
	if_store_busy 		,
	start_if_store		,	

	cen_ifsram 			,
	wen_ifsram 			,
	data_ifsram			,
	addr_ifsram			


);

//----------------------------------------------------------------------------
//---------------		Parameter		--------------------------------------
//----------------------------------------------------------------------------
localparam IFMAP_SRAM_ADDBITS = 11 ;
localparam IFMAP_SRAM_DATA_WIDTH = 64;

// one row address 0 to 263 means col0 ~ col65
localparam STSRAM_CNT_BITS = 6	;
localparam STSRAM_1ST_BITS = 10	;	// cp first stage bits width
localparam STSRAM_2ST_BITS = 10	;	// cp first stage bits width

//---- config -----------
localparam FINAL_DIN_NUM =  264 ;		// final of input data number each row
localparam FINAL_STR1ST_NUM =	FINAL_DIN_NUM*3	;
localparam FINAL_STR2ST_NUM =	FINAL_DIN_NUM*3	;
localparam FINAL_STRADDR_NUM =	FINAL_DIN_NUM*3	;		// 3row data = FINAL_DIN_NUM *3  
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//---------------		I/O			------------------------------------------
//----------------------------------------------------------------------------
input	wire 				clk		;
input	wire 				reset	;
input	wire [TBITS-1: 0 ]	ifstore_data_din		;
input	wire 				ifstore_empty_n_din		;
output	reg 				ifstore_read_dout		;

output 	reg 				if_store_done		;	// make the next state change
output	reg					if_store_busy		;	// when catch start signal make busy signal  "ON"
input	wire				start_if_store			;	// control from get_ins 

output wire cen_ifsram ;
output wire wen_ifsram ;
output wire [63:0] data_ifsram;
output wire [10:0] addr_ifsram;





reg nxet_busy ;


reg [1:0] current_state ;
reg [1:0] next_state ;
// ============================================================================





//----sramcnt_0---------
wire [ STSRAM_1ST_BITS-1 :0]	stsr_ct00	;	//first stage cnt
wire [ STSRAM_2ST_BITS-1 :0]	stsr_ct01	;	//second stage cnt
wire cten_stsr_ct01 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_0		;	// check the data we want
wire en_stsr_addrct_0 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_0 ;


reg valid_drdata ;
reg valid_drdata_dly1 ;
reg valid_drdata_dly2 ;
reg valid_drdata_dly3 ;
reg valid_drdata_dly4 ;
reg valid_drdata_dly5 ;
reg valid_drdata_dly6 ;
reg valid_drdata_dly7 ;
reg valid_drdata_dly8 ;
reg valid_drdata_dly9 ;


reg [11 : 0 ] cnt00 ;

//-------  input data stream ------
reg [11:0]			dr_num_dly0	;
reg [11:0]			dr_num_dly1	;
reg [11:0]			dr_num_dly2	;
reg [11:0]			dr_num_dly3	;
reg [11:0]			dr_num_dly4	;
reg [11:0]			dr_num_dly5	;
reg [11:0]			dr_num_dly6	;
reg [11:0]			dr_num_dly7	;

reg [TBITS-1:0] 	dr_data_dly0	;
reg [TBITS-1:0] 	dr_data_dly1	;
reg [TBITS-1:0] 	dr_data_dly2	;
reg [TBITS-1:0] 	dr_data_dly3	;
reg [TBITS-1:0] 	dr_data_dly4	;
reg [TBITS-1:0] 	dr_data_dly5	;
reg [TBITS-1:0] 	dr_data_dly6	;
reg [TBITS-1:0] 	dr_data_dly7	;


assign addr_ifsram	= stsr_addrct_0		;
assign data_ifsram	= dr_data_dly0 		;
assign cen_ifsram		= ~en_stsr_addrct_0	;
assign wen_ifsram		= ~en_stsr_addrct_0	;

//----sramcnt_0---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_1ST_BITS  ) 
    )cnt_00(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_0 ), .cnt_q ( stsr_ct00 ),	
    .final_number(	FINAL_STR1ST_NUM	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_2ST_BITS  ) 
    )cnt_01(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct01 ), .cnt_q ( stsr_ct01 ),	//
    .final_number(	FINAL_STR2ST_NUM	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_0(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_0 ), .cnt_q ( stsr_addrct_0 ),	//
    .final_number(	FINAL_STRADDR_NUM	)		// it will count to final_num-1 then goes to zero
);



assign en_stsr_addrct_0 = (  (stsr_cp_0 == dr_num_dly0) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want
// assign cten_stsr_ct01 = (	stsr_ct00	==	FINAL_1ST_NUM-1	)? 1'd1 : 1'd0 ;	// one IF SRAM no use this 
assign cten_stsr_ct01 =  1'd0 ;
assign stsr_cp_0 = 'd0 + stsr_ct00 + 32*stsr_ct01 ;		// generate cp number


//-------  input data stream ------
// shift data and input address for every sram 
//---------------------------------

always@(posedge clk )begin

	dr_num_dly0 <= cnt00;
	
	dr_num_dly1	<= dr_num_dly0	;
	dr_num_dly2	<= dr_num_dly1	;
	dr_num_dly3	<= dr_num_dly2	;
	dr_num_dly4	<= dr_num_dly3	;
	dr_num_dly5	<= dr_num_dly4	;
	dr_num_dly6	<= dr_num_dly5	;
	dr_num_dly7	<= dr_num_dly6	;

	dr_data_dly0	<= ifstore_data_din	;
	dr_data_dly1	<= dr_data_dly0		;
	dr_data_dly2	<= dr_data_dly1		;
	dr_data_dly3	<= dr_data_dly2		;
	dr_data_dly4	<= dr_data_dly3		;
	dr_data_dly5	<= dr_data_dly4		;
	dr_data_dly6	<= dr_data_dly5		;
	dr_data_dly7	<= dr_data_dly6		;

end

// ============================================================================
// ===== busy & done
// ============================================================================

always @(posedge clk ) begin
	if(reset) begin
		current_state <= 2'd0;
	end
	else begin
		current_state <= next_state;
	end
end
always @(*) begin
	case (current_state)
		2'd0: next_state = (start_if_store) ? 2'd1 : 2'd0 ;
		2'd1: next_state = (if_store_done) ? 2'd2 : 2'd1 ;
		2'd2: next_state = 2'd0 ;
		default: next_state = 2'd0 ;
	endcase	
end


always @( * ) begin
	if_store_busy = ( current_state == 2'd1) ? 1'd1 : 1'd0 ;
end
// always @(posedge clk ) begin
// 	if( reset )begin
// 		if_store_busy <= 1'd0 ;
// 	end
// 	else begin
// 		if_store_busy <= nxet_busy;
// 	end
// end

// always @(*) begin
// 	case (if_store_busy)
// 		1'd0: nxet_busy = ( start_if_store & (~if_store_done) )? 1'd1 : 1'd0 ;
// 		1'd1: nxet_busy = ( (~start_if_store) & (~if_store_done) )? 1'd0 : 1'd1 ;
// 		default: nxet_busy = 1'd0 ;
// 	endcase
// end

always @(*) begin
	// if_store_done = (if_store_busy) ? ( dr_num_dly0 == (FINAL_STRADDR_NUM-1) ) 	? 1'd1 : 1'd0 : 1'd0 ;
	
	if_store_done = ( ~if_store_busy ) ? 		1'd0:
				( dr_num_dly0 >= (FINAL_STRADDR_NUM-1) ) 	? 1'd1 : 1'd0  ;
end

// ============================================================================
// ===== generate valid in 
// ============================================================================


always @(posedge clk ) begin
	if(reset )begin
		ifstore_read_dout <= 1'd0;
	end		
	else begin
		if( if_store_busy ) begin
			if( ifstore_empty_n_din == 1'd1 )begin
				ifstore_read_dout <= 1'd1;
			end
			else begin
				ifstore_read_dout <= 1'd0;
			end
		end
		else begin
			ifstore_read_dout <= 1'd0;
		end
	end	
end



always@(*)begin
	valid_drdata = ifstore_read_dout & ifstore_empty_n_din;
end


always@( posedge clk )begin
	valid_drdata_dly1 <= valid_drdata;
	valid_drdata_dly2 <= valid_drdata_dly1;
	valid_drdata_dly3 <= valid_drdata_dly2;
	valid_drdata_dly4 <= valid_drdata_dly3;
	valid_drdata_dly5 <= valid_drdata_dly4;
	valid_drdata_dly6 <= valid_drdata_dly5;
	valid_drdata_dly7 <= valid_drdata_dly6;
	valid_drdata_dly8 <= valid_drdata_dly7;
	valid_drdata_dly9 <= valid_drdata_dly8;
end


always @(posedge clk ) begin
	if( reset )begin
		cnt00 <= 0;
	end
	else begin
		if ( valid_drdata )begin
			if( cnt00 >= FINAL_STRADDR_NUM-1 ) cnt00 <= 'd0;
			else cnt00 <= cnt00 +1 ;
		end
		else begin
			cnt00 <= cnt00 ;
		end
	end
end




// ============================================================================





endmodule