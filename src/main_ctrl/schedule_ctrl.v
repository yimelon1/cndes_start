
// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.10.24
// Ver      : 1.0
// Func     : schedule control, generate start signal for sram r/w module
// Log		:
// 		----2023.02.01: move out if_top module
// 		----2023.02.23: add padding module control
// ============================================================================


module schedule_ctrl (
	clk
	,	reset

	,	mast_curr_state 		


	,	if_write_start			
	,	if_write_busy			
	,	if_write_done			

	,	if_pad_done 		
	,	if_pad_busy 		
	,	if_pad_start		

	,	ker_write_start		
	,	ker_write_busy			
	,	ker_write_done			

	,	bias_write_start		
	,	bias_write_busy		
	,	bias_write_done		

	,	if_read_done 				//schedule -> if_rw
	,	if_read_busy 				//if_rw -> schedule
	,	if_read_start				//if_rw -> schedule

	// --------------Read sram I/O------------
	,	ifsram0_write			//schedule -> if_rw
	,	ifsram1_write			//schedule -> if_rw
	,	ifsram0_read			//schedule -> if_rw
	,	ifsram1_read			//schedule -> if_rw
	,	if_row_finish				//if_rw -> schedule
	,	if_change_sram				//if_rw -> schedule    
	,	if_read_current_state			//schedule -> if_rw
	//---------------------------------------------
	,	flag_fsld_end		
	,	left_done			

	//----testing ----
	,	sche_fsld_curr_state	
	//---------------------------------------------
);

	parameter TBITS = 64;
	parameter TBYTE = 8;


	//------- master FSM parameter -----------
	localparam MAST_FSM_BITS 	= 3;
	localparam M_IDLE 	= 3'd0;
	localparam LEFT 	= 3'd1;
	localparam BASE 	= 3'd2;
	localparam RIGHT 	= 3'd3;
	localparam FSLD 	= 3'd7;	// First load sram0
	//---------------------------------------------


	input wire clk		;
	input wire reset	;

	input wire [ MAST_FSM_BITS -1 : 0 ] mast_curr_state	;


	//-----------------buffer ctrl io -----------------------------

	input wire	if_write_done 		;
	input wire	if_write_busy		;
	output reg 	if_write_start		;

	input wire	if_pad_done 		;
	input wire	if_pad_busy 		;
	output reg	if_pad_start		;



	input wire	ker_write_done 		;
	input wire	bias_write_done 	;

	input wire	ker_write_busy 		;
	input wire	bias_write_busy 	;

	output reg 	ker_write_start 	;
	output reg 	bias_write_start 	;


	output reg 	flag_fsld_end 		;
	output wire  left_done;

	output reg if_read_start;  //schedule -> if_rw
    input wire if_read_busy;   //if_rw -> schedule
    input wire if_read_done;    //if_rw -> schedule

    output reg ifsram0_write;  //schedule -> if_rw
    output reg ifsram1_write;  //schedule -> if_rw
    output reg ifsram0_read;    //schedule -> if_rw
    output reg ifsram1_read;    //schedule -> if_rw
    input wire if_row_finish;        //if_rw -> schedule
    input wire if_change_sram;      //if_rw -> schedule    
    output reg [2:0] if_read_current_state;  //schedule -> if_rw

	//-----------------test -----------------------------
	output wire[3-1:0] sche_fsld_curr_state ;
	//---------------------------------------------------



//-----------------buffer ctrl io -----------------------------

//-------------------   done flag    --------------------------------
	reg [0:0]	sche_if_done ;
	reg [0:0]	sche_ker_done ;
	reg [0:0]	sche_bias_done ;
	reg [2:0]   if_read_next_state;
	reg rdwd_done;


//--------------- master state = fsld -------------------------------
	reg [3:0] fsld_current_state ;
	reg [3:0] fsld_next_state ;
	localparam FS_IDLE 	= 3'd0;
	localparam FS_KER 	= 3'd1;
	localparam FS_BIAS 	= 3'd2;
	localparam FS_IFPD 	= 3'd3;
	localparam FS_DONE 	= 3'd7;
