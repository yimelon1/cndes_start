//----generate by ker_r_io.py 
//----declare KER_SRAM read output signal start------ 
output reg cen_kersr_0 ,cen_kersr_1 ,cen_kersr_2 ,cen_kersr_3 ,cen_kersr_4 ,cen_kersr_5 ,cen_kersr_6 ,cen_kersr_7 ; 
output reg wen_kersr_0 ,wen_kersr_1 ,wen_kersr_2 ,wen_kersr_3 ,wen_kersr_4 ,wen_kersr_5 ,wen_kersr_6 ,wen_kersr_7 ; 
output reg [ 11 -1 : 0 ] addr_kersr_0 ,addr_kersr_1 ,addr_kersr_2 ,addr_kersr_3 ,addr_kersr_4 ,addr_kersr_5 ,addr_kersr_6 ,addr_kersr_7 ; 
output reg valid_0 ,valid_1 ,valid_2 ,valid_3 ,valid_4 ,valid_5 ,valid_6 ,valid_7 ; 
output reg final_0 ,final_1 ,final_2 ,final_3 ,final_4 ,final_5 ,final_6 ,final_7 ; 
//----generate by ker_r_io.py 
//----signal for sram read module io port start------ 
cen_kersr_0 ,wen_kersr_0 ,addr_kersr_0 ,valid_0 ,final_0 ,  //----signal for SRAM_0---------
cen_kersr_1 ,wen_kersr_1 ,addr_kersr_1 ,valid_1 ,final_1 ,  //----signal for SRAM_1---------
cen_kersr_2 ,wen_kersr_2 ,addr_kersr_2 ,valid_2 ,final_2 ,  //----signal for SRAM_2---------
cen_kersr_3 ,wen_kersr_3 ,addr_kersr_3 ,valid_3 ,final_3 ,  //----signal for SRAM_3---------
cen_kersr_4 ,wen_kersr_4 ,addr_kersr_4 ,valid_4 ,final_4 ,  //----signal for SRAM_4---------
cen_kersr_5 ,wen_kersr_5 ,addr_kersr_5 ,valid_5 ,final_5 ,  //----signal for SRAM_5---------
cen_kersr_6 ,wen_kersr_6 ,addr_kersr_6 ,valid_6 ,final_6 ,  //----signal for SRAM_6---------
cen_kersr_7 ,wen_kersr_7 ,addr_kersr_7 ,valid_7 ,final_7 ,  //----signal for SRAM_7---------
//----signal for sram read dec io port  end------ 
//----generate by ker_r_io.py 
//----ker_top sram read instance port start------ 
.cen_kersr_0 ( ksr_cen_kersr_0 ),.wen_kersr_0 ( ksr_wen_kersr_0 ),.addr_kersr_0 ( ksr_addr_kersr_0 ),.valid_0 ( ksr_valid_0 ),.final_0 ( ksr_final_0 ),//----declare ker_top SRAM_0---------
.cen_kersr_1 ( ksr_cen_kersr_1 ),.wen_kersr_1 ( ksr_wen_kersr_1 ),.addr_kersr_1 ( ksr_addr_kersr_1 ),.valid_1 ( ksr_valid_1 ),.final_1 ( ksr_final_1 ),//----declare ker_top SRAM_1---------
.cen_kersr_2 ( ksr_cen_kersr_2 ),.wen_kersr_2 ( ksr_wen_kersr_2 ),.addr_kersr_2 ( ksr_addr_kersr_2 ),.valid_2 ( ksr_valid_2 ),.final_2 ( ksr_final_2 ),//----declare ker_top SRAM_2---------
.cen_kersr_3 ( ksr_cen_kersr_3 ),.wen_kersr_3 ( ksr_wen_kersr_3 ),.addr_kersr_3 ( ksr_addr_kersr_3 ),.valid_3 ( ksr_valid_3 ),.final_3 ( ksr_final_3 ),//----declare ker_top SRAM_3---------
.cen_kersr_4 ( ksr_cen_kersr_4 ),.wen_kersr_4 ( ksr_wen_kersr_4 ),.addr_kersr_4 ( ksr_addr_kersr_4 ),.valid_4 ( ksr_valid_4 ),.final_4 ( ksr_final_4 ),//----declare ker_top SRAM_4---------
.cen_kersr_5 ( ksr_cen_kersr_5 ),.wen_kersr_5 ( ksr_wen_kersr_5 ),.addr_kersr_5 ( ksr_addr_kersr_5 ),.valid_5 ( ksr_valid_5 ),.final_5 ( ksr_final_5 ),//----declare ker_top SRAM_5---------
.cen_kersr_6 ( ksr_cen_kersr_6 ),.wen_kersr_6 ( ksr_wen_kersr_6 ),.addr_kersr_6 ( ksr_addr_kersr_6 ),.valid_6 ( ksr_valid_6 ),.final_6 ( ksr_final_6 ),//----declare ker_top SRAM_6---------
.cen_kersr_7 ( ksr_cen_kersr_7 ),.wen_kersr_7 ( ksr_wen_kersr_7 ),.addr_kersr_7 ( ksr_addr_kersr_7 ),.valid_7 ( ksr_valid_7 ),.final_7 ( ksr_final_7 ),//----declare ker_top SRAM_7---------
//----ker_top sram read instance port  end------ 
//----generate by ker_r_io.py 
//----declare ker_top sram read signal start------ 
wire ksr_cen_kersr_0 ,ksr_cen_kersr_1 ,ksr_cen_kersr_2 ,ksr_cen_kersr_3 ,ksr_cen_kersr_4 ,ksr_cen_kersr_5 ,ksr_cen_kersr_6 ,ksr_cen_kersr_7 ; 
wire ksr_wen_kersr_0 ,ksr_wen_kersr_1 ,ksr_wen_kersr_2 ,ksr_wen_kersr_3 ,ksr_wen_kersr_4 ,ksr_wen_kersr_5 ,ksr_wen_kersr_6 ,ksr_wen_kersr_7 ; 
wire [ 11 -1 : 0 ] ksr_addr_kersr_0 ,ksr_addr_kersr_1 ,ksr_addr_kersr_2 ,ksr_addr_kersr_3 ,ksr_addr_kersr_4 ,ksr_addr_kersr_5 ,ksr_addr_kersr_6 ,ksr_addr_kersr_7 ; 
wire ksr_valid_0 ,ksr_valid_1 ,ksr_valid_2 ,ksr_valid_3 ,ksr_valid_4 ,ksr_valid_5 ,ksr_valid_6 ,ksr_valid_7 ; 
wire ksr_final_0 ,ksr_final_1 ,ksr_final_2 ,ksr_final_3 ,ksr_final_4 ,ksr_final_5 ,ksr_final_6 ,ksr_final_7 ; 
//----declare ker_top sram read signal  end------ 
