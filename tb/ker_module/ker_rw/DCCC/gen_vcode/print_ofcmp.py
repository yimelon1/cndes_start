from __future__ import print_function


# 
#ctrl+c :: python print_ofcmp.py
#----change-------------
sram_depth = 288
c_line = r"\n"		# this is raw string
tab_indent = "\t"

with open("./cpcir/cpp11.txt", "w") as fp:

	fp.write( '//----generate compare circuit by print_ofcmp.py------ \n')

	for nfsram in range(  8  ):
		fp.write("//----cp if sram_{0:d}---------\n".format(nfsram))
		fp.write('for(num_cp=0; num_cp<		{0:d}	; num_cp=num_cp+1)begin\n'.format(sram_depth) )
		fp.write('{1:s}if(tb_ifsram_{0:d}[num_cp] !== gdd_ifsram_{0:d}[num_cp])begin\n'.format(nfsram , tab_indent ))
		fp.write('{1:s}{1:s}$display("sram_{0:d},error at %d, tbsram= %x  goldsram= %x{2:s}", num_cp, tb_ifsram_{0:d}[num_cp], gdd_ifsram_{0:d}[num_cp]);\n'.format(nfsram  , tab_indent , c_line))
		fp.write('{1:s}{1:s}error = error + 1;\n'.format(nfsram , tab_indent))
		fp.write('{1:s}{1:s}$fwrite(fp_w, "sram_{0:d},error at %d, tbsram= %x  goldsram= %x{2:s}", num_cp, tb_ifsram_{0:d}[num_cp], gdd_ifsram_{0:d}[num_cp]);\n'.format(nfsram  , tab_indent , c_line))
		fp.write('{1:s}end\n'.format(nfsram, tab_indent))
		fp.write('end\n'.format(nfsram, tab_indent))


	fp.write( '//----generate compare circuit end------ \n')



	# for(num_cp=0; num_cp<		288		; num_cp=num_cp+1)begin
	# 	if(tb_ifsram_0[num_cp] !== gdd_ifsram_0[num_cp])begin
	# 		$display("error at %d, ofmap= %x  ofmap_gold= %x\n", num_cp, tb_ifsram_0[num_cp], gdd_ifsram_0[num_cp]);
	# 		error = error + 1;
	# 		$fwrite(fp_w, "error at %d, ofmap= %x  ofmap_gold= %x\n", num_cp, tb_ifsram_0[num_cp], gdd_ifsram_0[num_cp]);
	# 	end
	# end