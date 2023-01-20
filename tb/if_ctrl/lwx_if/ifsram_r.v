// ============================================================================
// Designer : Wei-Xuan Luo
// Create   : 2022.11.17
// Ver      : 1.0
// Func     : input feature sram read module
// ============================================================================



module ifsram_r #(
    parameter TBITS = 64 ,
	parameter TBYTE = 8
)(

    input clk,
    input reset,
//=========for sche=============   
    input wire        if_read_start,
    output reg        if_read_busy,
    output reg        if_read_done,

//========for dram =========================
    output wire       cen_reads_ifsram ,
    output reg [10:0] addr_read_ifsram,

    output reg        change_sram,
    input  wire [2:0] current_state,

    // output reg  col_finish,
    output reg  row_finish
);

reg done_flag;
reg cen0;

assign cen_reads_ifsram = ~cen0;
parameter ROW = 3;
parameter COL = 15;
parameter CH  = 4; // 32/8 = 4
localparam [2:0] 
    IDLE          = 3'd0,
    LOAD          = 3'd1,
    UP_PADDING    = 3'd2,
    THREEROW      = 3'd3,
    TWOROW        = 3'd4,
    ONEROW        = 3'd5,
    DOWN_PADDING  = 3'd6;

reg [1:0] next_state;   
reg [1:0] c_state;


reg signed [5:0 ]  row_oft;
reg signed [5:0 ]  col_oft;
reg signed [5:0 ] current_col = 0;
reg signed [2:0]  ch;
reg [1:0] col_number;
reg [1:0] row_number;
reg col_finish;
//reg row_finish;


//==================================================
always @(*) begin
    if(col_finish)begin
        if(current_state == TWOROW && row_number == 1)
            change_sram = 1;
        else if(current_state == ONEROW && row_number == 0)
            change_sram = 1;
        else
            change_sram = 0;
    end
    else
        change_sram = 0;
end
//===================================================
always @(posedge clk ) begin
	if(reset) begin
		c_state <= 2'd0;
	end
	else begin
		c_state <= next_state;
	end
end
always @(*) begin
    if(reset)
        next_state = 0;
    else begin
        case (c_state)
            2'd0: next_state = (if_read_start) ? 2'd1 : 2'd0 ;
            2'd1: next_state = (if_read_done) ? 2'd2 : 2'd1 ;
            2'd2: next_state = 2'd0 ;
            default: next_state = next_state ;
        endcase	
    end
end


