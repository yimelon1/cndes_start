from __future__ import print_function


# kersram ver3 instance
#ctrl+c :: python ker_inst.py
#----change-------------

# KER_SRAM ker0 (
#    .Q		(	dout_kersr_0		),	// output data
#    .CLK		(	clk					),	//
#    .CEN		(	cen_kersr_0			),	// Chip Enable (active low)
#    .WEN		(	wen_kersr_0			),	// Write Enable (active low)
#    .A		(	addr__kersr_0		),	// Addresses (A[0] = LSB)
#    .D		(	din__kersr_0		),	// Data Inputs (D[0] = LSB)
#    .EMA		(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
# );

# wire cen_kersr_7	;
# wire wen_kersr_7	;
# wire [ 11 -1 : 0 ] addr__kersr_7 ;
# wire [ 64 -1 : 0 ] dout_kersr_7 ;
# wire [ 64 -1 : 0 ] din_kersr_7 ;

need_ident = 1
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
	fname_idn = '_withidn'
else :
	idnt0 = ''
	cline = ''
	fname_idn = ''

with open("./sram_ins/kerins"+fname_idn+".v", "w") as fp:

	fp.write( '//----instance KER_SRAM start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----instance KER SRAM_{0:d}---------\n".format(nfsram))

		fp.write("KER_SRAM ker_{2:d}({1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.Q{0:s}(	dout_kersr_{2:d} ),	{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.CLK{0:s}( clk ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.CEN{0:s}( cen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.WEN{0:s}( wen_kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.A{0:s}( addr__kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.D{0:s}( din__kersr_{2:d} ),{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}.EMA{0:s}( 3'b0 ){1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s});\n".format(idnt0,cline,nfsram))


	fp.write( '//----instance KER_SRAM end------ \n')	

with open("./sram_ins/kerdeclare"+fname_idn+".v", "w") as fp:

	fp.write( '//----declare KER_SRAM start------ \n')
	for nfsram in range(  8 ):

		fp.write("//----declare KER SRAM_{0:d}---------\n".format(nfsram))

		fp.write("{0:s}wire cen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wire wen_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wire [ 11 -1 : 0 ] addr__kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wire [ 64 -1 : 0 ] dout_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}wire [ 64 -1 : 0 ] din_kersr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))


	fp.write( '//----declare KER_SRAM end------ \n')	

# 		fp.write("|....\n")