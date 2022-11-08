from __future__ import print_function


# kersram ver3 instance
#ctrl+c :: python ker_top_genassign.py
#----change-------------



need_ident = 1
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
	fname_idn = '_withidn'
else :
	idnt0 = ''
	cline = ''
	fname_idn = ''


# assign cen_kersr_0 = ( tst_sram_rw )? ksw_cen_kersr_0 : tst_cen_kersr_0 ;


# assign wen_kersr_0 = ( tst_sram_rw )? ksw_wen_kersr_0 : tst_wen_kersr_0 ;

# assign addr__kersr_0 =  ( tst_sram_rw )? ksw_addr__kersr_0 : tst_addr__kersr_0 ;

# assign din__kersr_0 =  ( tst_sram_rw )? ksw_din_kersr_0 : 64'd0 ;


with open("./kersram_w/kertop_assign"+fname_idn+".v", "w") as fp:

	fp.write( '//----ker_top assign start------ \n')	
	fp.write( '//----ker_top assign cen ------ \n')	
	for nfsram in range(  8 ):
		fp.write("{0:s}assign cen_kersr_{2:d} = ( tst_sram_rw )? ksw_cen_kersr_{2:d} : tst_cen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker_top assign wen ------ \n')	
	for nfsram in range(  8 ):
		fp.write("{0:s}assign wen_kersr_{2:d} = ( tst_sram_rw )? ksw_wen_kersr_{2:d} : tst_wen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker_top assign addr ------ \n')	
	for nfsram in range(  8 ):
		fp.write("{0:s}assign addr__kersr_{2:d} =  ( tst_sram_rw )? ksw_addr__kersr_{2:d} : tst_addr__kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker_top assign din ------ \n')	
	for nfsram in range(  8 ):
		fp.write("{0:s}assign din__kersr_{2:d} =  ( tst_sram_rw )? ksw_din_kersr_{2:d} : 64'd0 ;{1:s}".format(idnt0,cline,nfsram))


	fp.write( '//----ker_top assign end------ \n')	

# 		fp.write("|....\n")