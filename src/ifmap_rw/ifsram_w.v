// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.09
// Ver      : 2.0
// Func     : just generate if sram signel
// 		2022.11.09 : move sram to outside 
// 		2023.02.13 : 512MAC version padding left
// 		2023.02.18 : counter replace to v4. more config register be used by control_signal.
// 				we need 
// 			---- every buffer address counting is different. first support padding =1,2 .
// 			---- 3x3 CONV limit : pad:1 , ch_in:64 , col_in:66 , padcol_in:65 , col_out:64 . 8*3col*3row*(64ch/8)=576/each SRAM
// 			---- 5x5 CONV limit : pad:2 , ch_in:64 , col_in:36 , padcol_in:34 , col_out:32 . 4*5col*5row*(64ch/8)=800/each SRAM
// 			---- 7x7 CONV limit : pad:3 , ch_in:64 , col_in:22 , padcol_in:19 , col_out:16 . 2*7col*7row*(64ch/8)=784/each SRAM
// 			---------
// 			-- test config : 3x3 CONV , ch=32 ,col_out=16 , pad_count=(32/8)*(3-pad)=4*2=8 ,nor_count=(32/8)*3=12
// 			---- (normal)input row length=(32/8)*(16+2)col*3row , (pad)input row length=(32/8)*(16+1)col*3row
// 			---- (limit)stage0_counter bits => 7*2 , 5*4 , 3*8 = 14,20,24 . so we need 5 bits for counting each window
// 			---- (limit)stage1_counter bits => 2 ,4 ,8 it shows how many output column in each buffer. so we need 3 bits for counting each window
// ============================================================================

