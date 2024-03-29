from __future__ import print_function


# biassram ver3 instance
#ctrl+c :: python bias_read_buf.py
#----change-------------



need_ident = 1
if( need_ident ):
	idnt0 = '    '
	cline = '\n'
	fname_idn = '_withidn'
else :
	idnt0 = ''
	cline = ''
	fname_idn = ''

def dec_un_ident(  file , num , dec_type , port_name ):
	file.write("{0}".format(dec_type))
	for i in range( num ):
		if( i == num-1):
			file.write("{1:s}_{2:d} ; {0:s}".format( '\n' ,port_name , i))
		else :
			file.write("{1:s}_{2:d} ,".format(  '\n' ,port_name , i))


# always @( posedge clk ) begin
# 	if(reset)begin
# 		bias_reg_curr_0<= 32'd0 ;
# 	end
# 	else begin
# 		case (rd_current_state)
# 			RD_NXLOAD_SW	:	bias_reg_curr_0<=bias_reg_next_0;
# 			RD_FIRST_RS_1	:	begin
# 				if( srrd_addr_dly1 == 0)bias_reg_curr_0 <= dout_biasr_0_dly0 ;
# 				else bias_reg_curr_0 <= bias_reg_curr_0 ;
# 			end

# 			default: bias_reg_curr_0<=bias_reg_curr_0;
# 		endcase

# 	end
# end	


# always @(posedge clk ) begin
# 	if(reset)bias_reg_next_0<=32'd0 ;
# 	else begin
# 		case (rd_current_state)
# 			RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin
# 				if( srrd_addr_dly1 == 0)bias_reg_next_0 <= dout_biasr_0_dly0 ;
# 				else bias_reg_next_0 <= bias_reg_next_0 ;
# 			end
# 			RD_NXLOAD_RS,RD_NXLOAD_HD	:	begin
# 				if( srrd_addr_dly1 == 0)bias_reg_next_0 <= dout_biasr_0_dly0 ;
# 				else bias_reg_next_0 <= bias_reg_next_0 ;
# 			end
# 			default: bias_reg_next_0 <= bias_reg_next_0;
# 		endcase
# 	end
# end


with open("./biassram_r/rrrbuffer_"+fname_idn+".v", "w") as fp:

	
	fp.write( '//----generated by bias_read_buf.py------ \n')

	for nfsram in range(  8 ):

		fp.write("always @( posedge clk ) begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}if(reset)begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}bias_reg_curr_{2:d}<= 32'd0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}else begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}case (rd_current_state){1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}RD_NXLOAD_SW	:	bias_reg_curr_{2:d}<=bias_reg_next_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}RD_FIRST_RS_1,RD_FIRST_HD_1	:	begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}if( srrd_addr_dly1 == {2:d})bias_reg_curr_{2:d} <= dout_biasr_0_dly0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}else bias_reg_curr_{2:d} <= bias_reg_curr_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}default: bias_reg_curr_{2:d}<=bias_reg_curr_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}endcase{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("end{1:s}".format(idnt0,cline,nfsram))
		
		fp.write("//----bias current buffer_{0:d}---------\n".format(nfsram))

	for nfsram in range(  8 ):

		fp.write("always @( posedge clk ) begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}if(reset)begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}bias_reg_next_{2:d}<= 32'd0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))

		fp.write("{0:s}else begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}case (rd_current_state){1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}RD_FIRST_RS_2,RD_FIRST_HD_2	: 	begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}if( srrd_addr_dly1 == {2:d})bias_reg_next_{2:d} <= dout_biasr_0_dly0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}else bias_reg_next_{2:d} <= bias_reg_next_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}end{1:s}".format(idnt0,cline,nfsram))

		fp.write("{0:s}{0:s}{0:s}RD_NXLOAD_RS,RD_NXLOAD_HD	: 	begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}if( srrd_addr_dly1 == {2:d})bias_reg_next_{2:d} <= dout_biasr_0_dly0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}else bias_reg_next_{2:d} <= bias_reg_next_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}end{1:s}".format(idnt0,cline,nfsram))

		fp.write("{0:s}{0:s}{0:s}default: bias_reg_next_{2:d} <= bias_reg_next_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}endcase{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("end{1:s}".format(idnt0,cline,nfsram))
		
		fp.write("//----bias next buffer_{0:d}---------\n".format(nfsram))




	fp.write( '//----python generate end------ \n')	


# 		fp.write("|....\n")