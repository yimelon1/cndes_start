from __future__ import print_function
import numpy as np
from sympy import Q


# channel major input pattern
#ctrl+c :: python yi_peout.py
#----change-------------


array=np.load('./yolov3-darknet53_body-MaxPool.npy')
ker=np.load('./w_2.npy')
biasnpy = np.load('./b_2.npy')

cp_row = 2
cp_col = 2 

ker_row = 2
ker_col = 2 
sht = 24

print( array.shape)
row_size = 		array.shape[1]
col_size = 		array.shape[2]
ch_size = 		array.shape[3]	

print( ker.shape)
ker_num_full = 		ker.shape[0]
ker_row_size = 		ker.shape[1]
ker_col_size = 		ker.shape[2]
ker_ch_size = 		ker.shape[3]	
# array[#][Row][Column][Channel]
cn_sum = 0
stage1_ar = np.empty([ 8] , dtype = np.int32)
stage2_ar = np.empty([ 4] , dtype = np.int32)
stage3_ar = np.empty([ 2] , dtype = np.int32)
stage4_ar = np.empty([ 1] , dtype = np.int32)
stage5_ar = np.empty([ 1] , dtype = np.int32)

# with open("./PAT/pe_out/peout_stagebystage.dat", "w") as fp:
# 	fp.write("stage 0 \n" ) 
# 	for ch in range( 8 ):
# 		fp.write( 'stage 0 act = {0:02x} ,ker= {1:02x} ch= {2:02d} \n'.format( array[0][ cp_row ][ cp_col ][ sht+ ch  ] , ker[ 0 ][ ker_row ][ ker_col ][ sht+ ch] , sht+ch  ))

# 	fp.write("stage 1 in hex \n" ) 
# 	for ch in range( 8 ):
# 		stage1_ar [ch]= int(array[0][ cp_row ][ cp_col ][ sht+ ch  ]) * int(ker[ 0 ][ ker_row ][ ker_col ][ sht+ ch])
# 		fp.write( 'stage 1 pe_{0:02d} = {1:08x} \n'.format(  sht+ch , stage1_ar [ch]   ))
# 	fp.write("stage 2 \n" )
# 	for i  in range( 4 ):
# 		stage2_ar [i] = stage1_ar[ 2*i +1 ]+ stage1_ar[ 2*i  ]
# 		fp.write( 'stage 2 pe_{0:02d} = {1:08x} \n'.format(  i , stage2_ar [i]   ))

# 	fp.write("stage 3 \n" )
# 	for i  in range( 2 ):
# 		stage3_ar [i] = stage2_ar[ 2*i +1 ]+ stage2_ar[ 2*i  ]
# 		fp.write( 'stage 3 pe_{0:02d} = {1:08x} \n'.format(  i , stage3_ar [i]   ))

# 	fp.write("stage 4 \n" )
# 	for i  in range( 1 ):
# 		stage4_ar [i] = stage3_ar[ 2*i +1 ]+ stage3_ar[ 2*i  ]
# 		fp.write( 'stage 4 pe_{0:02d} = {1:08x} \n'.format(  i , stage4_ar [i]   ))


adbias = 0
			
with open("./PAT/pe_out/peout.dat", "w") as fp:
	for row in range( 1 ): 
		for col in range( 8 ):  
			for k in range (64):
				for ch in range( ch_size ):  
					for cpinrow in range( 3 ):
						for cpincol in range( 3 ):
							cn_sum = cn_sum + int(array[0][ row+cpinrow ][ col+cpincol ][ ch  ]) * int(ker[ k ][cpinrow][cpincol][ch])

							# qq = int(array[0][ row+cpinrow ][ col+cpincol ][ ch  ]) * int(ker[0][cpinrow][cpincol][ch])
							# aa = array[0][ row+cpinrow ][ col+cpincol ][ ch  ]
							# kkn = ker[0][cpinrow][cpincol][ch]
							# fgf.write('q={0:10d} , a={1:10d} , ker={2:10d}'.format( qq,  aa , kkn   ))
							# fgf.write("\n")
				adbias = int( cn_sum ) + int( biasnpy[k] )
				# fp.write("%08x " %cn_sum) 
				fp.write("%08x" %adbias) 
				feat_info = { 'row' : row ,'col' : col ,'ch_s': ch  ,'ch_e': ch*8+7 ,'ker' : k ,'inte' : cn_sum , 'adbias': adbias }
				fp.write( '  //  '+'MACresult = {inte:5d} , ABIASresult =  {adbias:5d},row= {row:3d}, col= {col:3d}, ch= {ker:2d} '.format(**feat_info))
				fp.write("\n")
				cn_sum=0

			#fp.write( "row_end {:5x} \n" . format( row ) )













