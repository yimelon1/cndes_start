// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2023.03.06
// Ver      : 1.0
// Func     : multiplexer for every quant2buf 64 bits data, and choose 1 sent to ot_fifo
// ============================================================================
module ot_bitmux64 
#(
	parameter TBITS = 64 
	,	PEBLKROW_NUM = 8
)(
	clk 	
	,	reset 				
	,	valid_din 			
	,	data_din			
	,	valid_dout	
	,	result_dout	
);
	

//==============================================================================
//========    I/O Signal Declare    ========
//==============================================================================

input wire clk		;
input wire reset		;

input wire [ PEBLKROW_NUM-1:0]				valid_din 		;
input wire [ PEBLKROW_NUM*TBITS-1 : 0 ]		data_din		;
output wire 								valid_dout	;
output wire [TBITS-1 : 0]					result_dout	;
//-----------------------------------------------------------------------------

reg [TBITS-1 : 0]	bit64_result ;
reg					bit64_valid ;

assign valid_dout		=	bit64_valid		;
assign result_dout		=	bit64_result	;

always @(*) begin
	case (valid_din)
		8'b0000_0001:  bit64_result = data_din[ ( (PEBLKROW_NUM-7) *TBITS-1) -: TBITS ]	;
		8'b0000_0010:  bit64_result = data_din[ ( (PEBLKROW_NUM-6) *TBITS-1) -: TBITS ]	;
		8'b0000_0100:  bit64_result = data_din[ ( (PEBLKROW_NUM-5) *TBITS-1) -: TBITS ]	;
		8'b0000_1000:  bit64_result = data_din[ ( (PEBLKROW_NUM-4) *TBITS-1) -: TBITS ]	;
		8'b0001_0000:  bit64_result = data_din[ ( (PEBLKROW_NUM-3) *TBITS-1) -: TBITS ]	;
		8'b0010_0000:  bit64_result = data_din[ ( (PEBLKROW_NUM-2) *TBITS-1) -: TBITS ]	;
		8'b0100_0000:  bit64_result = data_din[ ( (PEBLKROW_NUM-1) *TBITS-1) -: TBITS ]	;
		8'b1000_0000:  bit64_result = data_din[ ( (PEBLKROW_NUM-0) *TBITS-1) -: TBITS ]	;
		default: bit64_result = 64'd0 ;
	endcase
end
always @(*) begin
	case (valid_din)
		8'b0000_0001:  bit64_valid = 1'd1 ;
		8'b0000_0010:  bit64_valid = 1'd1 ;
		8'b0000_0100:  bit64_valid = 1'd1 ;
		8'b0000_1000:  bit64_valid = 1'd1 ;
		8'b0001_0000:  bit64_valid = 1'd1 ;
		8'b0010_0000:  bit64_valid = 1'd1 ;
		8'b0100_0000:  bit64_valid = 1'd1 ;
		8'b1000_0000:  bit64_valid = 1'd1 ;
		default: bit64_valid = 1'd0 ;
	endcase
end


endmodule