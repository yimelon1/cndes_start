
// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.09.19
// Ver      : 3.0
// Func     : PE of DLA, using adder tree structure compute 8 element each rounds
// throught every stage, more one adder for bias addition
// and use shift reg for bias data alive till stage6.
// because quantization so need input feature sum
// ============================================================================


module pe_8e #(
	parameter ELE_BITS = 8 ,	// PE each pixel bits
	parameter OUT_BITS = 32,
	parameter BIAS_BITS = 32
)(
	input clk ,
	input reset ,
	input [ELE_BITS-1 : 0 ] act_0 ,
	input [ELE_BITS-1 : 0 ] act_1 ,
	input [ELE_BITS-1 : 0 ] act_2 ,
	input [ELE_BITS-1 : 0 ] act_3 ,
	input [ELE_BITS-1 : 0 ] act_4 ,
	input [ELE_BITS-1 : 0 ] act_5 ,
	input [ELE_BITS-1 : 0 ] act_6 ,
	input [ELE_BITS-1 : 0 ] act_7 ,
	input valid_in ,
	input final_in ,
	//---- kernel ----//
	input [ELE_BITS-1 : 0 ] ker_0 ,
	input [ELE_BITS-1 : 0 ] ker_1 ,
	input [ELE_BITS-1 : 0 ] ker_2 ,
	input [ELE_BITS-1 : 0 ] ker_3 ,
	input [ELE_BITS-1 : 0 ] ker_4 ,
	input [ELE_BITS-1 : 0 ] ker_5 ,
	input [ELE_BITS-1 : 0 ] ker_6 ,
	input [ELE_BITS-1 : 0 ] ker_7 ,
	//---- bias ----//
	input wire signed [BIAS_BITS-1 : 0 ] bias_in ,
	input wire [ 4-1 : 0 ]bias_offset,
	//-----------------------------------------//
	output reg valid_out ,
	output reg signed  [OUT_BITS-1 : 0 ] outmacb_sum ,
	output reg signed  [OUT_BITS-1 : 0 ] outact_sum

);

//-------------Declare-----------------------------------------//
reg signed [BIAS_BITS-1 : 0] stage0_bias_in ;
reg signed [BIAS_BITS-1 : 0] stage1_bias_in ;
reg signed [BIAS_BITS-1 : 0] stage2_bias_in ;
reg signed [BIAS_BITS-1 : 0] stage3_bias_in ;
reg signed [BIAS_BITS-1 : 0] stage4_bias_in ;
reg signed [BIAS_BITS-1 : 0] stage5_bias_in ;
reg signed [BIAS_BITS-1 : 0] stage6_bias_in ;
reg signed [BIAS_BITS-1 : 0] stage7_bias_in ;

reg [ 4-1 : 0] stage0_bias_offset ;
reg [ 4-1 : 0] stage1_bias_offset ;
reg [ 4-1 : 0] stage2_bias_offset ;
reg [ 4-1 : 0] stage3_bias_offset ;
reg [ 4-1 : 0] stage4_bias_offset ;
reg [ 4-1 : 0] stage5_bias_offset ;
reg [ 4-1 : 0] stage6_bias_offset ;
reg [ 4-1 : 0] stage7_bias_offset ;

reg signed [ 31 : 0 ] bias_sum ;


//-- stage 0--//
reg		[ELE_BITS-1 : 0 ] stage0_act_0 ;
reg		[ELE_BITS-1 : 0 ] stage0_act_1 ;
reg		[ELE_BITS-1 : 0 ] stage0_act_2 ;
reg		[ELE_BITS-1 : 0 ] stage0_act_3 ;
reg		[ELE_BITS-1 : 0 ] stage0_act_4 ;
reg		[ELE_BITS-1 : 0 ] stage0_act_5 ;
reg		[ELE_BITS-1 : 0 ] stage0_act_6 ;
reg		[ELE_BITS-1 : 0 ] stage0_act_7 ;

