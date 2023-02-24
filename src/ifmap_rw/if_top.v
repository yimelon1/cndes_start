// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.09
// Ver      : 2.0
// Func     : connect the sram and send data to pe
// 		2022.11.09 : deside sram signal for read or write and which sram buffer 
// 		2023.02.10 : join LWX coding the 512 MAC version, and write module need
//					to be rebuilded.
// ============================================================================

`timescale 1ns/100ps

module ifsram_rw #(
		parameter 	TBITS = 64	
	,	parameter 	TBYTE = 8	
)(
	clk		
	,	reset	

	,	if_write_data_din			
	,	if_write_empty_n_din		
	,	if_write_read_dout			

	,	if_write_done 			
	,	if_write_busy 			
	,	if_write_start			

	,	if_read_done 			
	,	if_read_busy 			
	,	if_read_start			

	,	if_pad_done 	
	,	if_pad_busy 	
	,	if_pad_start	

	,	ifsram0_read			
	,	ifsram1_read			
	,	ifsram0_write			
	,	ifsram1_write       	
	,	row_finish				
	,	change_sram				
	,	if_read_current_state	
	// ,

	// dout_ifsr_0 ,dout_ifsr_1 ,dout_ifsr_2 ,dout_ifsr_3 ,dout_ifsr_4 ,dout_ifsr_5 ,dout_ifsr_6 ,dout_ifsr_7        ,
	// if_valid_0  ,if_valid_1  ,if_valid_2  ,if_valid_3  ,if_valid_4  ,if_valid_5  ,if_valid_6  ,if_valid_7         ,
	// if_final_0  ,if_final_1  ,if_final_2  ,if_final_3  ,if_final_4  ,if_final_5  ,if_final_6  ,if_final_7         ,

);


//----------------------------------------------------------------------------
//---------------		Parameter		--------------------------------------
//----------------------------------------------------------------------------
localparam IFMAP_SRAM_ADDBITS = 11 ;
localparam IFMAP_SRAM_DATA_WIDTH = 64;


localparam [2:0] 
	IDLE          = 3'd0,
	UP_PADDING    = 3'd1,
	THREEROW      = 3'd2, //LOAD & READ 3 ROW for top sram
	TWOROW        = 3'd3, //READ 2 ROW for top sram
	ONEROW        = 3'd4, //READ 1 ROW for top sram
	DOWN_PADDING  = 3'd5;

//----------------------------------------------------------------------------
//---------------		I/O			------------------------------------------
//----------------------------------------------------------------------------
input	wire 				clk		;
input	wire 				reset	;

//fifo
input	wire [TBITS-1: 0 ]	if_write_data_din		;
input	wire 				if_write_empty_n_din		;
output	reg 				if_write_read_dout		;


//if sram read & write
output 	reg 				if_write_done		;	// make the next state change
output	reg					if_write_busy		;	// when catch start signal make busy signal  "ON"
input	wire				if_write_start			;	// control from get_ins 

output  reg	   				if_read_done 		;
output  reg					if_read_busy 		;
input   wire				if_read_start		;

output  reg	   				if_pad_done 		;
output  reg					if_pad_busy 		;
input   wire				if_pad_start		;

input	wire				ifsram0_write			;	// if sram write signal
input	wire				ifsram1_write			;	// if sram write signal
input	wire				ifsram0_read			;	// if sram read signal
input	wire				ifsram1_read			;	// if sram read signal

//control signal
output wire row_finish;
output wire change_sram;
input wire [2:0] if_read_current_state;


// ============================================================================
// =============================	Declare		===============================
// ============================================================================
//----to PE signal
	reg [64-1 :0] dout_ifsr_0 ,dout_ifsr_1 ,dout_ifsr_2 ,dout_ifsr_3 ,dout_ifsr_4 ,dout_ifsr_5 ,dout_ifsr_6 ,dout_ifsr_7;
	reg           if_valid_0  ,if_valid_1  ,if_valid_2  ,if_valid_3  ,if_valid_4  ,if_valid_5  ,if_valid_6  ,if_valid_7 ;
	reg           if_final_0  ,if_final_1  ,if_final_2  ,if_final_3  ,if_final_4  ,if_final_5  ,if_final_6  ,if_final_7 ;
//-----------------------------------------------------------------------------
//----- wirte if sram -----
	wire cen_write_ifsram_0 , cen_write_ifsram_1 , cen_write_ifsram_2 , cen_write_ifsram_3 , cen_write_ifsram_4 , cen_write_ifsram_5 , cen_write_ifsram_6 , cen_write_ifsram_7 ;
	wire wen_write_ifsram_0 , wen_write_ifsram_1 , wen_write_ifsram_2 , wen_write_ifsram_3 , wen_write_ifsram_4 , wen_write_ifsram_5 , wen_write_ifsram_6 , wen_write_ifsram_7 ;
	wire [TBITS-1:0]	data_write_ifsram_0 , data_write_ifsram_1 , data_write_ifsram_2 , data_write_ifsram_3 
					, data_write_ifsram_4 , data_write_ifsram_5 , data_write_ifsram_6 , data_write_ifsram_7;
	wire [IFMAP_SRAM_ADDBITS-1:0]	addr_write_ifsram_0 , addr_write_ifsram_1 , addr_write_ifsram_2 , addr_write_ifsram_3 
								, addr_write_ifsram_4 , addr_write_ifsram_5 , addr_write_ifsram_6 , addr_write_ifsram_7	;
//-----------------------------------------------------------------------------

//---- dout signal from SRAM ----
	reg  [TBITS-1:0] dout_sram_if;
	reg dy_dout_en0;

	reg [TBITS-1:0] dout_ifsr_0s0 , dout_ifsr_0s1 , dout_ifsr_0s2 , dout_ifsr_0s3 , dout_ifsr_0s4 , dout_ifsr_0s5 , dout_ifsr_0s6 , dout_ifsr_0s7	;
	reg if_valid_0s0 , if_valid_0s1 , if_valid_0s2 , if_valid_0s3 , if_valid_0s4 , if_valid_0s5 , if_valid_0s6 , if_valid_0s7	;
	reg if_final_0s1 , if_final_0s2 , if_final_0s3 , if_final_0s4 , if_final_0s5 , if_final_0s6 , if_final_0s7	;
	reg if_final_0s0 ;
//-----------------------------------------------------------------------------
//----- read if sram -----
	wire cen_read	;
	reg  cen_read1	, cen_read2	, cen_read3	, cen_read4	, cen_read5	, cen_read6	, cen_read7	;

	reg [10:0] addr_read_ifsram , addr_read_ifsram1 , addr_read_ifsram2 , addr_read_ifsram3 
			,	addr_read_ifsram4 , addr_read_ifsram5 , addr_read_ifsram6 , addr_read_ifsram7	;

	reg ifsram1b0_write , ifsram1b1_write	;
	reg ifsram2b0_write , ifsram2b1_write	;
	reg ifsram3b0_write , ifsram3b1_write	;
	reg ifsram4b0_write , ifsram4b1_write	;
	reg ifsram5b0_write , ifsram5b1_write	;
	reg ifsram6b0_write , ifsram6b1_write	;
	reg ifsram7b0_write , ifsram7b1_write	;

	reg ifsram1b0_read , ifsram1b1_read	;
	reg ifsram2b0_read , ifsram2b1_read	;
	reg ifsram3b0_read , ifsram3b1_read	;
	reg ifsram4b0_read , ifsram4b1_read	;
	reg ifsram5b0_read , ifsram5b1_read	;
	reg ifsram6b0_read , ifsram6b1_read	;
	reg ifsram7b0_read , ifsram7b1_read	;
//-----------------------------------------------------------------------------

//---- SRAM Port signal declare	----
	wire cen_if0b0 , cen_if0b1 ;
	wire cen_if1b0 , cen_if1b1 ;
	wire cen_if2b0 , cen_if2b1 ;
	wire cen_if3b0 , cen_if3b1 ;
	wire cen_if4b0 , cen_if4b1 ;
	wire cen_if5b0 , cen_if5b1 ;
	wire cen_if6b0 , cen_if6b1 ;
	wire cen_if7b0 , cen_if7b1 ;

	wire wen_if0b0 , wen_if0b1 ;
	wire wen_if1b0 , wen_if1b1 ;
	wire wen_if2b0 , wen_if2b1 ;
	wire wen_if3b0 , wen_if3b1 ;
	wire wen_if4b0 , wen_if4b1 ;
	wire wen_if5b0 , wen_if5b1 ;
	wire wen_if6b0 , wen_if6b1 ;
	wire wen_if7b0 , wen_if7b1 ;

	wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if0b0	,	addr_sram_if0b1	;
	wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if1b0	,	addr_sram_if1b1	;
	wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if2b0	,	addr_sram_if2b1	;
	wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if3b0	,	addr_sram_if3b1	;
	wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if4b0	,	addr_sram_if4b1	;
	wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if5b0	,	addr_sram_if5b1	;
	wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if6b0	,	addr_sram_if6b1	;
	wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_if7b0	,	addr_sram_if7b1	;

	wire [  TBITS-1  :   0   ]   din_sram_if0b0	,	din_sram_if0b1	;
	wire [  TBITS-1  :   0   ]   din_sram_if1b0	,	din_sram_if1b1	;
	wire [  TBITS-1  :   0   ]   din_sram_if2b0	,	din_sram_if2b1	;
	wire [  TBITS-1  :   0   ]   din_sram_if3b0	,	din_sram_if3b1	;
	wire [  TBITS-1  :   0   ]   din_sram_if4b0	,	din_sram_if4b1	;
	wire [  TBITS-1  :   0   ]   din_sram_if5b0	,	din_sram_if5b1	;
	wire [  TBITS-1  :   0   ]   din_sram_if6b0	,	din_sram_if6b1	;
	wire [  TBITS-1  :   0   ]   din_sram_if7b0	,	din_sram_if7b1	;

	wire [  TBITS-1  :   0   ]   dout_sram_if0b0	,	dout_sram_if0b1	;
	wire [  TBITS-1  :   0   ]   dout_sram_if1b0	,	dout_sram_if1b1	;
	wire [  TBITS-1  :   0   ]   dout_sram_if2b0	,	dout_sram_if2b1	;
	wire [  TBITS-1  :   0   ]   dout_sram_if3b0	,	dout_sram_if3b1	;
	wire [  TBITS-1  :   0   ]   dout_sram_if4b0	,	dout_sram_if4b1	;
	wire [  TBITS-1  :   0   ]   dout_sram_if5b0	,	dout_sram_if5b1	;
	wire [  TBITS-1  :   0   ]   dout_sram_if6b0	,	dout_sram_if6b1	;
	wire [  TBITS-1  :   0   ]   dout_sram_if7b0	,	dout_sram_if7b1	;


// ============================================================================
// =========================    Control Signal   ==============================
// ============================================================================
	//----------------dout signal-----------------
	always @(posedge clk)begin
		if(reset)
			dy_dout_en0 <= 0;
		else if(~cen_read)
			dy_dout_en0 <= 1;
		else
			dy_dout_en0 <= 0;
	end

	always@(*)begin
		if(dy_dout_en0)begin
			if(ifsram0_read)
				dout_sram_if = dout_sram_if0b0;
			else if(ifsram1_read)
				dout_sram_if = dout_sram_if0b1;
			else
				dout_sram_if = 0;
		end
		else
			dout_sram_if = 0;
	end



	//------------stage signal-------------------
	always @(*)begin 
		if_final_0s0 = row_finish;
	end

	always @(posedge clk)begin
		dout_ifsr_0s0 <= dout_sram_if;
		dout_ifsr_0s1 <= dout_ifsr_0s0;
		dout_ifsr_0s2 <= dout_ifsr_0s1;
		dout_ifsr_0s3 <= dout_ifsr_0s2;
		dout_ifsr_0s4 <= dout_ifsr_0s3;
		dout_ifsr_0s5 <= dout_ifsr_0s4;
		dout_ifsr_0s6 <= dout_ifsr_0s5;
		dout_ifsr_0s7 <= dout_ifsr_0s6;

		if_valid_0s0 <= dy_dout_en0;
		if_valid_0s1 <= if_valid_0s0;
		if_valid_0s2 <= if_valid_0s1;
		if_valid_0s3 <= if_valid_0s2;
		if_valid_0s4 <= if_valid_0s3;
		if_valid_0s5 <= if_valid_0s4;
		if_valid_0s6 <= if_valid_0s5;
		if_valid_0s7 <= if_valid_0s6;

		if_final_0s1 <= if_final_0s0;
		if_final_0s2 <= if_final_0s1;
		if_final_0s3 <= if_final_0s2;
		if_final_0s4 <= if_final_0s3;
		if_final_0s5 <= if_final_0s4;
		if_final_0s6 <= if_final_0s5;
		if_final_0s7 <= if_final_0s6;
	end

	//------------sram signal control-----------------------
	always @(posedge clk)begin
		addr_read_ifsram1 <= addr_read_ifsram;
		addr_read_ifsram2 <= addr_read_ifsram1;
		addr_read_ifsram3 <= addr_read_ifsram2;
		addr_read_ifsram4 <= addr_read_ifsram3;
		addr_read_ifsram5 <= addr_read_ifsram4;
		addr_read_ifsram6 <= addr_read_ifsram5;
		addr_read_ifsram7 <= addr_read_ifsram6;

		cen_read1 <= cen_read;
		cen_read2 <= cen_read1;
		cen_read3 <= cen_read2;
		cen_read4 <= cen_read3;
		cen_read5 <= cen_read4;
		cen_read6 <= cen_read5;
		cen_read7 <= cen_read6;

		// ifsram1b0_write <= ifsram0_write;
		// ifsram2b0_write <= ifsram1b0_write;
		// ifsram3b0_write <= ifsram2b0_write;
		// ifsram4b0_write <= ifsram3b0_write;
		// ifsram5b0_write <= ifsram4b0_write;
		// ifsram6b0_write <= ifsram5b0_write;
		// ifsram7b0_write <= ifsram6b0_write;

		// ifsram1b1_write <= ifsram1_write;
		// ifsram2b1_write <= ifsram1b1_write;
		// ifsram3b1_write <= ifsram2b1_write;
		// ifsram4b1_write <= ifsram3b1_write;
		// ifsram5b1_write <= ifsram4b1_write;
		// ifsram6b1_write <= ifsram5b1_write;
		// ifsram7b1_write <= ifsram6b1_write;
		
		ifsram1b0_read <= ifsram0_read;
		ifsram2b0_read <= ifsram1b0_read;
		ifsram3b0_read <= ifsram2b0_read;
		ifsram4b0_read <= ifsram3b0_read;
		ifsram5b0_read <= ifsram4b0_read;
		ifsram6b0_read <= ifsram5b0_read;
		ifsram7b0_read <= ifsram6b0_read;

		ifsram1b1_read <= ifsram1_read;
		ifsram2b1_read <= ifsram1b1_read;
		ifsram3b1_read <= ifsram2b1_read;
		ifsram4b1_read <= ifsram3b1_read;
		ifsram5b1_read <= ifsram4b1_read;
		ifsram6b1_read <= ifsram5b1_read;
		ifsram7b1_read <= ifsram6b1_read;
	end
	always @(*)begin
		ifsram1b0_write = ifsram0_write;
		ifsram2b0_write = ifsram1b0_write;
		ifsram3b0_write = ifsram2b0_write;
		ifsram4b0_write = ifsram3b0_write;
		ifsram5b0_write = ifsram4b0_write;
		ifsram6b0_write = ifsram5b0_write;
		ifsram7b0_write = ifsram6b0_write;

		ifsram1b1_write = ifsram1_write;
		ifsram2b1_write = ifsram1b1_write;
		ifsram3b1_write = ifsram2b1_write;
		ifsram4b1_write = ifsram3b1_write;
		ifsram5b1_write = ifsram4b1_write;
		ifsram6b1_write = ifsram5b1_write;
		ifsram7b1_write = ifsram6b1_write;
	end


// ============================================================================
// =====================    SRAM signal assignment   ==========================
// ============================================================================
//--------sram 0--------
	assign cen_if0b0			= (ifsram0_write) ? cen_write_ifsram_0  :	(ifsram0_read) ? cen_read  : 1     ;	// else condition is for read signal
	assign wen_if0b0			= (ifsram0_write) ? wen_write_ifsram_0  :	1	                				  	    ;	// else condition is for read signal
	assign addr_sram_if0b0		= (ifsram0_write) ? addr_write_ifsram_0 :	(ifsram0_read) ? addr_read_ifsram	: 11'd0 ;	// else condition is for read signal
	assign din_sram_if0b0		= (ifsram0_write) ? data_write_ifsram_0 :	64'd0	                                    ;

	assign cen_if0b1			= (ifsram1_write) ? cen_write_ifsram_0  :	(ifsram1_read) ? cen_read  : 1     ;	// else condition is for read signal
	assign wen_if0b1			= (ifsram1_write) ? wen_write_ifsram_0  :	1	                                        ;	// else condition is for read signal
	assign addr_sram_if0b1		= (ifsram1_write) ? addr_write_ifsram_0 :	(ifsram1_read) ? addr_read_ifsram   : 11'd0 ;	// else condition is for read signal
	assign din_sram_if0b1		= (ifsram1_write) ? data_write_ifsram_0 :	64'd0	                                    ;
	
	//--------sram 1--------
	assign cen_if1b0			= (ifsram1b0_write) ? cen_write_ifsram_1  :	(ifsram1b0_read) ? cen_read1  : 1     ;	// else condition is for read signal 
	assign wen_if1b0			= (ifsram1b0_write) ? wen_write_ifsram_1  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if1b0		= (ifsram1b0_write) ? addr_write_ifsram_1 :	(ifsram1b0_read) ? addr_read_ifsram1	: 0 ;	// else condition is for read signal 
	assign din_sram_if1b0		= (ifsram1b0_write) ? data_write_ifsram_1 :	0	                                    ; 

	assign cen_if1b1			= (ifsram1b1_write) ? cen_write_ifsram_1  :	(ifsram1b1_read) ? cen_read1  : 1     ;	// else condition is for read signal 
	assign wen_if1b1			= (ifsram1b1_write) ? wen_write_ifsram_1  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if1b1		= (ifsram1b1_write) ? addr_write_ifsram_1 :	(ifsram1b1_read) ? addr_read_ifsram1	: 0 ;	// else condition is for read signal 
	assign din_sram_if1b1		= (ifsram1b1_write) ? data_write_ifsram_1 :	0	                                    ; 

	//--------sram 2--------
	assign cen_if2b0			= (ifsram2b0_write) ? cen_write_ifsram_2  :	(ifsram2b0_read) ? cen_read2  : 1     ;	// else condition is for read signal 
	assign wen_if2b0			= (ifsram2b0_write) ? wen_write_ifsram_2  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if2b0		= (ifsram2b0_write) ? addr_write_ifsram_2 :	(ifsram2b0_read) ? addr_read_ifsram2	: 0 ;	// else condition is for read signal 
	assign din_sram_if2b0		= (ifsram2b0_write) ? data_write_ifsram_2 :	0	                                    ; 

	assign cen_if2b1			= (ifsram2b1_write) ? cen_write_ifsram_2  :	(ifsram2b1_read) ? cen_read2  : 1     ;	// else condition is for read signal 
	assign wen_if2b1			= (ifsram2b1_write) ? wen_write_ifsram_2  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if2b1		= (ifsram2b1_write) ? addr_write_ifsram_2 :	(ifsram2b1_read) ? addr_read_ifsram2	: 0 ;	// else condition is for read signal 
	assign din_sram_if2b1		= (ifsram2b1_write) ? data_write_ifsram_2 :	0	                                    ; 

	//--------sram 3--------
	assign cen_if3b0			= (ifsram3b0_write) ? cen_write_ifsram_3  :	(ifsram3b0_read) ? cen_read3  : 1     ;	// else condition is for read signal 
	assign wen_if3b0			= (ifsram3b0_write) ? wen_write_ifsram_3  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if3b0		= (ifsram3b0_write) ? addr_write_ifsram_3 :	(ifsram3b0_read) ? addr_read_ifsram3	: 0 ;	// else condition is for read signal 
	assign din_sram_if3b0		= (ifsram3b0_write) ? data_write_ifsram_3 :	0	                                    ; 

	assign cen_if3b1			= (ifsram3b1_write) ? cen_write_ifsram_3  :	(ifsram3b1_read) ? cen_read3  : 1     ;	// else condition is for read signal 
	assign wen_if3b1			= (ifsram3b1_write) ? wen_write_ifsram_3  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if3b1		= (ifsram3b1_write) ? addr_write_ifsram_3 :	(ifsram3b1_read) ? addr_read_ifsram3	: 0 ;	// else condition is for read signal 
	assign din_sram_if3b1		= (ifsram3b1_write) ? data_write_ifsram_3 :	0	                                    ; 

	//--------sram 4--------
	assign cen_if4b0			= (ifsram4b0_write) ? cen_write_ifsram_4  :	(ifsram4b0_read) ? cen_read4  : 1     ;	// else condition is for read signal 
	assign wen_if4b0			= (ifsram4b0_write) ? wen_write_ifsram_4  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if4b0		= (ifsram4b0_write) ? addr_write_ifsram_4 :	(ifsram4b0_read) ? addr_read_ifsram4	: 0 ;	// else condition is for read signal 
	assign din_sram_if4b0		= (ifsram4b0_write) ? data_write_ifsram_4 :	0	                                    ; 

	assign cen_if4b1			= (ifsram4b1_write) ? cen_write_ifsram_4  :	(ifsram4b1_read) ? cen_read4  : 1     ;	// else condition is for read signal 
	assign wen_if4b1			= (ifsram4b1_write) ? wen_write_ifsram_4  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if4b1		= (ifsram4b1_write) ? addr_write_ifsram_4 :	(ifsram4b1_read) ? addr_read_ifsram4	: 0 ;	// else condition is for read signal 
	assign din_sram_if4b1		= (ifsram4b1_write) ? data_write_ifsram_4 :	0	                                    ; 

	//--------sram 5--------
	assign cen_if5b0			= (ifsram5b0_write) ? cen_write_ifsram_5  :	(ifsram5b0_read) ? cen_read5  : 1     ;	// else condition is for read signal 
	assign wen_if5b0			= (ifsram5b0_write) ? wen_write_ifsram_5  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if5b0		= (ifsram5b0_write) ? addr_write_ifsram_5 :	(ifsram5b0_read) ? addr_read_ifsram5	: 0 ;	// else condition is for read signal 
	assign din_sram_if5b0		= (ifsram5b0_write) ? data_write_ifsram_5 :	0	                                    ; 

	assign cen_if5b1			= (ifsram5b1_write) ? cen_write_ifsram_5  :	(ifsram5b1_read) ? cen_read5  : 1     ;	// else condition is for read signal 
	assign wen_if5b1			= (ifsram5b1_write) ? wen_write_ifsram_5  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if5b1		= (ifsram5b1_write) ? addr_write_ifsram_5 :	(ifsram5b1_read) ? addr_read_ifsram5	: 0 ;	// else condition is for read signal 
	assign din_sram_if5b1		= (ifsram5b1_write) ? data_write_ifsram_5 :	0	                                    ; 

	//--------sram 6--------
	assign cen_if6b0			= (ifsram6b0_write) ? cen_write_ifsram_6  :	(ifsram6b0_read) ? cen_read6  : 1     ;	// else condition is for read signal 
	assign wen_if6b0			= (ifsram6b0_write) ? wen_write_ifsram_6  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if6b0		= (ifsram6b0_write) ? addr_write_ifsram_6 :	(ifsram6b0_read) ? addr_read_ifsram6	: 0 ;	// else condition is for read signal 
	assign din_sram_if6b0		= (ifsram6b0_write) ? data_write_ifsram_6 :	0	                                    ; 

	assign cen_if6b1			= (ifsram6b1_write) ? cen_write_ifsram_6  :	(ifsram6b1_read) ? cen_read6  : 1     ;	// else condition is for read signal 
	assign wen_if6b1			= (ifsram6b1_write) ? wen_write_ifsram_6  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if6b1		= (ifsram6b1_write) ? addr_write_ifsram_6 :	(ifsram6b1_read) ? addr_read_ifsram6	: 0 ;	// else condition is for read signal 
	assign din_sram_if6b1		= (ifsram6b1_write) ? data_write_ifsram_6 :	0	                                    ; 

	//--------sram 7--------
	assign cen_if7b0			= (ifsram7b0_write) ? cen_write_ifsram_7  :	(ifsram7b0_read) ? cen_read7  : 1     ;	// else condition is for read signal 
	assign wen_if7b0			= (ifsram7b0_write) ? wen_write_ifsram_7  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if7b0		= (ifsram7b0_write) ? addr_write_ifsram_7 :	(ifsram7b0_read) ? addr_read_ifsram7	: 0 ;	// else condition is for read signal 
	assign din_sram_if7b0		= (ifsram7b0_write) ? data_write_ifsram_7 :	0	                                    ; 

	assign cen_if7b1			= (ifsram7b1_write) ? cen_write_ifsram_7  :	(ifsram7b1_read) ? cen_read7  : 1     ;	// else condition is for read signal 
	assign wen_if7b1			= (ifsram7b1_write) ? wen_write_ifsram_7  :	1	                				  	    ;	// else condition is for read signal 
	assign addr_sram_if7b1		= (ifsram7b1_write) ? addr_write_ifsram_7 :	(ifsram7b1_read) ? addr_read_ifsram7	: 0 ;	// else condition is for read signal 
	assign din_sram_if7b1		= (ifsram7b1_write) ? data_write_ifsram_7 :	0	                                    ; 




// ============================================================================
// =========================    Instance Module   =============================
// ============================================================================

//-------------------------if sram0------------------------
	IF_SRAM if0b0 (
		.Q		(	dout_sram_if0b0		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if0b0			),	// Chip Enable (active low)
		.WEN	(	wen_if0b0			),	// Write Enable (active low)
		.A		(	addr_sram_if0b0		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if0b0		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	IF_SRAM if0b1 (
		.Q		(	dout_sram_if0b1		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if0b1			),	// Chip Enable (active low)
		.WEN	(	wen_if0b1			),	// Write Enable (active low)
		.A		(	addr_sram_if0b1		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if0b1		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	//-------------------------if sram1------------------------
	IF_SRAM if1b0 (
		.Q		(	dout_sram_if1b0		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if1b0			),	// Chip Enable (active low)
		.WEN	(	wen_if1b0			),	// Write Enable (active low)
		.A		(	addr_sram_if1b0		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if1b0		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	IF_SRAM if1b1 (
		.Q		(	dout_sram_if1b1		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if1b1			),	// Chip Enable (active low)
		.WEN	(	wen_if1b1			),	// Write Enable (active low)
		.A		(	addr_sram_if1b1		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if1b1		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	//-------------------------if sram2------------------------
	IF_SRAM if2b0 (
		.Q		(	dout_sram_if2b0		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if2b0			),	// Chip Enable (active low)
		.WEN	(	wen_if2b0			),	// Write Enable (active low)
		.A		(	addr_sram_if2b0		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if2b0		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	IF_SRAM if2b1 (
		.Q		(	dout_sram_if2b1		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if2b1			),	// Chip Enable (active low)
		.WEN	(	wen_if2b1			),	// Write Enable (active low)
		.A		(	addr_sram_if2b1		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if2b1		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	//-------------------------if sram3------------------------
	IF_SRAM if3b0 (
		.Q		(	dout_sram_if3b0		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if3b0			),	// Chip Enable (active low)
		.WEN	(	wen_if3b0			),	// Write Enable (active low)
		.A		(	addr_sram_if3b0		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if3b0		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	IF_SRAM if3b1 (
		.Q		(	dout_sram_if3b1		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if3b1			),	// Chip Enable (active low)
		.WEN	(	wen_if3b1			),	// Write Enable (active low)
		.A		(	addr_sram_if3b1		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if3b1		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	//-------------------------if sram4------------------------
	IF_SRAM if4b0 (
		.Q		(	dout_sram_if4b0		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if4b0			),	// Chip Enable (active low)
		.WEN	(	wen_if4b0			),	// Write Enable (active low)
		.A		(	addr_sram_if4b0		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if4b0		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	IF_SRAM if4b1 (
		.Q		(	dout_sram_if4b1		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if4b1			),	// Chip Enable (active low)
		.WEN	(	wen_if4b1			),	// Write Enable (active low)
		.A		(	addr_sram_if4b1		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if4b1		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	//-------------------------if sram5------------------------
	IF_SRAM if5b0 (
		.Q		(	dout_sram_if5b0		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if5b0			),	// Chip Enable (active low)
		.WEN	(	wen_if5b0			),	// Write Enable (active low)
		.A		(	addr_sram_if5b0		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if5b0		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	IF_SRAM if5b1 (
		.Q		(	dout_sram_if5b1		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if5b1			),	// Chip Enable (active low)
		.WEN	(	wen_if5b1			),	// Write Enable (active low)
		.A		(	addr_sram_if5b1		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if5b1		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	//-------------------------if sram6------------------------
	IF_SRAM if6b0 (
		.Q		(	dout_sram_if6b0		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if6b0			),	// Chip Enable (active low)
		.WEN	(	wen_if6b0			),	// Write Enable (active low)
		.A		(	addr_sram_if6b0		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if6b0		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	IF_SRAM if6b1 (
		.Q		(	dout_sram_if6b1		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if6b1			),	// Chip Enable (active low)
		.WEN	(	wen_if6b1			),	// Write Enable (active low)
		.A		(	addr_sram_if6b1		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if6b1		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	//-------------------------if sram7------------------------
	IF_SRAM if7b0 (
		.Q		(	dout_sram_if7b0		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if7b0			),	// Chip Enable (active low)
		.WEN	(	wen_if7b0			),	// Write Enable (active low)
		.A		(	addr_sram_if7b0		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if7b0		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);
	IF_SRAM if7b1 (
		.Q		(	dout_sram_if7b1		),	// output data
		.CLK	(	clk					),	//
		.CEN	(	cen_if7b1			),	// Chip Enable (active low)
		.WEN	(	wen_if7b1			),	// Write Enable (active low)
		.A		(	addr_sram_if7b1		),	// Addresses (A[0] = LSB)
		.D		(	din_sram_if7b1		),	// Data Inputs (D[0] = LSB)
		.EMA	(	3'b0				)	// Extra Margin Adjustment (EMA[0] = LSB)
	);



//--------------------------------------------------
//------	if sram write module instance	--------
//--------------------------------------------------
ifsram_w  #(
	.TBITS ( 64 ),
	.TBYTE ( 8  )
)if_write00(
	.clk		(	clk	)
	,	.reset		(	reset	)

	,	.ifstore_data_din		(	if_write_data_din			)
	,	.ifstore_empty_n_din	(	if_write_empty_n_din		)
	,	.ifstore_read_dout		(	if_write_read_dout			)

	
	,	.if_store_done	(	if_write_done	)
	,	.if_store_busy 	(	if_write_busy	)
	,	.start_if_store	(	if_write_start	)

	,	.dout_wrb0_cen	(	cen_write_ifsram_0	)
	,	.dout_wrb1_cen	(	cen_write_ifsram_1	)
	,	.dout_wrb2_cen	(	cen_write_ifsram_2	)
	,	.dout_wrb3_cen	(	cen_write_ifsram_3	)
	,	.dout_wrb4_cen	(	cen_write_ifsram_4	)
	,	.dout_wrb5_cen	(	cen_write_ifsram_5	)
	,	.dout_wrb6_cen	(	cen_write_ifsram_6	)
	,	.dout_wrb7_cen	(	cen_write_ifsram_7	)

	,	.dout_wrb0_wen	(	wen_write_ifsram_0	)
	,	.dout_wrb1_wen	(	wen_write_ifsram_1	)
	,	.dout_wrb2_wen	(	wen_write_ifsram_2	)
	,	.dout_wrb3_wen	(	wen_write_ifsram_3	)
	,	.dout_wrb4_wen	(	wen_write_ifsram_4	)
	,	.dout_wrb5_wen	(	wen_write_ifsram_5	)
	,	.dout_wrb6_wen	(	wen_write_ifsram_6	)
	,	.dout_wrb7_wen	(	wen_write_ifsram_7	)

	,	.dout_wrb0_addr	(	addr_write_ifsram_0	)
	,	.dout_wrb1_addr	(	addr_write_ifsram_1	)
	,	.dout_wrb2_addr	(	addr_write_ifsram_2	)
	,	.dout_wrb3_addr	(	addr_write_ifsram_3	)
	,	.dout_wrb4_addr	(	addr_write_ifsram_4	)
	,	.dout_wrb5_addr	(	addr_write_ifsram_5	)
	,	.dout_wrb6_addr	(	addr_write_ifsram_6	)
	,	.dout_wrb7_addr	(	addr_write_ifsram_7	)

	,	.dout_wrb0_data	(	data_write_ifsram_0	)
	,	.dout_wrb1_data	(	data_write_ifsram_1	)
	,	.dout_wrb2_data	(	data_write_ifsram_2	)
	,	.dout_wrb3_data	(	data_write_ifsram_3	)
	,	.dout_wrb4_data	(	data_write_ifsram_4	)
	,	.dout_wrb5_data	(	data_write_ifsram_5	)
	,	.dout_wrb6_data	(	data_write_ifsram_6	)
	,	.dout_wrb7_data	(	data_write_ifsram_7	)

);

//--------------------------------------------------
//------	if sram read module instance	--------
//--------------------------------------------------

ifsram_r #(
	.TBITS ( 64 ),
	.TBYTE ( 8  )
) if_read00 (
	.clk		       (clk),
	.reset		       (reset),

	.if_read_start     (if_read_start),
	.if_read_busy      (if_read_busy),
	.if_read_done      (if_read_done),

	.cen_reads_ifsram  (cen_read),
	.addr_read_ifsram  (addr_read_ifsram),
	.change_sram       (change_sram),
	.current_state     (if_read_current_state),

	.row_finish 	   (row_finish)

);

ifsram_pd #(
	.TBITS (	64	)
	,	.TBYTE (	8	)
	,	.IFMAP_SRAM_ADDBITS 	(	IFMAP_SRAM_ADDBITS		)
	,	.IFMAP_SRAM_DATA_WIDTH	(	IFMAP_SRAM_DATA_WIDTH	)
)if_pad00(
 	.clk	(	clk	)
	,	.reset		(	reset	)
	
	,	.if_pad_done 	(	if_pad_done 	)	
	,	.if_pad_busy 	(	if_pad_busy 	)	
	,	.if_pad_start	(	if_pad_start	)	

);



endmodule





