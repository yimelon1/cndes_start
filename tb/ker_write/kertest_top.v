

module ker_tset (
	clk,
	reset,

	ker_store_data_din		,
	ker_store_empty_n_din	,
	ker_store_read_dout		,

	ker_store_done 		,
	ker_store_busy 		,
	start_ker_store		,

	tst_sram_rw		,
	
//----test KER SRAM_0---------
    tst_cen_kersr_0 ,
    tst_wen_kersr_0 ,
    tst_addr__kersr_0 ,
    dout_kersr_0 ,
//----test KER SRAM_1---------
    tst_cen_kersr_1 ,
    tst_wen_kersr_1 ,
    tst_addr__kersr_1 ,
    dout_kersr_1 ,
//----test KER SRAM_2---------
    tst_cen_kersr_2 ,
    tst_wen_kersr_2 ,
    tst_addr__kersr_2 ,
    dout_kersr_2 ,
//----test KER SRAM_3---------
    tst_cen_kersr_3 ,
    tst_wen_kersr_3 ,
    tst_addr__kersr_3 ,
    dout_kersr_3 ,
//----test KER SRAM_4---------
    tst_cen_kersr_4 ,
    tst_wen_kersr_4 ,
    tst_addr__kersr_4 ,
    dout_kersr_4 ,
//----test KER SRAM_5---------
    tst_cen_kersr_5 ,
    tst_wen_kersr_5 ,
    tst_addr__kersr_5 ,
    dout_kersr_5 ,
//----test KER SRAM_6---------
    tst_cen_kersr_6 ,
    tst_wen_kersr_6 ,
    tst_addr__kersr_6 ,
    dout_kersr_6 ,
//----test KER SRAM_7---------
    tst_cen_kersr_7 ,
    tst_wen_kersr_7 ,
    tst_addr__kersr_7 ,
    dout_kersr_7 


);

	input wire clk ;
	input wire reset ;


	input wire [ 63 : 0 ] ker_store_data_din	;
	input wire		ker_store_empty_n_din	;
	output reg		ker_store_read_dout		;

	output reg 		ker_store_done 		;
	output reg 		ker_store_busy 		;
	input wire 		start_ker_store		;


//----ker w test input declare start------ 
    input wire tst_sram_rw ;
//----tb declare KER SRAM_0---------
    input wire tst_cen_kersr_0 ;
    input wire tst_wen_kersr_0 ;
    input wire [ 11 -1 : 0 ] tst_addr__kersr_0 ;
    input wire [ 64 -1 : 0 ] dout_kersr_0 ;
//----tb declare KER SRAM_1---------
    input wire tst_cen_kersr_1 ;
    input wire tst_wen_kersr_1 ;
    input wire [ 11 -1 : 0 ] tst_addr__kersr_1 ;
    input wire [ 64 -1 : 0 ] dout_kersr_1 ;
//----tb declare KER SRAM_2---------
    input wire tst_cen_kersr_2 ;
    input wire tst_wen_kersr_2 ;
    input wire [ 11 -1 : 0 ] tst_addr__kersr_2 ;
    input wire [ 64 -1 : 0 ] dout_kersr_2 ;
//----tb declare KER SRAM_3---------
    input wire tst_cen_kersr_3 ;
    input wire tst_wen_kersr_3 ;
    input wire [ 11 -1 : 0 ] tst_addr__kersr_3 ;
    input wire [ 64 -1 : 0 ] dout_kersr_3 ;
//----tb declare KER SRAM_4---------
    input wire tst_cen_kersr_4 ;
    input wire tst_wen_kersr_4 ;
    input wire [ 11 -1 : 0 ] tst_addr__kersr_4 ;
    input wire [ 64 -1 : 0 ] dout_kersr_4 ;
//----tb declare KER SRAM_5---------
    input wire tst_cen_kersr_5 ;
    input wire tst_wen_kersr_5 ;
    input wire [ 11 -1 : 0 ] tst_addr__kersr_5 ;
    input wire [ 64 -1 : 0 ] dout_kersr_5 ;
