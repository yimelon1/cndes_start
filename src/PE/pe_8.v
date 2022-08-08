
// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.08.06
// Ver      : 1.0
// Func     : PE of DLA, using adder tree structure compute 8 element each rounds
// throught every stage
// ============================================================================


module pe_8e #(
	parameter ELE_BITS = 8 ,
	parameter OUT_BITS = 32
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
	//-----------------------------------------//
	output valid_out ,
	output [OUT_BITS-1 : 0 ] out_sum

);

//-------------Declare-----------------------------------------//
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




// wire signed [ 2*ELE_BITS -1 : 0] multsigned_pd_0 ;
// wire signed [ 2*ELE_BITS -1 : 0] multsigned_pd_1 ;
// wire signed [ 2*ELE_BITS -1 : 0] multsigned_pd_2 ;
// wire signed [ 2*ELE_BITS -1 : 0] multsigned_pd_3 ;
// wire signed [ 2*ELE_BITS -1 : 0] multsigned_pd_4 ;
// wire signed [ 2*ELE_BITS -1 : 0] multsigned_pd_5 ;
// wire signed [ 2*ELE_BITS -1 : 0] multsigned_pd_6 ;
// wire signed [ 2*ELE_BITS -1 : 0] multsigned_pd_7 ;
// assign multsigned_pd_0 = $signed( stage0_act_0 ) * $signed( stage0_ker_0 )	;
// assign multsigned_pd_1 = $signed( stage0_act_1 ) * $signed( stage0_ker_1 )	;
// assign multsigned_pd_2 = $signed( stage0_act_2 ) * $signed( stage0_ker_2 )	;
// assign multsigned_pd_3 = $signed( stage0_act_3 ) * $signed( stage0_ker_3 )	;
// assign multsigned_pd_4 = $signed( stage0_act_4 ) * $signed( stage0_ker_4 )	;
// assign multsigned_pd_5 = $signed( stage0_act_5 ) * $signed( stage0_ker_5 )	;
// assign multsigned_pd_6 = $signed( stage0_act_6 ) * $signed( stage0_ker_6 )	;
// assign multsigned_pd_7 = $signed( stage0_act_7 ) * $signed( stage0_ker_7 )	;

reg signed [ 2*ELE_BITS -1 : 0] stage1_multsigned_pd_0 ;
reg signed [ 2*ELE_BITS -1 : 0] stage1_multsigned_pd_1 ;
reg signed [ 2*ELE_BITS -1 : 0] stage1_multsigned_pd_2 ;
reg signed [ 2*ELE_BITS -1 : 0] stage1_multsigned_pd_3 ;
reg signed [ 2*ELE_BITS -1 : 0] stage1_multsigned_pd_4 ;
reg signed [ 2*ELE_BITS -1 : 0] stage1_multsigned_pd_5 ;
reg signed [ 2*ELE_BITS -1 : 0] stage1_multsigned_pd_6 ;
reg signed [ 2*ELE_BITS -1 : 0] stage1_multsigned_pd_7 ;


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



// signed multiply
//- stage 1 -
always@( posedge clk )begin
	stage1_multsigned_pd_0 <= $signed( stage0_act_0 ) * $signed( stage0_ker_0 )	;
	stage1_multsigned_pd_1 <= $signed( stage0_act_1 ) * $signed( stage0_ker_1 )	;
	stage1_multsigned_pd_2 <= $signed( stage0_act_2 ) * $signed( stage0_ker_2 )	;
	stage1_multsigned_pd_3 <= $signed( stage0_act_3 ) * $signed( stage0_ker_3 )	;
	stage1_multsigned_pd_4 <= $signed( stage0_act_4 ) * $signed( stage0_ker_4 )	;
	stage1_multsigned_pd_5 <= $signed( stage0_act_5 ) * $signed( stage0_ker_5 )	;
	stage1_multsigned_pd_6 <= $signed( stage0_act_6 ) * $signed( stage0_ker_6 )	;
	stage1_multsigned_pd_7 <= $signed( stage0_act_7 ) * $signed( stage0_ker_7 )	;
end

//- stage 2 -
always@( posedge clk )begin
	stage2_addmult_0 <= $signed( stage1_multsigned_pd_0 ) + $signed( stage1_multsigned_pd_1 )	;
	stage2_addmult_1 <= $signed( stage1_multsigned_pd_2 ) + $signed( stage1_multsigned_pd_3 )	;
	stage2_addmult_2 <= $signed( stage1_multsigned_pd_4 ) + $signed( stage1_multsigned_pd_5 )	;
	stage2_addmult_3 <= $signed( stage1_multsigned_pd_6 ) + $signed( stage1_multsigned_pd_7 )	;
end

//- stage 3 -
always@( posedge clk )begin
	stage3_add2_0	<= $signed( stage2_addmult_0 ) + $signed( stage2_addmult_1 )	;
	stage3_add2_1	<= $signed( stage2_addmult_2 ) + $signed( stage2_addmult_3 )	;
end
//- stage 4 -
always@( posedge clk )begin
	stage4_addend_0 <= $signed( stage3_add2_0 ) + $signed( stage3_add2_1 )	;
end

//- stage 5 -
always@( posedge clk )begin
	stage5_acc_0 <= $signed( stage5_acc_0 ) + $signed( stage4_addend_0 )	;
end



always@( posedge clk )begin
		stage0_act_0 <= act_0	;
		stage0_act_1 <= act_1	;
		stage0_act_2 <= act_2	;
		stage0_act_3 <= act_3	;
		stage0_act_4 <= act_4	;
		stage0_act_5 <= act_5	;
		stage0_act_6 <= act_6	;
		stage0_act_7 <= act_7	;
end
always@( posedge clk )begin
		stage0_ker_0 <= ker_0	;
		stage0_ker_1 <= ker_1	;
		stage0_ker_2 <= ker_2	;
		stage0_ker_3 <= ker_3	;
		stage0_ker_4 <= ker_4	;
		stage0_ker_5 <= ker_5	;
		stage0_ker_6 <= ker_6	;
		stage0_ker_7 <= ker_7	;
end






endmodule

