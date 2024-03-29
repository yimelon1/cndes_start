//----generated by bias_top_mod.py------ 
//----generated by bias_top_mod.py------ 
//---- bias top declare BIAS_SRAM start------ 
wire cen_biassr_0 ; 
wire wen_biassr_0 ; 
wire [ 9 -1 : 0 ] addr_biassr_0 ; 
wire [ 32 -1 : 0 ] din_biassr_0 ; 
//---- bias top declare BIAS_SRAM end------ 

//----declare bias_top sram read signal start------ 
wire bsr_cen_biassr_0 ; 
wire bsr_wen_biassr_0 ; 
wire [ 9 -1 : 0 ] bsr_addr_biassr_0 ; 
//----declare bias_top sram read signal  end------ 

//----declare bias_top sram write signal start------ 
wire bsw_cen_biassr_0 ; 
wire bsw_wen_biassr_0 ; 
wire [ 9 -1 : 0 ] bsw_addr_biassr_0 ; 
wire [ 32 -1 : 0 ] bsw_din_biassr_0 ; 
//----declare bias_top sram write signal  end------ 
//----generated by bias_top_mod.py------ 
//----instance BIAS_SRAM start------ 
BIAS_SRAM bias_0(.Q(	dout_biassr_0 ),	.CLK( clk ),.CEN( cen_biassr_0 ),.WEN( wen_biassr_0 ),.A( addr_biassr_0 ),.D( din_biassr_0 ),.EMA( 3'b0 ));//----instance KER SRAM_0---------
//----instance BIAS_SRAM end------ 
//----generated by bias_top_mod.py------ 
//----bias_top assign start------ 
//----bias_top assign cen ------ 
assign cen_biassr_0 = ( tst_sram_rw )? bsw_cen_biassr_0 : bsr_cen_biassr_0 ;//----bias_top assign wen ------ 
assign wen_biassr_0 = ( tst_sram_rw )? bsw_wen_biassr_0 : bsr_wen_biassr_0 ;//----bias_top assign addr ------ 
assign addr_biassr_0 =  ( tst_sram_rw )? bsw_addr_biassr_0 : bsr_addr_biassr_0 ;//----bias_top assign din ------ 
assign din_biassr_0 =  ( tst_sram_rw )? bsw_din_biassr_0 : 64'd0 ;//----bias_top assign end------ 
wire bsw_cen_biassr_0 ; 
wire bsw_wen_biassr_0 ; 
wire [ 11 -1 : 0 ] bsw_addr_biassr_0 ; 
wire [ 64 -1 : 0 ] bsw_din_biassr_0 ; 
//----generated by bias_top_mod.py------ 
//----bias_top write module sram signal instanse------ 
.cen_biasr_0( bsw_cen_biassr_0 ),.wen_biasr_0( bsw_wen_biassr_0 ),.addr_biasr_0( bsw_addr_biassr_0 ),.din_biasr_0( bsw_din_biassr_0 ),//----bias_top write module sram signal instanse end------ 
