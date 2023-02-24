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

//=========for sram ============
    output wire       cen_reads_ifsram ,
    output reg [10:0] addr_read_ifsram,
    output reg        change_sram,
    input  wire [2:0] current_state,
    output reg  row_finish
);

//============   parameter  ===================
    parameter WINDOW = 4;
    parameter CH  = 4; // 32/8 = 4
    localparam [2:0] 
        IDLE          = 3'd0,
        UP_PADDING    = 3'd1,
        THREEROW      = 3'd2, //LOAD & READ 3 ROW for top sram
        TWOROW        = 3'd3, //READ 2 ROW for top sram
        ONEROW        = 3'd4, //READ 1 ROW for top sram
        DOWN_PADDING  = 3'd5;
    localparam [2:0] 
        IR_IDLE = 3'd0,
        IR_READ = 3'd1;

//============  reg & wire ============
    reg [1:0] next_state;   
    reg [1:0] c_state;
    reg done_flag;
    reg cen0;
    reg signed [5:0] row;
    reg signed [5:0] col_oft;
    reg signed [2:0] ch;
    reg signed [5:0] current_window;
    reg [1:0] col_number;
    reg [1:0] row_number;
    reg col_finish;
    reg signed [10:0] addr;

//=========== busy & done control ===========
    always @(posedge clk ) begin
        if(reset) 
            c_state <= 2'd0;
        else 
            c_state <= next_state;
    end

    always @(*) begin
        case (c_state)
            IR_IDLE: next_state = (if_read_start) ? IR_READ : IR_IDLE ;
            IR_READ: next_state = (if_read_done)  ? IR_IDLE : IR_READ ;
            default: next_state = IR_IDLE ;
        endcase	
    end


    always @( * ) begin
        if_read_busy = ( c_state == IR_READ) ? 1'd1 : 1'd0 ;
    end

    always @( * ) begin
        cen0 = ( c_state == IR_READ) ? 1'd1 : 1'd0 ;
    end

    always @ (*)begin
        if(done_flag) 
            if_read_done = 1;
        else
            if_read_done = 0;
    end

    always @ (*)begin //no finish
        // if(reset)
        //     done_flag <= 0;
        // else if(done_flag)
        //     done_flag <= 0;
        // else 
        if(row_finish && current_window == WINDOW)begin
            if(current_state == UP_PADDING || current_state == DOWN_PADDING)
                done_flag <= 1;
            else if(current_state >= THREEROW && current_state <= ONEROW)
                done_flag <= 1;
            else
                done_flag <= done_flag;
        end
        // else if(current_state == UP_PADDING || current_state == DOWN_PADDING)
        //     if(row_number == 1  && col_number == 2 && ch == 2'd2 && current_col == (COL-1))
        //         done_flag <= 1;
        //     else
        //         done_flag <= done_flag;
        // else if(current_state >= THREEROW && current_state <= ONEROW)
        //     if(row_number == 2  && col_number == 2 && ch == 2'd2 && current_col == (COL-1))
        //         done_flag <= 1;
        //     else
        //         done_flag <= done_flag;
        else
            done_flag <= 0;
    end 
//============  sram control  =========
    assign cen_reads_ifsram = ~cen0;

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

    always @ (*) begin
        addr_read_ifsram = (if_read_busy) ? addr : 0;
    end

    always @ (*) begin
        if(c_state == 1)
            //addr0 = (current_row + row_oft)*15*4 + (current_col+col_oft)*4 + ch;
            //addr = row_oft*(COL+1)*CH + (current_col+col_oft)*CH + ch;
            addr = row*(WINDOW*3)*CH + (current_window*3 + col_oft)*CH + ch;
        else
            addr = 0;
    end
//---------  index control  --------
//*********  channel control  **************  
always @ (posedge clk) begin
    if(reset)
        ch <= 0;
    else if(ch == (CH-1))
        ch <= 0;
    else if (cen0)
        ch <= ch + 3'd1;
    else 
        ch <= ch;
end
//*********  window control  **************    


always @ (posedge clk) begin
    if(reset)
        current_window <= 0;
    else if(current_window == WINDOW && row_finish)
        current_window <= 0;
    else if(c_state == IR_READ && row_finish)
        current_window <= current_window + 1; 
    else    
        current_window <= current_window;
end

//*********  col control  **************  

always @ (posedge clk) begin
    if(reset)
        col_oft <= 0;
    else if(col_finish)
        col_oft <= 0;
    else if(ch == (CH-1))
        col_oft <= col_oft + 1;
    else
        col_oft <= col_oft;
end

always @ (*) begin
    if(col_oft == 2 && ch == (CH-1))
        col_finish = 1;
    else
        col_finish = 0;
end

//*********  row control  **************  
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

always @ (*) begin
    if(current_state == UP_PADDING)begin
        if(row_number == 0) 
            row = 0;
        else if(row_number == 1)
            row = 1;
    end
    else if(current_state == THREEROW)begin
        if(row_number == 0) 
            row = 0;
        else if(row_number == 1)
            row = 1;
        else if(row_number == 2)
            row = 2;
        else
            row = 0;   
    end
    else if(current_state == TWOROW)begin
        if(row_number == 0) 
            row = 1;
        else if(row_number == 1)
            row = 2;
        else if(row_number == 2)
            row = 0;
        else
            row = 0;   
    end
    else if(current_state == ONEROW)begin
        if(row_number == 0) 
            row = 2;
        else if(row_number == 1)
            row = 0;
        else if(row_number == 2)
            row = 1;
        else
            row = 0;   
    end
    else if(current_state == DOWN_PADDING)begin
        if(row_number == 0) 
            row = 1;
        else if(row_number == 1)
            row = 2;
    end
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

endmodule