`define INS_REPLACE		// replace cnter and fsm


module ifsram_w
#(
	parameter TBITS = 64 ,
	parameter TBYTE = 8
)(
 	clk			
	,	reset		

	,	ifstore_data_din		
	,	ifstore_empty_n_din		
	,	ifstore_read_dout		

	,	if_store_done 			
	,	if_store_busy 			
	,	start_if_store			

	,	dout_wrb0_cen	
	,	dout_wrb1_cen	
	,	dout_wrb2_cen	
	,	dout_wrb3_cen	
	,	dout_wrb4_cen	
	,	dout_wrb5_cen	
	,	dout_wrb6_cen	
	,	dout_wrb7_cen	

	,	dout_wrb0_wen	
	,	dout_wrb1_wen	
	,	dout_wrb2_wen	
	,	dout_wrb3_wen	
	,	dout_wrb4_wen	
	,	dout_wrb5_wen	
	,	dout_wrb6_wen	
	,	dout_wrb7_wen	

	,	dout_wrb0_addr	
	,	dout_wrb1_addr	
	,	dout_wrb2_addr	
	,	dout_wrb3_addr	
	,	dout_wrb4_addr	
	,	dout_wrb5_addr	
	,	dout_wrb6_addr	
	,	dout_wrb7_addr	

	,	dout_wrb0_data	
	,	dout_wrb1_data	
	,	dout_wrb2_data	
	,	dout_wrb3_data	
	,	dout_wrb4_data	
	,	dout_wrb5_data	
	,	dout_wrb6_data	
	,	dout_wrb7_data	

);

//----------------------------------------------------------------------------
//---------------		Parameter		--------------------------------------
//----------------------------------------------------------------------------
localparam IFMAP_SRAM_ADDBITS = 11 ;
localparam IFMAP_SRAM_DATA_WIDTH = 64;
localparam DATAIN_CNT_BITS = 9;

// one row address 0 to 263 means col0 ~ col65
localparam IFWSTG0_CNTBITS = 5	;	// if write stage0_counter bits width for compare
localparam IFWSTG1_CNTBITS = 3	;	// if write stage1_counter bits width for compare


//---- config -----------
localparam FINAL_DIN_NUM =  68 ;		// final of input data number each row 4*66 -> 4*16

localparam FINAL_STRADDR_NUM =	FINAL_DIN_NUM*3	;		// 3row data = FINAL_DIN_NUM *3  
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//---------------		I/O	Declare		--------------------------------------
//----------------------------------------------------------------------------
input	wire 				clk		;
input	wire 				reset	;
input	wire [TBITS-1: 0 ]	ifstore_data_din		;
input	wire 				ifstore_empty_n_din		;
output	reg 				ifstore_read_dout		;

output 	reg 				if_store_done		;	// make the next state change
output	reg					if_store_busy		;	// when catch start signal make busy signal  "ON"
input	wire				start_if_store			;	// control from get_ins 


output	wire dout_wrb0_cen , dout_wrb1_cen , dout_wrb2_cen , dout_wrb3_cen , dout_wrb4_cen , dout_wrb5_cen , dout_wrb6_cen , dout_wrb7_cen	;
output	wire dout_wrb0_wen , dout_wrb1_wen , dout_wrb2_wen , dout_wrb3_wen , dout_wrb4_wen , dout_wrb5_wen , dout_wrb6_wen , dout_wrb7_wen	;

output	wire [IFMAP_SRAM_ADDBITS-1 : 0]dout_wrb0_addr , dout_wrb1_addr , dout_wrb2_addr , dout_wrb3_addr 
										, dout_wrb4_addr , dout_wrb5_addr , dout_wrb6_addr , dout_wrb7_addr	;
output	wire [TBITS-1 : 0]dout_wrb0_data , dout_wrb1_data , dout_wrb2_data , dout_wrb3_data 
							, dout_wrb4_data , dout_wrb5_data , dout_wrb6_data , dout_wrb7_data	;

reg [1:0] current_state ;
reg [1:0] next_state ;
// ============================================================================
//--------		Config master state		-----------
localparam  NORMAL 	= 2'd1 ;
localparam  LEFT 	= 2'd2 ;
localparam  RIGH 	= 2'd3 ;

//-----------------------------------------------------------------------------


//-------  input data stream ------
reg [DATAIN_CNT_BITS-1:0]			dr_num_dly0	;
reg [DATAIN_CNT_BITS-1:0]			dr_num_dly1	;
reg [DATAIN_CNT_BITS-1:0]			dr_num_dly2	;
reg [DATAIN_CNT_BITS-1:0]			dr_num_dly3	;
reg [DATAIN_CNT_BITS-1:0]			dr_num_dly4	;
reg [DATAIN_CNT_BITS-1:0]			dr_num_dly5	;
reg [DATAIN_CNT_BITS-1:0]			dr_num_dly6	;
reg [DATAIN_CNT_BITS-1:0]			dr_num_dly7	;

reg [TBITS-1:0] 	dr_data_dly0	;
reg [TBITS-1:0] 	dr_data_dly1	;
reg [TBITS-1:0] 	dr_data_dly2	;
reg [TBITS-1:0] 	dr_data_dly3	;
reg [TBITS-1:0] 	dr_data_dly4	;
reg [TBITS-1:0] 	dr_data_dly5	;
reg [TBITS-1:0] 	dr_data_dly6	;
reg [TBITS-1:0] 	dr_data_dly7	;

reg valid_drdata ;
reg valid_drdata_dly0 ;
reg valid_drdata_dly1 ;
reg valid_drdata_dly2 ;
reg valid_drdata_dly3 ;
reg valid_drdata_dly4 ;
reg valid_drdata_dly5 ;
reg valid_drdata_dly6 ;
reg valid_drdata_dly7 ;
reg valid_drdata_dly8 ;
reg valid_drdata_dly9 ;

localparam CNT_ROW_BITS = 3 ;
localparam ROW_CNT_START = 'd0 ;
localparam ROW_CNT_FINAL = 'd2 ;
wire [CNT_ROW_BITS -1 : 0]	row_count	;
wire row_last ;
wire en_row_count ;
reg		[ DATAIN_CNT_BITS -1 : 0 ] cnt00 ;

//-----------------------------------------------------------------------------



//----    signal alignment declare    -----
	wire	[TBITS -1 : 0 ] 			align_data_in 	;
	wire	[ DATAIN_CNT_BITS -1 : 0 ]	align_din_index ;
	wire								align_din_valid ;
//-----------------------------------------------------------------------------


//----   config register declare    -----
reg		[5-1:0]	cfg_atlchin ;
reg		[3-1:0] cfg_conv_switch ;

reg [2-1:0 ]	cfg_mast_state		;
reg [6-1:0 ]	cfg_pdlf	;
reg [6-1:0 ]	cfg_pdrg	;
reg [6-1:0 ]	cfg_nor		;

reg	[IFWSTG0_CNTBITS-1 :0]	cfg_stg0_nor_finum	;
reg	[IFWSTG0_CNTBITS-1 :0]	cfg_stg0_pdb0_finum	;
reg	[IFWSTG0_CNTBITS-1 :0]	cfg_stg0_pdb1_finum	;
reg	[IFWSTG1_CNTBITS-1 :0]	cfg_stg1_eb_col		;






//----    buffer 0 control    -----

localparam WR_IDLE 		= 3'd0;
localparam WR_NORMAL	= 3'd1;
localparam WR_LEFT		= 3'd2;
localparam WR_RIGH		= 3'd3;
localparam WR_DONE		= 3'd4;


wire [IFWSTG0_CNTBITS-1:0]	wrb0_cnt00 , wrb1_cnt00 , wrb2_cnt00 , wrb3_cnt00 , wrb4_cnt00 , wrb5_cnt00 , wrb6_cnt00 , wrb7_cnt00 ;
wire [IFWSTG0_CNTBITS-1:0]	wrb0_cnt01 , wrb1_cnt01 , wrb2_cnt01 , wrb3_cnt01 , wrb4_cnt01 , wrb5_cnt01 , wrb6_cnt01 , wrb7_cnt01 ;
wire wrb0_stg0_en , wrb1_stg0_en , wrb2_stg0_en , wrb3_stg0_en , wrb4_stg0_en , wrb5_stg0_en , wrb6_stg0_en , wrb7_stg0_en ;
wire wrb0_stg1_en , wrb1_stg1_en , wrb2_stg1_en , wrb3_stg1_en , wrb4_stg1_en , wrb5_stg1_en , wrb6_stg1_en , wrb7_stg1_en ;
wire wrb0_stg0_last , wrb1_stg0_last , wrb2_stg0_last , wrb3_stg0_last , wrb4_stg0_last , wrb5_stg0_last , wrb6_stg0_last , wrb7_stg0_last ;
wire wrb0_stg1_last , wrb1_stg1_last , wrb2_stg1_last , wrb3_stg1_last , wrb4_stg1_last , wrb5_stg1_last , wrb6_stg1_last , wrb7_stg1_last ;

wire [IFMAP_SRAM_ADDBITS-1:0] wrb0_sram_addrcnt , wrb1_sram_addrcnt , wrb2_sram_addrcnt , wrb3_sram_addrcnt , wrb4_sram_addrcnt 
	, wrb5_sram_addrcnt , wrb6_sram_addrcnt , wrb7_sram_addrcnt;
wire wrb0_sram_addrcnt_last , wrb1_sram_addrcnt_last , wrb2_sram_addrcnt_last , wrb3_sram_addrcnt_last , wrb4_sram_addrcnt_last 
	, wrb5_sram_addrcnt_last , wrb6_sram_addrcnt_last , wrb7_sram_addrcnt_last;


wire [IFWSTG0_CNTBITS-1 :0] wrb0_cnt00_finalnum ;
wire [IFWSTG1_CNTBITS-1 :0] wrb0_cnt01_finalnum ;

wire [IFWSTG0_CNTBITS-1 :0] wrb1_cnt00_finalnum ;
wire [IFWSTG1_CNTBITS-1 :0] wrb1_cnt01_finalnum ;

wire [IFWSTG0_CNTBITS-1 :0] wrb2_cnt00_finalnum ;
wire [IFWSTG1_CNTBITS-1 :0] wrb2_cnt01_finalnum ;

wire [IFWSTG0_CNTBITS-1 :0] wrb3_cnt00_finalnum ;
wire [IFWSTG1_CNTBITS-1 :0] wrb3_cnt01_finalnum ;

wire [IFWSTG0_CNTBITS-1 :0] wrb4_cnt00_finalnum ;
wire [IFWSTG1_CNTBITS-1 :0] wrb4_cnt01_finalnum ;

wire [IFWSTG0_CNTBITS-1 :0] wrb5_cnt00_finalnum ;
wire [IFWSTG1_CNTBITS-1 :0] wrb5_cnt01_finalnum ;

wire [IFWSTG0_CNTBITS-1 :0] wrb6_cnt00_finalnum ;
wire [IFWSTG1_CNTBITS-1 :0] wrb6_cnt01_finalnum ;

wire [IFWSTG0_CNTBITS-1 :0] wrb7_cnt00_finalnum ;
wire [IFWSTG1_CNTBITS-1 :0] wrb7_cnt01_finalnum ;


wire 	[IFMAP_SRAM_ADDBITS-1:0] wr_cpr_0	;	// write compare
wire 	[IFMAP_SRAM_ADDBITS-1:0] wr_cpr_1	;	// write compare
wire 	[IFMAP_SRAM_ADDBITS-1:0] wr_cpr_2	;	// write compare
wire 	[IFMAP_SRAM_ADDBITS-1:0] wr_cpr_3	;	// write compare
wire 	[IFMAP_SRAM_ADDBITS-1:0] wr_cpr_4	;	// write compare
wire 	[IFMAP_SRAM_ADDBITS-1:0] wr_cpr_5	;	// write compare
wire 	[IFMAP_SRAM_ADDBITS-1:0] wr_cpr_6	;	// write compare
wire 	[IFMAP_SRAM_ADDBITS-1:0] wr_cpr_7	;	// write compare


wire tst_row_fin_index	;	//test

reg row_last_dly0 , row_last_dly1 , row_last_dly2 , row_last_dly3 , row_last_dly4 , row_last_dly5 , row_last_dly6 , row_last_dly7 ;
wire wrb0_row_last , wrb1_row_last , wrb2_row_last , wrb3_row_last , wrb4_row_last , wrb5_row_last , wrb6_row_last , wrb7_row_last	;



//----    write buffer padding fsm    -----
wire [3-1:0] wrb0_current_state;
wire [3-1:0] wrb1_current_state;
wire [3-1:0] wrb2_current_state;
wire [3-1:0] wrb3_current_state;
wire [3-1:0] wrb4_current_state;
wire [3-1:0] wrb5_current_state;
wire [3-1:0] wrb6_current_state;
wire [3-1:0] wrb7_current_state;

wire	[5-1:0] b0_padding_parm	;
wire	[5-1:0]	b1_padding_parm ;


reg 	[6-1:0]	gen_pdshifter_0 	;
reg 	[6-1:0]	gen_pdshifter_1 	;
reg 	[6-1:0]	gen_norshifter 		;


wire [6-1:0] pdb0_shift;
wire [6-1:0] pdb1_shift;
wire [6-1:0] norb0_shifter;
wire [6-1:0] norb1_shifter;

//----    stride window shifter    -----
reg [6-1:0] strwind_sht_0 ;
reg [6-1:0] strwind_sht_1 ;
reg [6-1:0] strwind_sht_2 ;
reg [6-1:0] strwind_sht_3 ;
reg [6-1:0] strwind_sht_4 ;
reg [6-1:0] strwind_sht_5 ;
reg [6-1:0] strwind_sht_6 ;
reg [6-1:0] strwind_sht_7 ;

wire [6-1:0] strb0_shift ;
wire [6-1:0] strb1_shift ;
wire [6-1:0] strb2_shift ;
wire [6-1:0] strb3_shift ;
wire [6-1:0] strb4_shift ;
wire [6-1:0] strb5_shift ;
wire [6-1:0] strb6_shift ;
wire [6-1:0] strb7_shift ;


//----    padding address shifter    -----
wire [8-1:0]	wrb0_pdaddr_shifter	;

//----    busy & done checker and reset    -----
wire wrb_end_check ;
wire wrb_rst ;
wire wrcaf_reset ;	// write buffer cnt and wr_fsm reset 



//-----------------------------------------------------------------------------
//----    reset counter and fsm    -----
//-----------------------------------------------------------------------------
assign wrcaf_reset = reset | wrb_rst	;

// ============================================================================
// ========		Config register		 ==========================================
// ============================================================================
//----   config register generate     -----
always @(posedge clk ) begin
	if(reset)begin
		cfg_mast_state	<= LEFT 	;	//NORMAL LEFT RIGH 	
		cfg_pdlf		<= 6'd8 	;
		cfg_pdrg		<= 6'd8 	;
		cfg_nor			<= 6'd12 	;
		cfg_atlchin		<= 5'd4		;	// ch64->8 ch32->4 ... = ch_in/8
		cfg_conv_switch <= 3'd2		;	// 3x3 = 3'd2 , 5x5 = 3'd3 

		//(for counter, don'd use subtract)
		cfg_stg0_nor_finum	<=	5'd11	;	// 3x3 pad=1 needed (for counter, don'd use subtract)
		cfg_stg0_pdb0_finum	<=	5'd7	;	// 3x3 pad=1 needed, pdb0_finum	= (3-1)*atl_ch_in -1 = 2*4-1 = 7 , 5x5 pd=2 pdb0_finum =(5-2)*atl_ch_in -1,(for counter, don'd use subtract)
		cfg_stg0_pdb1_finum	<=	5'd7	;	// 5x5 pad=2 needed (for counter, don'd use subtract)
		cfg_stg1_eb_col		<=	5'd1	;	// how many col for each buffer, every buffer column = run_col -1 (for counter, don'd use subtract)
	end
	else begin
		cfg_mast_state	<= cfg_mast_state	;
		cfg_pdlf		<= cfg_pdlf			;
		cfg_pdrg		<= cfg_pdrg			;
		cfg_nor			<= cfg_nor			;
		cfg_atlchin		<= cfg_atlchin		;
		cfg_conv_switch <= cfg_conv_switch	;	
		cfg_stg0_nor_finum	<=	cfg_stg0_nor_finum	;
		cfg_stg0_pdb0_finum	<=	cfg_stg0_pdb0_finum	;
		cfg_stg0_pdb1_finum	<=	cfg_stg0_pdb1_finum	;
		cfg_stg1_eb_col		<=	cfg_stg1_eb_col		;
	end
end

//-----------------------------------------------------------------------------

//----    alignment signal assignment    -----
assign align_data_in	=	dr_data_dly0	;
assign align_din_index	=	dr_num_dly0		;
assign align_din_valid	=	valid_drdata_dly0		;
//-----------------------------------------------------------------------------



count_yi_v4 #(
    .BITS_OF_END_NUMBER (	3	)
)ins_name(
    .clk		( clk )
    ,	.reset 	 		(	wrcaf_reset	)
    ,	.enable	 		(	en_row_count	)

	,	.final_number	(	ROW_CNT_FINAL	)
	,	.last			(	row_last	)
    ,	.total_q		(	row_count	)
);

//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

	ifw_cnt_fsm	#(
		.CNT00_WIDTH	(	IFWSTG0_CNTBITS	)
		,	.CNT01_WIDTH		(	IFWSTG1_CNTBITS	)
		,	.WS_ADDR_WIDTH		(	IFMAP_SRAM_ADDBITS	)

	)	wr_buf_0 (
		.clk	(	clk		)
		,	.reset	(	wrcaf_reset	)

		,	.din_ifw_curr_state 	(	current_state	)	
		,	.din_cfg_mast_state 	(	cfg_mast_state	)	
		,	.din_row_last 			(	wrb0_row_last	)

		,	.dout_wr_curr_state 	(	wrb0_current_state	)	
		,	.dout_wr_cnt00 			(	wrb0_cnt00	)
		,	.dout_wr_cnt01 			(	wrb0_cnt01	)
		,	.dout_wr_srad_cnt		(	wrb0_sram_addrcnt	)
		,	.dout_wr_stg0_last		(	wrb0_stg0_last	)
		,	.dout_wr_stg1_last		(	wrb0_stg1_last	)
		,	.dout_wr_srad_last		(	wrb0_sram_addrcnt_last	)


		,	.wr_stg0_en 			(	wrb0_stg0_en	)	
		,	.wr_stg1_en 			(	wrb0_stg1_en	)	
		,	.wr_cnt00_finalnum 		(	wrb0_cnt00_finalnum	)

		,	.wr_cnt01_finalnum 		(	wrb0_cnt01_finalnum	)

		,	.wr_srad_finalnum		(	11'd1024	)

	);



//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------


ifw_cnt_fsm	#(
    .CNT00_WIDTH	(	IFWSTG0_CNTBITS	)
    ,	.CNT01_WIDTH		(	IFWSTG1_CNTBITS	)
    ,	.WS_ADDR_WIDTH		(	IFMAP_SRAM_ADDBITS	)

)	wr_buf_1 (
    .clk	(	clk		)
    ,	.reset	(	wrcaf_reset	)

	,	.din_ifw_curr_state 	(	current_state	)	
	,	.din_cfg_mast_state 	(	cfg_mast_state	)	
	,	.din_row_last 			(	wrb1_row_last	)

	,	.dout_wr_curr_state 	(	wrb1_current_state	)	
	,	.dout_wr_cnt00 			(	wrb1_cnt00	)
	,	.dout_wr_cnt01 			(	wrb1_cnt01	)
	,	.dout_wr_srad_cnt		(	wrb1_sram_addrcnt	)
	,	.dout_wr_stg0_last		(	wrb1_stg0_last	)
	,	.dout_wr_stg1_last		(	wrb1_stg1_last	)
	,	.dout_wr_srad_last		(	wrb1_sram_addrcnt_last	)

	,	.wr_stg0_en 			(	wrb1_stg0_en	)	
	,	.wr_stg1_en 			(	wrb1_stg1_en	)	

	,	.wr_cnt00_finalnum 		(	wrb1_cnt00_finalnum	)

	,	.wr_cnt01_finalnum 		(	wrb1_cnt01_finalnum	)

	,	.wr_srad_finalnum		(	11'd1024	)

);


ifw_cnt_fsm	#(
    .CNT00_WIDTH	(	IFWSTG0_CNTBITS	)
    ,	.CNT01_WIDTH		(	IFWSTG1_CNTBITS	)
    ,	.WS_ADDR_WIDTH		(	IFMAP_SRAM_ADDBITS	)

)	wr_buf_2 (
    .clk	(	clk		)
    ,	.reset	(	wrcaf_reset	)

	,	.din_ifw_curr_state 	(	current_state	)	
	,	.din_cfg_mast_state 	(	cfg_mast_state	)	
	,	.din_row_last 			(	wrb2_row_last	)

	,	.dout_wr_curr_state 	(	wrb2_current_state	)	
	,	.dout_wr_cnt00 			(	wrb2_cnt00	)
	,	.dout_wr_cnt01 			(	wrb2_cnt01	)
	,	.dout_wr_srad_cnt		(	wrb2_sram_addrcnt	)
	,	.dout_wr_stg0_last		(	wrb2_stg0_last	)
	,	.dout_wr_stg1_last		(	wrb2_stg1_last	)
	,	.dout_wr_srad_last		(	wrb2_sram_addrcnt_last	)

	,	.wr_stg0_en 			(	wrb2_stg0_en	)	
	,	.wr_stg1_en 			(	wrb2_stg1_en	)	

	,	.wr_cnt00_finalnum 		(	wrb2_cnt00_finalnum	)

	,	.wr_cnt01_finalnum 		(	wrb2_cnt01_finalnum	)

	,	.wr_srad_finalnum		(	11'd1024	)

);

ifw_cnt_fsm	#(
    .CNT00_WIDTH	(	IFWSTG0_CNTBITS	)
    ,	.CNT01_WIDTH		(	IFWSTG1_CNTBITS	)
    ,	.WS_ADDR_WIDTH		(	IFMAP_SRAM_ADDBITS	)

)	wr_buf_3 (
    .clk	(	clk		)
    ,	.reset	(	wrcaf_reset	)

	,	.din_ifw_curr_state 	(	current_state	)	
	,	.din_cfg_mast_state 	(	cfg_mast_state	)	
	,	.din_row_last 			(	wrb3_row_last	)

	,	.dout_wr_curr_state 	(	wrb3_current_state	)	
	,	.dout_wr_cnt00 			(	wrb3_cnt00	)
	,	.dout_wr_cnt01 			(	wrb3_cnt01	)
	,	.dout_wr_srad_cnt		(	wrb3_sram_addrcnt	)
	,	.dout_wr_stg0_last		(	wrb3_stg0_last	)
	,	.dout_wr_stg1_last		(	wrb3_stg1_last	)
	,	.dout_wr_srad_last		(	wrb3_sram_addrcnt_last	)

	,	.wr_stg0_en 			(	wrb3_stg0_en	)	
	,	.wr_stg1_en 			(	wrb3_stg1_en	)	

	,	.wr_cnt00_finalnum 		(	wrb3_cnt00_finalnum	)

	,	.wr_cnt01_finalnum 		(	wrb3_cnt01_finalnum	)

	,	.wr_srad_finalnum		(	11'd1024	)

);


ifw_cnt_fsm	#(
    .CNT00_WIDTH	(	IFWSTG0_CNTBITS	)
    ,	.CNT01_WIDTH		(	IFWSTG1_CNTBITS	)
    ,	.WS_ADDR_WIDTH		(	IFMAP_SRAM_ADDBITS	)

)	wr_buf_4 (
    .clk	(	clk		)
    ,	.reset	(	wrcaf_reset	)

	,	.din_ifw_curr_state 	(	current_state	)	
	,	.din_cfg_mast_state 	(	cfg_mast_state	)	
	,	.din_row_last 			(	wrb4_row_last	)

	,	.dout_wr_curr_state 	(	wrb4_current_state	)	
	,	.dout_wr_cnt00 			(	wrb4_cnt00	)
	,	.dout_wr_cnt01 			(	wrb4_cnt01	)
	,	.dout_wr_srad_cnt		(	wrb4_sram_addrcnt	)
	,	.dout_wr_stg0_last		(	wrb4_stg0_last	)
	,	.dout_wr_stg1_last		(	wrb4_stg1_last	)
	,	.dout_wr_srad_last		(	wrb4_sram_addrcnt_last	)

	,	.wr_stg0_en 			(	wrb4_stg0_en	)	
	,	.wr_stg1_en 			(	wrb4_stg1_en	)	

	,	.wr_cnt00_finalnum 		(	wrb4_cnt00_finalnum	)

	,	.wr_cnt01_finalnum 		(	wrb4_cnt01_finalnum	)

	,	.wr_srad_finalnum		(	11'd1024	)

);

ifw_cnt_fsm	#(
    .CNT00_WIDTH	(	IFWSTG0_CNTBITS	)
    ,	.CNT01_WIDTH		(	IFWSTG1_CNTBITS	)
    ,	.WS_ADDR_WIDTH		(	IFMAP_SRAM_ADDBITS	)

)	wr_buf_5 (
    .clk	(	clk		)
    ,	.reset	(	wrcaf_reset	)

	,	.din_ifw_curr_state 	(	current_state	)	
	,	.din_cfg_mast_state 	(	cfg_mast_state	)	
	,	.din_row_last 			(	wrb5_row_last	)

	,	.dout_wr_curr_state 	(	wrb5_current_state	)	
	,	.dout_wr_cnt00 			(	wrb5_cnt00	)
	,	.dout_wr_cnt01 			(	wrb5_cnt01	)
	,	.dout_wr_srad_cnt		(	wrb5_sram_addrcnt	)
	,	.dout_wr_stg0_last		(	wrb5_stg0_last	)
	,	.dout_wr_stg1_last		(	wrb5_stg1_last	)
	,	.dout_wr_srad_last		(	wrb5_sram_addrcnt_last	)

	,	.wr_stg0_en 			(	wrb5_stg0_en	)	
	,	.wr_stg1_en 			(	wrb5_stg1_en	)	
	,	.wr_cnt00_finalnum 		(	wrb5_cnt00_finalnum	)

	,	.wr_cnt01_finalnum 		(	wrb5_cnt01_finalnum	)

	,	.wr_srad_finalnum		(	11'd1024	)

);

ifw_cnt_fsm	#(
    .CNT00_WIDTH	(	IFWSTG0_CNTBITS	)
    ,	.CNT01_WIDTH		(	IFWSTG1_CNTBITS	)
    ,	.WS_ADDR_WIDTH		(	IFMAP_SRAM_ADDBITS	)

)	wr_buf_6 (
    .clk	(	clk		)
    ,	.reset	(	wrcaf_reset	)

	,	.din_ifw_curr_state 	(	current_state	)	
	,	.din_cfg_mast_state 	(	cfg_mast_state	)	
	,	.din_row_last 			(	wrb6_row_last	)

	,	.dout_wr_curr_state 	(	wrb6_current_state	)	
	,	.dout_wr_cnt00 			(	wrb6_cnt00	)
	,	.dout_wr_cnt01 			(	wrb6_cnt01	)
	,	.dout_wr_srad_cnt		(	wrb6_sram_addrcnt	)
	,	.dout_wr_stg0_last		(	wrb6_stg0_last	)
	,	.dout_wr_stg1_last		(	wrb6_stg1_last	)
	,	.dout_wr_srad_last		(	wrb6_sram_addrcnt_last	)

	,	.wr_stg0_en 			(	wrb6_stg0_en	)	
	,	.wr_stg1_en 			(	wrb6_stg1_en	)	

	,	.wr_cnt00_finalnum 		(	wrb6_cnt00_finalnum	)

	,	.wr_cnt01_finalnum 		(	wrb6_cnt01_finalnum	)

	,	.wr_srad_finalnum		(	11'd1024	)

);

ifw_cnt_fsm	#(
    .CNT00_WIDTH	(	IFWSTG0_CNTBITS	)
    ,	.CNT01_WIDTH		(	IFWSTG1_CNTBITS	)
    ,	.WS_ADDR_WIDTH		(	IFMAP_SRAM_ADDBITS	)

)	wr_buf_7 (
    .clk	(	clk		)
    ,	.reset	(	wrcaf_reset	)

	,	.din_ifw_curr_state 	(	current_state	)	
	,	.din_cfg_mast_state 	(	cfg_mast_state	)	
	,	.din_row_last 			(	wrb7_row_last	)

	,	.dout_wr_curr_state 	(	wrb7_current_state	)	
	,	.dout_wr_cnt00 			(	wrb7_cnt00	)
	,	.dout_wr_cnt01 			(	wrb7_cnt01	)
	,	.dout_wr_srad_cnt		(	wrb7_sram_addrcnt	)
	,	.dout_wr_stg0_last		(	wrb7_stg0_last	)
	,	.dout_wr_stg1_last		(	wrb7_stg1_last	)
	,	.dout_wr_srad_last		(	wrb7_sram_addrcnt_last	)

	,	.wr_stg0_en 			(	wrb7_stg0_en	)	
	,	.wr_stg1_en 			(	wrb7_stg1_en	)	

	,	.wr_cnt00_finalnum 		(	wrb7_cnt00_finalnum	)

	,	.wr_cnt01_finalnum 		(	wrb7_cnt01_finalnum	)

	,	.wr_srad_finalnum		(	11'd1024	)

);



// ============================================================================
// ===== SRAM output signal assignment ========================================
// ============================================================================
	assign	dout_wrb0_cen	=	(wrb0_stg0_en)	?	1'd0	: 1'd1	;
	assign	dout_wrb1_cen	=	(wrb1_stg0_en)	?	1'd0	: 1'd1	;
	assign	dout_wrb2_cen	=	(wrb2_stg0_en)	?	1'd0	: 1'd1	;
	assign	dout_wrb3_cen	=	(wrb3_stg0_en)	?	1'd0	: 1'd1	;
	assign	dout_wrb4_cen	=	(wrb4_stg0_en)	?	1'd0	: 1'd1	;
	assign	dout_wrb5_cen	=	(wrb5_stg0_en)	?	1'd0	: 1'd1	;
	assign	dout_wrb6_cen	=	(wrb6_stg0_en)	?	1'd0	: 1'd1	;
	assign	dout_wrb7_cen	=	(wrb7_stg0_en)	?	1'd0	: 1'd1	;

	assign	dout_wrb0_wen	=	dout_wrb0_cen	;
	assign	dout_wrb1_wen	=	dout_wrb1_cen	;
	assign	dout_wrb2_wen	=	dout_wrb2_cen	;
	assign	dout_wrb3_wen	=	dout_wrb3_cen	;
	assign	dout_wrb4_wen	=	dout_wrb4_cen	;
	assign	dout_wrb5_wen	=	dout_wrb5_cen	;
	assign	dout_wrb6_wen	=	dout_wrb6_cen	;
	assign	dout_wrb7_wen	=	dout_wrb7_cen	;


	assign	dout_wrb0_data	=	align_data_in	;
	assign	dout_wrb1_data	=	dr_data_dly1	;
	assign	dout_wrb2_data	=	dr_data_dly2	;
	assign	dout_wrb3_data	=	dr_data_dly3	;
	assign	dout_wrb4_data	=	dr_data_dly4	;
	assign	dout_wrb5_data	=	dr_data_dly5	;
	assign	dout_wrb6_data	=	dr_data_dly6	;
	assign	dout_wrb7_data	=	dr_data_dly7	;


	assign	dout_wrb0_addr	=	wrb0_sram_addrcnt	+	wrb0_pdaddr_shifter	;
	assign	dout_wrb1_addr	=	wrb1_sram_addrcnt	;
	assign	dout_wrb2_addr	=	wrb2_sram_addrcnt	;
	assign	dout_wrb3_addr	=	wrb3_sram_addrcnt	;
	assign	dout_wrb4_addr	=	wrb4_sram_addrcnt	;
	assign	dout_wrb5_addr	=	wrb5_sram_addrcnt	;
	assign	dout_wrb6_addr	=	wrb6_sram_addrcnt	;
	assign	dout_wrb7_addr	=	wrb7_sram_addrcnt	;

	
	assign	wrb0_pdaddr_shifter = ( cfg_mast_state == LEFT )? cfg_atlchin * ( row_count +1 ) : 'd0 	;


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------



//----    enable, start & final number    -----
assign wrb0_stg0_en = ((wr_cpr_0 == align_din_index) && align_din_valid )? 1'd1 : 1'd0 ;	
assign wrb0_stg1_en = ( wrb0_stg0_en && wrb0_stg0_last )? 1'd1 : 1'd0 ;	

assign wrb0_cnt00_finalnum = 	( wrb0_current_state == WR_NORMAL ) ? cfg_stg0_nor_finum :
									( wrb0_current_state == WR_LEFT ) ? cfg_stg0_pdb0_finum : cfg_stg0_nor_finum ;

assign wrb0_cnt01_finalnum =	cfg_stg1_eb_col	;


assign wrb1_stg0_en = ((wr_cpr_1 == dr_num_dly1) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;	
assign wrb1_stg1_en = ( wrb1_stg0_en && wrb1_stg0_last )? 1'd1 : 1'd0 ;	
assign wrb1_cnt00_finalnum = 	cfg_stg0_nor_finum	;

assign wrb1_cnt01_finalnum =	cfg_stg1_eb_col	;

assign wrb2_stg0_en = ((wr_cpr_2 == dr_num_dly2) && valid_drdata_dly2 )? 1'd1 : 1'd0 ;	
assign wrb2_stg1_en = ( wrb2_stg0_en && wrb2_stg0_last )? 1'd1 : 1'd0 ;	
assign wrb2_cnt00_finalnum = 	cfg_stg0_nor_finum	;
assign wrb2_cnt01_finalnum =	cfg_stg1_eb_col	;

assign wrb3_stg0_en = ((wr_cpr_3 == dr_num_dly3) && valid_drdata_dly3 )? 1'd1 : 1'd0 ;	
assign wrb3_stg1_en = ( wrb3_stg0_en && wrb3_stg0_last )? 1'd1 : 1'd0 ;	
assign wrb3_cnt00_finalnum = 	cfg_stg0_nor_finum	;
assign wrb3_cnt01_finalnum =	cfg_stg1_eb_col	;

assign wrb4_stg0_en = ((wr_cpr_4 == dr_num_dly4) && valid_drdata_dly4 )? 1'd1 : 1'd0 ;	
assign wrb4_stg1_en = ( wrb4_stg0_en && wrb4_stg0_last )? 1'd1 : 1'd0 ;	
assign wrb4_cnt00_finalnum = 	cfg_stg0_nor_finum	;
assign wrb4_cnt01_finalnum =	cfg_stg1_eb_col	;

assign wrb5_stg0_en = ((wr_cpr_5 == dr_num_dly5) && valid_drdata_dly5 )? 1'd1 : 1'd0 ;	
assign wrb5_stg1_en = ( wrb5_stg0_en && wrb5_stg0_last )? 1'd1 : 1'd0 ;	
assign wrb5_cnt00_finalnum = 	cfg_stg0_nor_finum	;
assign wrb5_cnt01_finalnum =	cfg_stg1_eb_col	;

assign wrb6_stg0_en = ((wr_cpr_6 == dr_num_dly6) && valid_drdata_dly6 )? 1'd1 : 1'd0 ;	
assign wrb6_stg1_en = ( wrb6_stg0_en && wrb6_stg0_last )? 1'd1 : 1'd0 ;	
assign wrb6_cnt00_finalnum = 	cfg_stg0_nor_finum	;
assign wrb6_cnt01_finalnum =	cfg_stg1_eb_col	;

assign wrb7_stg0_en = ((wr_cpr_7 == dr_num_dly7) && valid_drdata_dly7 )? 1'd1 : 1'd0 ;	
assign wrb7_stg1_en = ( wrb7_stg0_en && wrb7_stg0_last )? 1'd1 : 1'd0 ;	
assign wrb7_cnt00_finalnum = 	( wrb7_current_state == WR_RIGH ) ? 7 : 11;
assign wrb7_cnt01_finalnum =	cfg_stg1_eb_col	;


//-----------------------------------------------------------------------------




//----    align row_last signal for every wrb_module    -----
assign tst_row_fin_index = ( row_count == ROW_CNT_FINAL ) ? 1'd1 : 1'd0 ;

assign wrb0_row_last	=	tst_row_fin_index		;
assign wrb1_row_last	=	row_last_dly0	;
assign wrb2_row_last	=	row_last_dly1	;
assign wrb3_row_last	=	row_last_dly2	;
assign wrb4_row_last	=	row_last_dly3	;
assign wrb5_row_last	=	row_last_dly4	;
assign wrb6_row_last	=	row_last_dly5	;
assign wrb7_row_last 	=	row_last_dly6	;

always @(posedge clk ) begin
	row_last_dly0 <= tst_row_fin_index		;
	row_last_dly1 <= row_last_dly0	;
	row_last_dly2 <= row_last_dly1	;
	row_last_dly3 <= row_last_dly2	;
	row_last_dly4 <= row_last_dly3	;
	row_last_dly5 <= row_last_dly4	;
	row_last_dly6 <= row_last_dly5	;
	row_last_dly7 <= row_last_dly6	;
end

//-----------------------------------------------------------------------------
//----    without right padding. just buffer0,1 have different shifter   ------
//-----------------------------------------------------------------------------
//----    stride window shifter for every buffer    -----
assign strb0_shift = strwind_sht_0	;
assign strb1_shift = ( !(cfg_mast_state == LEFT) )?	strwind_sht_1 : strwind_sht_0	;
assign strb2_shift = ( !(cfg_mast_state == LEFT) )?	strwind_sht_2 : strwind_sht_1	;
assign strb3_shift = ( !(cfg_mast_state == LEFT) )?	strwind_sht_3 : strwind_sht_2	;
assign strb4_shift = ( !(cfg_mast_state == LEFT) )?	strwind_sht_4 : strwind_sht_3	;
assign strb5_shift = ( !(cfg_mast_state == LEFT) )?	strwind_sht_5 : strwind_sht_4	;
assign strb6_shift = ( !(cfg_mast_state == LEFT) )?	strwind_sht_6 : strwind_sht_5	;
assign strb7_shift = ( !(cfg_mast_state == LEFT) )?	strwind_sht_7 : strwind_sht_6	;

always @(posedge clk ) begin		// can replace by config
	if(reset)begin
		strwind_sht_0 <= 'd0 ;
		strwind_sht_1 <= 'd0 ;
		strwind_sht_2 <= 'd0 ;
		strwind_sht_3 <= 'd0 ;
		strwind_sht_4 <= 'd0 ;
		strwind_sht_5 <= 'd0 ;
		strwind_sht_6 <= 'd0 ;
		strwind_sht_7 <= 'd0 ;
	end
	else begin
		strwind_sht_0 <= 'd0 ;
		strwind_sht_1 <=  strwind_sht_0 + cfg_atlchin ;
		strwind_sht_2 <=  strwind_sht_1 + cfg_atlchin ;
		strwind_sht_3 <=  strwind_sht_2 + cfg_atlchin ;
		strwind_sht_4 <=  strwind_sht_3 + cfg_atlchin ;
		strwind_sht_5 <=  strwind_sht_4 + cfg_atlchin ;
		strwind_sht_6 <=  strwind_sht_5 + cfg_atlchin ;
		strwind_sht_7 <=  strwind_sht_6 + cfg_atlchin ;
	end
end
//-----------------------------------------------------------------------------


//----    Compare sum    -----
assign wr_cpr_0 = wrb0_cnt00 + pdb0_shift	+ strb0_shift + norb0_shifter	* wrb0_cnt01	;	//-- sub method 
assign wr_cpr_1 = wrb1_cnt00 + pdb1_shift	+ strb1_shift + norb1_shifter	* wrb1_cnt01	;	//-- sub method for buffer1 padding left

assign wr_cpr_2 = wrb2_cnt00				+ strb2_shift + gen_norshifter * wrb2_cnt01	;	//-- sub method for buffer2 padding left
assign wr_cpr_3 = wrb3_cnt00				+ strb3_shift + gen_norshifter * wrb3_cnt01	;	//-- sub method for buffer3 padding left
assign wr_cpr_4 = wrb4_cnt00				+ strb4_shift + gen_norshifter * wrb4_cnt01	;	//-- sub method for buffer4 padding left
assign wr_cpr_5 = wrb5_cnt00				+ strb5_shift + gen_norshifter * wrb5_cnt01	;	//-- sub method for buffer5 padding left
assign wr_cpr_6 = wrb6_cnt00				+ strb6_shift + gen_norshifter * wrb6_cnt01	;	//-- sub method for buffer6 padding left
assign wr_cpr_7 = wrb7_cnt00				+ strb7_shift + gen_norshifter * wrb7_cnt01	;	//-- sub method for buffer7 padding left

//-----------------------------------------------------------------------------

assign pdb0_shift 	= 	( wrb0_cnt01 < 1	)? 6'd0 :
								( !(cfg_mast_state == LEFT) )?	gen_norshifter : gen_pdshifter_0	;
assign pdb1_shift 	= 	( wrb1_cnt01 < 1	)? 6'd0 :
							( !(cfg_mast_state == LEFT) )?	gen_norshifter : gen_pdshifter_1	;
assign norb0_shifter 	= ( wrb0_cnt01 > 1	)? 	gen_norshifter	: 6'd0 ;
assign norb1_shifter 	= ( wrb1_cnt01 > 1	)? 	gen_norshifter	: 6'd0 ;


//-----------------------------------------------------------------------------

//----    padding parameter generater using config register    -----
always @(posedge clk ) begin	// can replace by config
	if(reset)begin
		gen_pdshifter_0 <= 6'd0 ;
		gen_pdshifter_1 <= 6'd0 ;
		gen_norshifter 	<= 6'd0 ;
	end
	else begin
		gen_pdshifter_0 <= cfg_atlchin*b0_padding_parm ;
		gen_pdshifter_1 <= cfg_atlchin*b1_padding_parm ;	// pad=2 will use. config actually channel* (8-1) buffers = 4*7 =28
		gen_norshifter 	<= cfg_atlchin*8	; // config actually channel * 8 buffers
	end
end

assign b0_padding_parm = 	( !(cfg_mast_state == LEFT) )? 5'd8 :				// other padding side use 5'd8
								( cfg_conv_switch == 3'd2 )? 5'd7 :				// left padding 3x3 use 5'd7
									(cfg_conv_switch == 3'd3 )? 5'd6 : 5'd0 ;	// left padding 5x5 use 5'd6
assign b1_padding_parm =	 ( !(cfg_mast_state == LEFT) )? 5'd8 :
									(cfg_conv_switch == 3'd3 )? 5'd7 : 5'd8 ;
//-----------------------------------------------------------------------------


// ============================================================================
// ===== busy & done
// ============================================================================

always @(posedge clk ) begin
	if(reset) begin
		current_state <= 2'd0;
	end
	else begin
		current_state <= next_state;
	end
end
always @(*) begin
	case (current_state)
		2'd0: next_state = (start_if_store) ? 2'd1 : 2'd0 ;
		2'd1: next_state = (wrb_end_check) ? 2'd2 : 2'd1 ;
		2'd2: next_state = 2'd3 ;	// for reset all counter
		2'd3: next_state = 2'd0 ;
		default: next_state = 2'd0 ;
	endcase	
end


always @( * ) begin
	if_store_busy =	( (current_state == 2'd1)	||	(current_state == 2'd2) ||(current_state == 2'd3)	) ? 1'd1 : 1'd0 ;
	if_store_done =	(current_state == 2'd3) ? 1'd1 : 1'd0  ;		// need fix 
end



assign 	wrb_end_check 	= ( wrb7_current_state == WR_DONE ) ? 1'd1 : 1'd0 ;	// check the latest wr_buf module on DONE state= 3'd4 
assign 	wrb_rst 		= ( current_state == 2'd2 ) ? 1'd1 : 1'd0 ;	// reset all wr_buf's counter and wr_fsm


// ============================================================================
// ===== generate valid in 
// ============================================================================


always @(posedge clk ) begin
	if(reset)begin
		ifstore_read_dout <= 1'd0;
	end		
	else begin
		if( if_store_busy ) begin
			if( ifstore_empty_n_din == 1'd1 )begin
				ifstore_read_dout <= 1'd1;
			end
			else begin
				ifstore_read_dout <= 1'd0;
			end
		end
		else begin
			ifstore_read_dout <= 1'd0;
		end
	end	
end



always@(*)begin
	valid_drdata = ifstore_read_dout & ifstore_empty_n_din;
end


always@( posedge clk )begin
	valid_drdata_dly0 <= valid_drdata;
	valid_drdata_dly1 <= valid_drdata_dly0;
	valid_drdata_dly2 <= valid_drdata_dly1;
	valid_drdata_dly3 <= valid_drdata_dly2;
	valid_drdata_dly4 <= valid_drdata_dly3;
	valid_drdata_dly5 <= valid_drdata_dly4;
	valid_drdata_dly6 <= valid_drdata_dly5;
	valid_drdata_dly7 <= valid_drdata_dly6;
	valid_drdata_dly8 <= valid_drdata_dly7;
	valid_drdata_dly9 <= valid_drdata_dly8;
end

always@(posedge clk )begin
	dr_num_dly0 <= cnt00;
	dr_num_dly1	<= dr_num_dly0	;
	dr_num_dly2	<= dr_num_dly1	;
	dr_num_dly3	<= dr_num_dly2	;
	dr_num_dly4	<= dr_num_dly3	;
	dr_num_dly5	<= dr_num_dly4	;
	dr_num_dly6	<= dr_num_dly5	;
	dr_num_dly7	<= dr_num_dly6	;


	dr_data_dly0 <= ifstore_data_din;
	dr_data_dly1	<= dr_data_dly0		;
	dr_data_dly2	<= dr_data_dly1		;
	dr_data_dly3	<= dr_data_dly2		;
	dr_data_dly4	<= dr_data_dly3		;
	dr_data_dly5	<= dr_data_dly4		;
	dr_data_dly6	<= dr_data_dly5		;
	dr_data_dly7	<= dr_data_dly6		;

end

always @(posedge clk ) begin
	if( reset )begin
		cnt00 <= 0;
	end
	else begin
		if ( valid_drdata )begin
			if( cnt00 >= FINAL_DIN_NUM-1 ) cnt00 <= 'd0;
			else cnt00 <= cnt00 +1 ;
		end
		else begin
			cnt00 <= cnt00 ;
		end
	end
end


assign en_row_count = ( (  align_din_index >= FINAL_DIN_NUM-1 )   ) ? 1'd1 : 1'd0 ;

// ============================================================================





endmodule