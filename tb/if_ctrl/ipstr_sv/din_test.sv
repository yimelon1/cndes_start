`define SDFFILE    "./DIN_SYN.sdf"	  // Modify your sdf file name
`define VIVA
// `define RTL
`define IF_SR;

`define End_CYCLE  1300      // Modify cycle times once your design need more cycle times!
`ifdef RTL
	`timescale 1ns/100ps
	`define CYCLE 10
	// `include "./pe_8v"
`endif
`ifdef VIVA
	`timescale 1ns/100ps
	`define CYCLE 10
	// `include "./pe_8v"
`endif


`define PATH_LOG "E:/yuan/v_code/proj0728/tb/ipstr_sv/log/log.txt"
//---------------------------- Pattern ----------------------------------------
`ifdef VIVA
	`define KER_DAT "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/2_w.dat"
	`define KSR_0 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_0.dat"
	`define KSR_1 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_1.dat"
	`define KSR_2 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_2.dat"
	`define KSR_3 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_3.dat"
	`define KSR_4 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_4.dat"
	`define KSR_5 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_5.dat"
	`define KSR_6 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_6.dat"
	`define KSR_7 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_7.dat"
	`define IFMAP_DAT 	"E:/yuan/v_code/proj0728/tb/svyyy33/PAT/2_in.dat"
	`define PEGD_DAT 	"E:/yuan/v_code/proj0728/tb/svyyy33/PAT/pe_out/peout.dat"
	`define IFS_DAT_0 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/if_sr/ifsram0_data.dat"
	`define IFS_DAT_1 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/if_sr/ifsram1_data.dat"
	`define IFS_DAT_2 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/if_sr/ifsram2_data.dat"
	`define IFS_DAT_3 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/if_sr/ifsram3_data.dat"
	`define IFS_DAT_4 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/if_sr/ifsram4_data.dat"
	`define IFS_DAT_5 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/if_sr/ifsram5_data.dat"
	`define IFS_DAT_6 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/if_sr/ifsram6_data.dat"
	`define IFS_DAT_7 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/if_sr/ifsram7_data.dat"
`else
	`define KER_DAT "PAT/2_w.dat"
	`define KSR_0 "PAT/w_sr/wsram_pat_0.dat"
	`define KSR_1 "PAT/w_sr/wsram_pat_1.dat"
	`define KSR_2 "PAT/w_sr/wsram_pat_2.dat"
	`define KSR_3 "PAT/w_sr/wsram_pat_3.dat"
	`define KSR_4 "PAT/w_sr/wsram_pat_4.dat"
	`define KSR_5 "PAT/w_sr/wsram_pat_5.dat"
	`define KSR_6 "PAT/w_sr/wsram_pat_6.dat"
	`define KSR_7 "PAT/w_sr/wsram_pat_7.dat"
	`define IFMAP_DAT "PAT/2_in.dat"
	`define PEGD_DAT "PAT/pe_out/peout.dat"