//--------------- master state = LEFT -------------------------------
	reg [3:0] left_current_state ;
	reg [3:0] left_next_state ;
	localparam LF_IDLE 	= 3'd0;
	localparam LF_FSLD	= 3'd1;
	localparam LF_RDWD	= 3'd2;
	// localparam LF_03	= 3'd3;
	// localparam LF_04	= 3'd3;
	// localparam LF_05	= 3'd3;
	// localparam LF_06	= 3'd3;

//--------------- master state = LEFT & left state = RDWD-------------------------------
	localparam [2:0] 
		IDLE          = 3'd0,
		UP_PADDING    = 3'd1,
		THREEROW      = 3'd2, //LOAD & READ 3 ROW for top sram
		TWOROW        = 3'd3, //READ 2 ROW for top sram
		ONEROW        = 3'd4, //READ 1 ROW for top sram
		DOWN_PADDING  = 3'd5;
//-------------------------------------------------------------------
	//---- if schedule need ----
	reg [4:0] write_row_number;
	reg [1:0]threerow_done;
	reg [1:0] dy_if_write_start;
	reg [1:0] dy_if_read_start;
	reg state_stay;
	reg [1:0]sram_top;
	reg stay_sram_top;
	reg change_time;
	reg read_last;


//---- testing instance ----
    // ifsram_rw iftest(
    //     .clk(clk),
    //     .reset(reset),

    //     .if_write_data_din(if_write_data_din)		,
    //     .if_write_empty_n_din(if_write_empty_n_din)		,
    //     .if_write_read_dout(if_write_read_dout)		,

    //     .if_write_done(if_write_done) 		,
    //     .if_write_busy(if_write_busy) 		,
    //     .if_write_start(if_write_start)		,	

    //     .if_read_done(if_read_done) 		,
    //     .if_read_busy(if_read_busy) 		,
    //     .if_read_start(if_read_start)		,

    //     .ifsram0_read(ifsram0_read)		,
    //     .ifsram1_read(ifsram1_read)		,
    //     .ifsram0_write(ifsram0_write)	,
    //     .ifsram1_write(ifsram1_write)   ,
    //     .if_row_finish(if_row_finish),
    //     .if_change_sram(if_change_sram),
    //     .current_state(if_read_current_state)   
    // );




assign sche_fsld_curr_state = fsld_current_state ;


//==============================================================================
//========    first load FSM and fsld_end    ========
//==============================================================================

always @(posedge clk ) begin
	if ( reset ) begin
		fsld_current_state <= 3'd0 ;
	end
	else begin
		fsld_current_state <= fsld_next_state ;
	end
end


always @(*) begin
	case (fsld_current_state)
		FS_IDLE 	:	fsld_next_state = ( mast_curr_state == FSLD )	? FS_KER  : FS_IDLE ;
		FS_KER 		:	fsld_next_state = ( ker_write_done )			? FS_BIAS : FS_KER  ;
		FS_BIAS 	:	fsld_next_state = ( bias_write_done )			? FS_IFPD : FS_BIAS ;
		FS_IFPD 	:	fsld_next_state = ( if_pad_done )				? FS_DONE : FS_IFPD ;
		FS_DONE 	:	fsld_next_state = FS_IDLE	;

		default: fsld_next_state = FS_IDLE ; 
	endcase
end

//----    output fsld end signal for master FSM    -----
always @(*) begin
	if (mast_curr_state == FSLD ) begin
		if ( fsld_current_state == FS_DONE )begin
			flag_fsld_end = 1'd1;
		end
		else begin
			flag_fsld_end = 1'd0;
		end
	end
	else begin
		flag_fsld_end = 1'd0;
	end
end
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------


//----------------left control-------------------
always @(posedge clk ) begin
	if ( reset ) begin
		left_current_state <= 3'd0 ;
	end
	else begin
		left_current_state <= left_next_state ;
	end
end

always @(*) begin
	case (left_current_state)
		LF_IDLE 	:	left_next_state = ( mast_curr_state == LEFT ) ? LF_FSLD : LF_IDLE ;
		LF_FSLD     :   left_next_state = (	if_write_done) 			  ? LF_RDWD : LF_FSLD ; //input data first load
		LF_RDWD 	:	left_next_state = ( rdwd_done) 		  ? LF_IDLE : LF_RDWD ;
		default     :   left_next_state = LF_IDLE ; 
	endcase