//----tb declare KER SRAM_6---------
    input wire tst_cen_kersr_6 ;
    input wire tst_wen_kersr_6 ;
    input wire [ 11 -1 : 0 ] tst_addr__kersr_6 ;
    input wire [ 64 -1 : 0 ] dout_kersr_6 ;
//----tb declare KER SRAM_7---------
    input wire tst_cen_kersr_7 ;
    input wire tst_wen_kersr_7 ;
    input wire [ 11 -1 : 0 ] tst_addr__kersr_7 ;
    input wire [ 64 -1 : 0 ] dout_kersr_7 ;
//----ker w test input declare end------ 


	//----declare KER_SRAM start------ 
//----declare KER SRAM_0---------
    wire cen_kersr_0 ;
    wire wen_kersr_0 ;
    wire [ 11 -1 : 0 ] addr__kersr_0 ;
    wire [ 64 -1 : 0 ] dout_kersr_0 ;
    wire [ 64 -1 : 0 ] din_kersr_0 ;
//----declare KER SRAM_1---------
    wire cen_kersr_1 ;
    wire wen_kersr_1 ;
    wire [ 11 -1 : 0 ] addr__kersr_1 ;
    wire [ 64 -1 : 0 ] dout_kersr_1 ;
    wire [ 64 -1 : 0 ] din_kersr_1 ;
//----declare KER SRAM_2---------
    wire cen_kersr_2 ;
    wire wen_kersr_2 ;
    wire [ 11 -1 : 0 ] addr__kersr_2 ;
    wire [ 64 -1 : 0 ] dout_kersr_2 ;
    wire [ 64 -1 : 0 ] din_kersr_2 ;
//----declare KER SRAM_3---------
    wire cen_kersr_3 ;
    wire wen_kersr_3 ;
    wire [ 11 -1 : 0 ] addr__kersr_3 ;
    wire [ 64 -1 : 0 ] dout_kersr_3 ;
    wire [ 64 -1 : 0 ] din_kersr_3 ;
//----declare KER SRAM_4---------
    wire cen_kersr_4 ;
    wire wen_kersr_4 ;
    wire [ 11 -1 : 0 ] addr__kersr_4 ;
    wire [ 64 -1 : 0 ] dout_kersr_4 ;
    wire [ 64 -1 : 0 ] din_kersr_4 ;
//----declare KER SRAM_5---------
    wire cen_kersr_5 ;
    wire wen_kersr_5 ;
    wire [ 11 -1 : 0 ] addr__kersr_5 ;
    wire [ 64 -1 : 0 ] dout_kersr_5 ;
    wire [ 64 -1 : 0 ] din_kersr_5 ;
//----declare KER SRAM_6---------
    wire cen_kersr_6 ;
    wire wen_kersr_6 ;
    wire [ 11 -1 : 0 ] addr__kersr_6 ;
    wire [ 64 -1 : 0 ] dout_kersr_6 ;
    wire [ 64 -1 : 0 ] din_kersr_6 ;
//----declare KER SRAM_7---------
    wire cen_kersr_7 ;
    wire wen_kersr_7 ;
    wire [ 11 -1 : 0 ] addr__kersr_7 ;
    wire [ 64 -1 : 0 ] dout_kersr_7 ;
    wire [ 64 -1 : 0 ] din_kersr_7 ;
//----declare KER_SRAM end------ 



//----ker_top sram write connect port  end------ 
//----declare ker_top SRAM_0---------
    wire ksw_cen_kersr_0;
    wire ksw_wen_kersr_0;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_0;
    wire [ 64 -1 : 0 ]ksw_din_kersr_0;
//----declare ker_top SRAM_1---------
    wire ksw_cen_kersr_1;
    wire ksw_wen_kersr_1;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_1;
    wire [ 64 -1 : 0 ]ksw_din_kersr_1;
//----declare ker_top SRAM_2---------
    wire ksw_cen_kersr_2;
    wire ksw_wen_kersr_2;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_2;
    wire [ 64 -1 : 0 ]ksw_din_kersr_2;
