from __future__ import print_function


# 
#ctrl+c :: python ker_ad.py
#----change-------------




need_ident = 1
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
else :
	idnt0 = ''
	cline = ''

with open("./ker_addr/keraddrs.v", "w") as fp:

	fp.write( '//----tb ker address count generate start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----keraddress_{0:d}---------\n".format(nfsram))

		fp.write("initial begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wait( cv_start_dly{2:d});{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}while( cv_start_dly{2:d} )begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}for( krr{2:d}=0 ; krr{2:d}<KERPART ; krr{2:d}=krr{2:d} +1 )begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}for( k{2:d}=0 ; k{2:d}<TE_FIR ; k{2:d}=k{2:d}+1 )begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}@(posedge  clk);{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}knn00 [{2:d}] = ker_sram_{2:d} [k{2:d} + krr{2:d}*36 ];{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}k{2:d}=0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}krr{2:d}=0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("end{1:s}".format(idnt0,cline,nfsram))
		
	fp.write( '//---- tb ker address count generate end------ \n')	



# 		fp.write("|....\n")