//========================================================================================================//
// Designer : Yi_Yuan Chen
// Create   : 2022.09.19
// Ver      : 1.0
// Func     : re-quantize the 32bits MAC+Bias result to uint8 anwser 
// 		take 32bits data per clk when valid_in = 1 from ru_get.v module .
//========================================================================================================//

module quan2uint8 (
	clk,
	reset,
	valid_in,
	serial32_in,
	act_sum_in,
	m0_scale,
	index,
	z_of_weight,
	z3
);

input wire	clk		;
input wire	reset	;
input wire	valid_in	;
input wire [ 31 : 0]	serial32_in	;
input wire [ 31 : 0]	act_sum_in	;
input wire [ 31 : 0]	m0_scale	;
input wire [ 7 : 0 ]	index		;
input wire	[ 15: 0 ]	z_of_weight	;
input wire	[ 7 : 0 ]	z3			;

assign act_zofw 	= act_sum_in * z_of_weight ;
assign before_m0 	= serial32_reg - act_zofw_reg ;
assign after_m0		= m0_scale * bfm0_reg ;
assign neg_result	= (after_m0_reg >= 0 )? (1<<30) : (1-(1<<30));
assign maskiflessthan=(saturatingrounding<0)? 1 : 0;

reg signed [ 31: 0 ] act_zofw_reg ;
reg signed [ 31: 0 ] serial32_reg ;
reg signed [ 31: 0 ] saturatingrounding ;


always@( posedge clk )begin
	if( reset )begin
		m0_scale_reg <= 'd0 ;
	end
	else begin
		m0_scale_reg <= m0_scale ;
	end
end

always@( posedge clk )begin
	if( reset )begin
		act_zofw_reg <= 'd0 ;
	end
	else begin
		act_zofw_reg <= act_zofw ;
	end
end

always@( posedge clk )begin
	if( reset )begin
		serial32_reg <= 'd0 ;
	end
	else begin
		serial32_reg <= serial32_in ;
	end
end

always@(posedge clk )begin
	if( reset )begin
		bfm0_reg <= 'd0 ;
	end
	else begin
		bfm0_reg <= before_m0 ;
	end
end

always@(posedge clk )begin
	if( reset )begin
		after_m0_reg <= 'd0 ;
	end
	else begin
		after_m0_reg <= after_m0 ;
	end
end

always@(posedge clk or posedge reset) begin
    if(reset) saturatingrounding <= 0 ;
    else      saturatingrounding <= ( after_m0_reg + neg_result ) >>> 31 ;
end

always@( posedge clk )begin
	if(reset) 	mask_index <= 0;
	else 		mask_index <= (1<<index)-1;
end





endmodule