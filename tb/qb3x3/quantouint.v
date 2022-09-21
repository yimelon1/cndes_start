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
	if_sum_in,
	M0,
	index,
	z_of_weight,
	z3
);



	
endmodule