from __future__ import print_function
import numpy as np


# channel major input pattern
#ctrl+c :: python yi_ifbufpat.py
#----change-------------


#array=np.load('./yolov3-yolov3_head-Conv_2-Relu6.npy')
array=np.load('../yolov3-darknet53_body-MaxPool.npy')

print( array.shape)
row_size = 		array.shape[1]
col_size = 		array.shape[2]
ch_size = 		array.shape[3]	
# array[#][Row][Column][Channel]


# with open("./PAT/if_sr/sr_collist.dat", "w") as fp:

# 	fp.write( '---------- \n')

# 	for iene in range( 8):
# 		fp.write( 'IFsram {0:d} for stride {0:d} \n'.format(iene ))
# 		for col in range(10):
# 			# fp.write( 'col_{0:2d}~col_{1:2d}'.format(  col*8 , col*8+2 ))
# 			fp.write( '| {0:2d}_{1:2d} |'.format(  col*8  +iene , col*8+2  +iene ))
# 			fp.write( 'row0 address at {0:4d} to {1:4d}\n'.format( col*8*4  +iene*4 , col*8*4  +iene*4 + 3*4-1))

# 		fp.write("|....\n")



#  padding tester------------------------------------------------------
nbpas = np.array(	 [[   [5,4] , [6,5]  ] ,[ [7,6] ,[8,7] ]])

print( nbpas.shape)
print( nbpas[0][1][1])

# bzppp = np.pad( nbpas , ((2,0),(2 ,3) ,(0,0)) ,'constant', constant_values=((1,1),(2 ,2) ,(0,0))) 

bzppp = np.pad( nbpas , ((0,0),(1,1) ,(0,0)) ,'constant', constant_values=0) 
print( bzppp.shape )
# print( bzppp)

#-------------------------------------------------------------------


cfg_padding = 1 
# ni_array = np.empty( [ row_size , col_size + cfg_padding*2 , ch_size ] , dtype=np.uint8 )

pad_array = np.pad( array , ( (0,0),(0,0) , (cfg_padding ,cfg_padding) ,(0,0))  ,'constant', constant_values=0 )

print( pad_array.shape )

# padding top 

for ixed in range(8  ):
	with open("./padtop_if_read/pt_if_read"+ "{0:d}".format(ixed) +".dat", "w") as fp:
		for ker_num in range(8) :
			for co_0 in range( 2 ):  #layer3 input size=208
				for row in range( 2 ): #16
					for co_1 in range( 3 ):
						for ch in range( ch_size//8 ):#channel=64 ,ch=64/8=8   
							for eight in range(	8 ):#8bytes to 1 pcs
								fp.write("%02x" %pad_array[0][  row ][ co_0*8 + co_1 +ixed ][ ch*8 + eight ]) 
								#fp.write("%02x" %array[0][10+row][col][ch*8+eight])
								#fp.write("%02x" %array[0][row][col][ch*8+eight])
							feat_info = { 'row' :  row ,'col' : co_0*8 + co_1 +ixed ,'ch_s': ch*8 ,'ch_e': ch*8+7 ,'ker' : ker_num }
							fp.write( '  //  '+'row= {row:3d}, col= {col:3d}, ch= {ch_s:2d} ~ {ch_e:2d} , conv_ker= {ker:2d}'.format(**feat_info))

							# fp.write( '  //  '+'row= {0:3d}, col= {1:3d}, ch= {2:2d} ~ {3:2d} '.format(row , col , ch*8 , ch*8+7 ))
							fp.write("\n")
				#fp.write( "row_end {:5x} \n" . format( row ) )


