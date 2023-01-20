from __future__ import print_function
import numpy as np


# channel major input pattern
#ctrl+c :: python yi_kerbufpat.py
#----change-------------
opera_col = 16
(padding , padtop , paddown ) = ( 1,1,0 )
#---------------------------------------------------


array=np.load('../w_2.npy')

print( array.shape)
ker_num =		array.shape[0]
row_size = 		array.shape[1]
col_size = 		array.shape[2]
ch_size = 		array.shape[3]	
# array[#][Row][Column][Channel]

actually_col = opera_col//8

if( padtop ==1): row_pad = 1 
else: row_pad = 0

if( padding ==1): conv_row = 2
else: conv_row = 3


for idx in range( 8 ):

	with open("./padtop_ker_read/pt_ker_read"+"{:d}".format(idx) +".dat", "w") as fp:
		
		for k in range( ker_num//8 ):
			for op_loop in range( actually_col ):
				for row in range( conv_row ): #16
					for col in range( col_size ):  #layer3 input size=208
						for ch in range( ch_size//8 ):#channel=64 ,ch=64/8=8   
							for eight in range(	8 ):#8bytes to 1 pcs
								fp.write("%02x" %array[    k*8 + idx    ][ row ][ col ][ ch*8 + eight ]) 
								#fp.write("%02x" %array[0][10+row][col][ch*8+eight])
								#fp.write("%02x" %array[0][row][col][ch*8+eight])
							feat_info = { 'row' : row ,'col' : col ,'ch_s': ch*8 ,'ch_e': ch*8+7 ,'ker' : k*8 + idx , 'op_loop': op_loop}
							fp.write( '  //  '+'ker_{ker:d} ,row= {row:3d}, col= {col:3d}, ch= {ch_s:2d} ~ {ch_e:2d} , op_loop= {op_loop:2d} '.format(**feat_info))
							
							fp.write("\n")