reg		[ELE_BITS-1 : 0 ] stage0_ker_0 ;
reg		[ELE_BITS-1 : 0 ] stage0_ker_1 ;
reg		[ELE_BITS-1 : 0 ] stage0_ker_2 ;
reg		[ELE_BITS-1 : 0 ] stage0_ker_3 ;
reg		[ELE_BITS-1 : 0 ] stage0_ker_4 ;
reg		[ELE_BITS-1 : 0 ] stage0_ker_5 ;
reg		[ELE_BITS-1 : 0 ] stage0_ker_6 ;
reg		[ELE_BITS-1 : 0 ] stage0_ker_7 ;

reg	stage0_final_in	;
reg	stage1_final_in	;
reg	stage2_final_in	;
reg	stage3_final_in	;
reg	stage4_final_in	;
reg	stage5_final_in	;
reg	stage6_final_in	;
reg	stage7_final_in	;

reg 	stage0_valid_in	;
reg 	stage1_valid_in	;
reg 	stage2_valid_in	;
reg 	stage3_valid_in	;
reg 	stage4_valid_in	;
reg 	stage5_valid_in	;
reg 	stage6_valid_in	;
reg 	stage7_valid_in	;



reg signed [ 2*ELE_BITS+1  : 0] stage1_multsigned_pd_0 ;
reg signed [ 2*ELE_BITS+1  : 0] stage1_multsigned_pd_1 ;
reg signed [ 2*ELE_BITS+1  : 0] stage1_multsigned_pd_2 ;
reg signed [ 2*ELE_BITS+1  : 0] stage1_multsigned_pd_3 ;
reg signed [ 2*ELE_BITS+1  : 0] stage1_multsigned_pd_4 ;
reg signed [ 2*ELE_BITS+1  : 0] stage1_multsigned_pd_5 ;
reg signed [ 2*ELE_BITS+1  : 0] stage1_multsigned_pd_6 ;
reg signed [ 2*ELE_BITS+1  : 0] stage1_multsigned_pd_7 ;


//--Declare stage 2--//
reg signed [ 2*ELE_BITS  : 0] stage2_addmult_0 ;
reg signed [ 2*ELE_BITS  : 0] stage2_addmult_1 ;
reg signed [ 2*ELE_BITS  : 0] stage2_addmult_2 ;
reg signed [ 2*ELE_BITS  : 0] stage2_addmult_3 ;
//--Declare stage 3--//
reg signed [ 2*ELE_BITS+1  : 0] stage3_add2_0 ;
reg signed [ 2*ELE_BITS+1  : 0] stage3_add2_1 ;


//--Declare stage 4--//
reg signed [ OUT_BITS-1  : 0] stage4_addend_0 ;
//--Declare stage 5--//
reg signed [ OUT_BITS-1  : 0] stage5_acc_0 ;
//--Declare stage 6--//
reg signed [ OUT_BITS-1  : 0] stage6_acc_0 ;

//--- act unsigned add reg ----
reg  [ ELE_BITS : 0] stage1_addact_ru_0	;
reg  [ ELE_BITS : 0] stage1_addact_ru_1	;
reg  [ ELE_BITS : 0] stage1_addact_ru_2	;
reg  [ ELE_BITS : 0] stage1_addact_ru_3	;

reg  [ ELE_BITS+1 : 0] stage2_addact_ru_0	;
reg  [ ELE_BITS+1 : 0] stage2_addact_ru_1	;

reg  [ ELE_BITS+2 : 0] stage3_addact_ru_0	;

reg  [ 17 : 0] stage4_addact_acc_0 ;

reg  [ 17 : 0] stage5_addact_acc_0 ;
reg  [ 17 : 0] stage6_addact_acc_0 ;