`endif 
//-----------------------------------------------------------------------------


module din_tb();
parameter TBITS = 64;
parameter TBYTE = 8;

parameter IFMAP_SIZE   = 173056;
parameter TB_ISRAM_DEPTH	=	300 ;

localparam IFMAP_SRAM_ADDBITS = 11       ;
localparam IFMAP_SRAM_DATA_WIDTH = 64    ;



reg              S_AXIS_MM2S_TVALID = 0;
wire             S_AXIS_MM2S_TREADY;
reg  [TBITS-1:0] S_AXIS_MM2S_TDATA = 0;
reg  [TBYTE-1:0] S_AXIS_MM2S_TKEEP = 0;
reg  [1-1:0]     S_AXIS_MM2S_TLAST = 0;

wire             M_AXIS_S2MM_TVALID			;
reg              M_AXIS_S2MM_TREADY			= 0	;
wire [TBITS-1:0] M_AXIS_S2MM_TDATA			;
wire [TBYTE-1:0] M_AXIS_S2MM_TKEEP			;
wire [1-1:0]     M_AXIS_S2MM_TLAST			;





wire [TBITS-1: 0 ]	isif_data_dout			;
wire [TBYTE-1: 0 ]	isif_strb_dout			;
wire 				isif_last_dout			;
wire 				isif_user_dout			;
wire 				isif_empty_n			;
wire 				isif_read				;

wire [TBITS-1: 0 ]	osif_data_din			;
wire [TBYTE-1: 0 ]	osif_strb_din			;
wire 				osif_last_din			;
wire 				osif_user_din			;
wire 				osif_full_n				;
wire 				osif_write				;



logic	clk = 0;              //input  
logic	reset = 0;
logic	rstn = 1;
reg [30:0] cycle=0;

reg tb_memread_done ;
reg    [TBITS-1 : 0]      ifmap        [0:IFMAP_SIZE-1];
integer i0 , i1 ;
integer num_cp;
integer error ;
integer fp_w ;


reg    [TBITS-1 : 0]      tb_ifsram_0        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      tb_ifsram_1        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      tb_ifsram_2        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      tb_ifsram_3        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      tb_ifsram_4        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      tb_ifsram_5        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      tb_ifsram_6        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      tb_ifsram_7        [0:	TB_ISRAM_DEPTH-1	]		;

reg    [TBITS-1 : 0]      gdd_ifsram_0        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      gdd_ifsram_1        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      gdd_ifsram_2        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      gdd_ifsram_3        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      gdd_ifsram_4        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      gdd_ifsram_5        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      gdd_ifsram_6        [0:	TB_ISRAM_DEPTH-1	]		;
reg    [TBITS-1 : 0]      gdd_ifsram_7        [0:	TB_ISRAM_DEPTH-1	]		;


reg tst_rdsram;
reg tst_rdsram_done;


reg en_sram_ifm0 ;
reg en_sram_ifm1 ;
reg en_sram_ifm2 ;
reg en_sram_ifm3 ;
reg en_sram_ifm4 ;
reg en_sram_ifm5 ;
reg en_sram_ifm6 ;
reg en_sram_ifm7 ;

reg wea_sram_ifm0 ;
reg wea_sram_ifm1 ;
reg wea_sram_ifm2 ;
reg wea_sram_ifm3 ;
reg wea_sram_ifm4 ;
reg wea_sram_ifm5 ;
reg wea_sram_ifm6 ;
reg wea_sram_ifm7 ;

reg [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm0  ;
reg [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm1  ;
reg [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm2  ;
reg [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm3  ;
reg [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm4  ;
reg [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm5  ;
reg [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm6  ;
reg [  IFMAP_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm7  ;

wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm0	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm1	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm2	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm3	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm4	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm5	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm6	;
wire [  IFMAP_SRAM_DATA_WIDTH-1   :   0   ]   dout_sram_ifm7	;



// =============================================================================
// =======		instance 	===================================================
// =============================================================================


INPUT_STREAM_if		#(
	.TBITS	(	TBITS	),
	.TBYTE	(	TBYTE	)
)
axififo_in (
	// AXI4-Stream singals
	.ACLK       (	clk	),
	.ARESETN    (	rstn	),
	.TVALID     (	S_AXIS_MM2S_TVALID	),
	.TREADY     (	S_AXIS_MM2S_TREADY	),
	.TDATA      (	S_AXIS_MM2S_TDATA	),
	.TKEEP      (	S_AXIS_MM2S_TKEEP	),
	.TLAST      (	S_AXIS_MM2S_TLAST	),
	.TUSER      ( 1'b0 ),

	// User signals
	.isif_data_dout         (	isif_data_dout		),
	.isif_strb_dout         (	isif_strb_dout		),
	.isif_last_dout         (	isif_last_dout		),
	.isif_user_dout         (	isif_user_dout		),
	.isif_empty_n           (	isif_empty_n		),
	.isif_read				(	isif_read			)
);

OUTPUT_STREAM_if	#(
	.TBITS	(	TBITS	),
	.TBYTE	(	TBYTE	)
)
axififo_out	(
	// AXI4-Stream singals
	.ACLK		(	clk	),
	.ARESETN	(	rstn	),
	.TVALID		(	M_AXIS_S2MM_TVALID			),
	.TREADY		(	M_AXIS_S2MM_TREADY			),
	.TDATA		(	M_AXIS_S2MM_TDATA			),
	.TKEEP		(	M_AXIS_S2MM_TKEEP			),
	.TLAST		(	M_AXIS_S2MM_TLAST			),
	.TUSER		(		),

	// User signals
	.osif_data_din		(	osif_data_din		),
	.osif_strb_din		(	osif_strb_din		),
	.osif_last_din		(	osif_last_din		),
	.osif_user_din		(	osif_user_din		),
	.osif_full_n		(	osif_full_n			),
	.osif_write			(	osif_write			)
);


stdata #(
	.TBITS	(	TBITS	),
	.TBYTE	(	TBYTE	)
)stt01(
	.clk			(	clk		),
	.reset			(	reset	),
	.fifo_data_din	(	isif_data_dout		),
	// fifo_strb_din	(			),
	.fifo_last_din		(	isif_last_dout		),
	// fifo_user_din	(			),
	.fifo_empty_n_din	(	isif_empty_n		),
	.fifo_read_dout		(	isif_read		),


	.tst_rdsram			(	tst_rdsram			),
	.tst_en_sram_ifm0	(	en_sram_ifm0		),
	.tst_en_sram_ifm1	(	en_sram_ifm1		),
	.tst_en_sram_ifm2	(	en_sram_ifm2		),
	.tst_en_sram_ifm3	(	en_sram_ifm3		),
	.tst_en_sram_ifm4	(	en_sram_ifm4		),
	.tst_en_sram_ifm5	(	en_sram_ifm5		),
	.tst_en_sram_ifm6	(	en_sram_ifm6		),
	.tst_en_sram_ifm7	(	en_sram_ifm7		),

	.tst_wea_sram_ifm0	(	wea_sram_ifm0		),
	.tst_wea_sram_ifm1	(	wea_sram_ifm1		),
	.tst_wea_sram_ifm2	(	wea_sram_ifm2		),
	.tst_wea_sram_ifm3	(	wea_sram_ifm3		),
	.tst_wea_sram_ifm4	(	wea_sram_ifm4		),
	.tst_wea_sram_ifm5	(	wea_sram_ifm5		),
	.tst_wea_sram_ifm6	(	wea_sram_ifm6		),
	.tst_wea_sram_ifm7	(	wea_sram_ifm7		),

	.tst_addr_sram_ifm0	(	addr_sram_ifm0		),
	.tst_addr_sram_ifm1	(	addr_sram_ifm1		),
	.tst_addr_sram_ifm2	(	addr_sram_ifm2		),
	.tst_addr_sram_ifm3	(	addr_sram_ifm3		),
	.tst_addr_sram_ifm4	(	addr_sram_ifm4		),
	.tst_addr_sram_ifm5	(	addr_sram_ifm5		),
	.tst_addr_sram_ifm6	(	addr_sram_ifm6		),
	.tst_addr_sram_ifm7	(	addr_sram_ifm7		),


	.tst_dout_sram_ifm0	(	dout_sram_ifm0		),
	.tst_dout_sram_ifm1	(	dout_sram_ifm1		),
	.tst_dout_sram_ifm2	(	dout_sram_ifm2		),
	.tst_dout_sram_ifm3	(	dout_sram_ifm3		),
	.tst_dout_sram_ifm4	(	dout_sram_ifm4		),
	.tst_dout_sram_ifm5	(	dout_sram_ifm5		),
	.tst_dout_sram_ifm6	(	dout_sram_ifm6		),
	.tst_dout_sram_ifm7	(	dout_sram_ifm7		)


);



// =============================================================================


// =============================================================================
always begin
	#(`CYCLE/2)clk = ~clk;
