//----bias declare start------ 
reg signed [31:0] bi_con_0 , bi_con_1 , bi_con_2 , bi_con_3 , bi_con_4 , bi_con_5 , bi_con_6 , bi_con_7 ;
reg signed [3:0] bi_offset_0 , bi_offset_1 , bi_offset_2 , bi_offset_3 , bi_offset_4 , bi_offset_5 , bi_offset_6 , bi_offset_7 ;
reg signed [31:0]	bi_con_0_dly0ed  	;
reg signed [31:0]	bi_con_1_dly0ed  	;
reg signed [31:0]	bi_con_2_dly0ed  	;
reg signed [31:0]	bi_con_3_dly0ed  	;
reg signed [31:0]	bi_con_4_dly0ed  	;
reg signed [31:0]	bi_con_5_dly0ed  	;
reg signed [31:0]	bi_con_6_dly0ed  	;
reg signed [31:0]	bi_con_7_dly0ed  	;
reg [3:0]  bi_offset_0_dly0ed  ;
reg [3:0]  bi_offset_1_dly0ed  ;
reg [3:0]  bi_offset_2_dly0ed  ;
reg [3:0]  bi_offset_3_dly0ed  ;
reg [3:0]  bi_offset_4_dly0ed  ;
reg [3:0]  bi_offset_5_dly0ed  ;
reg [3:0]  bi_offset_6_dly0ed  ;
reg [3:0]  bi_offset_7_dly0ed  ;
reg signed [31:0]	bi_con_0_dly0 ;
reg signed [31:0]	bi_con_1_dly0 ;
reg signed [31:0]	bi_con_2_dly0 ;
reg signed [31:0]	bi_con_3_dly0 ;
reg signed [31:0]	bi_con_4_dly0 ;
reg signed [31:0]	bi_con_5_dly0 ;
reg signed [31:0]	bi_con_6_dly0 ;
reg signed [31:0]	bi_con_7_dly0 ;
reg [3:0]  bi_offset_0_dly0  ;
reg [3:0]  bi_offset_1_dly0  ;
reg [3:0]  bi_offset_2_dly0  ;
reg [3:0]  bi_offset_3_dly0  ;
reg [3:0]  bi_offset_4_dly0  ;
reg [3:0]  bi_offset_5_dly0  ;
reg [3:0]  bi_offset_6_dly0  ;
reg [3:0]  bi_offset_7_dly0  ;
//----bias declare end------ 
//---- ------ 
//---- ------ 
//----bias data combinational start------ 
always@( * )begin
    bi_con_0 = 	(cv_start_dly0 ) ? bias_reg_0[krr0] : 'd0 ;    //for kerSR0--
    bi_offset_0 = (cv_start_dly0 ) ? krr0 : 'd0 ;    //for kerSR0--
    bi_con_1 = 	(cv_start_dly1 ) ? bias_reg_1[krr1] : 'd0 ;    //for kerSR1--
    bi_offset_1 = (cv_start_dly1 ) ? krr1 : 'd0 ;    //for kerSR1--
    bi_con_2 = 	(cv_start_dly2 ) ? bias_reg_2[krr2] : 'd0 ;    //for kerSR2--
    bi_offset_2 = (cv_start_dly2 ) ? krr2 : 'd0 ;    //for kerSR2--
    bi_con_3 = 	(cv_start_dly3 ) ? bias_reg_3[krr3] : 'd0 ;    //for kerSR3--
    bi_offset_3 = (cv_start_dly3 ) ? krr3 : 'd0 ;    //for kerSR3--
    bi_con_4 = 	(cv_start_dly4 ) ? bias_reg_4[krr4] : 'd0 ;    //for kerSR4--
    bi_offset_4 = (cv_start_dly4 ) ? krr4 : 'd0 ;    //for kerSR4--
    bi_con_5 = 	(cv_start_dly5 ) ? bias_reg_5[krr5] : 'd0 ;    //for kerSR5--
    bi_offset_5 = (cv_start_dly5 ) ? krr5 : 'd0 ;    //for kerSR5--
    bi_con_6 = 	(cv_start_dly6 ) ? bias_reg_6[krr6] : 'd0 ;    //for kerSR6--
    bi_offset_6 = (cv_start_dly6 ) ? krr6 : 'd0 ;    //for kerSR6--
    bi_con_7 = 	(cv_start_dly7 ) ? bias_reg_7[krr7] : 'd0 ;    //for kerSR7--
    bi_offset_7 = (cv_start_dly7 ) ? krr7 : 'd0 ;    //for kerSR7--
end
//----bias data combinational end------ 
//----bias data seq start------ 
always@(posedge clk )begin
//----bias data for kerSR0 ---------
    bi_con_0_dly0ed <= bi_con_0 ;
    bi_con_0_dly0 <= bi_con_0_dly0ed;
    bi_offset_0_dly0ed <= bi_offset_0;
    bi_offset_0_dly0 <= bi_offset_0_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR1 ---------
    bi_con_1_dly0ed <= bi_con_1 ;
    bi_con_1_dly0 <= bi_con_1_dly0ed;
    bi_offset_1_dly0ed <= bi_offset_1;
    bi_offset_1_dly0 <= bi_offset_1_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR2 ---------
    bi_con_2_dly0ed <= bi_con_2 ;
    bi_con_2_dly0 <= bi_con_2_dly0ed;
    bi_offset_2_dly0ed <= bi_offset_2;
    bi_offset_2_dly0 <= bi_offset_2_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR3 ---------
    bi_con_3_dly0ed <= bi_con_3 ;
    bi_con_3_dly0 <= bi_con_3_dly0ed;
    bi_offset_3_dly0ed <= bi_offset_3;
    bi_offset_3_dly0 <= bi_offset_3_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR4 ---------
    bi_con_4_dly0ed <= bi_con_4 ;
    bi_con_4_dly0 <= bi_con_4_dly0ed;
    bi_offset_4_dly0ed <= bi_offset_4;
    bi_offset_4_dly0 <= bi_offset_4_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR5 ---------
    bi_con_5_dly0ed <= bi_con_5 ;
    bi_con_5_dly0 <= bi_con_5_dly0ed;
    bi_offset_5_dly0ed <= bi_offset_5;
    bi_offset_5_dly0 <= bi_offset_5_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR6 ---------
    bi_con_6_dly0ed <= bi_con_6 ;
    bi_con_6_dly0 <= bi_con_6_dly0ed;
    bi_offset_6_dly0ed <= bi_offset_6;
    bi_offset_6_dly0 <= bi_offset_6_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR7 ---------
    bi_con_7_dly0ed <= bi_con_7 ;
    bi_con_7_dly0 <= bi_con_7_dly0ed;
    bi_offset_7_dly0ed <= bi_offset_7;
    bi_offset_7_dly0 <= bi_offset_7_dly0ed;	// cause bias need to Synchronize with final act and ker
end
//----bias data seq end------ 