//-- stage 0 ----
// check input valid  stage0_valid_in
always@( posedge clk )begin
	if ( stage0_valid_in )begin
		stage0_act_0 <= act_0	;
		stage0_act_1 <= act_1	;
		stage0_act_2 <= act_2	;
		stage0_act_3 <= act_3	;
		stage0_act_4 <= act_4	;
		stage0_act_5 <= act_5	;
		stage0_act_6 <= act_6	;
		stage0_act_7 <= act_7	;
	end
	else begin
		stage0_act_0 <= 'd0	;
		stage0_act_1 <= 'd0	;
		stage0_act_2 <= 'd0	;
		stage0_act_3 <= 'd0	;
		stage0_act_4 <= 'd0	;
		stage0_act_5 <= 'd0	;
		stage0_act_6 <= 'd0	;
		stage0_act_7 <= 'd0	;
	end
end

always@( posedge clk )begin

	if ( stage0_valid_in )begin
		stage0_ker_0 <= ker_0	;
		stage0_ker_1 <= ker_1	;
		stage0_ker_2 <= ker_2	;
		stage0_ker_3 <= ker_3	;
		stage0_ker_4 <= ker_4	;
		stage0_ker_5 <= ker_5	;
		stage0_ker_6 <= ker_6	;
		stage0_ker_7 <= ker_7	;
	end
	else begin
		stage0_ker_0 <= 'd0	;
		stage0_ker_1 <= 'd0	;
		stage0_ker_2 <= 'd0	;
		stage0_ker_3 <= 'd0	;
		stage0_ker_4 <= 'd0	;
		stage0_ker_5 <= 'd0	;
		stage0_ker_6 <= 'd0	;
		stage0_ker_7 <= 'd0	;
	end

end



//----------- stage 1 -----------
// signed multiply
always@( posedge clk )begin
	if( reset )begin
		stage1_multsigned_pd_0 <= 'd0 ;
		stage1_multsigned_pd_1 <= 'd0 ;
		stage1_multsigned_pd_2 <= 'd0 ;
		stage1_multsigned_pd_3 <= 'd0 ;
		stage1_multsigned_pd_4 <= 'd0 ;
		stage1_multsigned_pd_5 <= 'd0 ;
		stage1_multsigned_pd_6 <= 'd0 ;
		stage1_multsigned_pd_7 <= 'd0 ;
	end
	else begin
		stage1_multsigned_pd_0 <= $signed( {1'd0 , stage0_act_0} ) * $signed( {1'd0 , stage0_ker_0} )	;
		stage1_multsigned_pd_1 <= $signed( {1'd0 , stage0_act_1} ) * $signed( {1'd0 , stage0_ker_1} )	;
		stage1_multsigned_pd_2 <= $signed( {1'd0 , stage0_act_2} ) * $signed( {1'd0 , stage0_ker_2} )	;
		stage1_multsigned_pd_3 <= $signed( {1'd0 , stage0_act_3} ) * $signed( {1'd0 , stage0_ker_3} )	;
		stage1_multsigned_pd_4 <= $signed( {1'd0 , stage0_act_4} ) * $signed( {1'd0 , stage0_ker_4} )	;
		stage1_multsigned_pd_5 <= $signed( {1'd0 , stage0_act_5} ) * $signed( {1'd0 , stage0_ker_5} )	;
		stage1_multsigned_pd_6 <= $signed( {1'd0 , stage0_act_6} ) * $signed( {1'd0 , stage0_ker_6} )	;
		stage1_multsigned_pd_7 <= $signed( {1'd0 , stage0_act_7} ) * $signed( {1'd0 , stage0_ker_7} )	;
	end

end



// tree signed addition with unsigned number activation
always@(posedge clk )begin
	if(reset)begin
		stage1_addact_ru_0 <= 'd0 ;
		stage1_addact_ru_1 <= 'd0 ;
		stage1_addact_ru_2 <= 'd0 ;
		stage1_addact_ru_3 <= 'd0 ;

	end
	else begin
		stage1_addact_ru_0 <= stage0_act_0 + stage0_act_1	;
		stage1_addact_ru_1 <= stage0_act_2 + stage0_act_3	;
		stage1_addact_ru_2 <= stage0_act_4 + stage0_act_5	;
		stage1_addact_ru_3 <= stage0_act_6 + stage0_act_7	;
	end
end


