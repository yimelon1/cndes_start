from __future__ import print_function


# kersram ver3 instance
#ctrl+c :: python ker_w_io.py
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



with open("./kersram_w/kerw"+fname_idn+".v", "w") as fp:

	fp.write( '//----declare KER_SRAM start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----declare KER SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}output reg cen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}output reg wen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}output reg [ 11 -1 : 0 ] addr__kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}output reg [ 64 -1 : 0 ] din_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))


	fp.write( '//----declare KER_SRAM end------ \n')	
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----ker_top sram write dec io port start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----declare ker_top SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}cen_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wen_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}addr__kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}din_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))

	fp.write( '//----ker_top sram write dec io port  end------ \n')	
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))

	fp.write( '//----ker_top sram write instance port start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----declare ker_top SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}.cen_kersr_{2:d} ( ksw_cen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.wen_kersr_{2:d} ( ksw_wen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.addr__kersr_{2:d} ( ksw_addr__kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.din_kersr_{2:d} ( ksw_din_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))

	fp.write( '//----ker_top sram write instance port  end------ \n')	
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))

	fp.write( '//----ker_top sram write connect port  end------ \n')	
	for nfsram in range(  8 ):

		fp.write("//----declare ker_top SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}wire ksw_cen_kersr_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wire ksw_wen_kersr_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wire [ 11 -1 : 0 ]ksw_addr__kersr_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wire [ 64 -1 : 0 ]ksw_din_kersr_{2:d};{1:s}".format(idnt0,cline,nfsram))

	fp.write( '//----ker_top sram write connect port  end------ \n')	

# 		fp.write("|....\n")