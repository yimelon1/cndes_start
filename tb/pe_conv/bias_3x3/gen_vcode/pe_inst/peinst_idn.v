//----instance pe with bias start------ 
//----pe row0 col_0---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_0(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[0][63-:8] ) , .act_1( act_shf[0][55-:8] ) , .act_2( act_shf[0][47-:8] ) , .act_3( act_shf[0][39-:8] ) , .act_4( act_shf[0][31-:8] ) , .act_5( act_shf[0][23-:8] ) , .act_6( act_shf[0][15-:8] ) , .act_7( act_shf[0][ 7-:8] ) , .valid_in( valid_fg_dly0 ) ,.final_in( final_fg_dly0 ) ,
//---- kernel ----//
.ker_0( ker_shf[0][63-:8] ) , .ker_1( ker_shf[0][55-:8] ) , .ker_2( ker_shf[0][47-:8] ) , .ker_3( ker_shf[0][39-:8] ) , .ker_4( ker_shf[0][31-:8] ) , .ker_5( ker_shf[0][23-:8] ) , .ker_6( ker_shf[0][15-:8] ) , .ker_7( ker_shf[0][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_0_dly0 ), .bias_offset( bi_offset_0_dly0 ), .valid_out ( q_valid[0] ) ,.out_sum ( row_sumshf[0] ) );
//----pe row0 col_1---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_1(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[1][63-:8] ) , .act_1( act_shf[1][55-:8] ) , .act_2( act_shf[1][47-:8] ) , .act_3( act_shf[1][39-:8] ) , .act_4( act_shf[1][31-:8] ) , .act_5( act_shf[1][23-:8] ) , .act_6( act_shf[1][15-:8] ) , .act_7( act_shf[1][ 7-:8] ) , .valid_in( valid_fg_dly1 ) ,.final_in( final_fg_dly1 ) ,
//---- kernel ----//
.ker_0( ker_shf[1][63-:8] ) , .ker_1( ker_shf[1][55-:8] ) , .ker_2( ker_shf[1][47-:8] ) , .ker_3( ker_shf[1][39-:8] ) , .ker_4( ker_shf[1][31-:8] ) , .ker_5( ker_shf[1][23-:8] ) , .ker_6( ker_shf[1][15-:8] ) , .ker_7( ker_shf[1][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_1_dly0 ), .bias_offset( bi_offset_1_dly0 ), .valid_out ( q_valid[1] ) ,.out_sum ( row_sumshf[1] ) );
//----pe row0 col_2---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_2(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[2][63-:8] ) , .act_1( act_shf[2][55-:8] ) , .act_2( act_shf[2][47-:8] ) , .act_3( act_shf[2][39-:8] ) , .act_4( act_shf[2][31-:8] ) , .act_5( act_shf[2][23-:8] ) , .act_6( act_shf[2][15-:8] ) , .act_7( act_shf[2][ 7-:8] ) , .valid_in( valid_fg_dly2 ) ,.final_in( final_fg_dly2 ) ,
//---- kernel ----//
.ker_0( ker_shf[2][63-:8] ) , .ker_1( ker_shf[2][55-:8] ) , .ker_2( ker_shf[2][47-:8] ) , .ker_3( ker_shf[2][39-:8] ) , .ker_4( ker_shf[2][31-:8] ) , .ker_5( ker_shf[2][23-:8] ) , .ker_6( ker_shf[2][15-:8] ) , .ker_7( ker_shf[2][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_2_dly0 ), .bias_offset( bi_offset_2_dly0 ), .valid_out ( q_valid[2] ) ,.out_sum ( row_sumshf[2] ) );
//----pe row0 col_3---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_3(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[3][63-:8] ) , .act_1( act_shf[3][55-:8] ) , .act_2( act_shf[3][47-:8] ) , .act_3( act_shf[3][39-:8] ) , .act_4( act_shf[3][31-:8] ) , .act_5( act_shf[3][23-:8] ) , .act_6( act_shf[3][15-:8] ) , .act_7( act_shf[3][ 7-:8] ) , .valid_in( valid_fg_dly3 ) ,.final_in( final_fg_dly3 ) ,
//---- kernel ----//
.ker_0( ker_shf[3][63-:8] ) , .ker_1( ker_shf[3][55-:8] ) , .ker_2( ker_shf[3][47-:8] ) , .ker_3( ker_shf[3][39-:8] ) , .ker_4( ker_shf[3][31-:8] ) , .ker_5( ker_shf[3][23-:8] ) , .ker_6( ker_shf[3][15-:8] ) , .ker_7( ker_shf[3][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_3_dly0 ), .bias_offset( bi_offset_3_dly0 ), .valid_out ( q_valid[3] ) ,.out_sum ( row_sumshf[3] ) );
//----pe row0 col_4---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_4(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[4][63-:8] ) , .act_1( act_shf[4][55-:8] ) , .act_2( act_shf[4][47-:8] ) , .act_3( act_shf[4][39-:8] ) , .act_4( act_shf[4][31-:8] ) , .act_5( act_shf[4][23-:8] ) , .act_6( act_shf[4][15-:8] ) , .act_7( act_shf[4][ 7-:8] ) , .valid_in( valid_fg_dly4 ) ,.final_in( final_fg_dly4 ) ,
//---- kernel ----//
.ker_0( ker_shf[4][63-:8] ) , .ker_1( ker_shf[4][55-:8] ) , .ker_2( ker_shf[4][47-:8] ) , .ker_3( ker_shf[4][39-:8] ) , .ker_4( ker_shf[4][31-:8] ) , .ker_5( ker_shf[4][23-:8] ) , .ker_6( ker_shf[4][15-:8] ) , .ker_7( ker_shf[4][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_4_dly0 ), .bias_offset( bi_offset_4_dly0 ), .valid_out ( q_valid[4] ) ,.out_sum ( row_sumshf[4] ) );
//----pe row0 col_5---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_5(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[5][63-:8] ) , .act_1( act_shf[5][55-:8] ) , .act_2( act_shf[5][47-:8] ) , .act_3( act_shf[5][39-:8] ) , .act_4( act_shf[5][31-:8] ) , .act_5( act_shf[5][23-:8] ) , .act_6( act_shf[5][15-:8] ) , .act_7( act_shf[5][ 7-:8] ) , .valid_in( valid_fg_dly5 ) ,.final_in( final_fg_dly5 ) ,
//---- kernel ----//
.ker_0( ker_shf[5][63-:8] ) , .ker_1( ker_shf[5][55-:8] ) , .ker_2( ker_shf[5][47-:8] ) , .ker_3( ker_shf[5][39-:8] ) , .ker_4( ker_shf[5][31-:8] ) , .ker_5( ker_shf[5][23-:8] ) , .ker_6( ker_shf[5][15-:8] ) , .ker_7( ker_shf[5][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_5_dly0 ), .bias_offset( bi_offset_5_dly0 ), .valid_out ( q_valid[5] ) ,.out_sum ( row_sumshf[5] ) );
//----pe row0 col_6---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_6(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[6][63-:8] ) , .act_1( act_shf[6][55-:8] ) , .act_2( act_shf[6][47-:8] ) , .act_3( act_shf[6][39-:8] ) , .act_4( act_shf[6][31-:8] ) , .act_5( act_shf[6][23-:8] ) , .act_6( act_shf[6][15-:8] ) , .act_7( act_shf[6][ 7-:8] ) , .valid_in( valid_fg_dly6 ) ,.final_in( final_fg_dly6 ) ,
//---- kernel ----//
.ker_0( ker_shf[6][63-:8] ) , .ker_1( ker_shf[6][55-:8] ) , .ker_2( ker_shf[6][47-:8] ) , .ker_3( ker_shf[6][39-:8] ) , .ker_4( ker_shf[6][31-:8] ) , .ker_5( ker_shf[6][23-:8] ) , .ker_6( ker_shf[6][15-:8] ) , .ker_7( ker_shf[6][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_6_dly0 ), .bias_offset( bi_offset_6_dly0 ), .valid_out ( q_valid[6] ) ,.out_sum ( row_sumshf[6] ) );
//----pe row0 col_7---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_7(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[7][63-:8] ) , .act_1( act_shf[7][55-:8] ) , .act_2( act_shf[7][47-:8] ) , .act_3( act_shf[7][39-:8] ) , .act_4( act_shf[7][31-:8] ) , .act_5( act_shf[7][23-:8] ) , .act_6( act_shf[7][15-:8] ) , .act_7( act_shf[7][ 7-:8] ) , .valid_in( valid_fg_dly7 ) ,.final_in( final_fg_dly7 ) ,
//---- kernel ----//
.ker_0( ker_shf[7][63-:8] ) , .ker_1( ker_shf[7][55-:8] ) , .ker_2( ker_shf[7][47-:8] ) , .ker_3( ker_shf[7][39-:8] ) , .ker_4( ker_shf[7][31-:8] ) , .ker_5( ker_shf[7][23-:8] ) , .ker_6( ker_shf[7][15-:8] ) , .ker_7( ker_shf[7][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_7_dly0 ), .bias_offset( bi_offset_7_dly0 ), .valid_out ( q_valid[7] ) ,.out_sum ( row_sumshf[7] ) );
//----instance pe with bias end------ 
