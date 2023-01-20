
`define IF_SR	;
`include "./count_yi_v3.v"


module stdata 
#(
	parameter TBITS = 64 ,
	parameter TBYTE = 8
)(
	clk		,
	reset	,
	fifo_data_din	,
	fifo_strb_din	,
	fifo_last_din	,
	fifo_user_din	,
	fifo_empty_n_din	,
	fifo_read_dout	,	

	tst_rdsram	,

	tst_en_sram_ifm0	,
	tst_en_sram_ifm1	,
	tst_en_sram_ifm2	,
	tst_en_sram_ifm3	,
	tst_en_sram_ifm4	,
	tst_en_sram_ifm5	,
	tst_en_sram_ifm6	,
	tst_en_sram_ifm7	,

	tst_wea_sram_ifm0	,
	tst_wea_sram_ifm1	,
	tst_wea_sram_ifm2	,
	tst_wea_sram_ifm3	,
	tst_wea_sram_ifm4	,
	tst_wea_sram_ifm5	,
	tst_wea_sram_ifm6	,
	tst_wea_sram_ifm7	,

	tst_addr_sram_ifm0	,
	tst_addr_sram_ifm1	,
	tst_addr_sram_ifm2	,
	tst_addr_sram_ifm3	,
	tst_addr_sram_ifm4	,
	tst_addr_sram_ifm5	,
	tst_addr_sram_ifm6	,
	tst_addr_sram_ifm7	,

	tst_dout_sram_ifm0	,
	tst_dout_sram_ifm1	,
	tst_dout_sram_ifm2	,
	tst_dout_sram_ifm3	,
	tst_dout_sram_ifm4	,
	tst_dout_sram_ifm5	,
	tst_dout_sram_ifm6	,
	tst_dout_sram_ifm7	

);


input	wire 				clk		;
input	wire 				reset	;
input	wire [TBITS-1: 0 ]	fifo_data_din		;
input	wire [TBYTE-1: 0 ]	fifo_strb_din		;	// no use
input	wire 				fifo_last_din		;	// no use
input	wire 				fifo_user_din		;	// no use
input	wire 				fifo_empty_n_din	;
output	reg 				fifo_read_dout		;

localparam IFMAP_SRAM_ADDBITS = 11       ;
localparam IFMAP_SRAM_DATA_WIDTH = 64    ;

input wire tst_rdsram;

input wire tst_en_sram_ifm0 ;
input wire tst_en_sram_ifm1 ;
input wire tst_en_sram_ifm2 ;
input wire tst_en_sram_ifm3 ;
input wire tst_en_sram_ifm4 ;
input wire tst_en_sram_ifm5 ;
input wire tst_en_sram_ifm6 ;
input wire tst_en_sram_ifm7 ;

input wire tst_wea_sram_ifm0 ;
input wire tst_wea_sram_ifm1 ;
input wire tst_wea_sram_ifm2 ;
input wire tst_wea_sram_ifm3 ;
input wire tst_wea_sram_ifm4 ;
input wire tst_wea_sram_ifm5 ;
input wire tst_wea_sram_ifm6 ;
input wire tst_wea_sram_ifm7 ;

input wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   tst_addr_sram_ifm0  ;
input wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   tst_addr_sram_ifm1  ;
input wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   tst_addr_sram_ifm2  ;
input wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   tst_addr_sram_ifm3  ;
input wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   tst_addr_sram_ifm4  ;
input wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   tst_addr_sram_ifm5  ;
input wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   tst_addr_sram_ifm6  ;
input wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   tst_addr_sram_ifm7  ;

output wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   tst_dout_sram_ifm0	;
output wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   tst_dout_sram_ifm1	;
output wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   tst_dout_sram_ifm2	;
output wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   tst_dout_sram_ifm3	;
output wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   tst_dout_sram_ifm4	;
output wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   tst_dout_sram_ifm5	;
output wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   tst_dout_sram_ifm6	;
output wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   tst_dout_sram_ifm7	;



