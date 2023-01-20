from __future__ import print_function


# kersram ver3 instance
#ctrl+c :: python ker_r_io.py
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

with open("./kersram_r/ker_r"+fname_idn+".v", "w") as fp:
	fp.write( '//----generate by ker_r_io.py \n' )
	fp.write( '//----declare KER_SRAM read output signal start------ \n')

	un_ident( fp ,8 , 'output reg ' , 'cen_kersr' )
	un_ident( fp ,8 , 'output reg ' , 'wen_kersr' )
	un_ident( fp ,8 , 'output reg [ 11 -1 : 0 ] ' , 'addr_kersr' )
	un_ident( fp ,8 , 'output reg ' , 'valid' )
	un_ident( fp ,8 , 'output reg ' , 'final' )



	fp.write( '//----generate by ker_r_io.py \n' )
	fp.write( '//----signal for sram read module io port start------ \n')

	for nfsram in range(  8 ):

		fp.write("{0:s}cen_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wen_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}addr_kersr_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}valid_{2:d} ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}final_{2:d} ,  ".format(idnt0,cline,nfsram))
		fp.write("//----signal for SRAM_{0:d}---------\n".format(nfsram))

	fp.write( '//----signal for sram read dec io port  end------ \n')	
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))
	fp.write("{1:s}".format(idnt0,cline,nfsram))


	fp.write( '//----generate by ker_r_io.py \n' )
	fp.write( '//----ker_top sram read instance port start------ \n')
	for nfsram in range(  8 ):

		

		fp.write("{0:s}.cen_kersr_{2:d} ( ksr_cen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.wen_kersr_{2:d} ( ksr_wen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.addr_kersr_{2:d} ( ksr_addr_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.valid_{2:d} ( ksr_valid_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.final_{2:d} ( ksr_final_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("//----declare ker_top SRAM_{0:d}---------\n".format(nfsram))

	fp.write( '//----ker_top sram read instance port  end------ \n')	

	fp.write( '//----generate by ker_r_io.py \n' )
	fp.write( '//----declare ker_top sram read signal start------ \n')

	un_ident( fp ,8 , 'wire ' , 'ksr_cen_kersr' )
	un_ident( fp ,8 , 'wire ' , 'ksr_wen_kersr' )
	un_ident( fp ,8 , 'wire [ 11 -1 : 0 ] ' , 'ksr_addr_kersr' )
	un_ident( fp ,8 , 'wire ' , 'ksr_valid' )
	un_ident( fp ,8 , 'wire ' , 'ksr_final' )


	fp.write( '//----declare ker_top sram read signal  end------ \n')
	# if need_ident ==1 :
	# 	for nfsram in range(  8 ):

	# 		fp.write("//----declare KER SRAM_{0:d}---------\n".format(nfsram))

	# 		fp.write("{0:s}output reg cen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	# 		fp.write("{0:s}output reg wen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	# 		fp.write("{0:s}output reg [ 11 -1 : 0 ] addr_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	# 		fp.write("{0:s}output reg [ 64 -1 : 0 ] dout_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	# 		fp.write("{0:s}output reg valid_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
	# 		fp.write("{0:s}output reg final_{2:d} ;{1:s}".format(idnt0,cline,nfsram))


	# 	fp.write( '//----declare KER_SRAM end------ \n')	
	# 	fp.write("{1:s}".format(idnt0,cline,nfsram))
	# 	fp.write("{1:s}".format(idnt0,cline,nfsram))
	# 	fp.write("{1:s}".format(idnt0,cline,nfsram))
	# else :
	# 	un_ident( fp ,8 , 'output reg ' , 'cen_kersr' )
	# 	un_ident( fp ,8 , 'output reg ' , 'wen_kersr' )
	# 	un_ident( fp ,8 , 'output reg [ 11 -1 : 0 ] ' , 'addr_kersr' )
	# 	un_ident( fp ,8 , 'output reg [ 64 -1 : 0 ] ' , 'dout_kersr' )
	# 	un_ident( fp ,8 , 'output reg ' , 'valid' )
	# 	un_ident( fp ,8 , 'output reg ' , 'final' )









	# fp.write( '//----ker_top sram write instance port start------ \n')
	# for nfsram in range(  8 ):

	# 	fp.write("//----declare ker_top SRAM_{0:d}---------\n".format(nfsram))

	# 	fp.write("{0:s}.cen_kersr_{2:d} ( ksw_cen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
	# 	fp.write("{0:s}.wen_kersr_{2:d} ( ksw_wen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
	# 	fp.write("{0:s}.addr_kersr_{2:d} ( ksw_addr_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
	# 	fp.write("{0:s}.din_kersr_{2:d} ( ksw_din_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))

	# fp.write( '//----ker_top sram write instance port  end------ \n')	
	# fp.write("{1:s}".format(idnt0,cline,nfsram))
	# fp.write("{1:s}".format(idnt0,cline,nfsram))
	# fp.write("{1:s}".format(idnt0,cline,nfsram))

	# fp.write( '//----ker_top sram write connect port  end------ \n')	
	# for nfsram in range(  8 ):

	# 	fp.write("//----declare ker_top SRAM_{0:d}---------\n".format(nfsram))

	# 	fp.write("{0:s}wire ksw_cen_kersr_{2:d};{1:s}".format(idnt0,cline,nfsram))
	# 	fp.write("{0:s}wire ksw_wen_kersr_{2:d};{1:s}".format(idnt0,cline,nfsram))
	# 	fp.write("{0:s}wire [ 11 -1 : 0 ]ksw_addr_kersr_{2:d};{1:s}".format(idnt0,cline,nfsram))
	# 	fp.write("{0:s}wire [ 64 -1 : 0 ]ksw_din_kersr_{2:d};{1:s}".format(idnt0,cline,nfsram))

	# fp.write( '//----ker_top sram write connect port  end------ \n')	

# 		fp.write("|....\n")