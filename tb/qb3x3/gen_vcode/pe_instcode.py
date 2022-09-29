from __future__ import print_function


# pe ver3 instance
#ctrl+c :: python pe_instcode.py
#----change-------------


need_ident = 0
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
	fname_idn = 'idn'
else :
	idnt0 = ''
	cline = ''
	fname_idn = ''

with open("./pe_inst/peinst_"+fname_idn+".v", "w") as fp:

	fp.write( '//----instance pe with bias start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----pe row0 col_{0:d}---------\n".format(nfsram))

		fp.write("pe_8e  #(")
		fp.write("    .ELE_BITS(	8 	), ")
		fp.write("    .OUT_BITS(	32	), ")
		fp.write("    .BIAS_BITS(	32	) ")
		fp.write("\n")
		fp.write("{0:s})pe_r0_col_{2:d}(".format(idnt0,cline,nfsram))
		fp.write(".clk ( clk ),  ")
		fp.write(".reset ( reset ), \n")

		fp.write("{0:s}.act_0( act_shf[{2:d}][63-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.act_1( act_shf[{2:d}][55-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.act_2( act_shf[{2:d}][47-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.act_3( act_shf[{2:d}][39-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.act_4( act_shf[{2:d}][31-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.act_5( act_shf[{2:d}][23-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.act_6( act_shf[{2:d}][15-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.act_7( act_shf[{2:d}][ 7-:8] ) , {1:s}".format(idnt0,cline,nfsram))

		fp.write("{0:s}.valid_in( valid_fg_dly{2:d} ) ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.final_in( final_fg_dly{2:d} ) ,{1:s}".format(idnt0,cline,nfsram))
		fp.write("\n")
		fp.write("//---- kernel ----//\n")
		fp.write("{0:s}.ker_0( ker_shf[{2:d}][63-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ker_1( ker_shf[{2:d}][55-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ker_2( ker_shf[{2:d}][47-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ker_3( ker_shf[{2:d}][39-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ker_4( ker_shf[{2:d}][31-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ker_5( ker_shf[{2:d}][23-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ker_6( ker_shf[{2:d}][15-:8] ) , {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.ker_7( ker_shf[{2:d}][ 7-:8] ) , {1:s}".format(idnt0,cline,nfsram))

		fp.write("//---- bias ----//\n")
		fp.write("{0:s}.bias_in	( bi_con_{2:d}_dly0 ), {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.bias_offset( bi_offset_{2:d}_dly0 ), {1:s}".format(idnt0,cline,nfsram))

		fp.write(".valid_out ( q_valid[{2:d}] ) ,{1:s}".format(idnt0,cline,nfsram))
		fp.write(".outmacb_sum ( row_sumshf[{2:d}] ) ,{1:s}".format(idnt0,cline,nfsram))
		fp.write(".outact_sum ( act_sum[{2:d}] ) {1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s});\n".format(idnt0,cline,nfsram))

	fp.write( '//----instance pe with bias end------ \n')	



# 		fp.write("|....\n")