// //---- BRAM_IFMAP --------
wire en_sram_ifm0 ;
wire en_sram_ifm1 ;
wire en_sram_ifm2 ;
wire en_sram_ifm3 ;
wire en_sram_ifm4 ;
wire en_sram_ifm5 ;
wire en_sram_ifm6 ;
wire en_sram_ifm7 ;

wire wea_sram_ifm0 ;
wire wea_sram_ifm1 ;
wire wea_sram_ifm2 ;
wire wea_sram_ifm3 ;
wire wea_sram_ifm4 ;
wire wea_sram_ifm5 ;
wire wea_sram_ifm6 ;
wire wea_sram_ifm7 ;

wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm0  ;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm1  ;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm2  ;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm3  ;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm4  ;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm5  ;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm6  ;
wire [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm7  ;

wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm0		;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm1		;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm2		;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm3		;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm4		;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm5		;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm6		;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm7		;

wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm0	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm1	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm2	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm3	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm4	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm5	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm6	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm7	;




`include"bram_svss.v"

//-------  input data stream ------
reg [11:0]			dr_num_dly0	;
reg [11:0]			dr_num_dly1	;
reg [11:0]			dr_num_dly2	;
reg [11:0]			dr_num_dly3	;
reg [11:0]			dr_num_dly4	;
reg [11:0]			dr_num_dly5	;
reg [11:0]			dr_num_dly6	;
reg [11:0]			dr_num_dly7	;

reg [TBITS-1:0] 	dr_data	;
reg [TBITS-1:0] 	dr_data_dly1	;
reg [TBITS-1:0] 	dr_data_dly2	;
reg [TBITS-1:0] 	dr_data_dly3	;
reg [TBITS-1:0] 	dr_data_dly4	;
reg [TBITS-1:0] 	dr_data_dly5	;
reg [TBITS-1:0] 	dr_data_dly6	;
reg [TBITS-1:0] 	dr_data_dly7	;





//-------------------------------------------
// one row address 0 to 263 means col0 ~ col65
localparam STSRAM_CNT_BITS = 6	;

//---------------------------------------------------------------------
//----declare if store cnt start------ 
//----sramcnt_0---------
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct00	;	//first stage cnt
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct01	;	//second stage cnt
wire cten_stsr_ct01 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_0		;	// check the data we want
wire en_stsr_addrct_0 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_0 ;
//-----------....
//----sramcnt_1---------
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct10	;	//first stage cnt
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct11	;	//second stage cnt
wire cten_stsr_ct11 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_1		;	// check the data we want
wire en_stsr_addrct_1 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_1 ;
//-----------....
//----sramcnt_2---------
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct20	;	//first stage cnt
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct21	;	//second stage cnt
wire cten_stsr_ct21 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_2		;	// check the data we want
wire en_stsr_addrct_2 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_2 ;
//-----------....
//----sramcnt_3---------
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct30	;	//first stage cnt
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct31	;	//second stage cnt
wire cten_stsr_ct31 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_3		;	// check the data we want
wire en_stsr_addrct_3 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_3 ;
//-----------....
//----sramcnt_4---------
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct40	;	//first stage cnt
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct41	;	//second stage cnt
wire cten_stsr_ct41 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_4		;	// check the data we want
wire en_stsr_addrct_4 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_4 ;
//-----------....
//----sramcnt_5---------
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct50	;	//first stage cnt
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct51	;	//second stage cnt
wire cten_stsr_ct51 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_5		;	// check the data we want
wire en_stsr_addrct_5 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_5 ;
//-----------....
//----sramcnt_6---------
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct60	;	//first stage cnt
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct61	;	//second stage cnt
wire cten_stsr_ct61 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_6		;	// check the data we want
wire en_stsr_addrct_6 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_6 ;
//-----------....
//----sramcnt_7---------
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct70	;	//first stage cnt
wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct71	;	//second stage cnt
wire cten_stsr_ct71 ;		//second stage enable
wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_7		;	// check the data we want
wire en_stsr_addrct_7 ;	
wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_7 ;
//-----------....
//----declare if store cnt end------ 

//---------------------------------------------------------------------

//--------------------IF SRAM signal -------------------------------


assign en_sram_ifm0 = (tst_rdsram)? 	tst_en_sram_ifm0	:	en_stsr_addrct_0		;
assign en_sram_ifm1 = (tst_rdsram)? 	tst_en_sram_ifm1	:	en_stsr_addrct_1		;
assign en_sram_ifm2 = (tst_rdsram)? 	tst_en_sram_ifm2	:	en_stsr_addrct_2		;
assign en_sram_ifm3 = (tst_rdsram)? 	tst_en_sram_ifm3	:	en_stsr_addrct_3		;
assign en_sram_ifm4 = (tst_rdsram)? 	tst_en_sram_ifm4	:	en_stsr_addrct_4		;
assign en_sram_ifm5 = (tst_rdsram)? 	tst_en_sram_ifm5	:	en_stsr_addrct_5		;
assign en_sram_ifm6 = (tst_rdsram)? 	tst_en_sram_ifm6	:	en_stsr_addrct_6		;
assign en_sram_ifm7 = (tst_rdsram)? 	tst_en_sram_ifm7	:	en_stsr_addrct_7		;

assign wea_sram_ifm0 = (tst_rdsram)? 	tst_wea_sram_ifm0	:	en_stsr_addrct_0		;
assign wea_sram_ifm1 = (tst_rdsram)? 	tst_wea_sram_ifm1	:	en_stsr_addrct_1		;
assign wea_sram_ifm2 = (tst_rdsram)? 	tst_wea_sram_ifm2	:	en_stsr_addrct_2		;
assign wea_sram_ifm3 = (tst_rdsram)? 	tst_wea_sram_ifm3	:	en_stsr_addrct_3		;
assign wea_sram_ifm4 = (tst_rdsram)? 	tst_wea_sram_ifm4	:	en_stsr_addrct_4		;
assign wea_sram_ifm5 = (tst_rdsram)? 	tst_wea_sram_ifm5	:	en_stsr_addrct_5		;
assign wea_sram_ifm6 = (tst_rdsram)? 	tst_wea_sram_ifm6	:	en_stsr_addrct_6		;
assign wea_sram_ifm7 = (tst_rdsram)? 	tst_wea_sram_ifm7	:	en_stsr_addrct_7		;

assign addr_sram_ifm0 = (tst_rdsram)? 	tst_addr_sram_ifm0	:	stsr_addrct_0		;
assign addr_sram_ifm1 = (tst_rdsram)? 	tst_addr_sram_ifm1	:	stsr_addrct_1		;
assign addr_sram_ifm2 = (tst_rdsram)? 	tst_addr_sram_ifm2	:	stsr_addrct_2		;
assign addr_sram_ifm3 = (tst_rdsram)? 	tst_addr_sram_ifm3	:	stsr_addrct_3		;
assign addr_sram_ifm4 = (tst_rdsram)? 	tst_addr_sram_ifm4	:	stsr_addrct_4		;
assign addr_sram_ifm5 = (tst_rdsram)? 	tst_addr_sram_ifm5	:	stsr_addrct_5		;
assign addr_sram_ifm6 = (tst_rdsram)? 	tst_addr_sram_ifm6	:	stsr_addrct_6		;
assign addr_sram_ifm7 = (tst_rdsram)? 	tst_addr_sram_ifm7	:	stsr_addrct_7		;

assign din_sram_ifm0 = dr_data		;
assign din_sram_ifm1 = dr_data_dly1	;
assign din_sram_ifm2 = dr_data_dly2	;
assign din_sram_ifm3 = dr_data_dly3	;
assign din_sram_ifm4 = dr_data_dly4	;
assign din_sram_ifm5 = dr_data_dly5	;
assign din_sram_ifm6 = dr_data_dly6	;
assign din_sram_ifm7 = dr_data_dly7	;

assign 	tst_dout_sram_ifm0	=	dout_sram_ifm0	;
assign 	tst_dout_sram_ifm1	=	dout_sram_ifm1	;
assign 	tst_dout_sram_ifm2	=	dout_sram_ifm2	;
assign 	tst_dout_sram_ifm3	=	dout_sram_ifm3	;
assign 	tst_dout_sram_ifm4	=	dout_sram_ifm4	;
assign 	tst_dout_sram_ifm5	=	dout_sram_ifm5	;
assign 	tst_dout_sram_ifm6	=	dout_sram_ifm6	;
assign 	tst_dout_sram_ifm7	=	dout_sram_ifm7	;


//---------------------------------------------------------------------------------------
// assign en_sram_ifm0 = en_stsr_addrct_0	;
// assign en_sram_ifm1 = en_stsr_addrct_1	;
// assign en_sram_ifm2 = en_stsr_addrct_2	;
// assign en_sram_ifm3 = en_stsr_addrct_3	;
// assign en_sram_ifm4 = en_stsr_addrct_4	;
// assign en_sram_ifm5 = en_stsr_addrct_5	;
// assign en_sram_ifm6 = en_stsr_addrct_6	;
// assign en_sram_ifm7 = en_stsr_addrct_7	;

// assign wea_sram_ifm0 = en_stsr_addrct_0	;
// assign wea_sram_ifm1 = en_stsr_addrct_1	;
// assign wea_sram_ifm2 = en_stsr_addrct_2	;
// assign wea_sram_ifm3 = en_stsr_addrct_3	;
// assign wea_sram_ifm4 = en_stsr_addrct_4	;
// assign wea_sram_ifm5 = en_stsr_addrct_5	;
// assign wea_sram_ifm6 = en_stsr_addrct_6	;
// assign wea_sram_ifm7 = en_stsr_addrct_7	;


// assign addr_sram_ifm0 = stsr_addrct_0	;
// assign addr_sram_ifm1 = stsr_addrct_1	;
// assign addr_sram_ifm2 = stsr_addrct_2	;
// assign addr_sram_ifm3 = stsr_addrct_3	;
// assign addr_sram_ifm4 = stsr_addrct_4	;
// assign addr_sram_ifm5 = stsr_addrct_5	;
// assign addr_sram_ifm6 = stsr_addrct_6	;
// assign addr_sram_ifm7 = stsr_addrct_7	;

// assign din_sram_ifm0 = dr_data		;
// assign din_sram_ifm1 = dr_data_dly1		;
// assign din_sram_ifm2 = dr_data_dly2		;
// assign din_sram_ifm3 = dr_data_dly3		;
// assign din_sram_ifm4 = dr_data_dly4		;
// assign din_sram_ifm5 = dr_data_dly5		;
// assign din_sram_ifm6 = dr_data_dly6		;
// assign din_sram_ifm7 = dr_data_dly7		;


//--------------------IF SRAM signal -------------------------------


//----- dram data counter -----
// fifo_empty_n_din	
// fifo_read_dout		

always@(posedge clk )begin
	fifo_read_dout <= fifo_empty_n_din;
end

reg valid_drdata ;
reg valid_drdata_dly1 ;
reg valid_drdata_dly2 ;
reg valid_drdata_dly3 ;
reg valid_drdata_dly4 ;
reg valid_drdata_dly5 ;
reg valid_drdata_dly6 ;
reg valid_drdata_dly7 ;
reg valid_drdata_dly8 ;
reg valid_drdata_dly9 ;


always@(*)begin
	valid_drdata = fifo_read_dout & fifo_empty_n_din;
end


always@( posedge clk )begin
	valid_drdata_dly1 <= valid_drdata;
	valid_drdata_dly2 <= valid_drdata_dly1;
	valid_drdata_dly3 <= valid_drdata_dly2;
	valid_drdata_dly4 <= valid_drdata_dly3;
	valid_drdata_dly5 <= valid_drdata_dly4;
	valid_drdata_dly6 <= valid_drdata_dly5;
	valid_drdata_dly7 <= valid_drdata_dly6;
	valid_drdata_dly8 <= valid_drdata_dly7;
	valid_drdata_dly9 <= valid_drdata_dly8;

end


reg [11 : 0 ] cnt00 ;

always @(posedge clk ) begin
	if( reset )begin
		cnt00 <= 0;
	end
	else begin
		if ( valid_drdata )begin
			if( cnt00 >= 'd263) cnt00 <= 'd0;
			else cnt00 <= cnt00 +1 ;
		end
		else begin
			cnt00 <= cnt00 ;
		end
	end
end


//-------  input data stream ------
// shift data and input address for every sram 
//---------------------------------
always@( posedge clk )begin
	if( reset )begin
		dr_num_dly0 <= 0;
		dr_data <= 0;
	end
	else begin
		if (valid_drdata )begin
			dr_num_dly0 <= cnt00;
			dr_data <= fifo_data_din;
		end
		else begin
			dr_num_dly0 <= dr_num_dly0;
			dr_data <= dr_data;
		end
	end
	
end


always@(posedge clk )begin
	dr_num_dly1	<= dr_num_dly0	;
	dr_num_dly2	<= dr_num_dly1	;
	dr_num_dly3	<= dr_num_dly2	;
	dr_num_dly4	<= dr_num_dly3	;
	dr_num_dly5	<= dr_num_dly4	;
	dr_num_dly6	<= dr_num_dly5	;
	dr_num_dly7	<= dr_num_dly6	;

	dr_data_dly1	<= dr_data		;
	dr_data_dly2	<= dr_data_dly1		;
	dr_data_dly3	<= dr_data_dly2		;
	dr_data_dly4	<= dr_data_dly3		;
	dr_data_dly5	<= dr_data_dly4		;
	dr_data_dly6	<= dr_data_dly5		;
	dr_data_dly7	<= dr_data_dly6		;

end



//----instance if store cnt start------ 
//----sramcnt_0---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_00(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_0 ), .cnt_q ( stsr_ct00 ),	
    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_01(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct01 ), .cnt_q ( stsr_ct01 ),	//
    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_0(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_0 ), .cnt_q ( stsr_addrct_0 ),	//
    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero
);
assign en_stsr_addrct_0 = (  (stsr_cp_0 == dr_num_dly0) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want
assign cten_stsr_ct01 = (	stsr_ct00	==	6'd11	)? 1'd1 : 1'd0 ;
assign stsr_cp_0 = 'd0 + stsr_ct00 + 32*stsr_ct01 ;		// generate cp number
//----sramcnt_1---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_10(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_1 ), .cnt_q ( stsr_ct10 ),	
    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_11(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct11 ), .cnt_q ( stsr_ct11 ),	//
    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_1(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_1 ), .cnt_q ( stsr_addrct_1 ),	//
    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero
);
assign en_stsr_addrct_1 = (  (stsr_cp_1 == dr_num_dly1) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want
assign cten_stsr_ct11 = (	stsr_ct10	==	6'd11	)? 1'd1 : 1'd0 ;
assign stsr_cp_1 = 'd4 + stsr_ct10 + 32*stsr_ct11 ;		// generate cp number
//----sramcnt_2---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_20(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_2 ), .cnt_q ( stsr_ct20 ),	
    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_21(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct21 ), .cnt_q ( stsr_ct21 ),	//
    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_2(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_2 ), .cnt_q ( stsr_addrct_2 ),	//
    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero
);
assign en_stsr_addrct_2 = (  (stsr_cp_2 == dr_num_dly2) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want
assign cten_stsr_ct21 = (	stsr_ct20	==	6'd11	)? 1'd1 : 1'd0 ;
assign stsr_cp_2 = 'd8 + stsr_ct20 + 32*stsr_ct21 ;		// generate cp number
//----sramcnt_3---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_30(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_3 ), .cnt_q ( stsr_ct30 ),	
    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_31(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct31 ), .cnt_q ( stsr_ct31 ),	//
    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_3(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_3 ), .cnt_q ( stsr_addrct_3 ),	//
    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero
);
assign en_stsr_addrct_3 = (  (stsr_cp_3 == dr_num_dly3) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want
assign cten_stsr_ct31 = (	stsr_ct30	==	6'd11	)? 1'd1 : 1'd0 ;
assign stsr_cp_3 = 'd12 + stsr_ct30 + 32*stsr_ct31 ;		// generate cp number
//----sramcnt_4---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_40(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_4 ), .cnt_q ( stsr_ct40 ),	
    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_41(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct41 ), .cnt_q ( stsr_ct41 ),	//
    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_4(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_4 ), .cnt_q ( stsr_addrct_4 ),	//
    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero
);
assign en_stsr_addrct_4 = (  (stsr_cp_4 == dr_num_dly4) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want
assign cten_stsr_ct41 = (	stsr_ct40	==	6'd11	)? 1'd1 : 1'd0 ;
assign stsr_cp_4 = 'd16 + stsr_ct40 + 32*stsr_ct41 ;		// generate cp number
//----sramcnt_5---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_50(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_5 ), .cnt_q ( stsr_ct50 ),	
    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_51(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct51 ), .cnt_q ( stsr_ct51 ),	//
    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_5(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_5 ), .cnt_q ( stsr_addrct_5 ),	//
    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero
);
assign en_stsr_addrct_5 = (  (stsr_cp_5 == dr_num_dly5) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want
assign cten_stsr_ct51 = (	stsr_ct50	==	6'd11	)? 1'd1 : 1'd0 ;
assign stsr_cp_5 = 'd20 + stsr_ct50 + 32*stsr_ct51 ;		// generate cp number
//----sramcnt_6---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_60(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_6 ), .cnt_q ( stsr_ct60 ),	
    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_61(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct61 ), .cnt_q ( stsr_ct61 ),	//
    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_6(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_6 ), .cnt_q ( stsr_addrct_6 ),	//
    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero
);
assign en_stsr_addrct_6 = (  (stsr_cp_6 == dr_num_dly6) && valid_drdata_dly7 )? 1'd1 : 1'd0 ;		// check data we want
assign cten_stsr_ct61 = (	stsr_ct60	==	6'd11	)? 1'd1 : 1'd0 ;
assign stsr_cp_6 = 'd24 + stsr_ct60 + 32*stsr_ct61 ;		// generate cp number
//----sramcnt_7---------
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_70(.clk ( clk ), .reset ( reset ), .enable ( en_stsr_addrct_7 ), .cnt_q ( stsr_ct70 ),	
    .final_number(	'd12	)	// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
    )cnt_71(.clk ( clk ),.reset ( reset ), .enable ( cten_stsr_ct71 ), .cnt_q ( stsr_ct71 ),	//
    .final_number(	'd8	)		// it will count to final_num-1 then goes to zero
);
count_yi_v3 #(    .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
    )cnt_sraddr_7(.clk ( clk ),.reset ( reset ), .enable ( en_stsr_addrct_7 ), .cnt_q ( stsr_addrct_7 ),	//
    .final_number(	'd300	)		// it will count to final_num-1 then goes to zero
);
assign en_stsr_addrct_7 = (  (stsr_cp_7 == dr_num_dly7) && valid_drdata_dly8 )? 1'd1 : 1'd0 ;		// check data we want
assign cten_stsr_ct71 = (	stsr_ct70	==	6'd11	)? 1'd1 : 1'd0 ;
assign stsr_cp_7 = 'd28 + stsr_ct70 + 32*stsr_ct71 ;		// generate cp number
//----instance if store cnt end------ 




// //-------------------------------------------
// // one row address 0 to 263 means col0 ~ col65

// wire [6-1:0]  ct11 ;
// wire [ 6-1 :0]	ct22	;
// wire cten_ct22 ;
// wire [ 11:0 ]sr00 ;

// wire ensrst_0 ;
// wire [ 10 - 1 :0 ] sraddrst_0 ;


// count_yi_v3 #(
//     .BITS_OF_END_NUMBER( 6  ) 
// )cnt_11(
//     .clk ( clk ),
//     .reset ( reset ), 
//     .enable ( ensrst_0 ), 	
// 	.final_number(	'd12	),			
//     .cnt_q ( ct11 )			
// );
// count_yi_v3 #(
//     .BITS_OF_END_NUMBER( 6  ) 
// )cnt_22(
//     .clk ( clk ),
//     .reset ( reset ), 
//     .enable ( cten_ct22 ), 	
// 	.final_number(	'd24	),		// it will count to final_num-1 then goes to zero
//     .cnt_q ( ct22 )			//
// );


// assign cten_ct22 = (ct11==6'd11)? 1'd1 : 1'd0 ;
// assign sr00 = 0 + ct11 + 32*ct22 ;
// assign ensrst_0 = (  (sr00 == dr_num) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;


// count_yi_v3 #(
//     .BITS_OF_END_NUMBER( 10  ) 
// )cnt_sraddr_0(
//     .clk ( clk ),
//     .reset ( reset ), 
//     .enable ( ensrst_0 ), 	//temp
// 	.final_number(	'd300	),			//temp
//     .cnt_q ( sraddrst_0 )			// ch 0~7 choose
// );



// //-------------------------------------------
// // one row address 0 to 263 means col0 ~ col65
// localparam STSRAM_CNT_BITS = 6	;


// wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct00	;
// wire [ STSRAM_CNT_BITS-1 :0]	stsr_ct01	;
// wire cten_stsr_ct01 ;

// wire [ IFMAP_SRAM_ADDBITS -1 : 0 ]	stsr_cp_0		;	// to sram

// wire en_stsr_addrct_0 ;
// wire [ IFMAP_SRAM_ADDBITS - 1 :0 ] stsr_addrct_0 ;

// //---------------the counter that compares with input data number ---------------
// count_yi_v3 #(
//     .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
// )cnt_11(
//     .clk ( clk ),
//     .reset ( reset ), 
//     .enable ( en_stsr_addrct_0 ), 	
// 	.final_number(	'd12	),			
//     .cnt_q ( stsr_ct00 )			
// );
// count_yi_v3 #(
//     .BITS_OF_END_NUMBER( STSRAM_CNT_BITS  ) 
// )cnt_22(
//     .clk ( clk ),
//     .reset ( reset ), 
//     .enable ( cten_stsr_ct01 ), 	
// 	.final_number(	'd24	),		// it will count to final_num-1 then goes to zero
//     .cnt_q ( stsr_ct01 )			//
// );

// assign en_stsr_addrct_0 = (  (stsr_cp_0 == dr_num) && valid_drdata_dly1 )? 1'd1 : 1'd0 ;		// check data we want

// assign cten_stsr_ct01 = (	stsr_ct00	==	6'd11	)? 1'd1 : 1'd0 ;
// assign stsr_cp_0 = 0 + stsr_ct00 + 32*stsr_ct01 ;		// generate cp number 



// //--------- sram address counter ---------------
// count_yi_v3 #(
//     .BITS_OF_END_NUMBER( IFMAP_SRAM_ADDBITS  ) 
// )cnt_sraddr_0(
//     .clk ( clk ),
//     .reset ( reset ), 
//     .enable ( en_stsr_addrct_0 ), 	//temp
// 	.final_number(	'd300	),			//temp
//     .cnt_q ( stsr_addrct_0 )			// ch 0~7 choose
// );


endmodule

