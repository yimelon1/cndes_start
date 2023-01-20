from __future__ import print_function
import numpy as np


# channel major input pattern
#ctrl+c :: python yi_ofqtb.py
#----change-------------


array=np.load('./yolov3-darknet53_body-Conv_1-Relu6.npy')

print( array.shape)
row_size = 		array.shape[1]
col_size = 		array.shape[2]
ch_size = 		array.shape[3]	
# array[#][Row][Column][Channel]
set_col = 30
with open("./PAT/ot_buf/QtB_col_{0:d}.dat".format( set_col ), "w") as fp:

	for row in range( 1 ): #16
		for ch in range( ch_size//8):#channel=64 ,ch=64/8=8  
				for col in range( set_col ):  #layer3 input size=208 	
					for eig in range(8) :
						fp.write("%02x" %array[0][ row ][ col ][ ch*8 +eig ]) 
							#fp.write("%02x" %array[0][10+row][col][ch*8+eight])
							#fp.write("%02x" %array[0][row][col][ch*8+eight])
						feat_info = { 'row' : row ,'col' : col ,'ch_s': ch*8 ,'ch_e': ch*8+7 ,'ker' : 0 , 'ch_now':ch*8 +eig }
						fp.write( '  //  '+'row= {row:3d}, col= {col:3d}, ch= {ch_now:2d} '.format(**feat_info))
						fp.write("\n")
		#fp.write( "row_end {:5x} \n" . format( row ) )



with open("./PAT/ot_buf/QtBend_col_{0:d}.dat".format( set_col ), "w") as fp:
	for row in range( 1 ): #16
		for ch in range( ch_size//8):#channel=64 ,ch=64/8=8  
			for col in range( set_col ):  #layer3 input size=208 	
				for eig in range(8) :
					fp.write("%02x" %array[0][ row ][ col ][ ch*8 +eig]) 
						#fp.write("%02x" %array[0][10+row][col][ch*8+eight])
						#fp.write("%02x" %array[0][row][col][ch*8+eight])
				feat_info = { 'row' : row ,'col' : col ,'ch_s': ch*8 ,'ch_e': ch*8+7 ,'ker' : 0 , 'ch_now':ch }
				fp.write( '  //  '+'row= {row:3d}, col= {col:3d}, ch= {ch_s:2d} ~ {ch_e:2d} '.format(**feat_info))
				fp.write("\n")
		#fp.write( "row_end {:5x} \n" . format( row ) )









