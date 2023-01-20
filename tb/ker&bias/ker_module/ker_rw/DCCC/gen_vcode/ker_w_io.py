from __future__ import print_function


# kersram ver3 instance
#ctrl+c :: python ker_w_io.py
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



with open("./kersram_w/kerw"+fname_idn+".v", "w") as fp:


	fp.write( '//----declare KER_SRAM start------ \n')
	for nfsram in range(  8 ):

		fp.write("{0:s}output reg cen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}output reg wen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}output reg [ 11 -1 : 0 ] addr_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}output reg [ 64 -1 : 0 ] din_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("//----declare KER SRAM_{0:d}---------\n".format(nfsram))

	fp.write( '//----declare KER_SRAM end------ \n')	
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	
	fp.write( '//----ker_top sram write dec io port start------ \n')
	for nfsram in range(  8 ):

		

		fp.write("{0:s}cen_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wen_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}addr_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}din_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("//----declare ker_top SRAM_{0:d}---------\n".format(nfsram))

	fp.write( '//----ker_top sram write dec io port  end------ \n')	
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))


	fp.write( '//----generate by ker_w_io.py \n' )
	fp.write( '//----ker_top sram write instance port start------ \n')
	for nfsram in range(  8 ):

		

		fp.write("{0:s}.cen_kersr_{2:d} ( ksw_cen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.wen_kersr_{2:d} ( ksw_wen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.addr_kersr_{2:d} ( ksw_addr_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.din_kersr_{2:d} ( ksw_din_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("//----declare ker_top SRAM_{0:d}---------\n".format(nfsram))

	fp.write( '//----ker_top sram write instance port  end------ \n')	
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))



	fp.write( '//----generate by ker_w_io.py \n' )
	fp.write( '//----declare ker_top sram write signal start------ \n')

	un_ident( fp ,8 , 'wire ' , 'ksw_cen_kersr' )
	un_ident( fp ,8 , 'wire ' , 'ksw_wen_kersr' )
	un_ident( fp ,8 , 'wire [ 11 -1 : 0 ] ' , 'ksw_addr_kersr' )
	un_ident( fp ,8 , 'wire [ 64 -1 : 0 ] ' , 'ksw_din_kersr' )

	fp.write( '//----declare ker_top sram write signal  end------ \n')
# 		fp.write("|....\n")