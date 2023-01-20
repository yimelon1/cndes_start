//----declare KER_SRAM start------ 
output reg cen_kersr_0 ;output reg wen_kersr_0 ;output reg [ 11 -1 : 0 ] addr_kersr_0 ;output reg [ 64 -1 : 0 ] din_kersr_0 ;//----declare KER SRAM_0---------
output reg cen_kersr_1 ;output reg wen_kersr_1 ;output reg [ 11 -1 : 0 ] addr_kersr_1 ;output reg [ 64 -1 : 0 ] din_kersr_1 ;//----declare KER SRAM_1---------
output reg cen_kersr_2 ;output reg wen_kersr_2 ;output reg [ 11 -1 : 0 ] addr_kersr_2 ;output reg [ 64 -1 : 0 ] din_kersr_2 ;//----declare KER SRAM_2---------
output reg cen_kersr_3 ;output reg wen_kersr_3 ;output reg [ 11 -1 : 0 ] addr_kersr_3 ;output reg [ 64 -1 : 0 ] din_kersr_3 ;//----declare KER SRAM_3---------
output reg cen_kersr_4 ;output reg wen_kersr_4 ;output reg [ 11 -1 : 0 ] addr_kersr_4 ;output reg [ 64 -1 : 0 ] din_kersr_4 ;//----declare KER SRAM_4---------
output reg cen_kersr_5 ;output reg wen_kersr_5 ;output reg [ 11 -1 : 0 ] addr_kersr_5 ;output reg [ 64 -1 : 0 ] din_kersr_5 ;//----declare KER SRAM_5---------
output reg cen_kersr_6 ;output reg wen_kersr_6 ;output reg [ 11 -1 : 0 ] addr_kersr_6 ;output reg [ 64 -1 : 0 ] din_kersr_6 ;//----declare KER SRAM_6---------
output reg cen_kersr_7 ;output reg wen_kersr_7 ;output reg [ 11 -1 : 0 ] addr_kersr_7 ;output reg [ 64 -1 : 0 ] din_kersr_7 ;//----declare KER SRAM_7---------
//----declare KER_SRAM end------ 
//----ker_top sram write dec io port start------ 
cen_kersr_0 ,wen_kersr_0 ,addr_kersr_0 ,din_kersr_0 ,//----declare ker_top SRAM_0---------
cen_kersr_1 ,wen_kersr_1 ,addr_kersr_1 ,din_kersr_1 ,//----declare ker_top SRAM_1---------
cen_kersr_2 ,wen_kersr_2 ,addr_kersr_2 ,din_kersr_2 ,//----declare ker_top SRAM_2---------
cen_kersr_3 ,wen_kersr_3 ,addr_kersr_3 ,din_kersr_3 ,//----declare ker_top SRAM_3---------
cen_kersr_4 ,wen_kersr_4 ,addr_kersr_4 ,din_kersr_4 ,//----declare ker_top SRAM_4---------
cen_kersr_5 ,wen_kersr_5 ,addr_kersr_5 ,din_kersr_5 ,//----declare ker_top SRAM_5---------
cen_kersr_6 ,wen_kersr_6 ,addr_kersr_6 ,din_kersr_6 ,//----declare ker_top SRAM_6---------
cen_kersr_7 ,wen_kersr_7 ,addr_kersr_7 ,din_kersr_7 ,//----declare ker_top SRAM_7---------
//----ker_top sram write dec io port  end------ 
//----generate by ker_w_io.py 
//----ker_top sram write instance port start------ 
.cen_kersr_0 ( ksw_cen_kersr_0 ),.wen_kersr_0 ( ksw_wen_kersr_0 ),.addr_kersr_0 ( ksw_addr_kersr_0 ),.din_kersr_0 ( ksw_din_kersr_0 ),//----declare ker_top SRAM_0---------
.cen_kersr_1 ( ksw_cen_kersr_1 ),.wen_kersr_1 ( ksw_wen_kersr_1 ),.addr_kersr_1 ( ksw_addr_kersr_1 ),.din_kersr_1 ( ksw_din_kersr_1 ),//----declare ker_top SRAM_1---------
.cen_kersr_2 ( ksw_cen_kersr_2 ),.wen_kersr_2 ( ksw_wen_kersr_2 ),.addr_kersr_2 ( ksw_addr_kersr_2 ),.din_kersr_2 ( ksw_din_kersr_2 ),//----declare ker_top SRAM_2---------
.cen_kersr_3 ( ksw_cen_kersr_3 ),.wen_kersr_3 ( ksw_wen_kersr_3 ),.addr_kersr_3 ( ksw_addr_kersr_3 ),.din_kersr_3 ( ksw_din_kersr_3 ),//----declare ker_top SRAM_3---------
.cen_kersr_4 ( ksw_cen_kersr_4 ),.wen_kersr_4 ( ksw_wen_kersr_4 ),.addr_kersr_4 ( ksw_addr_kersr_4 ),.din_kersr_4 ( ksw_din_kersr_4 ),//----declare ker_top SRAM_4---------
.cen_kersr_5 ( ksw_cen_kersr_5 ),.wen_kersr_5 ( ksw_wen_kersr_5 ),.addr_kersr_5 ( ksw_addr_kersr_5 ),.din_kersr_5 ( ksw_din_kersr_5 ),//----declare ker_top SRAM_5---------
.cen_kersr_6 ( ksw_cen_kersr_6 ),.wen_kersr_6 ( ksw_wen_kersr_6 ),.addr_kersr_6 ( ksw_addr_kersr_6 ),.din_kersr_6 ( ksw_din_kersr_6 ),//----declare ker_top SRAM_6---------
.cen_kersr_7 ( ksw_cen_kersr_7 ),.wen_kersr_7 ( ksw_wen_kersr_7 ),.addr_kersr_7 ( ksw_addr_kersr_7 ),.din_kersr_7 ( ksw_din_kersr_7 ),//----declare ker_top SRAM_7---------
//----ker_top sram write instance port  end------ 
//----generate by ker_w_io.py 
//----declare ker_top sram write signal start------ 
wire ksw_cen_kersr_0 ,ksw_cen_kersr_1 ,ksw_cen_kersr_2 ,ksw_cen_kersr_3 ,ksw_cen_kersr_4 ,ksw_cen_kersr_5 ,ksw_cen_kersr_6 ,ksw_cen_kersr_7 ; 
wire ksw_wen_kersr_0 ,ksw_wen_kersr_1 ,ksw_wen_kersr_2 ,ksw_wen_kersr_3 ,ksw_wen_kersr_4 ,ksw_wen_kersr_5 ,ksw_wen_kersr_6 ,ksw_wen_kersr_7 ; 
wire [ 11 -1 : 0 ] ksw_addr_kersr_0 ,ksw_addr_kersr_1 ,ksw_addr_kersr_2 ,ksw_addr_kersr_3 ,ksw_addr_kersr_4 ,ksw_addr_kersr_5 ,ksw_addr_kersr_6 ,ksw_addr_kersr_7 ; 
wire [ 64 -1 : 0 ] ksw_din_kersr_0 ,ksw_din_kersr_1 ,ksw_din_kersr_2 ,ksw_din_kersr_3 ,ksw_din_kersr_4 ,ksw_din_kersr_5 ,ksw_din_kersr_6 ,ksw_din_kersr_7 ; 
//----declare ker_top sram write signal  end------ 
