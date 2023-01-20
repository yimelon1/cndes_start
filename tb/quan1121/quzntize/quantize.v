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
	z3,
	q_out,
	q_valid,
);



input wire				clk			;
input wire				reset		;
input wire				valid_in	;
input wire				q_valid		;
input wire  [ 31: 0 ]	serial32_in	;	// ifm x ker + bias
input wire  [ 31: 0 ]	act_sum_in	;	// ifm
input wire  [ 31: 0 ]	m0_scale	;	// m0
input wire  [ 7 : 0 ]	index		;
input wire	[ 15: 0 ]	z_of_weight	;	// zw
input wire	[ 7 : 0 ]	z3			;	// zero weight 

output reg [  7: 0 ] q_out;





// wire   [31:0] mask;
wire   [31:0] act_zofw;
wire  signed [31:0] before_m0;
wire  signed [63:0] after_m0;
wire  signed [31:0] neg_result;
wire   [31:0] maskiflessthan;
wire   [31:0] threshold;
wire   [31:0] remainder;
wire  signed [31:0] maskifgreaterthan;
wire  signed [31:0] m_move_rounding;


reg signed [ 31: 0 ] act_zofw_reg ;
reg signed [ 31: 0 ] serial32_reg ;
reg signed [ 63: 0 ] saturatingrounding ;
reg signed [ 31: 0 ] bfm0_reg ;
reg signed [ 63: 0 ] after_m0_reg ;
reg signed [ 31: 0 ] m0_scale_reg ;
reg signed [ 31: 0 ] mask_index ;
reg signed [ 31: 0 ] add_z3;


// reg mutipl_M_valid;
// reg saturatingrounding_valid;
// output reg q3_valid;




assign act_zofw 	  	 = act_sum_in * z_of_weight ;	  				 // ifm x zw
assign before_m0 	  	 = serial32_reg - act_zofw_reg ; 				 // ifm x ker + bias - ifm x zw = conv
assign after_m0		  	 = m0_scale_reg * bfm0_reg ;		  				 // conv x m0  	
assign neg_result	  	 = (after_m0_reg >= 0) ? (1<<30) : (1-(1<<30));  // nudge
assign maskiflessthan 	 = (saturatingrounding<0) ? 1 : 0; 			     // maskless
assign remainder 	  	 = saturatingrounding&mask_index;
assign threshold	  	 = (mask_index>>1) + (maskiflessthan & 1);		 // threshold
assign maskifgreaterthan = (remainder>threshold)?1:0;
assign m_move_rounding	 = (saturatingrounding>>>index)+(maskifgreaterthan&1);



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

always@( posedge clk )begin
	if( reset )begin
		bfm0_reg <= 'd0 ;
	end
	else begin
		bfm0_reg <= before_m0 ;
	end
end

always@( posedge clk )begin
	if( reset )begin
		after_m0_reg <= 'd0 ;
	end
	else begin
		after_m0_reg <= after_m0 ;
	end
end
// saruratingrounding shift 31bit
always@( posedge clk or posedge reset ) begin
    if(reset) saturatingrounding <= 0 ;
    else      saturatingrounding <= ( after_m0_reg + neg_result ) >>> 31;
end

// mask
always@( posedge clk )begin
	if(reset) 	mask_index <= 0;
	else 		mask_index <= (1<<index)-1;
end
//assign add_z3 = m_move_rounding+z3;
always@(posedge clk or posedge reset) begin
    if(reset) add_z3<=0;
    else      add_z3<= m_move_rounding+z3;
end

always@(*)
begin
    if(add_z3>255)     q_out =     	   255;
    else if (add_z3<0) q_out =       	 0;
    else               q_out = add_z3[7:0];
end


endmodule