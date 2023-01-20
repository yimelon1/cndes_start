// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.09.08
// Ver      : 1.0
// Func     : to get output result from each PE in ROW_n. and should be serial
// 		sent to quantization module.
// ============================================================================


module getpe_result #(
	parameter INV_BITS = 1 ,
	parameter QOUT_BITS = 32
) (
	clk ,
	reset ,
	pe0_result ,
	pe1_result ,
	pe2_result ,
	pe3_result ,
	pe4_result ,
	pe5_result ,
	pe6_result ,
	pe7_result ,
	valid_out ,
	serial_result 
);
	
input wire			clk 		;
input wire			reset 		;
input wire	[ QOUT_BITS + INV_BITS - 1 : 0 ]		pe0_result 		;
input wire	[ QOUT_BITS + INV_BITS - 1 : 0 ]		pe1_result 		;
input wire	[ QOUT_BITS + INV_BITS - 1 : 0 ]		pe2_result 		;
input wire	[ QOUT_BITS + INV_BITS - 1 : 0 ]		pe3_result 		;
input wire	[ QOUT_BITS + INV_BITS - 1 : 0 ]		pe4_result 		;
input wire	[ QOUT_BITS + INV_BITS - 1 : 0 ]		pe5_result 		;
input wire	[ QOUT_BITS + INV_BITS - 1 : 0 ]		pe6_result 		;
input wire	[ QOUT_BITS + INV_BITS - 1 : 0 ]		pe7_result 		;

output reg						valid_out 		;
output reg	[ QOUT_BITS - 1: 0 ]			serial_result		;

wire [ 7:0 ] valid_in ;
reg signed [ 31 : 0 ] data_choose ;



assign valid_in = { 
	pe0_result[ QOUT_BITS + INV_BITS-1  -: 1 ],
	pe1_result[ QOUT_BITS + INV_BITS-1  -: 1 ],
	pe2_result[ QOUT_BITS + INV_BITS-1  -: 1 ],
	pe3_result[ QOUT_BITS + INV_BITS-1  -: 1 ],
	pe4_result[ QOUT_BITS + INV_BITS-1  -: 1 ],
	pe5_result[ QOUT_BITS + INV_BITS-1  -: 1 ],
	pe6_result[ QOUT_BITS + INV_BITS-1  -: 1 ],
	pe7_result[ QOUT_BITS + INV_BITS-1  -: 1 ]
	}	;


always@(*)begin
	case (valid_in)
		8'b1000_0000: data_choose = { pe0_result[ QOUT_BITS -1  -: 32 ]};
		8'b0100_0000: data_choose = { pe1_result[ QOUT_BITS -1  -: 32 ]};
		8'b0010_0000: data_choose = { pe2_result[ QOUT_BITS -1  -: 32 ]};
		8'b0001_0000: data_choose = { pe3_result[ QOUT_BITS -1  -: 32 ]};
		8'b0000_1000: data_choose = { pe4_result[ QOUT_BITS -1  -: 32 ]};
		8'b0000_0100: data_choose = { pe5_result[ QOUT_BITS -1  -: 32 ]};
		8'b0000_0010: data_choose = { pe6_result[ QOUT_BITS -1  -: 32 ]};
		8'b0000_0001: data_choose = { pe7_result[ QOUT_BITS -1  -: 32 ]};
		default: data_choose = 32'd0 ;
	endcase
end

always@( posedge clk )begin
	if(reset)begin
		serial_result <= 32'd0 ;
		valid_out <= 0;
	end
	else begin
		if(  valid_in !== 8'd0 )begin
			serial_result <= data_choose ;
			valid_out <= 1;
		end
		else begin
			serial_result <= 32'd0;
			valid_out <= 0;
		end
	end
end





endmodule