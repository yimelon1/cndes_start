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

        input clk	
    ,   input reset		
//=========for sche=============   
    ,   input wire        if_read_start		
    ,   output reg        if_read_busy		
    ,   output reg        if_read_done		

//=============for sram ============
    ,   output wire       cen_reads_ifsram	
    ,   output reg [10:0] addr_read_ifsram	
    ,   output reg        change_sram		
    ,   input  wire [2:0] current_state		
    ,   output reg  row_finish	
    ,   output reg  dy2_conv_finish
//=========cfg input signal
    ,   input  wire [3:0]		cfg_window			
    ,   input  wire [5-1:0]		cfg_atlchin		 // 32/8 = 4
    ,   input  wire [7:0]       cfg_kernel_repeat
    
);

//============   parameter  ===================
    // parameter WINDOW = 4;
    // parameter CH  = 4; // 32/8 = 4
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
    reg [5:0] row;
    reg [5:0] col_oft;
    reg [2:0] ch;
    reg [5:0] current_window;
    reg [1:0] col_number;
    reg [1:0] row_number;
    reg col_finish;
    reg [10:0] addr;
reg local_done_flag;


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
            IR_READ: next_state = (local_done_flag)  ? IR_IDLE : IR_READ ;
            default: next_state = IR_IDLE ;
        endcase	
    end
    reg read_busy;
    reg dy0_read_busy;

    always @( * ) begin
        read_busy = ( c_state == IR_READ) ? 1'd1 : 1'd0 ;
    end
    always @( posedge clk ) begin
        if(reset)begin
            dy0_read_busy <= 0;
            if_read_busy <= 0;
        end
        else begin
            dy0_read_busy <= read_busy;
            if_read_busy <= dy0_read_busy;
        end 
    end


    always @( * ) begin
        cen0 = ( c_state == IR_READ) ? 1'd1 : 1'd0 ;
    end
    wire conv_finish;
    reg dy_cen0_0;
    reg dy_cen0_1;
    reg dy0_window_finish;
    reg dy1_window_finish;
    reg dy2_window_finish;
    always @( posedge clk ) begin
        if(reset)begin
            dy_cen0_0 <= 0;
            dy_cen0_1 <= 0;
        end
        else begin
            dy_cen0_0 <= cen0;
            dy_cen0_1 <= dy_cen0_0;
        end   
    end

    always @ (*)begin
        if(done_flag) 
            if_read_done = 1;
        else
            if_read_done = 0;
    end

    reg window_finish;
    reg dy0_conv_finish;
    reg dy1_conv_finish;
    //reg dy2_conv_finish;
   
    
    always @ (*)begin //no finish
        // if(reset)
        //     done_flag <= 0;
        // else if(done_flag)
        //     done_flag <= 0;
        // else 
        if(dy2_conv_finish)begin
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
    
    always @ (*)begin //no finish
        // if(reset)
        //     done_flag <= 0;
        // else if(done_flag)
        //     done_flag <= 0;
        // else 
        if(conv_finish)begin
            if(current_state == UP_PADDING || current_state == DOWN_PADDING)
                local_done_flag <= 1;
            else if(current_state >= THREEROW && current_state <= ONEROW)
                local_done_flag <= 1;
            else
                local_done_flag <= local_done_flag;
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
            local_done_flag <= 0;
    end
//============  sram control  =========
    assign cen_reads_ifsram = ~dy_cen0_1;

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
        addr_read_ifsram = (dy_cen0_1) ? addr : 0;
    end
    
    reg [10:0] row_offset;
    reg [10:0] col_offset;
    reg [2:0] ch_offset;
    wire [10:0]addrtt; 
    always @ (posedge clk) begin
        addr <= row_offset + col_offset + ch_offset;
    end
    assign addrtt = row*cfg_window*3*cfg_atlchin + (current_window*3 + col_oft)*cfg_atlchin + ch;
    //row offset
    always @ (posedge clk) begin
        if(reset)
            row_offset <= 0;
        else if(c_state == 1)
            row_offset <= row*cfg_window*3*cfg_atlchin;
        else if(c_state == 0)
            row_offset <= 0;
        else    
            row_offset <= row_offset;
    end
    //col_offset
    always @ (posedge clk) begin
        if(reset)
            col_offset <= 0;
        else if(c_state == 1)
            col_offset <= (current_window*3 + col_oft)*cfg_atlchin;
        else if(c_state == 0)
            col_offset <= 0;
        else    
            col_offset <= col_offset;
    end
    //channel offset
    always @ (posedge clk) begin
        if(reset)
            ch_offset <= 0;
        else if(c_state == 1)
            ch_offset <= ch;
        else if(c_state == 0)
            ch_offset <= 0;
        else    
            ch_offset <= ch_offset;
    end   
//---------  index control  --------
//*********  repeat control  **************  

    reg [4:0] repeat_window;

    always @ (posedge clk) begin
        if(reset)
            repeat_window <= 0;
        else if(conv_finish)
            repeat_window <= 0;
        else if(c_state == IR_READ && window_finish)
            repeat_window <= repeat_window + 1;
        else 
            repeat_window <= repeat_window;
    end

assign conv_finish = (window_finish && repeat_window == cfg_kernel_repeat) ? 1 : 0;

    always @ (posedge clk) begin
        if(reset)begin
            dy0_conv_finish <= 0;
            dy1_conv_finish <= 0;
            dy2_conv_finish <= 0;
        end
        else begin
            dy0_conv_finish <= conv_finish;
            dy1_conv_finish <= dy0_conv_finish;
            dy2_conv_finish <= dy1_conv_finish;
        end
    end



//*********  channel control  **************  
    always @ (posedge clk) begin
        if(reset)
            ch <= 0;
        else if(ch == (cfg_atlchin-1))
            ch <= 0;
        else if (cen0)
            ch <= ch + 3'd1;
        else 
            ch <= ch;
    end
//*********  window control  **************    


    // always @ (posedge clk) begin
    //     if(reset)
    //         current_window <= 0;
    //     else if(current_window == cfg_window && row_finish)
    //         current_window <= 0;
    //     else if(c_state == IR_READ && row_finish)
    //         current_window <= current_window + 1; 
    //     else    
    //         current_window <= current_window;
    // end

    always @ (posedge clk) begin
        if(reset)
            current_window <= 0;
        else if(current_window == cfg_window-1 && row_finish)
            current_window <= 0;
        else if(c_state == IR_READ && row_finish)
            current_window <= current_window + 1; 
        else    
            current_window <= current_window;
    end

    always @ (*) begin
        if(row_finish && current_window == cfg_window-1)
            window_finish<= 1;
        else    
            window_finish<= 0;
    end
    
    always @ (posedge clk) begin
        if(reset)begin
            dy0_window_finish <= 0;
            dy1_window_finish <= 0;
            dy2_window_finish <= 0;
        end
        else begin
            dy0_window_finish <= window_finish;
            dy1_window_finish <= dy0_window_finish;
            dy2_window_finish <= dy1_window_finish;
        end
    end


//*********  col control  **************  

    always @ (posedge clk) begin
        if(reset)
            col_oft <= 0;
        else if(col_finish)
            col_oft <= 0;
        else if(ch == (cfg_atlchin-1))
            col_oft <= col_oft + 1;
        else
            col_oft <= col_oft;
    end

    always @ (*) begin
        if(col_oft == 2 && ch == (cfg_atlchin-1))
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