//----declare ker_top SRAM_3---------
    wire ksw_cen_kersr_3;
    wire ksw_wen_kersr_3;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_3;
    wire [ 64 -1 : 0 ]ksw_din_kersr_3;
//----declare ker_top SRAM_4---------
    wire ksw_cen_kersr_4;
    wire ksw_wen_kersr_4;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_4;
    wire [ 64 -1 : 0 ]ksw_din_kersr_4;
//----declare ker_top SRAM_5---------
    wire ksw_cen_kersr_5;
    wire ksw_wen_kersr_5;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_5;
    wire [ 64 -1 : 0 ]ksw_din_kersr_5;
//----declare ker_top SRAM_6---------
    wire ksw_cen_kersr_6;
    wire ksw_wen_kersr_6;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_6;
    wire [ 64 -1 : 0 ]ksw_din_kersr_6;
//----declare ker_top SRAM_7---------
    wire ksw_cen_kersr_7;
    wire ksw_wen_kersr_7;
    wire [ 11 -1 : 0 ]ksw_addr__kersr_7;
    wire [ 64 -1 : 0 ]ksw_din_kersr_7;
//----ker_top sram write connect port  end------ 


//----ker_top assign start------ 
//----ker_top assign cen ------ 
    assign cen_kersr_0 = ( tst_sram_rw )? ksw_cen_kersr_0 : tst_cen_kersr_0 ;
    assign cen_kersr_1 = ( tst_sram_rw )? ksw_cen_kersr_1 : tst_cen_kersr_1 ;
    assign cen_kersr_2 = ( tst_sram_rw )? ksw_cen_kersr_2 : tst_cen_kersr_2 ;
    assign cen_kersr_3 = ( tst_sram_rw )? ksw_cen_kersr_3 : tst_cen_kersr_3 ;
    assign cen_kersr_4 = ( tst_sram_rw )? ksw_cen_kersr_4 : tst_cen_kersr_4 ;
    assign cen_kersr_5 = ( tst_sram_rw )? ksw_cen_kersr_5 : tst_cen_kersr_5 ;
    assign cen_kersr_6 = ( tst_sram_rw )? ksw_cen_kersr_6 : tst_cen_kersr_6 ;
    assign cen_kersr_7 = ( tst_sram_rw )? ksw_cen_kersr_7 : tst_cen_kersr_7 ;
//----ker_top assign wen ------ 
    assign wen_kersr_0 = ( tst_sram_rw )? ksw_wen_kersr_0 : tst_wen_kersr_0 ;
    assign wen_kersr_1 = ( tst_sram_rw )? ksw_wen_kersr_1 : tst_wen_kersr_1 ;
    assign wen_kersr_2 = ( tst_sram_rw )? ksw_wen_kersr_2 : tst_wen_kersr_2 ;
    assign wen_kersr_3 = ( tst_sram_rw )? ksw_wen_kersr_3 : tst_wen_kersr_3 ;
    assign wen_kersr_4 = ( tst_sram_rw )? ksw_wen_kersr_4 : tst_wen_kersr_4 ;
    assign wen_kersr_5 = ( tst_sram_rw )? ksw_wen_kersr_5 : tst_wen_kersr_5 ;
    assign wen_kersr_6 = ( tst_sram_rw )? ksw_wen_kersr_6 : tst_wen_kersr_6 ;
    assign wen_kersr_7 = ( tst_sram_rw )? ksw_wen_kersr_7 : tst_wen_kersr_7 ;
