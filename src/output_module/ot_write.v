// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.12.15
// Ver      : 1.0
// Func     : output write sram module
// ============================================================================

module ot_write #(
	parameter ADDR_FINAL = 20	// output length
)
(
	clk,
	reset,
	valid_in 	,
	data_in		,
	fifo_empty_n	,
	fifo_read 		,

	last		,

	addr_otsr	,
	cen_otsr	,
	wen_otsr	,
	data_for_sram	
);
	
	localparam SRAM_DATA_BITS = 64;
	localparam SRAM_ADDR_BITS = 10;
	// localparam ADDR_FINAL = 20;	// output length

//-----------------------------------------------------------------------------

	input clk		;
	input reset		;

	input valid_in 	;
	input [ SRAM_DATA_BITS-1 : 0 ]		data_in		;
	input	fifo_empty_n 	;
	output	fifo_read 	;


	output wire last ;

	output cen_otsr	;
	output wen_otsr	;
	output [ SRAM_ADDR_BITS-1 : 0 ]		addr_otsr		;
	output [ SRAM_DATA_BITS-1 : 0 ]		data_for_sram	;
//-----------------------------------------------------------------------------


reg [ SRAM_ADDR_BITS-1 : 0 ]		cnt_addr		;		
reg [ SRAM_ADDR_BITS-1 : 0 ]		cnt_addr2		;		
	

reg valid_in_dly0 ;
reg [64-1:0] data_in_dly0 ;


reg read ;


assign fifo_read = read ;


assign cen_otsr = ~valid_in_dly0 ;
assign wen_otsr = ~valid_in_dly0 ;
assign data_for_sram = ( valid_in_dly0 )? data_in_dly0 : 64'd0 ;
assign addr_otsr = cnt_addr ;

assign last = (  !valid_in_dly0 )? 1'd0 : 
				(cnt_addr == ADDR_FINAL-1) ? 1'd1 : 1'd0 ;


always @(posedge clk ) begin
	if( reset )
		read <= 1'd0 ;
	else 
		read <= fifo_empty_n ;
end

always @(posedge clk ) begin
	// valid_in_dly0 <= valid_in ;
	valid_in_dly0 <= fifo_empty_n & read ;
	data_in_dly0 <= data_in ;
end
//---- counter type1  cnt_addr < ADDR_FINAL-1--------------
always @(posedge clk ) begin
	if( reset )begin
		cnt_addr <= 10'd0 ;
	end 
	else begin
		if( valid_in_dly0 )begin
			if( cnt_addr < ADDR_FINAL-1 )begin
				cnt_addr <= cnt_addr + 1 ;
			end
			else begin
				cnt_addr <= 10'd0 ;
			end
		end
		else begin
			cnt_addr <= cnt_addr ;
		end
	end
end

//---- counter type2   cnt_addr >= ADDR_FINAL-1--------------
always @(posedge clk ) begin
	if( reset )begin
		cnt_addr2 <= 10'd0 ;
	end 
	else begin
		if( valid_in_dly0 )begin
			if( cnt_addr2 >= ADDR_FINAL-1 )begin
				cnt_addr2 <= 10'd0  ;
			end
			else begin
				cnt_addr2 <= cnt_addr2 +1 ;
			end
		end
		else begin
			cnt_addr2 <= cnt_addr2 ;
		end
	end
end




endmodule