always @( * ) begin
	if_read_busy = ( c_state == 2'd1) ? 1'd1 : 1'd0 ;
end

always @( * ) begin
    cen0 = ( c_state == 2'd1) ? 1'd1 : 1'd0 ;
end

always @ (*)begin
    if(done_flag) 
        if_read_done = 1;
    else
        if_read_done = 0;
end


always @ (posedge clk)begin
    if(reset)
        done_flag <= 0;
    else if(done_flag)
        done_flag <= 0;
    else if(current_state == UP_PADDING || current_state == DOWN_PADDING)
        if(row_number == 1  && col_number == 2 && ch == 2'd2 && current_col == (COL-1))
            done_flag <= 1;
        else
            done_flag <= done_flag;
    else if(current_state >= THREEROW && current_state <= ONEROW)
        if(row_number == 2  && col_number == 2 && ch == 2'd2 && current_col == (COL-1))
            done_flag <= 1;
        else
            done_flag <= done_flag;
    else
        done_flag <= done_flag;
end 


//=================================================================================

reg signed [10:0] addr0;
always @ (*) begin
    addr_read_ifsram = (if_read_busy) ? addr0 : 0;
end

always @ (*) begin
    if(reset)
        addr0 = 0;
    else if(c_state == 1)
        //addr0 = (current_row + row_oft)*15*4 + (current_col+col_oft)*4 + ch;
        addr0 = row_oft*(COL+1)*CH + (current_col+col_oft)*CH + ch;
    else
        addr0 = 0;
end
//=================================================================================



//===========col control================

always @ (posedge clk) begin
    if(reset)
        current_col <= 0;
    else if(current_state == UP_PADDING || current_state == DOWN_PADDING)begin
        if(row_number == 1  && ch == 2'd3)begin
            if(current_col == 0 && col_number == 1)
                current_col <= current_col + 1;
            else if(col_number == 2)
                if(current_col > 0 && current_col < (COL-1))
                    current_col <= current_col + 1;
                else if(current_col == (COL-1))
                    current_col <= 0;
            else
                current_col <= current_col;
        end
        else
            current_col <= current_col;
    end
    else if(current_state >= THREEROW && current_state <= ONEROW)begin
        if(row_number == 2  && ch == 2'd3)begin
            if(current_col == 0 && col_number == 1)
                current_col <= current_col + 1;
            else if(col_number == 2)
                if(current_col > 0 && current_col < (COL-1))
                    current_col <= current_col + 1;
                else if(current_col == (COL-1))
                    current_col <= 0;
            else
                current_col <= current_col;
        end
        else
            current_col <= current_col;
    end
    else
        current_col <= current_col;
end






//===========number control================


always @ (posedge clk ) begin
    if(reset)
        col_number <= 0;
    else if(ch == 2'd3)begin
        if(current_col == 0 && col_number == 1)
            col_number <= 0;
        else if((current_col > 0 && current_col < COL) && col_number == 2)
            col_number <= 0;
        else
            col_number <= col_number + 1;
    end
    else 
        col_number <= col_number;
end

always @ (*) begin
    if(ch == 2'd3)begin
        if(current_col == 0 && col_number == 1)
            col_finish = 1;
        else if((current_col > 0 && current_col < COL) && col_number == 2)
            col_finish = 1;
        else
            col_finish = 0;
    end
    else 
        col_finish = 0;
end

always @ (*) begin
    if(col_finish)begin
        if((current_state == UP_PADDING || current_state == DOWN_PADDING) && row_number == 1)
            row_finish = 1;
        else if((current_state >= THREEROW && current_state <= ONEROW) && row_number == 2)
            row_finish = 1;
        else
            row_finish = 0;
    end
    else 
        row_finish = 0;
end



always @ (posedge clk ) begin
    if(reset)
        row_number <= 0;
    else if(col_finish)begin
        if((current_state == UP_PADDING || current_state == DOWN_PADDING) && row_number == 1)
            row_number <= 0;
        else if((current_state >= THREEROW && current_state <= ONEROW) && row_number == 2)
            row_number <= 0;
        else
            row_number <= row_number + 1;
    end
    else
        row_number <= row_number;
end


//===========offset control================

always @ (posedge clk) begin
    if(reset)
        ch <= 0;
    else if(ch == 2'd3)
        ch <= 0;
    else if (cen0)
        ch <= ch + 3'd1;
    else 
        ch <= ch;
end


always @ (*)begin
    if(current_col == 0)begin
        if(col_number == 0)
            col_oft = 0;
        else if (col_number == 1)
            col_oft = 1;
        else 
            col_oft = 0;
    end
    else if(current_col > 0 && current_col < COL)begin
        if(col_number == 0)
            col_oft = -1;
        else if (col_number == 1)
            col_oft = 0;
        else if (col_number == 2)
            col_oft = 1;
        else 
            col_oft = 0;
    end
    else
        col_oft = 0; 
end



always @ (*) begin
    // if(reset)
    //     row_oft <= 0;
    // else 
    if(current_state == UP_PADDING)begin
        if(row_number == 0) 
            row_oft = 0;
        else if(row_number == 1)
            row_oft = 1;
    end
    else if(current_state == THREEROW)begin
        if(row_number == 0) 
            row_oft = 0;
        else if(row_number == 1)
            row_oft = 1;
        else if(row_number == 2)
            row_oft = 2;
        else
            row_oft = 0;   
    end
    else if(current_state == TWOROW)begin
        if(row_number == 0) 
            row_oft = 1;
        else if(row_number == 1)
            row_oft = 2;
        else if(row_number == 2)
            row_oft = 0;
        else
            row_oft = 0;   
    end
    else if(current_state == ONEROW)begin
        if(row_number == 0) 
            row_oft = 2;
        else if(row_number == 1)
            row_oft = 0;
        else if(row_number == 2)
            row_oft = 1;
        else
            row_oft = 0;   
    end
    else if(current_state == DOWN_PADDING)begin
        if(row_number == 0) 
            row_oft = 1;
        else if(row_number == 1)
            row_oft = 2;
    end
end




endmodule