//----ker_top assign addr ------ 
    assign addr__kersr_0 =  ( tst_sram_rw )? ksw_addr__kersr_0 : tst_addr__kersr_0 ;
    assign addr__kersr_1 =  ( tst_sram_rw )? ksw_addr__kersr_1 : tst_addr__kersr_1 ;
    assign addr__kersr_2 =  ( tst_sram_rw )? ksw_addr__kersr_2 : tst_addr__kersr_2 ;
    assign addr__kersr_3 =  ( tst_sram_rw )? ksw_addr__kersr_3 : tst_addr__kersr_3 ;
    assign addr__kersr_4 =  ( tst_sram_rw )? ksw_addr__kersr_4 : tst_addr__kersr_4 ;
    assign addr__kersr_5 =  ( tst_sram_rw )? ksw_addr__kersr_5 : tst_addr__kersr_5 ;
    assign addr__kersr_6 =  ( tst_sram_rw )? ksw_addr__kersr_6 : tst_addr__kersr_6 ;
    assign addr__kersr_7 =  ( tst_sram_rw )? ksw_addr__kersr_7 : tst_addr__kersr_7 ;
//----ker_top assign din ------ 
    assign din__kersr_0 =  ( tst_sram_rw )? ksw_din_kersr_0 : 64'd0 ;
    assign din__kersr_1 =  ( tst_sram_rw )? ksw_din_kersr_1 : 64'd0 ;
    assign din__kersr_2 =  ( tst_sram_rw )? ksw_din_kersr_2 : 64'd0 ;
    assign din__kersr_3 =  ( tst_sram_rw )? ksw_din_kersr_3 : 64'd0 ;
    assign din__kersr_4 =  ( tst_sram_rw )? ksw_din_kersr_4 : 64'd0 ;
    assign din__kersr_5 =  ( tst_sram_rw )? ksw_din_kersr_5 : 64'd0 ;
    assign din__kersr_6 =  ( tst_sram_rw )? ksw_din_kersr_6 : 64'd0 ;
    assign din__kersr_7 =  ( tst_sram_rw )? ksw_din_kersr_7 : 64'd0 ;
//----ker_top assign end------ 


