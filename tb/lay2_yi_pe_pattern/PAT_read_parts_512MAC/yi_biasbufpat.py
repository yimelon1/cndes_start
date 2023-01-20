from __future__ import print_function
import numpy as np
def tohex(val, nbits):
 return hex((val + (1 <<nbits)) % (1 <<nbits))

#ctrl+c ::　python yi_biasbufpat.py
#----change-------------
opera_col = 16
(padding , padtop , paddown ) = ( 1,1,0 )
#---------------------------------------------------
array=np.load('../b_2.npy')

print(array.shape)
ch_size = array.shape[0]


actually_col = opera_col//8

if( padding ==1): col_loop = 24		# 6*4ch_address
else: col_loop = 36		# 9*4ch_address



for idx in range( 8 ):
	with open("./padtop_bia_read/pt_bias_read"+"{0:d}".format(idx)+".dat", "w") as fa:
		for k in range ( ch_size //8):
			for op_loop in range( col_loop*actually_col ) :
				data = array[ k*8 + idx]
				if data<0:
					data=2**32+data		# transform 2's complement
					#fp.write(str("%08X" %(data)))
					fa.write(str("%08X" %(data)))
				else:
					#fp.write(str("%08X" %(data)))
					fa.write(str("%08X" %(data)))
				fa.write( "    // out_ch = {0:d} , op_loop = {1:d}".format(k*8 + idx , op_loop ))
				fa.write("\n")