end

assign left_done = rdwd_done;


always @(posedge clk ) begin
	if(reset)
		rdwd_done <= 0;
	else if(left_current_state == LF_IDLE)
		rdwd_done <= 0;
	else if(read_last && if_read_current_state == DOWN_PADDING && if_read_done)
		rdwd_done <= 1;
	else
		rdwd_done <= rdwd_done;
end


//--------------------left rdwd control--------------

always @(posedge clk ) begin
	if(reset)
		threerow_done <= 0;
	else if(if_read_current_state == TWOROW)
		threerow_done <= 0;
	else if(if_read_current_state == THREEROW && (if_read_done || if_write_done))
		threerow_done <= threerow_done + 1;
	else
		threerow_done <= threerow_done;
end




always @(posedge clk) begin
	if ( reset ) begin
		if_read_current_state <= 3'd0 ;
	end
	else begin
		if_read_current_state <= if_read_next_state ;
	end
end


always @(*) begin
	case (if_read_current_state)
		IDLE         : if_read_next_state = (left_current_state == LF_RDWD && !rdwd_done) ? UP_PADDING : IDLE;
		UP_PADDING   : if_read_next_state = (if_read_done) ? THREEROW : UP_PADDING;
		THREEROW     : if_read_next_state = (threerow_done == 2) ? TWOROW   : THREEROW;
		TWOROW       : if_read_next_state = (if_read_done) ? ONEROW   : TWOROW;
		ONEROW       : if_read_next_state = (if_read_done && read_last) ? DOWN_PADDING : (if_read_done && !read_last) ? THREEROW : ONEROW;
		DOWN_PADDING : if_read_next_state = (if_read_done) ? IDLE     : DOWN_PADDING;
		default      : if_read_next_state = IDLE;
	endcase
end


