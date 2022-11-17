//----generate by ker_r_io.py 
//----declare KER_SRAM start------ 
//----declare KER SRAM_0---------
    output reg cen_kersr_0 ;
    output reg wen_kersr_0 ;
    output reg [ 11 -1 : 0 ] addr__kersr_0 ;
    output reg [ 64 -1 : 0 ] dout_kersr_0 ;
    output reg valid_0 ;
    output reg final_0 ;
//----declare KER SRAM_1---------
    output reg cen_kersr_1 ;
    output reg wen_kersr_1 ;
    output reg [ 11 -1 : 0 ] addr__kersr_1 ;
    output reg [ 64 -1 : 0 ] dout_kersr_1 ;
    output reg valid_1 ;
    output reg final_1 ;
//----declare KER SRAM_2---------
    output reg cen_kersr_2 ;
    output reg wen_kersr_2 ;
    output reg [ 11 -1 : 0 ] addr__kersr_2 ;
    output reg [ 64 -1 : 0 ] dout_kersr_2 ;
    output reg valid_2 ;
    output reg final_2 ;
//----declare KER SRAM_3---------
    output reg cen_kersr_3 ;
    output reg wen_kersr_3 ;
    output reg [ 11 -1 : 0 ] addr__kersr_3 ;
    output reg [ 64 -1 : 0 ] dout_kersr_3 ;
    output reg valid_3 ;
    output reg final_3 ;
//----declare KER SRAM_4---------
    output reg cen_kersr_4 ;
    output reg wen_kersr_4 ;
    output reg [ 11 -1 : 0 ] addr__kersr_4 ;
    output reg [ 64 -1 : 0 ] dout_kersr_4 ;
    output reg valid_4 ;
    output reg final_4 ;
//----declare KER SRAM_5---------
    output reg cen_kersr_5 ;
    output reg wen_kersr_5 ;
    output reg [ 11 -1 : 0 ] addr__kersr_5 ;
    output reg [ 64 -1 : 0 ] dout_kersr_5 ;
    output reg valid_5 ;
    output reg final_5 ;
//----declare KER SRAM_6---------
    output reg cen_kersr_6 ;
    output reg wen_kersr_6 ;
    output reg [ 11 -1 : 0 ] addr__kersr_6 ;
    output reg [ 64 -1 : 0 ] dout_kersr_6 ;
    output reg valid_6 ;
    output reg final_6 ;
//----declare KER SRAM_7---------
    output reg cen_kersr_7 ;
    output reg wen_kersr_7 ;
    output reg [ 11 -1 : 0 ] addr__kersr_7 ;
    output reg [ 64 -1 : 0 ] dout_kersr_7 ;
    output reg valid_7 ;
    output reg final_7 ;
//----declare KER_SRAM end------ 



//----ker_top sram write dec io port start------ 
//----declare ker_top SRAM_0---------
    cen_kersr_0 ,
    wen_kersr_0 ,
    addr__kersr_0 ,
    dout_kersr_0 ,
    valid_0 ,
    final_0 ,
//----declare ker_top SRAM_1---------
    cen_kersr_1 ,
    wen_kersr_1 ,
    addr__kersr_1 ,
    dout_kersr_1 ,
    valid_1 ,
    final_1 ,
//----declare ker_top SRAM_2---------
    cen_kersr_2 ,
    wen_kersr_2 ,
    addr__kersr_2 ,
    dout_kersr_2 ,
    valid_2 ,
    final_2 ,
//----declare ker_top SRAM_3---------
    cen_kersr_3 ,
    wen_kersr_3 ,
    addr__kersr_3 ,
    dout_kersr_3 ,
    valid_3 ,
    final_3 ,
//----declare ker_top SRAM_4---------
    cen_kersr_4 ,
    wen_kersr_4 ,
    addr__kersr_4 ,
    dout_kersr_4 ,
    valid_4 ,
    final_4 ,
//----declare ker_top SRAM_5---------
    cen_kersr_5 ,
    wen_kersr_5 ,
    addr__kersr_5 ,
    dout_kersr_5 ,
    valid_5 ,
    final_5 ,
//----declare ker_top SRAM_6---------
    cen_kersr_6 ,
    wen_kersr_6 ,
    addr__kersr_6 ,
    dout_kersr_6 ,
    valid_6 ,
    final_6 ,
//----declare ker_top SRAM_7---------
    cen_kersr_7 ,
    wen_kersr_7 ,
    addr__kersr_7 ,
    dout_kersr_7 ,
    valid_7 ,
    final_7 ,
