//----generated by ker_top_mod.py------ 
//----top port list with rw SRAM reference------ 
 dout_kersr_0 ,dout_kersr_1 ,dout_kersr_2 ,dout_kersr_3 ,dout_kersr_4 ,dout_kersr_5 ,dout_kersr_6 ,dout_kersr_7 ; 
 ksr_valid_0 ,ksr_valid_1 ,ksr_valid_2 ,ksr_valid_3 ,ksr_valid_4 ,ksr_valid_5 ,ksr_valid_6 ,ksr_valid_7 ; 
 ksr_final_0 ,ksr_final_1 ,ksr_final_2 ,ksr_final_3 ,ksr_final_4 ,ksr_final_5 ,ksr_final_6 ,ksr_final_7 ; 
//----top port list with rw SRAM reference------ 
output wire [ 64 -1 : 0 ] dout_kersr_0 ,dout_kersr_1 ,dout_kersr_2 ,dout_kersr_3 ,dout_kersr_4 ,dout_kersr_5 ,dout_kersr_6 ,dout_kersr_7 ; 
output wire ksr_valid_0 ,ksr_valid_1 ,ksr_valid_2 ,ksr_valid_3 ,ksr_valid_4 ,ksr_valid_5 ,ksr_valid_6 ,ksr_valid_7 ; 
output wire ksr_final_0 ,ksr_final_1 ,ksr_final_2 ,ksr_final_3 ,ksr_final_4 ,ksr_final_5 ,ksr_final_6 ,ksr_final_7 ; 
//----generated by ker_top_mod.py------ 
//---- kersram top declare KER_SRAM start------ 
wire cen_kersr_0 ,cen_kersr_1 ,cen_kersr_2 ,cen_kersr_3 ,cen_kersr_4 ,cen_kersr_5 ,cen_kersr_6 ,cen_kersr_7 ; 
wire wen_kersr_0 ,wen_kersr_1 ,wen_kersr_2 ,wen_kersr_3 ,wen_kersr_4 ,wen_kersr_5 ,wen_kersr_6 ,wen_kersr_7 ; 
wire [ 11 -1 : 0 ] addr_kersr_0 ,addr_kersr_1 ,addr_kersr_2 ,addr_kersr_3 ,addr_kersr_4 ,addr_kersr_5 ,addr_kersr_6 ,addr_kersr_7 ; 
wire [ 64 -1 : 0 ] din_kersr_0 ,din_kersr_1 ,din_kersr_2 ,din_kersr_3 ,din_kersr_4 ,din_kersr_5 ,din_kersr_6 ,din_kersr_7 ; 
//---- kersram top declare KER_SRAM end------ 

//----declare ker_top sram read signal start------ 
wire ksr_cen_kersr_0 ,ksr_cen_kersr_1 ,ksr_cen_kersr_2 ,ksr_cen_kersr_3 ,ksr_cen_kersr_4 ,ksr_cen_kersr_5 ,ksr_cen_kersr_6 ,ksr_cen_kersr_7 ; 
wire ksr_wen_kersr_0 ,ksr_wen_kersr_1 ,ksr_wen_kersr_2 ,ksr_wen_kersr_3 ,ksr_wen_kersr_4 ,ksr_wen_kersr_5 ,ksr_wen_kersr_6 ,ksr_wen_kersr_7 ; 
wire [ 11 -1 : 0 ] ksr_addr_kersr_0 ,ksr_addr_kersr_1 ,ksr_addr_kersr_2 ,ksr_addr_kersr_3 ,ksr_addr_kersr_4 ,ksr_addr_kersr_5 ,ksr_addr_kersr_6 ,ksr_addr_kersr_7 ; 
//----declare ker_top sram read signal  end------ 

