//----generated by bias_read_tag.py------ 
//----bias current tag_0---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_0<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_0<=tag_bias_next_0;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_0 <= 7'd0 ;
            default: tag_bias_curr_0<=tag_bias_curr_0;
        endcase
    end
end
//----bias current tag_1---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_1<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_1<=tag_bias_next_1;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_1 <= 7'd0 ;
            default: tag_bias_curr_1<=tag_bias_curr_1;
        endcase
    end
end
//----bias current tag_2---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_2<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_2<=tag_bias_next_2;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_2 <= 7'd0 ;
            default: tag_bias_curr_2<=tag_bias_curr_2;
        endcase
    end
end
//----bias current tag_3---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_3<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_3<=tag_bias_next_3;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_3 <= 7'd0 ;
            default: tag_bias_curr_3<=tag_bias_curr_3;
        endcase
    end
end
//----bias current tag_4---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_4<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_4<=tag_bias_next_4;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_4 <= 7'd0 ;
            default: tag_bias_curr_4<=tag_bias_curr_4;
        endcase
    end
end
//----bias current tag_5---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_5<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_5<=tag_bias_next_5;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_5 <= 7'd0 ;
            default: tag_bias_curr_5<=tag_bias_curr_5;
        endcase
    end
end
//----bias current tag_6---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_6<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_6<=tag_bias_next_6;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_6 <= 7'd0 ;
            default: tag_bias_curr_6<=tag_bias_curr_6;
        endcase
    end
end
//----bias current tag_7---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_curr_7<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_NXLOAD_SW	:	tag_bias_curr_7<=tag_bias_next_7;
            RD_FIRST_RS_1,RD_FIRST_HD_1	:	tag_bias_curr_7 <= 7'd0 ;
            default: tag_bias_curr_7<=tag_bias_curr_7;
        endcase
    end
end
//----bias next tag_0---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_0<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 0)tag_bias_next_0 <= cpker_p1 ;
                else tag_bias_next_0 <= tag_bias_next_0 ;
            end
            default: tag_bias_next_0 <= tag_bias_next_0;
        endcase
    end
end
//----bias next tag_1---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_1<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 1)tag_bias_next_1 <= cpker_p1 ;
                else tag_bias_next_1 <= tag_bias_next_1 ;
            end
            default: tag_bias_next_1 <= tag_bias_next_1;
        endcase
    end
end
//----bias next tag_2---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_2<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 2)tag_bias_next_2 <= cpker_p1 ;
                else tag_bias_next_2 <= tag_bias_next_2 ;
            end
            default: tag_bias_next_2 <= tag_bias_next_2;
        endcase
    end
end
//----bias next tag_3---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_3<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 3)tag_bias_next_3 <= cpker_p1 ;
                else tag_bias_next_3 <= tag_bias_next_3 ;
            end
            default: tag_bias_next_3 <= tag_bias_next_3;
        endcase
    end
end
//----bias next tag_4---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_4<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 4)tag_bias_next_4 <= cpker_p1 ;
                else tag_bias_next_4 <= tag_bias_next_4 ;
            end
            default: tag_bias_next_4 <= tag_bias_next_4;
        endcase
    end
end
//----bias next tag_5---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_5<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 5)tag_bias_next_5 <= cpker_p1 ;
                else tag_bias_next_5 <= tag_bias_next_5 ;
            end
            default: tag_bias_next_5 <= tag_bias_next_5;
        endcase
    end
end
//----bias next tag_6---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_6<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 6)tag_bias_next_6 <= cpker_p1 ;
                else tag_bias_next_6 <= tag_bias_next_6 ;
            end
            default: tag_bias_next_6 <= tag_bias_next_6;
        endcase
    end
end
//----bias next tag_7---------
always @( posedge clk ) begin
    if(reset)begin
        tag_bias_next_7<= 7'd0 ;
    end
    else begin
        case (rd_current_state)
            RD_FIRST_RS_2,RD_FIRST_HD_2	,RD_NXLOAD_RS,RD_NXLOAD_HD : 	begin
                if( srrd_addr_dly1 == 7)tag_bias_next_7 <= cpker_p1 ;
                else tag_bias_next_7 <= tag_bias_next_7 ;
            end
            default: tag_bias_next_7 <= tag_bias_next_7;
        endcase
    end
end
//----python generate end------ 
