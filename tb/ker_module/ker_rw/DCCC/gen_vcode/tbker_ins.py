from __future__ import print_function


# kersram ver3 instance
#ctrl+c :: python tbker_ins.py
#----change-------------
#

need_ident = 1
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
	fname_idn = '_withidn'
else :
	idnt0 = ''
	cline = ''
	fname_idn = ''


with open("./sram_ins/tbker_dec"+fname_idn+".v", "w") as fp:
	fp.write( '//----generate by tbker_ins.py \n' )
	fp.write( '//----tb declare KER_SRAM start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----tb declare KER SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}reg tst_cen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}reg tst_wen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}reg [ 11 -1 : 0 ] tst_addr__kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}reg [ 64 -1 : 0 ] dout_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))


	fp.write( '//----tb declare KER_SRAM end------ \n')	
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker w test input declare start------ \n')	
	
	fp.write("{0:s}input wire tst_sram_rw ;{1:s}".format(idnt0,cline,nfsram))
	for nfsram in range(  8 ):
		fp.write("//----tb declare KER SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}input wire tst_cen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}input wire tst_wen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}input wire [ 11 -1 : 0 ] tst_addr__kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}output wire [ 64 -1 : 0 ] dout_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker w test input declare end------ \n')	


with open("./sram_ins/tbker_indec"+fname_idn+".v", "w") as fp:

	# fp.write( '//----declare KER_SRAM start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----test KER SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}tst_cen_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}tst_wen_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}tst_addr__kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		if ( nfsram == 7 ):
			fp.write("{0:s}dout_kersr_{2:d} {1:s}".format(idnt0,cline,nfsram))
		else :
			fp.write("{0:s}dout_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
	fp.write( "{1:s}".format(idnt0,cline,nfsram))
	fp.write( "{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker write for tb instance start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----test KER SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}.tst_cen_kersr_{2:d} ( tst_cen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.tst_wen_kersr_{2:d} ( tst_wen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.tst_addr__kersr_{2:d} ( tst_addr__kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		if ( nfsram == 7 ):
			fp.write("{0:s}.dout_kersr_{2:d} ( dout_kersr_{2:d} ){1:s}".format(idnt0,cline,nfsram))
		else :
			fp.write("{0:s}.dout_kersr_{2:d} ( dout_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))

	fp.write( '//----ker write for tb instance end------ \n')
	