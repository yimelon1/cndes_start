from __future__ import print_function


# biassram ver3 instance
#ctrl+c :: python bias_read_tag.py
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

# //----bias current tag_0---------
# always @( posedge clk ) begin
#     if(reset)begin
#         tag_bias_curr_1<= 7'd0 ;
#     end
#     else begin
#         case (rd_current_state)
#             RD_NXLOAD_SW	:	tag_bias_curr_1 <= tag_bias_next_1 ;
#             RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_1 <= 7'd0 ;
#             default: tag_bias_curr_0 <= tag_bias_curr_1 ;
#         endcase
#     end
# end
# //----bias next tag_0---------
# always @( posedge clk ) begin
#     if(reset)begin
#         tag_bias_next_1<= 7'd0 ;
#     end
#     else begin
#         case (rd_current_state)
#             RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
#                 if( srrd_addr_dly1 == 1)tag_bias_next_1 <= cpker_p1 ;
#                 else tag_bias_next_1 <= tag_bias_next_1 ;
#             end 
#             default: tag_bias_next_1 <= tag_bias_next_1;
#         endcase
#     end
# end


with open("./biassram_r/rrrtaggg_"+fname_idn+".v", "w") as fp:

	fp.write( '//----generated by bias_read_tag.py------ \n')

	for nfsram in range(  8 ):

		fp.write("//----bias current tag_{0:d}---------\n".format(nfsram))
		fp.write("always @( posedge clk ) begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}if(reset)begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}tag_bias_curr_{2:d}<= 7'd0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}else begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}case (rd_current_state){1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}RD_NXLOAD_SW	:	tag_bias_curr_{2:d}<=tag_bias_next_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_{2:d} <= 7'd0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}default: tag_bias_curr_{2:d}<=tag_bias_curr_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}endcase{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("end{1:s}".format(idnt0,cline,nfsram))
		
		
	for nfsram in range(  8 ):

		fp.write("//----bias next tag_{0:d}---------\n".format(nfsram))
		fp.write("always @( posedge clk ) begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}if(reset)begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}tag_bias_next_{2:d}<= 7'd0 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))

		fp.write("{0:s}else begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}case (rd_current_state){1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}if( srrd_addr_dly1 == {2:d})tag_bias_next_{2:d} <= cpker_p1 ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}{0:s}else tag_bias_next_{2:d} <= tag_bias_next_{2:d} ;{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}{0:s}end{1:s}".format(idnt0,cline,nfsram))

		fp.write("{0:s}{0:s}{0:s}default: tag_bias_next_{2:d} <= tag_bias_next_{2:d};{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}{0:s}endcase{1:s}".format(idnt0,cline,nfsram))
		fp.write("{0:s}end{1:s}".format(idnt0,cline,nfsram))
		fp.write("end{1:s}".format(idnt0,cline,nfsram))
		
	fp.write( '//----python generate end------ \n')	



# 		fp.write("|....\n")