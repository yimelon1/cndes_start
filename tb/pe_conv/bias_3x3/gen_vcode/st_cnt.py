from __future__ import print_function


# 
#ctrl+c :: python st_cnt.py
#----change-------------


with open("./if_store/dec_cnt.txt", "w") as fp:

	fp.write( '//----declare if store cnt start------ \n')

	for nfsram in range(  8  ):
		fp.write("//----sramcnt_{0:d}---------\n".format(nfsram))
		fp.write("wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct{0:d}0	;	//first stage cnt\n".format(nfsram))
		fp.write("wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct{0:d}1	;	//second stage cnt\n".format(nfsram))
		fp.write("wire cten_stsr_ct{0:d}1 ;		//second stage enable\n".format(nfsram))
		fp.write("wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_{0:d}		;	// check the data we want\n".format(nfsram))
		fp.write("wire en_stsr_addrct_{0:d} ;	\n".format(nfsram))
		fp.write("wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_{0:d} ;\n".format(nfsram))
		fp.write("//-----------....\n")

	fp.write( '//----declare if store cnt end------ \n')


with open("./if_store/cnt_circuit.txt", "w") as fp:

	fp.write( '//----instance if store cnt start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----sramcnt_{0:d}---------\n".format(nfsram))

		fp.write("count_yi_v3 #(")
		fp.write("    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) \n")
		fp.write("    )cnt_{0:d}0(".format(nfsram))
		fp.write(".clk ( clk ), ")
		fp.write(".reset ( reset ), ")
		fp.write(".enable ( en_stsr_addrct_{0:d} ), ".format(nfsram))
		fp.write(".cnt_q ( stsr_ct{0:d}0 ),	\n".format(nfsram))
		fp.write("    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero\n")
		fp.write(");\n")

		fp.write("count_yi_v3 #(")
		fp.write("    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) \n")
		fp.write("    )cnt_{0:d}1(".format(nfsram))
		fp.write(".clk ( clk ),")
		fp.write(".reset ( reset ), ")
		fp.write(".enable ( cten_stsr_ct{0:d}1 ), ".format(nfsram))
		fp.write(".cnt_q ( stsr_ct{0:d}1 ),	//\n".format(nfsram))
		fp.write("    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero\n")
		fp.write(");\n")


		fp.write("count_yi_v3 #(")
		fp.write("    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) \n")
		fp.write("    )cnt_sraddr_{0:d}(".format(nfsram))
		fp.write(".clk ( clk ),")
		fp.write(".reset ( reset ), ")
		fp.write(".enable ( en_stsr_addrct_{0:d} ), ".format(nfsram))
		fp.write(".cnt_q ( stsr_addrct_{0:d} ),	//\n".format(nfsram))
		fp.write("    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero\n")
		fp.write(");\n")

		fp.write("assign en_stsr_addrct_{0:d} = (  (stsr_cp_{0:d} == dr_num_dly{0:d}) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want\n".format(nfsram))

		fp.write("assign cten_stsr_ct{0:d}1 = (	stsr_ct{0:d}0	==	6'd11	)? 1'd1 : 1'd0 ;\n".format(nfsram))
		fp.write("assign stsr_cp_{0:d} = 'd{1:d} + stsr_ct{0:d}0 + 32*stsr_ct{0:d}1 ;		// generate cp number\n".format(nfsram,nfsram*4))

	fp.write( '//----instance if store cnt end------ \n')	

# 		fp.write("|....\n")