end
always@(*)begin
	rstn = ~reset;
end

always @(posedge clk) begin
    cycle <= cycle+1;
    if (cycle > `End_CYCLE) begin
        $display("********************************************************************");
        $display("**  Failed waiting Valid signal, Simulation STOP at cycle %d **",cycle);
        $display("**  If needed, You can increase End_CYCLE value in tp.v           **");
        $display("********************************************************************");
        $finish;
    end
end


initial begin // initial pattern and expected result
	wait(reset==1);
	tb_memread_done = 0; 
	//--------- pattern reading start -----------
	$readmemh(`IFMAP_DAT, ifmap);
	$readmemh(`IFS_DAT_0, gdd_ifsram_0	);
	$readmemh(`IFS_DAT_1, gdd_ifsram_1	);
	$readmemh(`IFS_DAT_2, gdd_ifsram_2	);
	$readmemh(`IFS_DAT_3, gdd_ifsram_3	);
	$readmemh(`IFS_DAT_4, gdd_ifsram_4	);
	$readmemh(`IFS_DAT_5, gdd_ifsram_5	);
	$readmemh(`IFS_DAT_6, gdd_ifsram_6	);
	$readmemh(`IFS_DAT_7, gdd_ifsram_7	);


	//--------- pattern reading end -----------	
	#1;
	tb_memread_done = 1;

