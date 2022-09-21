from __future__ import print_function
import numpy as np


# channel major input pattern
#ctrl+c :: python yi_out2.py
#----change-------------


array=np.load('./yolov3-darknet53_body-Conv_1-Relu6.npy')

print( array.shape)
row_size = 		array.shape[1]
col_size = 		array.shape[2]
ch_size = 		array.shape[3]	
# array[#][Row][Column][Channel]

with open("./PAT/2_out.dat", "w") as fp:

	for row in range( row_size ): #16
		for col in range( col_size ):  #layer3 input size=208
			for ch in range( ch_size//8 ):#channel=64 ,ch=64/8=8   
				for eight in range(	8	):#8bytes to 1 pcs
					fp.write("%02x" %array[0][ row ][ col ][ ch*8 + eight ]) 
					#fp.write("%02x" %array[0][10+row][col][ch*8+eight])
					#fp.write("%02x" %array[0][row][col][ch*8+eight])
				feat_info = { 'row' : row ,'col' : col ,'ch_s': ch*8 ,'ch_e': ch*8+7 ,'ker' : 0}
				fp.write( '  //  '+'row= {row:3d}, col= {col:3d}, ch= {ch_s:2d} ~ {ch_e:2d} '.format(**feat_info))
				fp.write("\n")
		#fp.write( "row_end {:5x} \n" . format( row ) )













