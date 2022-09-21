from __future__ import print_function


# 
#ctrl+c :: python ru_get_stay.py
#----change-------------

		# if( pe0_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin
		# 	if ( pe1_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin
		# 		pe0_test_stay <= pe1_test_stay  ;
		# 	end
		# 	else begin
		# 		pe0_test_stay <= pe0_rsu_stay ;
		# 	end
		# end
		# else  begin
		# 	pe0_test_stay <= pe0_test_stay  ;
		# end


need_ident = 1
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
else :
	idnt0 = ''
	cline = ''

with open("./ru/ruget.v", "w") as fp:

	fp.write( '//---- pe_result mod start------ \n')
	for nfsram in range(  7 ):

		fp.write("//----pe{0:d}_result---------\n".format(nfsram))

		fp.write("if( pe{2:d}_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}if ( pe{3:d}_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin{1:s}".format(idnt0,cline,nfsram,nfsram+1))
		fp.write("{0:s}{0:s}pe{2:d}_test_stay <= pe{3:d}_test_stay  ;{1:s}".format(idnt0,cline,nfsram,nfsram+1))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}else begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}pe{2:d}_test_stay <= pe{2:d}_rsu_stay ;{1:s}".format(idnt0,cline,nfsram,nfsram+1))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("end{1:s}".format(idnt0,cline,nfsram))
		fp.write("else begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}pe{2:d}_test_stay <= pe{2:d}_test_stay  ;{1:s}".format(idnt0,cline,nfsram,nfsram+1))
		fp.write("end{1:s}".format(idnt0,cline,nfsram))

		
	fp.write( '//---- pe_result mod end------ \n')	



# 		fp.write("|....\n")