end


initial begin
	#1;
	reset = 0;
	#(`CYCLE*3);
	reset = 1;
	S_AXIS_MM2S_TKEEP = 'hff;
	tst_rdsram = 0;
	#(`CYCLE*3);
	@(posedge clk);
	reset = 0;
	

	for ( i1=0 ; i1<3 ; i1=i1+1 )begin
		for( i0=0; i0<(66*4) ; i0=i0+1) begin
			@(posedge clk);
			S_AXIS_MM2S_TVALID=1;
			S_AXIS_MM2S_TDATA = ifmap[i0 + i1*208*4 ]	;
			if(  i1 == 2 && i0==(66*4-1) )begin
				S_AXIS_MM2S_TLAST = 1 ;
			end
			wait(S_AXIS_MM2S_TREADY);
		end
		// #(`CYCLE*30);
		@(posedge clk);
		S_AXIS_MM2S_TVALID = 0 ;
		S_AXIS_MM2S_TLAST = 0 ;

	end

	
	#(`CYCLE*30);	// wait for sram7 storing done
	tst_rdsram = 1;
	



end

initial begin
	wait( reset );
	addr_sram_ifm0 = 'd0;
	addr_sram_ifm1 = 'd0;
	addr_sram_ifm2 = 'd0;
	addr_sram_ifm3 = 'd0;
	addr_sram_ifm4 = 'd0;
	addr_sram_ifm5 = 'd0;
	addr_sram_ifm6 = 'd0;
	addr_sram_ifm7 = 'd0;
	en_sram_ifm0	= 1'd0 ;
	en_sram_ifm1	= 1'd0 ;
	en_sram_ifm2	= 1'd0 ;
	en_sram_ifm3	= 1'd0 ;
	en_sram_ifm4	= 1'd0 ;
	en_sram_ifm5	= 1'd0 ;
	en_sram_ifm6	= 1'd0 ;
	en_sram_ifm7	= 1'd0 ;
	wea_sram_ifm0	= 1'd0 ;
	wea_sram_ifm1	= 1'd0 ;
	wea_sram_ifm2	= 1'd0 ;
	wea_sram_ifm3	= 1'd0 ;
	wea_sram_ifm4	= 1'd0 ;
	wea_sram_ifm5	= 1'd0 ;
	wea_sram_ifm6	= 1'd0 ;
	wea_sram_ifm7	= 1'd0 ;
	tst_rdsram_done	= 0;

	wait( tst_rdsram );
	en_sram_ifm0	= 1'd0 ;
	wea_sram_ifm0	= 1'd0 ;
	#(`CYCLE*3);
	i0 = 0;
	for( i0 = 0; i0<291 ; i0= i0+1 )begin
		@( posedge clk);
		en_sram_ifm0	<= 1'd1 ;
		en_sram_ifm1	<= 1'd1 ;
		en_sram_ifm2	<= 1'd1 ;
		en_sram_ifm3	<= 1'd1 ;
		en_sram_ifm4	<= 1'd1 ;
		en_sram_ifm5	<= 1'd1 ;
		en_sram_ifm6	<= 1'd1 ;
		en_sram_ifm7	<= 1'd1 ;
		wea_sram_ifm0	<= 1'd0 ;
		wea_sram_ifm1	<= 1'd0 ;
		wea_sram_ifm2	<= 1'd0 ;
		wea_sram_ifm3	<= 1'd0 ;
		wea_sram_ifm4	<= 1'd0 ;
		wea_sram_ifm5	<= 1'd0 ;
		wea_sram_ifm6	<= 1'd0 ;
		wea_sram_ifm7	<= 1'd0 ;
		if( i0 <= 287) addr_sram_ifm0 = i0	;	else addr_sram_ifm0 <= 'd0;
		if( i0 <= 287) addr_sram_ifm1 = i0	;	else addr_sram_ifm1 <= 'd0;
		if( i0 <= 287) addr_sram_ifm2 = i0	;	else addr_sram_ifm2 <= 'd0;
		if( i0 <= 287) addr_sram_ifm3 = i0	;	else addr_sram_ifm3 <= 'd0;
		if( i0 <= 287) addr_sram_ifm4 = i0	;	else addr_sram_ifm4 <= 'd0;
		if( i0 <= 287) addr_sram_ifm5 = i0	;	else addr_sram_ifm5 <= 'd0;
		if( i0 <= 287) addr_sram_ifm6 = i0	;	else addr_sram_ifm6 <= 'd0;
		if( i0 <= 287) addr_sram_ifm7 = i0	;	else addr_sram_ifm7 <= 'd0;
		if( i0 >= 'd3 )tb_ifsram_0[ i0-3 ] <= dout_sram_ifm0 ;else tb_ifsram_0[ i0-3 ] <= tb_ifsram_0[ i0-3 ] ;
		if( i0 >= 'd3 )tb_ifsram_1[ i0-3 ] <= dout_sram_ifm1 ;else tb_ifsram_1[ i0-3 ] <= tb_ifsram_1[ i0-3 ] ;
		if( i0 >= 'd3 )tb_ifsram_2[ i0-3 ] <= dout_sram_ifm2 ;else tb_ifsram_2[ i0-3 ] <= tb_ifsram_2[ i0-3 ] ;
		if( i0 >= 'd3 )tb_ifsram_3[ i0-3 ] <= dout_sram_ifm3 ;else tb_ifsram_3[ i0-3 ] <= tb_ifsram_3[ i0-3 ] ;
		if( i0 >= 'd3 )tb_ifsram_4[ i0-3 ] <= dout_sram_ifm4 ;else tb_ifsram_4[ i0-3 ] <= tb_ifsram_4[ i0-3 ] ;
		if( i0 >= 'd3 )tb_ifsram_5[ i0-3 ] <= dout_sram_ifm5 ;else tb_ifsram_5[ i0-3 ] <= tb_ifsram_5[ i0-3 ] ;
		if( i0 >= 'd3 )tb_ifsram_6[ i0-3 ] <= dout_sram_ifm6 ;else tb_ifsram_6[ i0-3 ] <= tb_ifsram_6[ i0-3 ] ;
		if( i0 >= 'd3 )tb_ifsram_7[ i0-3 ] <= dout_sram_ifm7 ;else tb_ifsram_7[ i0-3 ] <= tb_ifsram_7[ i0-3 ] ;

	end

	@( posedge clk);
	addr_sram_ifm0 = 'd0;
	addr_sram_ifm1 = 'd0;
	addr_sram_ifm2 = 'd0;
	addr_sram_ifm3 = 'd0;
	addr_sram_ifm4 = 'd0;
	addr_sram_ifm5 = 'd0;
	addr_sram_ifm6 = 'd0;
	addr_sram_ifm7 = 'd0;
	en_sram_ifm0	= 1'd1 ;
	en_sram_ifm1	= 1'd1 ;
	en_sram_ifm2	= 1'd1 ;
	en_sram_ifm3	= 1'd1 ;
	en_sram_ifm4	= 1'd1 ;
	en_sram_ifm5	= 1'd1 ;
	en_sram_ifm6	= 1'd1 ;
	en_sram_ifm7	= 1'd1 ;
	wea_sram_ifm0	= 1'd0 ;
	wea_sram_ifm1	= 1'd0 ;
	wea_sram_ifm2	= 1'd0 ;
	wea_sram_ifm3	= 1'd0 ;
	wea_sram_ifm4	= 1'd0 ;
	wea_sram_ifm5	= 1'd0 ;
	wea_sram_ifm6	= 1'd0 ;
	wea_sram_ifm7	= 1'd0 ;

	#(`CYCLE*3);
	@( posedge clk);
	tst_rdsram_done = 1 ;

end



initial begin
	fp_w = $fopen(`PATH_LOG, "w");
	wait( reset );
	error = 0;

	#(`CYCLE*3);
	wait( tst_rdsram_done) ;

	//----generate compare circuit by print_ofcmp.py------ 
	//----cp if sram_0---------
	for(num_cp=0; num_cp<		288	; num_cp=num_cp+1)begin
		if(tb_ifsram_0[num_cp] !== gdd_ifsram_0[num_cp])begin
			$display("sram_0,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_0[num_cp], gdd_ifsram_0[num_cp]);
			error = error + 1;
			$fwrite(fp_w, "sram_0,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_0[num_cp], gdd_ifsram_0[num_cp]);
		end
	end
	//----cp if sram_1---------
	for(num_cp=0; num_cp<		288	; num_cp=num_cp+1)begin
		if(tb_ifsram_1[num_cp] !== gdd_ifsram_1[num_cp])begin
			$display("sram_1,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_1[num_cp], gdd_ifsram_1[num_cp]);
			error = error + 1;
			$fwrite(fp_w, "sram_1,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_1[num_cp], gdd_ifsram_1[num_cp]);
		end
	end
	//----cp if sram_2---------
	for(num_cp=0; num_cp<		288	; num_cp=num_cp+1)begin
		if(tb_ifsram_2[num_cp] !== gdd_ifsram_2[num_cp])begin
			$display("sram_2,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_2[num_cp], gdd_ifsram_2[num_cp]);
			error = error + 1;
			$fwrite(fp_w, "sram_2,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_2[num_cp], gdd_ifsram_2[num_cp]);
		end
	end
	//----cp if sram_3---------
	for(num_cp=0; num_cp<		288	; num_cp=num_cp+1)begin
		if(tb_ifsram_3[num_cp] !== gdd_ifsram_3[num_cp])begin
			$display("sram_3,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_3[num_cp], gdd_ifsram_3[num_cp]);
			error = error + 1;
			$fwrite(fp_w, "sram_3,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_3[num_cp], gdd_ifsram_3[num_cp]);
		end
	end
	//----cp if sram_4---------
	for(num_cp=0; num_cp<		288	; num_cp=num_cp+1)begin
		if(tb_ifsram_4[num_cp] !== gdd_ifsram_4[num_cp])begin
			$display("sram_4,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_4[num_cp], gdd_ifsram_4[num_cp]);
			error = error + 1;
			$fwrite(fp_w, "sram_4,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_4[num_cp], gdd_ifsram_4[num_cp]);
		end
	end
	//----cp if sram_5---------
	for(num_cp=0; num_cp<		288	; num_cp=num_cp+1)begin
		if(tb_ifsram_5[num_cp] !== gdd_ifsram_5[num_cp])begin
			$display("sram_5,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_5[num_cp], gdd_ifsram_5[num_cp]);
			error = error + 1;
			$fwrite(fp_w, "sram_5,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_5[num_cp], gdd_ifsram_5[num_cp]);
		end
	end
	//----cp if sram_6---------
	for(num_cp=0; num_cp<		288	; num_cp=num_cp+1)begin
		if(tb_ifsram_6[num_cp] !== gdd_ifsram_6[num_cp])begin
			$display("sram_6,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_6[num_cp], gdd_ifsram_6[num_cp]);
			error = error + 1;
			$fwrite(fp_w, "sram_6,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_6[num_cp], gdd_ifsram_6[num_cp]);
		end
	end
	//----cp if sram_7---------
	for(num_cp=0; num_cp<		288	; num_cp=num_cp+1)begin
		if(tb_ifsram_7[num_cp] !== gdd_ifsram_7[num_cp])begin
			$display("sram_7,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_7[num_cp], gdd_ifsram_7[num_cp]);
			error = error + 1;
			$fwrite(fp_w, "sram_7,error at %d, tbsram= %x  goldsram= %x\n", num_cp, tb_ifsram_7[num_cp], gdd_ifsram_7[num_cp]);
		end
	end
	//----generate compare circuit end------ 


	// for(num_cp=0; num_cp<		288		; num_cp=num_cp+1)begin
	// 	if(tb_ifsram_0[num_cp] !== gdd_ifsram_0[num_cp])begin
	// 		$display("error at %d, ofmap= %x  ofmap_gold= %x\n", num_cp, tb_ifsram_0[num_cp], gdd_ifsram_0[num_cp]);
	// 		error = error + 1;
	// 		$fwrite(fp_w, "error at %d, ofmap= %x  ofmap_gold= %x\n", num_cp, tb_ifsram_0[num_cp], gdd_ifsram_0[num_cp]);
	// 	end
	// end
	$display( " total cycle = %d\n" ,cycle);

	if(error > 0)begin
		$display("QQ, Total error = %d\n", error);
	end else begin
		$display("^__^");

	end

	$fclose(fp_w);

	#(`CYCLE*3);
	$finish;
end


endmodule