//----declare ker_top sram write signal start------ 
wire ksw_cen_kersr_0 ,ksw_cen_kersr_1 ,ksw_cen_kersr_2 ,ksw_cen_kersr_3 ,ksw_cen_kersr_4 ,ksw_cen_kersr_5 ,ksw_cen_kersr_6 ,ksw_cen_kersr_7 ; 
wire ksw_wen_kersr_0 ,ksw_wen_kersr_1 ,ksw_wen_kersr_2 ,ksw_wen_kersr_3 ,ksw_wen_kersr_4 ,ksw_wen_kersr_5 ,ksw_wen_kersr_6 ,ksw_wen_kersr_7 ; 
wire [ 11 -1 : 0 ] ksw_addr_kersr_0 ,ksw_addr_kersr_1 ,ksw_addr_kersr_2 ,ksw_addr_kersr_3 ,ksw_addr_kersr_4 ,ksw_addr_kersr_5 ,ksw_addr_kersr_6 ,ksw_addr_kersr_7 ; 
wire [ 64 -1 : 0 ] ksw_din_kersr_0 ,ksw_din_kersr_1 ,ksw_din_kersr_2 ,ksw_din_kersr_3 ,ksw_din_kersr_4 ,ksw_din_kersr_5 ,ksw_din_kersr_6 ,ksw_din_kersr_7 ; 
//----declare ker_top sram write signal  end------ 
//----generated by ker_top_mod.py------ 
//----instance KER_SRAM start------ 
KER_SRAM ker_0(.Q(	dout_kersr_0 ),	.CLK( clk ),.CEN( cen_kersr_0 ),.WEN( wen_kersr_0 ),.A( addr_kersr_0 ),.D( din_kersr_0 ),.EMA( 3'b0 ));//----instance KER SRAM_0---------
KER_SRAM ker_1(.Q(	dout_kersr_1 ),	.CLK( clk ),.CEN( cen_kersr_1 ),.WEN( wen_kersr_1 ),.A( addr_kersr_1 ),.D( din_kersr_1 ),.EMA( 3'b0 ));//----instance KER SRAM_1---------
KER_SRAM ker_2(.Q(	dout_kersr_2 ),	.CLK( clk ),.CEN( cen_kersr_2 ),.WEN( wen_kersr_2 ),.A( addr_kersr_2 ),.D( din_kersr_2 ),.EMA( 3'b0 ));//----instance KER SRAM_2---------
KER_SRAM ker_3(.Q(	dout_kersr_3 ),	.CLK( clk ),.CEN( cen_kersr_3 ),.WEN( wen_kersr_3 ),.A( addr_kersr_3 ),.D( din_kersr_3 ),.EMA( 3'b0 ));//----instance KER SRAM_3---------
KER_SRAM ker_4(.Q(	dout_kersr_4 ),	.CLK( clk ),.CEN( cen_kersr_4 ),.WEN( wen_kersr_4 ),.A( addr_kersr_4 ),.D( din_kersr_4 ),.EMA( 3'b0 ));//----instance KER SRAM_4---------
KER_SRAM ker_5(.Q(	dout_kersr_5 ),	.CLK( clk ),.CEN( cen_kersr_5 ),.WEN( wen_kersr_5 ),.A( addr_kersr_5 ),.D( din_kersr_5 ),.EMA( 3'b0 ));//----instance KER SRAM_5---------
KER_SRAM ker_6(.Q(	dout_kersr_6 ),	.CLK( clk ),.CEN( cen_kersr_6 ),.WEN( wen_kersr_6 ),.A( addr_kersr_6 ),.D( din_kersr_6 ),.EMA( 3'b0 ));//----instance KER SRAM_6---------
KER_SRAM ker_7(.Q(	dout_kersr_7 ),	.CLK( clk ),.CEN( cen_kersr_7 ),.WEN( wen_kersr_7 ),.A( addr_kersr_7 ),.D( din_kersr_7 ),.EMA( 3'b0 ));//----instance KER SRAM_7---------
//----instance KER_SRAM end------ 
//----generated by ker_top_mod.py------ 
//----ker_top assign start------ 
//----ker_top assign cen ------ 
assign cen_kersr_0 = ( tst_sram_rw )? ksw_cen_kersr_0 : ksr_cen_kersr_0 ;assign cen_kersr_1 = ( tst_sram_rw )? ksw_cen_kersr_1 : ksr_cen_kersr_1 ;assign cen_kersr_2 = ( tst_sram_rw )? ksw_cen_kersr_2 : ksr_cen_kersr_2 ;assign cen_kersr_3 = ( tst_sram_rw )? ksw_cen_kersr_3 : ksr_cen_kersr_3 ;assign cen_kersr_4 = ( tst_sram_rw )? ksw_cen_kersr_4 : ksr_cen_kersr_4 ;assign cen_kersr_5 = ( tst_sram_rw )? ksw_cen_kersr_5 : ksr_cen_kersr_5 ;assign cen_kersr_6 = ( tst_sram_rw )? ksw_cen_kersr_6 : ksr_cen_kersr_6 ;assign cen_kersr_7 = ( tst_sram_rw )? ksw_cen_kersr_7 : ksr_cen_kersr_7 ;//----ker_top assign wen ------ 
assign wen_kersr_0 = ( tst_sram_rw )? ksw_wen_kersr_0 : ksr_wen_kersr_0 ;assign wen_kersr_1 = ( tst_sram_rw )? ksw_wen_kersr_1 : ksr_wen_kersr_1 ;assign wen_kersr_2 = ( tst_sram_rw )? ksw_wen_kersr_2 : ksr_wen_kersr_2 ;assign wen_kersr_3 = ( tst_sram_rw )? ksw_wen_kersr_3 : ksr_wen_kersr_3 ;assign wen_kersr_4 = ( tst_sram_rw )? ksw_wen_kersr_4 : ksr_wen_kersr_4 ;assign wen_kersr_5 = ( tst_sram_rw )? ksw_wen_kersr_5 : ksr_wen_kersr_5 ;assign wen_kersr_6 = ( tst_sram_rw )? ksw_wen_kersr_6 : ksr_wen_kersr_6 ;assign wen_kersr_7 = ( tst_sram_rw )? ksw_wen_kersr_7 : ksr_wen_kersr_7 ;//----ker_top assign addr ------ 
assign addr_kersr_0 =  ( tst_sram_rw )? ksw_addr_kersr_0 : ksr_addr_kersr_0 ;assign addr_kersr_1 =  ( tst_sram_rw )? ksw_addr_kersr_1 : ksr_addr_kersr_1 ;assign addr_kersr_2 =  ( tst_sram_rw )? ksw_addr_kersr_2 : ksr_addr_kersr_2 ;assign addr_kersr_3 =  ( tst_sram_rw )? ksw_addr_kersr_3 : ksr_addr_kersr_3 ;assign addr_kersr_4 =  ( tst_sram_rw )? ksw_addr_kersr_4 : ksr_addr_kersr_4 ;assign addr_kersr_5 =  ( tst_sram_rw )? ksw_addr_kersr_5 : ksr_addr_kersr_5 ;assign addr_kersr_6 =  ( tst_sram_rw )? ksw_addr_kersr_6 : ksr_addr_kersr_6 ;assign addr_kersr_7 =  ( tst_sram_rw )? ksw_addr_kersr_7 : ksr_addr_kersr_7 ;//----ker_top assign din ------ 
assign din_kersr_0 =  ( tst_sram_rw )? ksw_din_kersr_0 : 64'd0 ;assign din_kersr_1 =  ( tst_sram_rw )? ksw_din_kersr_1 : 64'd0 ;assign din_kersr_2 =  ( tst_sram_rw )? ksw_din_kersr_2 : 64'd0 ;assign din_kersr_3 =  ( tst_sram_rw )? ksw_din_kersr_3 : 64'd0 ;assign din_kersr_4 =  ( tst_sram_rw )? ksw_din_kersr_4 : 64'd0 ;assign din_kersr_5 =  ( tst_sram_rw )? ksw_din_kersr_5 : 64'd0 ;assign din_kersr_6 =  ( tst_sram_rw )? ksw_din_kersr_6 : 64'd0 ;assign din_kersr_7 =  ( tst_sram_rw )? ksw_din_kersr_7 : 64'd0 ;//----ker_top assign end------ 


//----generated by ker_top_mod.py------ 
//----top port list for other module instance------ 
.dout_kersr_0 ( dout_kersr_0 ), .ksr_valid_0  ( ksr_valid_0 ), .ksr_final_0  ( ksr_final_0 ), //----instance KER top_0---------
.dout_kersr_1 ( dout_kersr_1 ), .ksr_valid_1  ( ksr_valid_1 ), .ksr_final_1  ( ksr_final_1 ), //----instance KER top_1---------
.dout_kersr_2 ( dout_kersr_2 ), .ksr_valid_2  ( ksr_valid_2 ), .ksr_final_2  ( ksr_final_2 ), //----instance KER top_2---------
.dout_kersr_3 ( dout_kersr_3 ), .ksr_valid_3  ( ksr_valid_3 ), .ksr_final_3  ( ksr_final_3 ), //----instance KER top_3---------
.dout_kersr_4 ( dout_kersr_4 ), .ksr_valid_4  ( ksr_valid_4 ), .ksr_final_4  ( ksr_final_4 ), //----instance KER top_4---------
.dout_kersr_5 ( dout_kersr_5 ), .ksr_valid_5  ( ksr_valid_5 ), .ksr_final_5  ( ksr_final_5 ), //----instance KER top_5---------
.dout_kersr_6 ( dout_kersr_6 ), .ksr_valid_6  ( ksr_valid_6 ), .ksr_final_6  ( ksr_final_6 ), //----instance KER top_6---------
.dout_kersr_7 ( dout_kersr_7 ), .ksr_valid_7  ( ksr_valid_7 ), .ksr_final_7  ( ksr_final_7 ), //----instance KER top_7---------