//----ker_top sram write dec io port  end------ 



//----ker_top sram write instance port start------ 
//----declare ker_top SRAM_0---------
    .cen_kersr_0 ( ksw_cen_kersr_0 ),
    .wen_kersr_0 ( ksw_wen_kersr_0 ),
    .addr__kersr_0 ( ksw_addr__kersr_0 ),
    .din_kersr_0 ( ksw_din_kersr_0 ),
//----declare ker_top SRAM_1---------
    .cen_kersr_1 ( ksw_cen_kersr_1 ),
    .wen_kersr_1 ( ksw_wen_kersr_1 ),
    .addr__kersr_1 ( ksw_addr__kersr_1 ),
    .din_kersr_1 ( ksw_din_kersr_1 ),
//----declare ker_top SRAM_2---------
    .cen_kersr_2 ( ksw_cen_kersr_2 ),
    .wen_kersr_2 ( ksw_wen_kersr_2 ),
    .addr__kersr_2 ( ksw_addr__kersr_2 ),
    .din_kersr_2 ( ksw_din_kersr_2 ),
//----declare ker_top SRAM_3---------
    .cen_kersr_3 ( ksw_cen_kersr_3 ),
    .wen_kersr_3 ( ksw_wen_kersr_3 ),
    .addr__kersr_3 ( ksw_addr__kersr_3 ),
    .din_kersr_3 ( ksw_din_kersr_3 ),
//----declare ker_top SRAM_4---------
    .cen_kersr_4 ( ksw_cen_kersr_4 ),
    .wen_kersr_4 ( ksw_wen_kersr_4 ),
    .addr__kersr_4 ( ksw_addr__kersr_4 ),
    .din_kersr_4 ( ksw_din_kersr_4 ),
//----declare ker_top SRAM_5---------
    .cen_kersr_5 ( ksw_cen_kersr_5 ),
    .wen_kersr_5 ( ksw_wen_kersr_5 ),
    .addr__kersr_5 ( ksw_addr__kersr_5 ),
    .din_kersr_5 ( ksw_din_kersr_5 ),
//----declare ker_top SRAM_6---------
    .cen_kersr_6 ( ksw_cen_kersr_6 ),
    .wen_kersr_6 ( ksw_wen_kersr_6 ),
    .addr__kersr_6 ( ksw_addr__kersr_6 ),
    .din_kersr_6 ( ksw_din_kersr_6 ),
//----declare ker_top SRAM_7---------
    .cen_kersr_7 ( ksw_cen_kersr_7 ),
    .wen_kersr_7 ( ksw_wen_kersr_7 ),
    .addr__kersr_7 ( ksw_addr__kersr_7 ),
    .din_kersr_7 ( ksw_din_kersr_7 ),
//----ker_top sram write instance port  end------ 



//----ker_top sram write connect port  end------ 
//----declare ker_top SRAM_0---------
    wire ksw_cen_kersr_0;
    wire ksw_wen_kersr_0;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_0;
    wire [ 64 -1 : 0 ]ksw_din_kersr_0;
//----declare ker_top SRAM_1---------
    wire ksw_cen_kersr_1;
    wire ksw_wen_kersr_1;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_1;
    wire [ 64 -1 : 0 ]ksw_din_kersr_1;
//----declare ker_top SRAM_2---------
    wire ksw_cen_kersr_2;
    wire ksw_wen_kersr_2;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_2;
    wire [ 64 -1 : 0 ]ksw_din_kersr_2;
//----declare ker_top SRAM_3---------
    wire ksw_cen_kersr_3;
    wire ksw_wen_kersr_3;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_3;
    wire [ 64 -1 : 0 ]ksw_din_kersr_3;
//----declare ker_top SRAM_4---------
    wire ksw_cen_kersr_4;
    wire ksw_wen_kersr_4;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_4;
    wire [ 64 -1 : 0 ]ksw_din_kersr_4;
//----declare ker_top SRAM_5---------
    wire ksw_cen_kersr_5;
    wire ksw_wen_kersr_5;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_5;
    wire [ 64 -1 : 0 ]ksw_din_kersr_5;
//----declare ker_top SRAM_6---------
    wire ksw_cen_kersr_6;
    wire ksw_wen_kersr_6;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_6;
    wire [ 64 -1 : 0 ]ksw_din_kersr_6;
//----declare ker_top SRAM_7---------
    wire ksw_cen_kersr_7;
    wire ksw_wen_kersr_7;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_7;
    wire [ 64 -1 : 0 ]ksw_din_kersr_7;
//----ker_top sram write connect port  end------ 
