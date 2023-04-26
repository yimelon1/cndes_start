//========================================================================================================//
// Designer : Yen-Ren Hou
// Create   : 2022.11.25
// Ver      : 1.0
// Func     : re-quantize the 32bits MAC+Bias result to uint8 anwser 
//   take 32bits data per clk when valid_in = 1 from ru_get.v module .
//========================================================================================================//

module quan2uint8(
	clk				
	,	reset			
	,	m0_scale		
	,	index			
	,	z_of_weight		
	,	z3				
	,	valid_in		
	,	serial32_in		
	,	act_sum_in		
	,	q_out			
	,	valid_out		

);


//IO
input wire    		clk;
input wire     		reset;
input wire    		valid_in;
input wire   [31:0] serial32_in; // ifm x ker + bias
input wire   [31:0] act_sum_in;  // ifm
input wire   [31:0] m0_scale;    // m0
input wire   [7 :0] index;
input wire 	 [15:0] z_of_weight; // zw
input wire	 [7 :0] z3; 		 // zero weig h

output reg   [7 :0] q_out;
output reg  		valid_out;


// Difine
// wire   		 [31:0] act_zofw;
// wire  signed [31:0] before_m0;
// wire  signed [63:0] after_m0;
wire  signed [31:0] neg_result;
wire   		 [31:0] maskiflessthan;
wire   		 [31:0] threshold;
wire   		 [31:0] remainder;
wire  signed [31:0] maskifgreaterthan;
wire  signed [31:0] m_move_rounding;


reg   signed [31:0] act_zofw_reg ;
reg   signed [31:0] serial32_reg ;
reg   signed [63:0] saturatingrounding ;
reg   signed [31:0] bfm0_reg ;
reg   signed [63:0] after_m0_reg ;
reg   signed [31:0] m0_scale_reg ;
reg   signed [31:0] mask_index ;
reg   signed [31:0] add_z3;
reg   signed [7 :0] index_reg;
reg   signed [7 :0] z3_reg;
  
reg                	stage0_valid_in;
reg                	stage1_valid_in;
reg                	stage2_valid_in;
reg                	stage3_valid_in;
reg                	stage4_valid_in;

//operation
assign neg_result        = (after_m0_reg >= 0) ? (1<<30) : (1-(1<<30)); // nudge
assign maskiflessthan    = (saturatingrounding<0) ? 1 : 0;              // maskless
assign remainder         = saturatingrounding&mask_index;
assign threshold         = (mask_index>>1) + (maskiflessthan & 1);      // threshold
assign maskifgreaterthan = (remainder>threshold)?1:0;
assign m_move_rounding   = (saturatingrounding>>>index_reg)+(maskifgreaterthan&1);

//////////////////valid_in/////////////////////////////
always@( posedge clk )begin
	if( reset )begin
  		act_zofw_reg <= 'd0;
		m0_scale_reg <= 'd0;
		serial32_reg <= 'd0;
		index_reg <= 'd0;
		z3_reg <= 'd0;
	end
	else if(valid_in) begin
		act_zofw_reg <= act_sum_in * z_of_weight;	//放進訊號線再計算會多等一個CLK
		serial32_reg <= serial32_in;
		m0_scale_reg <= m0_scale;
		index_reg <= index;
		z3_reg <= z3;
	end
	else begin
		act_zofw_reg <= 'd0;
		serial32_reg <= 'd0;
		m0_scale_reg <= m0_scale_reg;
		index_reg <= index_reg;
		z3_reg <= z3_reg;
	end
end
////////////////////////////////////////////////////

always@( posedge clk )begin
	if( reset )begin
		bfm0_reg <= 'd0;
	end
	else begin
		bfm0_reg <= serial32_reg - act_zofw_reg;
	end
end

always@( posedge clk )begin
	if( reset )begin
		after_m0_reg <= 'd0;
	end
	else begin
		after_m0_reg <= m0_scale_reg * bfm0_reg;
	end
end
// saruratingrounding shift 31bit
always@( posedge clk or posedge reset ) begin
    if(reset) saturatingrounding <= 0;
    else      saturatingrounding <= (after_m0_reg + neg_result) >>> 31;
end

// mask (index-1位要留下來?)
always@( posedge clk )begin
	if(reset)  mask_index <= 0;
	else   	mask_index <= (1<<index_reg)-1;
end
//assign add_z3 = m_move_rounding+z3;
always@(posedge clk or posedge reset) begin
    if(reset) add_z3 <= 0;
    else      add_z3 <= m_move_rounding+z3_reg;
end

always@(*)
begin
    if(add_z3>255)     q_out = 255;
    else if (add_z3<0) q_out = 0;
    else               q_out = add_z3[7:0];
end

always@( posedge clk )begin
	stage0_valid_in <= valid_in;
	stage1_valid_in <= stage0_valid_in;
	stage2_valid_in <= stage1_valid_in;
	stage3_valid_in <= stage2_valid_in;
	stage4_valid_in <= stage3_valid_in;
end

always @(*) begin
	valid_out = stage4_valid_in ;
end

endmodule