//----------- stage 2 -----------
// add stage1 mult
always@( posedge clk )begin
	if( reset )begin
		stage2_addmult_0 <= 'd0 ;
		stage2_addmult_1 <= 'd0 ;
		stage2_addmult_2 <= 'd0 ;
		stage2_addmult_3 <= 'd0 ;
	end
	else begin
		stage2_addmult_0 <= $signed( stage1_multsigned_pd_0 ) + $signed( stage1_multsigned_pd_1 )	;
		stage2_addmult_1 <= $signed( stage1_multsigned_pd_2 ) + $signed( stage1_multsigned_pd_3 )	;
		stage2_addmult_2 <= $signed( stage1_multsigned_pd_4 ) + $signed( stage1_multsigned_pd_5 )	;
		stage2_addmult_3 <= $signed( stage1_multsigned_pd_6 ) + $signed( stage1_multsigned_pd_7 )	;
	end

end
// tree signed addition activation
always@(posedge clk )begin
	if( reset )begin
		stage2_addact_ru_0 <= 'd0 ;
		stage2_addact_ru_1 <= 'd0 ;

	end
	else begin
		stage2_addact_ru_0 <= stage1_addact_ru_0 + stage1_addact_ru_1 ;
		stage2_addact_ru_1 <= stage1_addact_ru_2 + stage1_addact_ru_3 ;
	end
end


//----------- stage 3 -----------
always@( posedge clk )begin
	if( reset )begin
		stage3_add2_0 <= 'd0 ;
		stage3_add2_1 <= 'd0 ;
	end
	else begin
		stage3_add2_0	<= $signed( stage2_addmult_0 ) + $signed( stage2_addmult_1 )	;
		stage3_add2_1	<= $signed( stage2_addmult_2 ) + $signed( stage2_addmult_3 )	;
	end
	
end

// tree signed addition activation
always@(posedge clk )begin
	if( reset )begin
		stage3_addact_ru_0 <= 'd0 ;
	end
	else begin
		stage3_addact_ru_0 <= stage2_addact_ru_0 + stage2_addact_ru_1 ;
	end
end

//----------- stage 4 -----------
// signed add for MAC
always@( posedge clk )begin
	if( reset )begin
		stage4_addend_0 <= 'd0 ;
	end
	else begin
		stage4_addend_0 <= $signed( stage3_add2_0 ) + $signed( stage3_add2_1 )	;
	end
end

// acculmator for Act_sum operation, check final flag for necessary ACC
always@(posedge clk )begin
	if( reset )begin
		stage4_addact_acc_0 <= 'd0 ;
	end
	else begin
		if( stage4_valid_in)begin
			if( !stage4_final_in )begin
				stage4_addact_acc_0 <=  stage4_addact_acc_0 +  stage3_addact_ru_0  ;
			end
			else begin
				stage4_addact_acc_0 <=  stage3_addact_ru_0  ;
			end
		end
		else begin
			stage4_addact_acc_0 <= stage4_addact_acc_0 ;
		end
	end
end


//----------- stage 5 -----------
// acculmator for MAC operation, check final flag for necessary ACC
always@( posedge clk )begin
	if( reset )begin
		stage5_acc_0 <= 'd0 ;
	end
	else begin
		if( stage5_valid_in )begin
			if( !stage5_final_in)begin
				stage5_acc_0 <= $signed( stage5_acc_0 ) + $signed( stage4_addend_0 )	;
			end
			else begin
				stage5_acc_0 <= 'd0 + $signed( stage4_addend_0 )	;
			end
			
		end
		else begin
			stage5_acc_0 <= stage5_acc_0	;
		end
		
	end
	
end

// shift  act_sum  to stage 5
always@(posedge clk )begin
	if(reset) begin
		stage5_addact_acc_0 <= 'd0 ;
	end
	else begin
		stage5_addact_acc_0 <= stage4_addact_acc_0 ;
	end
end

//----------- stage 6 -----------
// shift to stage 6 for bias at final stage
always@(posedge clk )begin
	if(reset)begin
		stage6_acc_0 <= 32'd0	;
	end
	else begin
		stage6_acc_0 <= stage5_acc_0	;
	end