always @ (*)begin
	if(write_row_number == 5'd15)
		read_last <= 1;
	else
		read_last <= 0;
end



//=======================================================================

//-----------------if write signal-----------------


always @(posedge clk) begin
	if(reset)
		if_write_start <= 0;
	else if(dy_if_write_start == 3)
		if_write_start <= 0;
	else if(left_current_state == LF_FSLD && !if_write_busy)
		if_write_start <= 1;
	else if(if_read_current_state == THREEROW && !if_write_busy && threerow_done == 0)
		if_write_start <= 1;
	else 
		if_write_start <= if_write_start;
end

always@ (posedge clk)begin
	if(reset)
		dy_if_write_start <= 0;
	else if(dy_if_write_start == 3)
		dy_if_write_start <= 0;
	else if(if_write_start)
		dy_if_write_start <= dy_if_write_start + 1;
	else 
		dy_if_write_start <= dy_if_write_start;
end



always@ (posedge clk)begin
	if(reset)
		write_row_number <= 0;
	else if(left_current_state == LF_IDLE)
		write_row_number <= 0;
	else if(if_write_done)
		write_row_number <= write_row_number + 5'd3;
	else
		write_row_number <= write_row_number;
end


always@ (posedge clk)begin
	if(reset)begin
		ifsram0_write <= 0;
		ifsram1_write <= 0;
	end	
	else if(if_write_done)begin
		ifsram0_write <= 0;
		ifsram1_write <= 0;
	end
	else if(if_write_start)begin
		if(write_row_number == 0 || write_row_number == 6 || write_row_number == 12)begin
			ifsram0_write <= 1;
			ifsram1_write <= 0;
		end
		else if(write_row_number == 3 || write_row_number == 9)begin
			ifsram0_write <= 0;
			ifsram1_write <= 1;
		end
		else begin
			ifsram0_write <= ifsram0_write;
			ifsram1_write <= ifsram1_write;
		end
	end
	else begin
		ifsram0_write <= ifsram0_write;
		ifsram1_write <= ifsram1_write;
	end
end

//--------------------------------------------------

//-----------------if read signal-----------------

always @(posedge clk) begin
	if(reset)
		if_read_start <= 0;
	else if(dy_if_read_start == 3)
		if_read_start <= 0;
	else if((if_read_current_state >= UP_PADDING && if_read_current_state <= DOWN_PADDING)&& !if_read_busy )
		if_read_start <= 1;
	else 
		if_read_start <= if_read_start;
end



always @ (posedge clk) begin //let if_read_current_state not run twice
	if(reset)
		state_stay <= 0;
	else if(if_read_start)
		state_stay <= 0;
	else if(if_read_done)
		state_stay <= 1;
	else
		state_stay <= state_stay;
end


always@ (posedge clk)begin
	if(reset)
		dy_if_read_start <= 0;
	else if(dy_if_read_start == 3)
		dy_if_read_start <= 0;
	else if(if_read_start)
		dy_if_read_start <= dy_if_read_start + 1;
	else 
		dy_if_read_start <= dy_if_read_start;
end

//------------------------------------------------
//--------------------

always @(posedge clk)begin
    if(reset)begin
        sram_top <= 0;
		stay_sram_top <= 0;
	end
	else if(if_write_done)
		stay_sram_top <= 0;
	else if(stay_sram_top)
		sram_top <= sram_top;
	else if(sram_top == 0)begin
		if(ifsram0_write)begin
			sram_top <= 1;
			stay_sram_top <= 1;
		end
		else if(ifsram1_write)begin 
			sram_top <= 2;
			stay_sram_top <= 1;
		end
		else 
			sram_top <= sram_top;
	end
	else begin
		if(ifsram0_write)begin
			sram_top <= 2;
			stay_sram_top <= 1;
		end
		else if(ifsram1_write)begin
			sram_top <= 1;
			stay_sram_top <= 1;
		end
		else 
			sram_top <= sram_top;
	end
end



always @(posedge clk)begin
	if(reset)
		change_time <= 0;
	else if(if_change_sram)
		change_time <= 1;
	else if(if_row_finish)
		change_time <= 0;
	else
		change_time <= change_time;
end


always @ (*) begin
	if(if_read_busy)begin
		if(if_read_current_state == UP_PADDING || if_read_current_state == THREEROW || if_read_current_state == DOWN_PADDING)begin
			if(sram_top == 1)begin
				ifsram0_read = 1;
				ifsram1_read = 0;
			end
			else if(sram_top == 2)begin
				ifsram0_read = 0;
				ifsram1_read = 1;
			end
			else begin
				ifsram0_read = 0;
				ifsram1_read = 0;
			end
		end
		else if(if_read_current_state >= THREEROW || if_read_current_state <= ONEROW)begin
			if(sram_top == 1)begin
				if(change_time)begin
					ifsram0_read = 0;
					ifsram1_read = 1;
				end
				else begin
					ifsram0_read = 1;
					ifsram1_read = 0;
				end
			end
			else if(sram_top == 2)begin
				if(change_time)begin
					ifsram0_read = 1;
					ifsram1_read = 0;
				end
				else begin
					ifsram0_read = 0;
					ifsram1_read = 1;
				end
			end
			else begin
				ifsram0_read = 0;
				ifsram1_read = 0;
			end
		end
		else begin
            ifsram0_read = 0;
            ifsram1_read = 0;
		end
	end
	else begin
        ifsram0_read = 0;
        ifsram1_read = 0;
	end
end
//------

//===========================kernel and bias control===============

always @(posedge clk ) begin
	if (reset) begin ker_write_start<= 1'd0 ; end
	else begin
		if( fsld_current_state == FS_KER  )begin
			ker_write_start<= ~ker_write_busy & ~ker_write_done ;
		end
		else begin
			ker_write_start<= 1'd0;
		end
	end
end


always @(posedge clk ) begin
	if (reset) begin bias_write_start<= 1'd0 ; end
	else begin
		if( fsld_current_state == FS_BIAS  )begin
			bias_write_start<= ~bias_write_busy & ~bias_write_done ;
		end
		else begin
			bias_write_start<= 1'd0;
		end
	end
end

//==============================================================================
//========    if padding control start signal    ========
//==============================================================================

always @(posedge clk ) begin
	if(reset)if_pad_start <= 1'd0 ;
	else begin
		if( fsld_current_state == FS_IFPD  )begin
			if_pad_start<= (!if_pad_busy) & (!if_pad_done)  ;
		end
		else begin
			if_pad_start<= 1'd0;
		end
	end
end


endmodule