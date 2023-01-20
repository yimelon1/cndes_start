// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.10.24
// Ver      : 1.0
// Func     : kernel sram control module
// ============================================================================

`define SHT_METHOD


module kersram_w (
	clk,
	reset,

	ker_store_data_din		,
	ker_store_empty_n_din	,
	ker_store_read_dout		,

	ker_store_done 		,
	ker_store_busy 		,
	start_ker_store		,

	//----------- kernel sram signal ---------------
//----ker_top sram write instance port start------ 
//----declare ker_top SRAM_0---------
    cen_kersr_0 ,
    wen_kersr_0 ,
    addr__kersr_0 ,
    din_kersr_0 ,
//----declare ker_top SRAM_1---------
    cen_kersr_1 ,
    wen_kersr_1 ,
    addr__kersr_1 ,
    din_kersr_1 ,
//----declare ker_top SRAM_2---------
    cen_kersr_2 ,
    wen_kersr_2 ,
    addr__kersr_2 ,
    din_kersr_2 ,
//----declare ker_top SRAM_3---------
    cen_kersr_3 ,
    wen_kersr_3 ,
    addr__kersr_3 ,
    din_kersr_3 ,
//----declare ker_top SRAM_4---------
    cen_kersr_4 ,
    wen_kersr_4 ,
    addr__kersr_4 ,
    din_kersr_4 ,
//----declare ker_top SRAM_5---------
    cen_kersr_5 ,
    wen_kersr_5 ,
    addr__kersr_5 ,
    din_kersr_5 ,
//----declare ker_top SRAM_6---------
    cen_kersr_6 ,
    wen_kersr_6 ,
    addr__kersr_6 ,
    din_kersr_6 ,
//----declare ker_top SRAM_7---------
    cen_kersr_7 ,
    wen_kersr_7 ,
    addr__kersr_7 ,
    din_kersr_7 
//----ker_top sram write instance port  end------ 


	
);


	input wire clk ;
	input wire reset ;
	
	input wire [ 63 : 0 ] ker_store_data_din	;
	input wire		ker_store_empty_n_din	;
	output reg		ker_store_read_dout		;

	output reg 		ker_store_done 		;
	output reg 		ker_store_busy 		;
	input wire 		start_ker_store		;

//----declare KER_SRAM start------ 
//----declare KER SRAM_0---------
    output reg cen_kersr_0 ;
    output reg wen_kersr_0 ;
    output reg [ 11 -1 : 0 ] addr__kersr_0 ;
    output reg [ 64 -1 : 0 ] din_kersr_0 ;
//----declare KER SRAM_1---------
    output reg cen_kersr_1 ;
    output reg wen_kersr_1 ;
    output reg [ 11 -1 : 0 ] addr__kersr_1 ;
    output reg [ 64 -1 : 0 ] din_kersr_1 ;
//----declare KER SRAM_2---------
    output reg cen_kersr_2 ;
    output reg wen_kersr_2 ;
    output reg [ 11 -1 : 0 ] addr__kersr_2 ;
    output reg [ 64 -1 : 0 ] din_kersr_2 ;
//----declare KER SRAM_3---------
    output reg cen_kersr_3 ;
    output reg wen_kersr_3 ;
    output reg [ 11 -1 : 0 ] addr__kersr_3 ;
    output reg [ 64 -1 : 0 ] din_kersr_3 ;
//----declare KER SRAM_4---------
    output reg cen_kersr_4 ;
    output reg wen_kersr_4 ;
    output reg [ 11 -1 : 0 ] addr__kersr_4 ;
    output reg [ 64 -1 : 0 ] din_kersr_4 ;
//----declare KER SRAM_5---------
    output reg cen_kersr_5 ;
    output reg wen_kersr_5 ;
    output reg [ 11 -1 : 0 ] addr__kersr_5 ;
    output reg [ 64 -1 : 0 ] din_kersr_5 ;
//----declare KER SRAM_6---------
    output reg cen_kersr_6 ;
    output reg wen_kersr_6 ;
    output reg [ 11 -1 : 0 ] addr__kersr_6 ;
    output reg [ 64 -1 : 0 ] din_kersr_6 ;
//----declare KER SRAM_7---------
    output reg cen_kersr_7 ;
    output reg wen_kersr_7 ;
    output reg [ 11 -1 : 0 ] addr__kersr_7 ;
    output reg [ 64 -1 : 0 ] din_kersr_7 ;
//----declare KER_SRAM end------ 


//---------- config parameter -----------------------
parameter ADDR_CNT_BITS = 11;
parameter KER_ST_LENGTH = 288;		// every layer has different kernel number and channels


reg [ 1 : 0 ] current_state ;
reg [ 1 : 0 ] next_state ;

//---------- done flag ------------------
reg flag_ker_store_done ;

reg en_kerst_addrct_0 ;
wire [ ADDR_CNT_BITS-1 : 0 ] addrct_0;

parameter ST_IDLE	= 4'd10;
parameter ST_K0 	= 4'd0;
parameter ST_K1 	= 4'd1;
parameter ST_K2 	= 4'd2;
parameter ST_K3 	= 4'd3;
parameter ST_K4 	= 4'd4;
parameter ST_K5 	= 4'd5;
parameter ST_K6 	= 4'd6;
parameter ST_K7 	= 4'd7;
parameter ST_DONE	= 4'd8;

reg [3:0] st_current_state ;
reg [3:0] st_next_state ;



`ifdef SHT_METHOD
	
	reg [3:0] st_state_sht_1 ;
	reg [3:0] st_state_sht_2 ;
	reg [3:0] st_state_sht_3 ;
	reg [3:0] st_state_sht_4 ;
	reg [3:0] st_state_sht_5 ;
	reg [3:0] st_state_sht_6 ;
	reg [3:0] st_state_sht_7 ;
	reg [3:0] st_state_sht_8 ;
	
	reg [ 63 : 0 ] st_data_sht_1 ;
	reg [ 63 : 0 ] st_data_sht_2 ;
	reg [ 63 : 0 ] st_data_sht_3 ;
	reg [ 63 : 0 ] st_data_sht_4 ;
	reg [ 63 : 0 ] st_data_sht_5 ;
	reg [ 63 : 0 ] st_data_sht_6 ;
	reg [ 63 : 0 ] st_data_sht_7 ;
	reg [ 63 : 0 ] st_data_sht_8 ;

	reg st_data_valid_1;
	reg st_data_valid_2;
	reg st_data_valid_3;
	reg st_data_valid_4;
	reg st_data_valid_5;
	reg st_data_valid_6;
	reg st_data_valid_7;
	reg st_data_valid_8;

	reg [ 10 : 0 ]st_datanum_1 ;
	reg [ 10 : 0 ]st_datanum_2 ;
	reg [ 10 : 0 ]st_datanum_3 ;
	reg [ 10 : 0 ]st_datanum_4 ;
	reg [ 10 : 0 ]st_datanum_5 ;
	reg [ 10 : 0 ]st_datanum_6 ;
	reg [ 10 : 0 ]st_datanum_7 ;
	reg [ 10 : 0 ]st_datanum_8 ;
