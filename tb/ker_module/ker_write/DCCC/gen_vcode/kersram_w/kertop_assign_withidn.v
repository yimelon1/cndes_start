//----ker_top assign start------ 
//----ker_top assign cen ------ 
    assign cen_kersr_0 = ( tst_sram_rw )? ksw_cen_kersr_0 : tst_cen_kersr_0 ;
    assign cen_kersr_1 = ( tst_sram_rw )? ksw_cen_kersr_1 : tst_cen_kersr_1 ;
    assign cen_kersr_2 = ( tst_sram_rw )? ksw_cen_kersr_2 : tst_cen_kersr_2 ;
    assign cen_kersr_3 = ( tst_sram_rw )? ksw_cen_kersr_3 : tst_cen_kersr_3 ;
    assign cen_kersr_4 = ( tst_sram_rw )? ksw_cen_kersr_4 : tst_cen_kersr_4 ;
    assign cen_kersr_5 = ( tst_sram_rw )? ksw_cen_kersr_5 : tst_cen_kersr_5 ;
    assign cen_kersr_6 = ( tst_sram_rw )? ksw_cen_kersr_6 : tst_cen_kersr_6 ;
    assign cen_kersr_7 = ( tst_sram_rw )? ksw_cen_kersr_7 : tst_cen_kersr_7 ;
//----ker_top assign wen ------ 
    assign wen_kersr_0 = ( tst_sram_rw )? ksw_wen_kersr_0 : tst_wen_kersr_0 ;
    assign wen_kersr_1 = ( tst_sram_rw )? ksw_wen_kersr_1 : tst_wen_kersr_1 ;
    assign wen_kersr_2 = ( tst_sram_rw )? ksw_wen_kersr_2 : tst_wen_kersr_2 ;
    assign wen_kersr_3 = ( tst_sram_rw )? ksw_wen_kersr_3 : tst_wen_kersr_3 ;
    assign wen_kersr_4 = ( tst_sram_rw )? ksw_wen_kersr_4 : tst_wen_kersr_4 ;
    assign wen_kersr_5 = ( tst_sram_rw )? ksw_wen_kersr_5 : tst_wen_kersr_5 ;
    assign wen_kersr_6 = ( tst_sram_rw )? ksw_wen_kersr_6 : tst_wen_kersr_6 ;
    assign wen_kersr_7 = ( tst_sram_rw )? ksw_wen_kersr_7 : tst_wen_kersr_7 ;
//----ker_top assign addr ------ 
    assign addr__kersr_0 =  ( tst_sram_rw )? ksw_addr__kersr_0 : tst_addr__kersr_0 ;
    assign addr__kersr_1 =  ( tst_sram_rw )? ksw_addr__kersr_1 : tst_addr__kersr_1 ;
    assign addr__kersr_2 =  ( tst_sram_rw )? ksw_addr__kersr_2 : tst_addr__kersr_2 ;
    assign addr__kersr_3 =  ( tst_sram_rw )? ksw_addr__kersr_3 : tst_addr__kersr_3 ;
    assign addr__kersr_4 =  ( tst_sram_rw )? ksw_addr__kersr_4 : tst_addr__kersr_4 ;
    assign addr__kersr_5 =  ( tst_sram_rw )? ksw_addr__kersr_5 : tst_addr__kersr_5 ;
    assign addr__kersr_6 =  ( tst_sram_rw )? ksw_addr__kersr_6 : tst_addr__kersr_6 ;
    assign addr__kersr_7 =  ( tst_sram_rw )? ksw_addr__kersr_7 : tst_addr__kersr_7 ;
//----ker_top assign din ------ 
    assign din__kersr_0 =  ( tst_sram_rw )? ksw_din_kersr_0 : 64'd0 ;
    assign din__kersr_1 =  ( tst_sram_rw )? ksw_din_kersr_1 : 64'd0 ;
    assign din__kersr_2 =  ( tst_sram_rw )? ksw_din_kersr_2 : 64'd0 ;
    assign din__kersr_3 =  ( tst_sram_rw )? ksw_din_kersr_3 : 64'd0 ;
    assign din__kersr_4 =  ( tst_sram_rw )? ksw_din_kersr_4 : 64'd0 ;
    assign din__kersr_5 =  ( tst_sram_rw )? ksw_din_kersr_5 : 64'd0 ;
    assign din__kersr_6 =  ( tst_sram_rw )? ksw_din_kersr_6 : 64'd0 ;
    assign din__kersr_7 =  ( tst_sram_rw )? ksw_din_kersr_7 : 64'd0 ;
//----ker_top assign end------ 