//----instance KER_SRAM start------ 
//----instance KER SRAM_0---------
KER_SRAM ker_0(
    .Q    (	dout_kersr_0 ),	
    .CLK    ( clk ),
    .CEN    ( cen_kersr_0 ),
    .WEN    ( wen_kersr_0 ),
    .A    ( addr__kersr_0 ),
    .D    ( din__kersr_0 ),
    .EMA    ( 3'b0 )
    );
//----instance KER SRAM_1---------
KER_SRAM ker_1(
    .Q    (	dout_kersr_1 ),	
    .CLK    ( clk ),
    .CEN    ( cen_kersr_1 ),
    .WEN    ( wen_kersr_1 ),
    .A    ( addr__kersr_1 ),
    .D    ( din__kersr_1 ),
    .EMA    ( 3'b0 )
    );
//----instance KER SRAM_2---------
KER_SRAM ker_2(
    .Q    (	dout_kersr_2 ),	
    .CLK    ( clk ),
    .CEN    ( cen_kersr_2 ),
    .WEN    ( wen_kersr_2 ),
    .A    ( addr__kersr_2 ),
    .D    ( din__kersr_2 ),
    .EMA    ( 3'b0 )
    );
//----instance KER SRAM_3---------
KER_SRAM ker_3(
    .Q    (	dout_kersr_3 ),	
    .CLK    ( clk ),
    .CEN    ( cen_kersr_3 ),
    .WEN    ( wen_kersr_3 ),
    .A    ( addr__kersr_3 ),
    .D    ( din__kersr_3 ),
    .EMA    ( 3'b0 )
    );
//----instance KER SRAM_4---------
KER_SRAM ker_4(
    .Q    (	dout_kersr_4 ),	
    .CLK    ( clk ),
    .CEN    ( cen_kersr_4 ),
    .WEN    ( wen_kersr_4 ),
    .A    ( addr__kersr_4 ),
    .D    ( din__kersr_4 ),
    .EMA    ( 3'b0 )
    );
//----instance KER SRAM_5---------
KER_SRAM ker_5(
    .Q    (	dout_kersr_5 ),	
    .CLK    ( clk ),
    .CEN    ( cen_kersr_5 ),
    .WEN    ( wen_kersr_5 ),
    .A    ( addr__kersr_5 ),
    .D    ( din__kersr_5 ),
    .EMA    ( 3'b0 )
    );
//----instance KER SRAM_6---------
KER_SRAM ker_6(
    .Q    (	dout_kersr_6 ),	
    .CLK    ( clk ),
    .CEN    ( cen_kersr_6 ),
    .WEN    ( wen_kersr_6 ),
    .A    ( addr__kersr_6 ),
    .D    ( din__kersr_6 ),
    .EMA    ( 3'b0 )
    );
//----instance KER SRAM_7---------
KER_SRAM ker_7(
    .Q    (	dout_kersr_7 ),	
    .CLK    ( clk ),
    .CEN    ( cen_kersr_7 ),
    .WEN    ( wen_kersr_7 ),
    .A    ( addr__kersr_7 ),
    .D    ( din__kersr_7 ),
    .EMA    ( 3'b0 )
    );
//----instance KER_SRAM end------ 



kersram_w ker_write (
	.clk	(	clk		),
	.reset	(	reset	),

	.ker_store_data_din		(	ker_store_data_din	),
	.ker_store_empty_n_din	(	ker_store_empty_n_din	),
	.ker_store_read_dout	(	ker_store_read_dout	),

	.ker_store_done 		(	ker_store_done	),
	.ker_store_busy 		(	ker_store_busy	),
	.start_ker_store		(	start_ker_store	),

	//----------- kernel sram signal ---------------
//----ker_top sram write instance port start------ 
//----declare ker_top SRAM_0---------
    .cen_kersr_0 ( ksw_cen_kersr_0 ),
    .wen_kersr_0 ( ksw_wen_kersr_0 ),
    .addr__kersr_0 ( ksw_addr__kersr_0 ),
    .din_kersr_0 ( ksw_din_kersr_0 ),
//----declare ker_top SRAM_1---------
    .cen_kersr_1 ( ksw_cen_kersr_1 ),
    .wen_kersr_1 ( ksw_wen_kersr_1 ),
    .addr__kersr_1 ( ksw_addr__kersr_1 ),
    .din_kersr_1 ( ksw_din_kersr_1 ),
//----declare ker_top SRAM_2---------
    .cen_kersr_2 ( ksw_cen_kersr_2 ),
    .wen_kersr_2 ( ksw_wen_kersr_2 ),
    .addr__kersr_2 ( ksw_addr__kersr_2 ),
    .din_kersr_2 ( ksw_din_kersr_2 ),
//----declare ker_top SRAM_3---------
    .cen_kersr_3 ( ksw_cen_kersr_3 ),
    .wen_kersr_3 ( ksw_wen_kersr_3 ),
    .addr__kersr_3 ( ksw_addr__kersr_3 ),
    .din_kersr_3 ( ksw_din_kersr_3 ),
//----declare ker_top SRAM_4---------
    .cen_kersr_4 ( ksw_cen_kersr_4 ),
    .wen_kersr_4 ( ksw_wen_kersr_4 ),
    .addr__kersr_4 ( ksw_addr__kersr_4 ),
    .din_kersr_4 ( ksw_din_kersr_4 ),
//----declare ker_top SRAM_5---------
    .cen_kersr_5 ( ksw_cen_kersr_5 ),
    .wen_kersr_5 ( ksw_wen_kersr_5 ),
    .addr__kersr_5 ( ksw_addr__kersr_5 ),
    .din_kersr_5 ( ksw_din_kersr_5 ),
//----declare ker_top SRAM_6---------
    .cen_kersr_6 ( ksw_cen_kersr_6 ),
    .wen_kersr_6 ( ksw_wen_kersr_6 ),
    .addr__kersr_6 ( ksw_addr__kersr_6 ),
    .din_kersr_6 ( ksw_din_kersr_6 ),
//----declare ker_top SRAM_7---------
    .cen_kersr_7 ( ksw_cen_kersr_7 ),
    .wen_kersr_7 ( ksw_wen_kersr_7 ),
    .addr__kersr_7 ( ksw_addr__kersr_7 ),
    .din_kersr_7 ( ksw_din_kersr_7 )
//----ker_top sram write instance port  end------ 
);



endmodule