`endif 










always @(posedge clk ) begin
	if( reset )begin
		st_current_state <= ST_IDLE ;
	end
	else begin
		st_current_state <= st_next_state ;
	end
end
always @(*) begin
	case (st_current_state) 
		ST_IDLE	: st_next_state = ( current_state == 2'd1 )? ST_K0 : ST_IDLE ;
		ST_K0 	: st_next_state = ( addrct_0 == KER_ST_LENGTH-1 )? ST_K1 : ST_K0 ;
		ST_K1 	: st_next_state = ( addrct_0 == KER_ST_LENGTH-1 )? ST_K2 : ST_K1 ;
		ST_K2 	: st_next_state = ( addrct_0 == KER_ST_LENGTH-1 )? ST_K3 : ST_K2 ;
		ST_K3 	: st_next_state = ( addrct_0 == KER_ST_LENGTH-1 )? ST_K4 : ST_K3 ;
		ST_K4 	: st_next_state = ( addrct_0 == KER_ST_LENGTH-1 )? ST_K5 : ST_K4 ;
		ST_K5 	: st_next_state = ( addrct_0 == KER_ST_LENGTH-1 )? ST_K6 : ST_K5 ;
		ST_K6 	: st_next_state = ( addrct_0 == KER_ST_LENGTH-1 )? ST_K7 : ST_K6 ;
		ST_K7 	: st_next_state = ( addrct_0 == KER_ST_LENGTH-1 )? ST_DONE : ST_K7 ;
		ST_DONE	: st_next_state = ST_IDLE;
		default: st_next_state = ST_IDLE;
	endcase
end


// ============================================================================

count_yi_v3 #(    .BITS_OF_END_NUMBER( ADDR_CNT_BITS  ) 
    )cnt_staddr(.clk ( clk ), .reset ( reset ), .enable ( en_kerst_addrct_0 ), .cnt_q ( addrct_0 ),	
    .final_number(	KER_ST_LENGTH	)	// it will count to final_num-1 then goes to zero
);

always@( * )begin
	en_kerst_addrct_0 = ker_store_empty_n_din & ker_store_read_dout ;
end


//-----------   kernel store FSM done signal -----------------
always @(*) begin
	flag_ker_store_done = (st_current_state== ST_DONE) ? 1'd1 : 1'd0 ;
end



`ifdef SHT_METHOD

	always @(posedge clk ) begin
		st_state_sht_1 <= st_current_state ;
		st_state_sht_2 <= st_state_sht_1 ;
		st_state_sht_3 <= st_state_sht_2 ;
		st_state_sht_4 <= st_state_sht_3 ;
		st_state_sht_5 <= st_state_sht_4 ;
		st_state_sht_6 <= st_state_sht_5 ;
		st_state_sht_7 <= st_state_sht_6 ;
		st_state_sht_8 <= st_state_sht_7 ;
	end

	always @(posedge clk ) begin
		st_data_sht_1 <= ker_store_data_din ;
		st_data_sht_2 <= st_data_sht_1 ;
		st_data_sht_3 <= st_data_sht_2 ;
		st_data_sht_4 <= st_data_sht_3 ;
		st_data_sht_5 <= st_data_sht_4 ;
		st_data_sht_6 <= st_data_sht_5 ;
		st_data_sht_7 <= st_data_sht_6 ;
		st_data_sht_8 <= st_data_sht_7 ;
	end

	always @(posedge clk ) begin
		st_data_valid_1 <= en_kerst_addrct_0 ;
		st_data_valid_2 <= st_data_valid_1 ;
		st_data_valid_3 <= st_data_valid_2 ;
		st_data_valid_4 <= st_data_valid_3 ;
		st_data_valid_5 <= st_data_valid_4 ;
		st_data_valid_6 <= st_data_valid_5 ;
		st_data_valid_7 <= st_data_valid_6 ;
		st_data_valid_8 <= st_data_valid_7 ;
	end

	always @(posedge clk ) begin
		st_datanum_1 <= addrct_0 ;
		st_datanum_2 <= st_datanum_1 ;
		st_datanum_3 <= st_datanum_2 ;
		st_datanum_4 <= st_datanum_3 ;
		st_datanum_5 <= st_datanum_4 ;
		st_datanum_6 <= st_datanum_5 ;
		st_datanum_7 <= st_datanum_6 ;
		st_datanum_8 <= st_datanum_7 ;
	end

	always @(*) begin
		cen_kersr_0 = ( (	st_current_state	== ST_K0) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		cen_kersr_1 = ( (	st_state_sht_1	== ST_K1) & st_data_valid_1 ) ? 1'd0 : 1'd1 ;
		cen_kersr_2 = ( (	st_state_sht_2	== ST_K2) & st_data_valid_2 ) ? 1'd0 : 1'd1 ;
		cen_kersr_3 = ( (	st_state_sht_3	== ST_K3) & st_data_valid_3 ) ? 1'd0 : 1'd1 ;
		cen_kersr_4 = ( (	st_state_sht_4	== ST_K4) & st_data_valid_4 ) ? 1'd0 : 1'd1 ;
		cen_kersr_5 = ( (	st_state_sht_5	== ST_K5) & st_data_valid_5 ) ? 1'd0 : 1'd1 ;
		cen_kersr_6 = ( (	st_state_sht_6	== ST_K6) & st_data_valid_6 ) ? 1'd0 : 1'd1 ;
		cen_kersr_7 = ( (	st_state_sht_7	== ST_K7) & st_data_valid_7 ) ? 1'd0 : 1'd1 ;
		wen_kersr_0 = cen_kersr_0 ;
		wen_kersr_1 = cen_kersr_1 ;
		wen_kersr_2 = cen_kersr_2 ;
		wen_kersr_3 = cen_kersr_3 ;
		wen_kersr_4 = cen_kersr_4 ;
		wen_kersr_5 = cen_kersr_5 ;
		wen_kersr_6 = cen_kersr_6 ;
		wen_kersr_7 = cen_kersr_7 ;
	end

	always @(*) begin
		addr__kersr_0 = (	st_current_state	== ST_K0) ? addrct_0 : 'd0 ;
		addr__kersr_1 = (	st_state_sht_1	== ST_K1) ? st_datanum_1 : 'd0 ;
		addr__kersr_2 = (	st_state_sht_2	== ST_K2) ? st_datanum_2 : 'd0 ;
		addr__kersr_3 = (	st_state_sht_3	== ST_K3) ? st_datanum_3 : 'd0 ;
		addr__kersr_4 = (	st_state_sht_4	== ST_K4) ? st_datanum_4 : 'd0 ;
		addr__kersr_5 = (	st_state_sht_5	== ST_K5) ? st_datanum_5 : 'd0 ;
		addr__kersr_6 = (	st_state_sht_6	== ST_K6) ? st_datanum_6 : 'd0 ;
		addr__kersr_7 = (	st_state_sht_7	== ST_K7) ? st_datanum_7 : 'd0 ;
		din_kersr_0 = ker_store_data_din ;
		din_kersr_1 = 	st_data_sht_1	;
		din_kersr_2 = 	st_data_sht_2	;
		din_kersr_3 = 	st_data_sht_3	;
		din_kersr_4 = 	st_data_sht_4	;
		din_kersr_5 = 	st_data_sht_5	;
		din_kersr_6 = 	st_data_sht_6	;
		din_kersr_7 = 	st_data_sht_7	;
	end

`else 
	//-------  broatcast --------------------
	always @(*) begin
		cen_kersr_0 = ( (st_current_state== ST_K0) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		cen_kersr_1 = ( (st_current_state== ST_K1) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		cen_kersr_2 = ( (st_current_state== ST_K2) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		cen_kersr_3 = ( (st_current_state== ST_K3) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		cen_kersr_4 = ( (st_current_state== ST_K4) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		cen_kersr_5 = ( (st_current_state== ST_K5) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		cen_kersr_6 = ( (st_current_state== ST_K6) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		cen_kersr_7 = ( (st_current_state== ST_K7) & en_kerst_addrct_0 ) ? 1'd0 : 1'd1 ;
		wen_kersr_0 = cen_kersr_0 ;
		wen_kersr_1 = cen_kersr_1 ;
		wen_kersr_2 = cen_kersr_2 ;
		wen_kersr_3 = cen_kersr_3 ;
		wen_kersr_4 = cen_kersr_4 ;
		wen_kersr_5 = cen_kersr_5 ;
		wen_kersr_6 = cen_kersr_6 ;
		wen_kersr_7 = cen_kersr_7 ;
	end

	always @(*) begin
		addr__kersr_0 = (st_current_state== ST_K0) ? addrct_0 : 'd0 ;
		addr__kersr_1 = (st_current_state== ST_K1) ? addrct_0 : 'd0 ;
		addr__kersr_2 = (st_current_state== ST_K2) ? addrct_0 : 'd0 ;
		addr__kersr_3 = (st_current_state== ST_K3) ? addrct_0 : 'd0 ;
		addr__kersr_4 = (st_current_state== ST_K4) ? addrct_0 : 'd0 ;
		addr__kersr_5 = (st_current_state== ST_K5) ? addrct_0 : 'd0 ;
		addr__kersr_6 = (st_current_state== ST_K6) ? addrct_0 : 'd0 ;
		addr__kersr_7 = (st_current_state== ST_K7) ? addrct_0 : 'd0 ;
		din_kersr_0 = ker_store_data_din ;
		din_kersr_1 = ker_store_data_din ;
		din_kersr_2 = ker_store_data_din ;
		din_kersr_3 = ker_store_data_din ;
		din_kersr_4 = ker_store_data_din ;
		din_kersr_5 = ker_store_data_din ;
		din_kersr_6 = ker_store_data_din ;
		din_kersr_7 = ker_store_data_din ;
	end

`endif 



// ============================================================================
// ===== busy & done
// ============================================================================
always @(posedge clk ) begin
	if( reset )begin
		current_state <= 2'd0;
	end
	else begin
		current_state <= next_state	;
	end
end

always @(*) begin
	case (current_state)
		2'd0 : next_state = ( start_ker_store ) ? 2'd1 : 2'd0 ;
		2'd1 : next_state = ( ker_store_done ) ?	2'd2 : 2'd1  ;
		2'd2 : next_state = 2'd0 ;

		default: next_state = 2'd0;
	endcase
end

always @(*) begin
	ker_store_busy = ( current_state == 2'd1 ) ? 1'd1 : 1'd0 ;
end

always @(posedge clk ) begin
	if( reset )begin
		ker_store_done <= 1'd0;
	end
	else begin
		if( ker_store_busy) begin
			if( flag_ker_store_done )begin
				ker_store_done <= 1'd1;
			end
			else begin
				ker_store_done <= 1'd0;
			end
		end
		else begin
			ker_store_done <= 1'd0;
		end
	end
end



// ============================================================================
// ============= kernel store read fifo =======================================
// ============================================================================

always @(posedge clk ) begin
	if( reset )begin
		ker_store_read_dout <= 1'd0 ;
	end
	else begin
		if( ker_store_busy && (st_current_state != ST_IDLE) )begin
			if( ker_store_empty_n_din == 1'd1 )begin
				ker_store_read_dout <= 1'd1 ;
			end
			else begin
				ker_store_read_dout <= 1'd0;
			end
		end
		else begin
			ker_store_read_dout <= 1'd0;
		end
	end
end



endmodule