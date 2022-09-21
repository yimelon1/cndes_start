from __future__ import print_function
import numpy as np
def tohex(val, nbits):
 return hex((val + (1 <<nbits)) % (1 <<nbits))

#ctrl+c ::　python yi_biasbuffer.py
#----change-------------
# ch_size = 64
#array=np.load(r"E:\yuan\py_code\layer_dat_20220110\WORKSPACE\layer_07\bias_7.npy")  

# pattern_dir_path = 'E:/yuan/py_code/layer_dat_20220110/WORKSPACE/layer_02/lay2_yi_pe_pattern/' 	# 908 pc
pattern_dir_path = 'E:/yuan/work/1x1_worlkkl/lay2_yi_pe_pattern/' 	# home pc

# array    = np.load( pattern_dir_path +'b_2.npy')
array=np.load('./b_2.npy')

print(array.shape)
ch_size = array.shape[0]

for idx in range( 8 ):
	with open("./PAT/bias_buffer/2b_buff"+"{0:d}".format(idx)+".dat", "w") as fa:
		for k in range ( ch_size //8):
			data = array[ k*8 + idx]
			if data<0:
				data=2**32+data		# transform 2's complement
				#fp.write(str("%08X" %(data)))
				fa.write(str("%08X" %(data)))
			else:
				#fp.write(str("%08X" %(data)))
				fa.write(str("%08X" %(data)))
			fa.write( "    // out_ch = {0:d}".format(k*8 + idx))
			fa.write("\n")