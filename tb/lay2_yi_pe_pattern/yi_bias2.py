from __future__ import print_function
import numpy as np
def tohex(val, nbits):
 return hex((val + (1 <<nbits)) % (1 <<nbits))

#ctrl+c ::　python yi_bias2.py
#----change-------------
# ch_size = 64
#array=np.load(r"E:\yuan\py_code\layer_dat_20220110\WORKSPACE\layer_07\bias_7.npy")  

pattern_dir_path = 'E:/yuan/py_code/layer_dat_20220110/WORKSPACE/layer_02/lay2_yi_pe_pattern/' 
array    = np.load( pattern_dir_path +'b_2.npy')


# array[#][Row][Column][Channel]
fp = open("./PAT/2_bias.dat", "w")
#----change-------------

#-----relative path use 
# root directory "/"
# Current sibling directory "./"
# Parent directory "../"

#-----Absolute path use
# "r’D:\xxxx\xxxx2"
# "D:\\xxxx\\xxxx2"

# pattern_dir_path = 'E:/yuan/py_code/layer_dat_20220110/WORKSPACE/layer_02/lay2_yi_pe_pattern/'

# ifm_np  = np.load( pattern_dir_path +'yolov3-darknet53_body-MaxPool.npy')
# ker     = np.load( pattern_dir_path +'w_2.npy')
# bias    = np.load( pattern_dir_path +'b_2.npy')
# gold_np = np.load( pattern_dir_path +'yolov3-darknet53_body-Conv_1-Relu6.npy')

print(array.shape)
ch_size = array.shape[0]
for ch in range( ch_size ):  # go with channel of filters 
 data=array[ch]
 if data<0:
  data=2**32+data		# transform 2's complement
  #fp.write(str("%08X" %(data)))
  fp.write(str("%08X" %(data)))
 else:
  #fp.write(str("%08X" %(data)))
  fp.write(str("%08X" %(data)))
 fp.write("\n")
fp.close()