end

// shift act_sum to stage 6 for final stage output
always@(posedge clk )begin
	if(reset) begin
		stage6_addact_acc_0 <= 'd0 ;
	end
	else begin
		stage6_addact_acc_0 <= stage5_addact_acc_0 ;
	end
end

//----------- stage 7 -----------
//--ver2 pe output logic ----
always@( posedge clk )begin
	if(reset )begin
		outmacb_sum <= 32'd0 ;
		outact_sum <= 32'd0 ;
		valid_out <= 0 ;
	end
	else begin
		if( stage6_valid_in )begin
			if( stage6_final_in)begin
				outmacb_sum <= $signed( stage6_acc_0 ) + $signed( stage6_bias_in )	;
				outact_sum <=  $signed(stage6_addact_acc_0) ;
				valid_out <= 1 ;
			end
			else begin
				outmacb_sum <= outmacb_sum;
				outact_sum <= outact_sum;
				valid_out <= 0 ;
			end
			
		end
		else begin
			outmacb_sum <= 32'd0	;
			outact_sum <= 32'd0	;
			valid_out <= 0 ;
		end

	end
end



always@( posedge clk )begin
	stage0_final_in <= final_in ;
	stage1_final_in <= stage0_final_in ;
	stage2_final_in <= stage1_final_in ;
	stage3_final_in <= stage2_final_in ;
	stage4_final_in <= stage3_final_in ;
	stage5_final_in <= stage4_final_in ;
	stage6_final_in <= stage5_final_in ;
	stage7_final_in <= stage6_final_in ;
end
always@( posedge clk )begin
	stage0_valid_in <= valid_in ;
	stage1_valid_in <= stage0_valid_in ;
	stage2_valid_in <= stage1_valid_in ;
	stage3_valid_in <= stage2_valid_in ;
	stage4_valid_in <= stage3_valid_in ;
	stage5_valid_in <= stage4_valid_in ;
	stage6_valid_in <= stage5_valid_in ;
	stage7_valid_in <= stage6_valid_in ;
end



//---- biasing block ----//
always@( posedge clk )begin
	if ( stage0_valid_in )begin
		stage0_bias_in	<= bias_in	;
		stage0_bias_offset	<= bias_offset	;
	end
	else begin
		stage0_bias_in	<= 'd0	;
		stage0_bias_offset	<= 'd0	;
	end
end

always@( posedge clk )begin
	if ( reset )begin
		stage1_bias_in	<= 'd0	;
		stage2_bias_in	<= 'd0	;
		stage3_bias_in	<= 'd0	;
		stage4_bias_in	<= 'd0	;
		stage5_bias_in	<= 'd0	;
		stage6_bias_in	<= 'd0	;
		stage7_bias_in	<= 'd0	;

		stage1_bias_offset	<= 'd0	;
		stage2_bias_offset	<= 'd0	;
		stage3_bias_offset	<= 'd0	;
		stage4_bias_offset	<= 'd0	;
		stage5_bias_offset	<= 'd0	;
		stage6_bias_offset	<= 'd0	;
		stage7_bias_offset	<= 'd0	;

	end
	else begin
		stage1_bias_in	<= stage0_bias_in	;
		stage2_bias_in	<= stage1_bias_in	;
		stage3_bias_in	<= stage2_bias_in	;
		stage4_bias_in	<= stage3_bias_in	;
		stage5_bias_in	<= stage4_bias_in	;
		stage6_bias_in	<= stage5_bias_in	;
		stage7_bias_in	<= stage6_bias_in	;

		stage1_bias_offset	<= stage0_bias_offset	;
		stage2_bias_offset	<= stage1_bias_offset	;
		stage3_bias_offset	<= stage2_bias_offset	;
		stage4_bias_offset	<= stage3_bias_offset	;
		stage5_bias_offset	<= stage4_bias_offset	;
		stage6_bias_offset	<= stage5_bias_offset	;
		stage7_bias_offset	<= stage6_bias_offset	;
	end
end


endmodule

