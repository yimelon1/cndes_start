from __future__ import print_function


# kersram ver3 instance
#ctrl+c :: python ker_top_mod.py
#----change-------------



need_ident = 0
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
	fname_idn = '_withidn'
else :
	idnt0 = ''
	cline = ''
	fname_idn = ''

def un_ident(  file , num , dec_type , port_name ):
	file.write("{0}".format(dec_type))
	for i in range( num ):
		if( i == 7):
			file.write("{1:s}_{2:d} ; {0:s}".format( '\n' ,port_name , i))
		else :
			file.write("{1:s}_{2:d} ,".format(  '\n' ,port_name , i))

with open("./kersram_top/kertop_"+fname_idn+".v", "w") as fp:
	fp.write( '//----generated by ker_top_mod.py------ \n')
	fp.write( '//----top port list with rw SRAM reference------ \n')
	un_ident( fp ,8 , ' ' , 'dout_kersr' )
	un_ident( fp ,8 , ' ' , 'ksr_valid' )
	un_ident( fp ,8 , ' ' , 'ksr_final' )
	fp.write( '//----top port list with rw SRAM reference------ \n')
	
	fp.write( '//----generated by ker_top_mod.py------ \n')
	un_ident( fp ,8 , 'output wire [ 64 -1 : 0 ] ' , 'dout_kersr' )
	un_ident( fp ,8 , 'output wire ' , 'ksr_valid' )
	un_ident( fp ,8 , 'output wire ' , 'ksr_final' )
	# declare
	fp.write( '//----generated by ker_top_mod.py------ \n')
	fp.write( '//---- kersram top declare KER_SRAM start------ \n')

	un_ident( fp ,8 , 'wire ' , 'cen_kersr' )
	un_ident( fp ,8 , 'wire ' , 'wen_kersr' )
	un_ident( fp ,8 , 'wire [ 11 -1 : 0 ] ' , 'addr_kersr' )

	un_ident( fp ,8 , 'wire [ 64 -1 : 0 ] ' , 'din_kersr' )

	fp.write( '//---- kersram top declare KER_SRAM end------ \n')	

	fp.write( '\n')	

	fp.write( '//----declare ker_top sram read signal start------ \n')
	un_ident( fp ,8 , 'wire ' , 'ksr_cen_kersr' )
	un_ident( fp ,8 , 'wire ' , 'ksr_wen_kersr' )
	un_ident( fp ,8 , 'wire [ 11 -1 : 0 ] ' , 'ksr_addr_kersr' )

	fp.write( '//----declare ker_top sram read signal  end------ \n')

	fp.write( '\n')

	fp.write( '//----declare ker_top sram write signal start------ \n')
	un_ident( fp ,8 , 'wire ' , 'ksw_cen_kersr' )
	un_ident( fp ,8 , 'wire ' , 'ksw_wen_kersr' )
	un_ident( fp ,8 , 'wire [ 11 -1 : 0 ] ' , 'ksw_addr_kersr' )
	un_ident( fp ,8 , 'wire [ 64 -1 : 0 ] ' , 'ksw_din_kersr' )
	fp.write( '//----declare ker_top sram write signal  end------ \n')

	# instance
	fp.write( '//----generated by ker_top_mod.py------ \n')
	fp.write( '//----instance KER_SRAM start------ \n')
	for nfsram in range(  8 ):

		

		fp.write("KER_SRAM ker_{2:d}({1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.Q{0:s}(	dout_kersr_{2:d} ),	{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.CLK{0:s}( clk ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.CEN{0:s}( cen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.WEN{0:s}( wen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.A{0:s}( addr_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.D{0:s}( din_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.EMA{0:s}( 3'b0 ){1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s});{1:s}".format(idnt0,cline,nfsram))
		fp.write("//----instance KER SRAM_{0:d}---------\n".format(nfsram))


	fp.write( '//----instance KER_SRAM end------ \n')	



	# assign
	fp.write( '//----generated by ker_top_mod.py------ \n')	
	fp.write( '//----ker_top assign start------ \n')	
	fp.write( '//----ker_top assign cen ------ \n')	
	for nfsram in range(  8 ):
		fp.write("{0:s}assign cen_kersr_{2:d} = ( tst_sram_rw )? ksw_cen_kersr_{2:d} : ksr_cen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker_top assign wen ------ \n')	
	for nfsram in range(  8 ):
		fp.write("{0:s}assign wen_kersr_{2:d} = ( tst_sram_rw )? ksw_wen_kersr_{2:d} : ksr_wen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker_top assign addr ------ \n')	
	for nfsram in range(  8 ):
		fp.write("{0:s}assign addr_kersr_{2:d} =  ( tst_sram_rw )? ksw_addr_kersr_{2:d} : ksr_addr_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker_top assign din ------ \n')	
	for nfsram in range(  8 ):
		fp.write("{0:s}assign din_kersr_{2:d} =  ( tst_sram_rw )? ksw_din_kersr_{2:d} : 64'd0 ;{1:s}".format(idnt0,cline,nfsram))


	fp.write( '//----ker_top assign end------ \n')	

	fp.write( '\n')	
	fp.write( '\n')	
	fp.write( '//----generated by ker_top_mod.py------ \n')
	fp.write( '//----top port list for other module instance------ \n')
	for nfsram in range( 8 ):
		fp.write("{0:s}.dout_kersr_{2:d} ( dout_kersr_{2:d} ), {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ksr_valid_{2:d}  ( ksr_valid_{2:d} ), {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ksr_final_{2:d}  ( ksr_final_{2:d} ), {1:s}".format(idnt0,cline,nfsram))
		fp.write("//----instance KER top_{0:d}---------\n".format(nfsram))

# 		fp.write("|....\n")