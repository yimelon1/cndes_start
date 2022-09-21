from __future__ import print_function


# 
#ctrl+c :: python tb_bia.py
#----change-------------


# always@( * )begin

# 	bi_con = 	(cv_start_dly0 ) ? bias_reg_0[krr0] : 'd0 ;
# 	bi_offset = (cv_start_dly0 ) ? krr0 : 'd0 ;

# end

	# bi_con_n_dly0ed <= bi_con_n;
	# bi_con_n_dly0 <= bi_con_n_dly0ed;
	# bi_offset_n_dly0ed <= bi_offset_n;
	# bi_offset_n_dly0 <= bi_offset_n_dly0ed;	// cause bias need to Synchronize with final act and ker 


need_ident = 1
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
else :
	idnt0 = ''
	cline = ''

with open("./tb_bia/tb_bia.v", "w") as fp:
	fp.write( '//----bias declare start------ \n')

	fp.write("reg signed [31:0]")
	for nfsram in range(  8 ):
		fp.write(" bi_con_{2:d} ".format(idnt0,cline,nfsram))
		if( nfsram <= 6):
			fp.write( ',')
	fp.write( ';\n')

	fp.write("reg signed [3:0]")
	for nfsram in range(  8 ):
		fp.write(" bi_offset_{2:d} ".format(idnt0,cline,nfsram))
		if( nfsram <= 6):
			fp.write( ',')
	fp.write( ';\n')

	for nfsram in range(  8 ):
		fp.write("reg signed [31:0]	bi_con_{2:d}_dly0ed  	;{1:s}".format(idnt0,cline,nfsram))
	for nfsram in range(  8 ):
		fp.write("reg [3:0]  bi_offset_{2:d}_dly0ed  ;{1:s}".format(idnt0,cline,nfsram))
	for nfsram in range(  8 ):
		fp.write("reg signed [31:0]	bi_con_{2:d}_dly0 ;{1:s}".format(idnt0,cline,nfsram))
	for nfsram in range(  8 ):
		fp.write("reg [3:0]  bi_offset_{2:d}_dly0  ;{1:s}".format(idnt0,cline,nfsram))

	fp.write( '//----bias declare end------ \n')
	fp.write( '//---- ------ \n')
	fp.write( '//---- ------ \n')

	fp.write( '//----bias data combinational start------ \n')
	fp.write( 'always@( * )begin\n')

	for nfsram in range(  8 ):

		# fp.write("//----bias data for kerSR{0:d} ---------\n".format(nfsram))
		fp.write("{0:s}bi_con_{2:d} = 	(cv_start_dly{2:d} ) ? bias_reg_{2:d}[krr{2:d}] : 'd0 ;{0:s}//for kerSR{2:d}--{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}bi_offset_{2:d} = (cv_start_dly{2:d} ) ? krr{2:d} : 'd0 ;{0:s}//for kerSR{2:d}--{1:s}".format(idnt0,cline,nfsram))

	fp.write("end{1:s}".format(idnt0,cline,nfsram))


	fp.write( '//----bias data combinational end------ \n')	

	fp.write( '//----bias data seq start------ \n')
	fp.write( 'always@(posedge clk )begin\n')
	for nfsram in range(  8 ):
		fp.write("//----bias data for kerSR{0:d} ---------\n".format(nfsram))
		fp.write("{0:s}bi_con_{2:d}_dly0ed <= bi_con_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}bi_con_{2:d}_dly0 <= bi_con_{2:d}_dly0ed;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}bi_offset_{2:d}_dly0ed <= bi_offset_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}bi_offset_{2:d}_dly0 <= bi_offset_{2:d}_dly0ed;	// cause bias need to Synchronize with final act and ker{1:s}".format(idnt0,cline,nfsram))

	fp.write("end{1:s}".format(idnt0,cline,nfsram))
	fp.write( '//----bias data seq end------ \n')	

# 		fp.write("|....\n")