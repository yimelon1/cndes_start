// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.12.04
// Ver      : 1.0
// Func     : testbench for IF KE BI module read and write 
// 			whether it has last signal or not, it should work at HEAD detection.
// ============================================================================


// `define VIVA
`define End_CYCLE  5000      // Modify cycle times once your design need more cycle times!
`define NI_DELAY  2		// NONIDEAL delay latency
`define AFPOS_DELAY  0.5		// after posedge NONIDEAL delay latency

`ifdef RTL
	`timescale 1ns/100ps
    `define CYCLE 5	// 100MHz  1ns*`CYCLE = 10ns / cycle
`endif
`ifdef GATE
	`timescale 1ns/1ps
    `define CYCLE 3.3
`endif
`ifdef VIVA
	`timescale 1ns/100ps
    `define CYCLE 10	// 100MHz
`endif


//-- pattern path --
`ifdef RTL
	//----input pattern ----
	`define IF_WPAT 		"../../../PAT/2_in.dat"	
	`define KER_WPAT_0	"../../../PAT/w_sr/wsram_pat_0.dat"
	`define KER_WPAT_1	"../../../PAT/w_sr/wsram_pat_1.dat"
	`define KER_WPAT_2	"../../../PAT/w_sr/wsram_pat_2.dat"
	`define KER_WPAT_3	"../../../PAT/w_sr/wsram_pat_3.dat"
	`define KER_WPAT_4	"../../../PAT/w_sr/wsram_pat_4.dat"
	`define KER_WPAT_5	"../../../PAT/w_sr/wsram_pat_5.dat"
	`define KER_WPAT_6	"../../../PAT/w_sr/wsram_pat_6.dat"
	`define KER_WPAT_7	"../../../PAT/w_sr/wsram_pat_7.dat"
	`define BIAS_WPAT	"../../../PAT/2_bias.dat"

	//----gold pattern ----
	`define IFRD_PAT_0	"../../../PAT/512MAC/rdprt_PAT/padtop_if_read/pt_ifm_read0.dat"
	`define IFRD_PAT_1	"../../../PAT/512MAC/rdprt_PAT/padtop_if_read/pt_ifm_read1.dat"
	`define IFRD_PAT_2	"../../../PAT/512MAC/rdprt_PAT/padtop_if_read/pt_ifm_read2.dat"
	`define IFRD_PAT_3	"../../../PAT/512MAC/rdprt_PAT/padtop_if_read/pt_ifm_read3.dat"
	`define IFRD_PAT_4	"../../../PAT/512MAC/rdprt_PAT/padtop_if_read/pt_ifm_read4.dat"
	`define IFRD_PAT_5	"../../../PAT/512MAC/rdprt_PAT/padtop_if_read/pt_ifm_read5.dat"
	`define IFRD_PAT_6	"../../../PAT/512MAC/rdprt_PAT/padtop_if_read/pt_ifm_read6.dat"
	`define IFRD_PAT_7	"../../../PAT/512MAC/rdprt_PAT/padtop_if_read/pt_ifm_read7.dat"

	`define KERD_PAT_0	"../../../PAT/512MAC/rdprt_PAT/padtop_ker_read/pt_ker_read0.dat"
	`define KERD_PAT_1	"../../../PAT/512MAC/rdprt_PAT/padtop_ker_read/pt_ker_read1.dat"
	`define KERD_PAT_2	"../../../PAT/512MAC/rdprt_PAT/padtop_ker_read/pt_ker_read2.dat"
	`define KERD_PAT_3	"../../../PAT/512MAC/rdprt_PAT/padtop_ker_read/pt_ker_read3.dat"
	`define KERD_PAT_4	"../../../PAT/512MAC/rdprt_PAT/padtop_ker_read/pt_ker_read4.dat"
	`define KERD_PAT_5	"../../../PAT/512MAC/rdprt_PAT/padtop_ker_read/pt_ker_read5.dat"
	`define KERD_PAT_6	"../../../PAT/512MAC/rdprt_PAT/padtop_ker_read/pt_ker_read6.dat"
	`define KERD_PAT_7	"../../../PAT/512MAC/rdprt_PAT/padtop_ker_read/pt_ker_read7.dat"

	`define BIRD_PAT_0	"../../../PAT/512MAC/rdprt_PAT/padtop_bia_read/pt_bias_read0.dat"
	`define BIRD_PAT_1	"../../../PAT/512MAC/rdprt_PAT/padtop_bia_read/pt_bias_read1.dat"
	`define BIRD_PAT_2	"../../../PAT/512MAC/rdprt_PAT/padtop_bia_read/pt_bias_read2.dat"
	`define BIRD_PAT_3	"../../../PAT/512MAC/rdprt_PAT/padtop_bia_read/pt_bias_read3.dat"
	`define BIRD_PAT_4	"../../../PAT/512MAC/rdprt_PAT/padtop_bia_read/pt_bias_read4.dat"
	`define BIRD_PAT_5	"../../../PAT/512MAC/rdprt_PAT/padtop_bia_read/pt_bias_read5.dat"
	`define BIRD_PAT_6	"../../../PAT/512MAC/rdprt_PAT/padtop_bia_read/pt_bias_read6.dat"
	`define BIRD_PAT_7	"../../../PAT/512MAC/rdprt_PAT/padtop_bia_read/pt_bias_read7.dat"

`endif


// =============================================================================
// ================				module start				====================
// =============================================================================

module fsm_check_tb();
	
// =============================================================================
// =============	testbench configurable parameter	========================
// =============================================================================
localparam TB_RUN_COL = 16 ;
localparam TB_RUN_CH = 32 ;
localparam TB_RUN_KERSRAM_LENGTH = 288 ;
localparam TB_RUN_BIAS_LENGTH = 64 ;

localparam TB_GPAT_LEN = 512 ;
localparam TB_GPAT_KE_LEN = 512 ;
localparam TB_GPAT_BI_LEN = 512 ;



//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//----	parameter controller (don't move )-------------------
	parameter TBITS = 64	;
	parameter TBYTE = 8		;


localparam ATL_RUN_COL_P2 = TB_RUN_COL+1 ;	// left : TB_RUN_COL+1  , normal:  TB_RUN_COL+2 , right :  TB_RUN_COL+1
localparam ATL_CH = TB_RUN_CH/8  ; // actually channel address
localparam ATL_IFWPAT_LENGTH = 3*(ATL_RUN_COL_P2)*ATL_CH -1   ; // actually ifmap pattern length , +2 is for 3x3 compute
//------------------------------------------------------------------------------


localparam INST_HEAD = 64'hefef123abbeeff22 ;
localparam DATA_HEAD = 64'hefef6543dadaff11 ;
localparam CFG_0 = 64'hffff000000000000 ;
localparam CFG_1 = 64'heeeeeeeeeeeeeeee ;
localparam CFG_2 = 64'heeeeeeeeeeeeeeee ;



//--------------------------------------------

// =============================================================================
// ================				necessary declare			====================
// =============================================================================


	//---------- clk & reset declare-----------------
	reg [30:0] cycle=0;
	reg  clk;         
	reg  reset;       
	logic rstn = 1;


	//---------- test pattern declare-----------------
	logic tb_memread_done ;
	reg [64-1:0] ifw_array 		[0: 208*208*4 ];
	reg [64-1:0] ifmap_w_data 		[0: ATL_IFWPAT_LENGTH-1 ];
	reg [64-1:0] kerw_array_0		[0:511];
	reg [64-1:0] kerw_array_1		[0:511];
	reg [64-1:0] kerw_array_2		[0:511];
	reg [64-1:0] kerw_array_3		[0:511];
	reg [64-1:0] kerw_array_4		[0:511];
	reg [64-1:0] kerw_array_5		[0:511];
	reg [64-1:0] kerw_array_6		[0:511];
	reg [64-1:0] kerw_array_7		[0:511];
	reg [32-1:0] biasw_array	[0:256];
	//---------- goldmap mem pattern declare-----------------
	reg [64-1:0] g_if_0 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_if_1 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_if_2 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_if_3 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_if_4 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_if_5 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_if_6 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_if_7 [ 0: TB_GPAT_LEN-1 ];

	reg [64-1:0] g_ke_0 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_ke_1 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_ke_2 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_ke_3 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_ke_4 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_ke_5 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_ke_6 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] g_ke_7 [ 0: TB_GPAT_LEN-1 ];

	reg [32-1:0] g_bi_0 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] g_bi_1 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] g_bi_2 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] g_bi_3 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] g_bi_4 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] g_bi_5 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] g_bi_6 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] g_bi_7 [ 0: TB_GPAT_LEN-1 ];

	//---------- design under test (DUT) output declare-----------------
	reg dutot_done =0;		// DUT output done we can compare data with gold pattern
	// DUT output error for compare block 
	reg [10-1:0 ]err_if_0 , err_if_1 ,err_if_2 ,err_if_3 , err_if_4 , err_if_5 , err_if_6 , err_if_7 ;
	reg [10-1:0 ]err_ke_0 , err_ke_1 ,err_ke_2 ,err_ke_3 , err_ke_4 , err_ke_5 , err_ke_6 , err_ke_7 ;
	reg [10-1:0 ]err_bi_0 , err_bi_1 ,err_bi_2 ,err_bi_3 , err_bi_4 , err_bi_5 , err_bi_6 , err_bi_7 ;

	reg [10-1:0] cnt_pe_0	;	// for output data count
	reg [10-1:0] cnt_pe_1	;
	reg [10-1:0] cnt_pe_2	;
	reg [10-1:0] cnt_pe_3	;
	reg [10-1:0] cnt_pe_4	;
	reg [10-1:0] cnt_pe_5	;
	reg [10-1:0] cnt_pe_6	;
	reg [10-1:0] cnt_pe_7	;

	reg [64-1:0] dut_if_0 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_if_1 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_if_2 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_if_3 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_if_4 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_if_5 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_if_6 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_if_7 [ 0: TB_GPAT_LEN-1 ];

	reg [64-1:0] dut_ke_0 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_ke_1 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_ke_2 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_ke_3 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_ke_4 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_ke_5 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_ke_6 [ 0: TB_GPAT_LEN-1 ];
	reg [64-1:0] dut_ke_7 [ 0: TB_GPAT_LEN-1 ];

	reg [32-1:0] dut_bi_0 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] dut_bi_1 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] dut_bi_2 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] dut_bi_3 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] dut_bi_4 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] dut_bi_5 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] dut_bi_6 [ 0: TB_GPAT_LEN-1 ];
	reg [32-1:0] dut_bi_7 [ 0: TB_GPAT_LEN-1 ];

	//--------------------------------------------

	integer ix0 , ix1 ;	// deal with ifmap length
	integer rsti0 , rsti1 , rsti2 , rsti3 , rsti4 , rsti5 , rsti6 , rsti7 ;// DUT output mem rst integer

// =============================================================================
//----- DUT AXI I/O ----
	logic S_AXIS_MM2S_TVALID	;
	logic S_AXIS_MM2S_TREADY	;
	logic [TBITS-1:0]S_AXIS_MM2S_TDATA	;
	logic [TBYTE-1:0]S_AXIS_MM2S_TKEEP	;
	logic S_AXIS_MM2S_TLAST	;

//----- test flow flag ----
logic tst_fl_sent_ifmap 	= 0 ;
logic tst_fl_sent_kernel 	= 0 ;
logic tst_fl_sent_bias 		= 0 ;

integer  iix , i1 , i0 ;

integer cpi ;

// =============================================================================
// ================		python generate declare			========================
// =============================================================================
//----gen by pre_pe.py ----declare tb top PE connection wire start------ 
wire p_valid_0 ,p_valid_1 ,p_valid_2 ,p_valid_3 ,p_valid_4 ,p_valid_5 ,p_valid_6 ,p_valid_7 ; 
wire p_final_0 ,p_final_1 ,p_final_2 ,p_final_3 ,p_final_4 ,p_final_5 ,p_final_6 ,p_final_7 ; 
wire [64-1:0] p_if_0 ,p_if_1 ,p_if_2 ,p_if_3 ,p_if_4 ,p_if_5 ,p_if_6 ,p_if_7 ; 
wire [64-1:0] p_ke_0 ,p_ke_1 ,p_ke_2 ,p_ke_3 ,p_ke_4 ,p_ke_5 ,p_ke_6 ,p_ke_7 ; 
wire [32-1:0] p_bi_0 ,p_bi_1 ,p_bi_2 ,p_bi_3 ,p_bi_4 ,p_bi_5 ,p_bi_6 ,p_bi_7 ; 
//----declare tb top PE connection wire end------ 


// ============================================================================
// ================			instance DUT		===============================
// ============================================================================

	dla512_top	#(
			.TBITS(TBITS)
		,	.TBYTE(TBYTE)
	)
	tp001(	.clk	(	clk		)
		,	.reset	(	reset	)

		,	.S_AXIS_MM2S_TVALID	(	S_AXIS_MM2S_TVALID	)
		,	.S_AXIS_MM2S_TREADY	(	S_AXIS_MM2S_TREADY	)
		,	.S_AXIS_MM2S_TDATA	(	S_AXIS_MM2S_TDATA	)
		,	.S_AXIS_MM2S_TKEEP	(	S_AXIS_MM2S_TKEEP	)
		,	.S_AXIS_MM2S_TLAST	(	S_AXIS_MM2S_TLAST	)

		// ,	.M_AXIS_S2MM_TVALID	(	M_AXIS_S2MM_TVALID	)
		// ,	.M_AXIS_S2MM_TREADY	(	M_AXIS_S2MM_TREADY	)
		// ,	.M_AXIS_S2MM_TDATA	(	M_AXIS_S2MM_TDATA	)
		// ,	.M_AXIS_S2MM_TKEEP	(	M_AXIS_S2MM_TKEEP	)
		// ,	.M_AXIS_S2MM_TLAST	(	M_AXIS_S2MM_TLAST	)


		//----tb top instance start------ 
		,	.valid_to_pe_0 ( p_valid_0 ),	.final_to_pe_0 ( p_final_0 ),	.dout_if_0 ( p_if_0 ),	.dout_ke_0 ( p_ke_0 ),	.dout_bi_0 ( p_bi_0 )//-- PE block -0-
		,	.valid_to_pe_1 ( p_valid_1 ),	.final_to_pe_1 ( p_final_1 ),	.dout_if_1 ( p_if_1 ),	.dout_ke_1 ( p_ke_1 ),	.dout_bi_1 ( p_bi_1 )//-- PE block -1-
		,	.valid_to_pe_2 ( p_valid_2 ),	.final_to_pe_2 ( p_final_2 ),	.dout_if_2 ( p_if_2 ),	.dout_ke_2 ( p_ke_2 ),	.dout_bi_2 ( p_bi_2 )//-- PE block -2-
		,	.valid_to_pe_3 ( p_valid_3 ),	.final_to_pe_3 ( p_final_3 ),	.dout_if_3 ( p_if_3 ),	.dout_ke_3 ( p_ke_3 ),	.dout_bi_3 ( p_bi_3 )//-- PE block -3-
		,	.valid_to_pe_4 ( p_valid_4 ),	.final_to_pe_4 ( p_final_4 ),	.dout_if_4 ( p_if_4 ),	.dout_ke_4 ( p_ke_4 ),	.dout_bi_4 ( p_bi_4 )//-- PE block -4-
		,	.valid_to_pe_5 ( p_valid_5 ),	.final_to_pe_5 ( p_final_5 ),	.dout_if_5 ( p_if_5 ),	.dout_ke_5 ( p_ke_5 ),	.dout_bi_5 ( p_bi_5 )//-- PE block -5-
		,	.valid_to_pe_6 ( p_valid_6 ),	.final_to_pe_6 ( p_final_6 ),	.dout_if_6 ( p_if_6 ),	.dout_ke_6 ( p_ke_6 ),	.dout_bi_6 ( p_bi_6 )//-- PE block -6-
		,	.valid_to_pe_7 ( p_valid_7 ),	.final_to_pe_7 ( p_final_7 ),	.dout_if_7 ( p_if_7 ),	.dout_ke_7 ( p_ke_7 ),	.dout_bi_7 ( p_bi_7 )//-- PE block -7-
		//----tb top instance end------ 


	);




// =============================================================================
// ================		clock generate & end cycle		========================
// =============================================================================

	initial clk = 1;

	always begin #(`CYCLE / 2) clk = ~clk; end
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
// =============================================================
// =============================================================================
// ================		fsdb dump +mda+packedmda		========================
// ================		Kernel data load readmemh		========================
// =============================================================================

	initial begin
		`ifdef RTL
			$fsdbDumpfile("tb_sim000.fsdb");
			$fsdbDumpvars(0,"+mda","+packedmda");		//++
			$fsdbDumpMDA();
		`elsif GATE
			$sdf_annotate(`SDFFILE,bias_top);	//  $sdf_annotate("sdf_file"[,module_instance][,"sdf_configfile"][,"sdf_logfile"][,"mtm_spec"][,"scale_factors"][,"scale_type"]);
			$fsdbDumpfile("dla_top_SYN.fsdb");	
			$fsdbDumpvars();
		`else 
		`endif
	end


// =============================================================================
// ================		initial pattern and expected result		================
// =============================================================================
	initial begin 
		wait(reset==1);
		tb_memread_done = 0; 
		//--------- pattern reading start -----------

		$readmemh(`IF_WPAT 		,	ifw_array 		);

		$readmemh(`KER_WPAT_0	,	kerw_array_0		);
		$readmemh(`KER_WPAT_1	,	kerw_array_1		);
		$readmemh(`KER_WPAT_2	,	kerw_array_2		);
		$readmemh(`KER_WPAT_3	,	kerw_array_3		);
		$readmemh(`KER_WPAT_4	,	kerw_array_4		);
		$readmemh(`KER_WPAT_5	,	kerw_array_5		);
		$readmemh(`KER_WPAT_6	,	kerw_array_6		);
		$readmemh(`KER_WPAT_7	,	kerw_array_7		);

		$readmemh(`BIAS_WPAT	,	biasw_array		);

		// $readmemh(`IFRD_PAT_0, g_if_0 );
		// $readmemh(`IFRD_PAT_1, g_if_1 );
		// $readmemh(`IFRD_PAT_2, g_if_2 );
		// $readmemh(`IFRD_PAT_3, g_if_3 );
		// $readmemh(`IFRD_PAT_4, g_if_4 );
		// $readmemh(`IFRD_PAT_5, g_if_5 );
		// $readmemh(`IFRD_PAT_6, g_if_6 );
		// $readmemh(`IFRD_PAT_7, g_if_7 );

		// $readmemh(`KERD_PAT_0, g_ke_0 );
		// $readmemh(`KERD_PAT_1, g_ke_1 );
		// $readmemh(`KERD_PAT_2, g_ke_2 );
		// $readmemh(`KERD_PAT_3, g_ke_3 );
		// $readmemh(`KERD_PAT_4, g_ke_4 );
		// $readmemh(`KERD_PAT_5, g_ke_5 );
		// $readmemh(`KERD_PAT_6, g_ke_6 );
		// $readmemh(`KERD_PAT_7, g_ke_7 );

		// $readmemh(`BIRD_PAT_0, g_bi_0 );
		// $readmemh(`BIRD_PAT_1, g_bi_1 );
		// $readmemh(`BIRD_PAT_2, g_bi_2 );
		// $readmemh(`BIRD_PAT_3, g_bi_3 );
		// $readmemh(`BIRD_PAT_4, g_bi_4 );
		// $readmemh(`BIRD_PAT_5, g_bi_5 );
		// $readmemh(`BIRD_PAT_6, g_bi_6 );
		// $readmemh(`BIRD_PAT_7, g_bi_7 );


		for (ix0 = 0; ix0 < 3 ; ix0 = ix0 +1	) begin		// 3row index
			for ( ix1 = 0 ; ix1 < TB_RUN_COL*ATL_CH ; ix1 = ix1 +1 ) begin	//each row pattern length
				ifmap_w_data [ ix0*TB_RUN_COL*ATL_CH   + ix1 ]= ifw_array[ ix0*208*ATL_CH   + ix1  ]	;
				
			end
		end	
		//--------- pattern reading end -----------

		#1;
		tb_memread_done = 1;

	end

// =============================================================




// =============================================================================
// =======		testing control 	============================================
// =============================================================================

	//start test gi circuit
	initial begin
		#1;
		reset = 0;
		#( `CYCLE*3 ) ;
		reset = 1;
		//-----------reset signal start ------------------
		S_AXIS_MM2S_TKEEP = 'hff;
		S_AXIS_MM2S_TLAST = 0 ;
		dutot_done =0 ;	
		//-----------reset signal end ------------------
		#( `CYCLE*4 + `NI_DELAY ) ;
		reset = 0;
		#( `CYCLE*5 ) ;

		//----- instruction --------------
		for( iix = 0 ; iix <1 ; iix=iix+1 )begin
			@( posedge clk );
			S_AXIS_MM2S_TVALID = 1 ;
			S_AXIS_MM2S_TDATA	= INST_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
		end
		@( posedge clk );
			S_AXIS_MM2S_TVALID = 1 ;
			S_AXIS_MM2S_TDATA	= INST_HEAD ;
			S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		@( posedge clk );
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;

		@( posedge clk );
			S_AXIS_MM2S_TVALID = 1 ;
			S_AXIS_MM2S_TDATA	= CFG_0 ;
			wait(S_AXIS_MM2S_TREADY);
		@( posedge clk );
			S_AXIS_MM2S_TVALID = 1 ;
			S_AXIS_MM2S_TDATA	= CFG_1 ;
			wait(S_AXIS_MM2S_TREADY);
		@( posedge clk );
			S_AXIS_MM2S_TVALID = 1 ;
			S_AXIS_MM2S_TDATA	= CFG_2 ;
			S_AXIS_MM2S_TLAST = 1 ;
			wait(S_AXIS_MM2S_TREADY);
		@( posedge clk );
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
			iix = 0 ;

		//----- instruction --------------

		wait(tb_memread_done) ;
		#( `CYCLE*5 ) ;
		


		tst_fl_sent_kernel 	= 1 ;
		i1=0 ;
		//------------------------------------------------
		//---- first load -- sending kernel data ----
		//------------ now send kernel sram 0 data -----
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			for ( i1=0 ; i1<TB_RUN_KERSRAM_LENGTH ; i1=i1+1 )begin	// each kernel sram need 288 address data
				@(posedge clk );
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = kerw_array_0[ i1  ]	;
				if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				wait(S_AXIS_MM2S_TREADY);
			end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		//------------------------------------------------

		//------------ now send kernel sram 1 data -----
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			for ( i1=0 ; i1<TB_RUN_KERSRAM_LENGTH ; i1=i1+1 )begin	// each kernel sram need 288 address data
				@(posedge clk );
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = kerw_array_1[ i1  ]	;
				if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				wait(S_AXIS_MM2S_TREADY);
			end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		//------------------------------------------------
		
		//------------ now send kernel sram 2 data -----
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			for ( i1=0 ; i1<TB_RUN_KERSRAM_LENGTH ; i1=i1+1 )begin	// each kernel sram need 288 address data
				@(posedge clk );
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = kerw_array_2[ i1  ]	;
				if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				wait(S_AXIS_MM2S_TREADY);
			end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		//------------------------------------------------
		//------------ now send kernel sram 3 data -----
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			for ( i1=0 ; i1<TB_RUN_KERSRAM_LENGTH ; i1=i1+1 )begin	// each kernel sram need 288 address data
				@(posedge clk );
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = kerw_array_3[ i1  ]	;
				if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				wait(S_AXIS_MM2S_TREADY);
			end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		//------------------------------------------------
		//------------ now send kernel sram 4 data -----
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			for ( i1=0 ; i1<TB_RUN_KERSRAM_LENGTH ; i1=i1+1 )begin	// each kernel sram need 288 address data
				@(posedge clk );
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = kerw_array_4[ i1  ]	;
				if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				wait(S_AXIS_MM2S_TREADY);
			end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		//------------------------------------------------
		//------------ now send kernel sram 5 data -----
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			for ( i1=0 ; i1<TB_RUN_KERSRAM_LENGTH ; i1=i1+1 )begin	// each kernel sram need 288 address data
				@(posedge clk );
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = kerw_array_5[ i1  ]	;
				if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				wait(S_AXIS_MM2S_TREADY);
			end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		//------------------------------------------------

	
		//------------ now send kernel sram 6 data -----
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			while ( i1<TB_RUN_KERSRAM_LENGTH ) begin
				wait(S_AXIS_MM2S_TREADY);
				@(posedge clk ); #1;
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = kerw_array_6[ i1  ]	;
				if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				i1=i1+1;
			end

			// for ( i1=0 ; i1<TB_RUN_KERSRAM_LENGTH ; i1=i1+1 )begin	// each kernel sram need 288 address data
			// 	@(posedge clk );
			// 	S_AXIS_MM2S_TVALID	=	1	;
			// 	S_AXIS_MM2S_TDATA = kerw_array_6[ i1  ]	;
			// 	if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
			// 		S_AXIS_MM2S_TLAST = 1; 
			// 	end
			// 	wait(S_AXIS_MM2S_TREADY);
			// end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		//------------------------------------------------

		//------------ now send kernel sram 7 data -----
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			while ( i1<TB_RUN_KERSRAM_LENGTH ) begin
				wait(S_AXIS_MM2S_TREADY);
				@(posedge clk ); #1;
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = kerw_array_7[ i1  ]	;
				if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				i1=i1+1;
			end

			// for ( i1=0 ; i1<TB_RUN_KERSRAM_LENGTH ; i1=i1+1 )begin	// each kernel sram need 288 address data
			// 	@(posedge clk );
			// 	S_AXIS_MM2S_TVALID	=	1	;
			// 	S_AXIS_MM2S_TDATA = kerw_array_7[ i1  ]	;
			// 	if( i1 == TB_RUN_KERSRAM_LENGTH-1 )begin
			// 		S_AXIS_MM2S_TLAST = 1; 
			// 	end
			// 	wait(S_AXIS_MM2S_TREADY);
			// end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		//------------------------------------------------
		tst_fl_sent_kernel 	= 0 ;

		
		//------------------------------------------------
		//---- first load -- sending bias data ----
		//------------ now send bias sram data -----
		tst_fl_sent_bias = 1 ;
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			for ( i1=0 ; i1<TB_RUN_BIAS_LENGTH ; i1=i1+1 )begin	
				@(posedge clk );
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = biasw_array[ i1  ]	;
				if( i1 == TB_RUN_BIAS_LENGTH-1 )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				wait(S_AXIS_MM2S_TREADY);
			end
			@(posedge clk ) ;
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i1=0 ;
		tst_fl_sent_bias = 0 ;
		//------------------------------------------------




		//----- after first load data we going to send ifmap data  --------------
		tst_fl_sent_ifmap 	= 1 ;
		i0 = 0 ;
		for ( i1=0 ; i1<3 ; i1=i1+1 )begin	// 3row data
			//---- DATA HEAD ----
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TVALID = 1 ;	S_AXIS_MM2S_TDATA	= DATA_HEAD ;	
			S_AXIS_MM2S_TLAST	= 1;	// last signal 
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );	S_AXIS_MM2S_TLAST = 0 ;		S_AXIS_MM2S_TVALID = 0 ;
			//---- DATA HEAD end---------------------
			while ( i0< ATL_RUN_COL_P2*ATL_CH ) begin
				wait(S_AXIS_MM2S_TREADY);
				@(posedge clk ); #1;
				S_AXIS_MM2S_TVALID	=	1	;
				S_AXIS_MM2S_TDATA = ifmap_w_data[ i0  ]	;
				if( i0 == ATL_RUN_COL_P2*ATL_CH - 1  )begin
					S_AXIS_MM2S_TLAST = 1; 
				end
				i0=i0+1;
			end

			@(posedge clk);
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				i0 = 0 ;
		end
		tst_fl_sent_ifmap 	= 0 ;



		#( `CYCLE*5 ) ;
		wait( cnt_pe_7 >= TB_GPAT_LEN-2 ) ;
		#( `CYCLE*5 ) ;




		
		@(posedge clk); #1;
		dutot_done = 1 ;	// output done now for compare 
		//--------------------------------------------------------------------------

	end 


// =============================================================================
// ===============		compare data block		================================
// =============================================================================
	initial begin
		#1;
		wait( reset ) ;
		#( `CYCLE*5 ) ;
		wait( dutot_done ) ;	// wait DUT output data all done
		for( cpi =0 ; cpi< TB_GPAT_LEN ; cpi = cpi +1 )begin
			//----- compare part --------------
			if( dut_if_0 [ cpi ] !== g_if_0[ cpi ] ) err_if_0 = err_if_0 + 1 ;
			if( dut_ke_0 [ cpi ] !== g_ke_0[ cpi ] ) err_ke_0 = err_ke_0 + 1 ;
			if( dut_bi_0 [ cpi ] !== g_bi_0[ cpi ] ) err_bi_0 = err_bi_0 + 1 ;
			//--------------------------------------------
			//--------------------------------------------
			if( dut_if_7 [ cpi ] !== g_if_7[ cpi ] ) err_if_7 = err_if_7 + 1 ;
			if( dut_ke_7 [ cpi ] !== g_ke_7[ cpi ] ) err_ke_7 = err_ke_7 + 1 ;
			if( dut_bi_7 [ cpi ] !== g_bi_7[ cpi ] ) err_bi_7 = err_bi_7 + 1 ;
			//--------------------------------------------

			// //-------------------------------------------
			// if( dut_if_0 [ cpi ] !== g_if_0[ cpi ] ) err_if_0 = err_if_0 + 1 ;
			// if( dut_ke_0 [ cpi ] !== g_ke_0[ cpi ] ) err_ke_0 = err_ke_0 + 1 ;
			// if( dut_bi_0 [ cpi ] !== g_bi_0[ cpi ] ) err_bi_0 = err_bi_0 + 1 ;
			// //--------------------------------------------
			// if( dut_if_1 [ cpi ] !== g_if_1[ cpi ] ) err_if_1 = err_if_1 + 1 ;
			// if( dut_ke_1 [ cpi ] !== g_ke_1[ cpi ] ) err_ke_1 = err_ke_1 + 1 ;
			// if( dut_bi_1 [ cpi ] !== g_bi_1[ cpi ] ) err_bi_1 = err_bi_1 + 1 ;
			// //--------------------------------------------
			// if( dut_if_2 [ cpi ] !== g_if_2[ cpi ] ) err_if_2 = err_if_2 + 1 ;
			// if( dut_ke_2 [ cpi ] !== g_ke_2[ cpi ] ) err_ke_2 = err_ke_2 + 1 ;
			// if( dut_bi_2 [ cpi ] !== g_bi_2[ cpi ] ) err_bi_2 = err_bi_2 + 1 ;
			// //--------------------------------------------
			// if( dut_if_3 [ cpi ] !== g_if_3[ cpi ] ) err_if_3 = err_if_3 + 1 ;
			// if( dut_ke_3 [ cpi ] !== g_ke_3[ cpi ] ) err_ke_3 = err_ke_3 + 1 ;
			// if( dut_bi_3 [ cpi ] !== g_bi_3[ cpi ] ) err_bi_3 = err_bi_3 + 1 ;
			// //--------------------------------------------
			// if( dut_if_4 [ cpi ] !== g_if_4[ cpi ] ) err_if_4 = err_if_4 + 1 ;
			// if( dut_ke_4 [ cpi ] !== g_ke_4[ cpi ] ) err_ke_4 = err_ke_4 + 1 ;
			// if( dut_bi_4 [ cpi ] !== g_bi_4[ cpi ] ) err_bi_4 = err_bi_4 + 1 ;
			// //--------------------------------------------
			// if( dut_if_5 [ cpi ] !== g_if_5[ cpi ] ) err_if_5 = err_if_5 + 1 ;
			// if( dut_ke_5 [ cpi ] !== g_ke_5[ cpi ] ) err_ke_5 = err_ke_5 + 1 ;
			// if( dut_bi_5 [ cpi ] !== g_bi_5[ cpi ] ) err_bi_5 = err_bi_5 + 1 ;
			// //--------------------------------------------
			// if( dut_if_6 [ cpi ] !== g_if_6[ cpi ] ) err_if_6 = err_if_6 + 1 ;
			// if( dut_ke_6 [ cpi ] !== g_ke_6[ cpi ] ) err_ke_6 = err_ke_6 + 1 ;
			// if( dut_bi_6 [ cpi ] !== g_bi_6[ cpi ] ) err_bi_6 = err_bi_6 + 1 ;
			// //--------------------------------------------
			// if( dut_if_7 [ cpi ] !== g_if_7[ cpi ] ) err_if_7 = err_if_7 + 1 ;
			// if( dut_ke_7 [ cpi ] !== g_ke_7[ cpi ] ) err_ke_7 = err_ke_7 + 1 ;
			// if( dut_bi_7 [ cpi ] !== g_bi_7[ cpi ] ) err_bi_7 = err_bi_7 + 1 ;
			// //--------------------------------------------
		end

		//----display the compare result on terminal ----
		$display("********************************************************************");
		$display("**  ---- the compare result -----                                 **");
		$display("**  err_if_0 = %3d                                                **", err_if_0 );
		$display("**  err_ke_0 = %3d                                                **", err_ke_0 );
		$display("**  err_bi_0 = %3d                                                **", err_bi_0 );
		$display("**    ------------------------------                              **");
		$display("**  err_if_7 = %3d                                                **", err_if_7 );
		$display("**  err_ke_7 = %3d                                                **", err_ke_7 );
		$display("**  err_bi_7 = %3d                                                **", err_bi_7 );
		$display("**    ------------------------------                              **");
		$display("**  please check the error number ,Simulation STOP at cycle %d **",cycle);
		$display("**  If needed, You can increase End_CYCLE value in tp.v           **");
		$display("********************************************************************");

		$finish;


	end
//--------------------------------------------------------------------------


// =============================================================================
// =======		to get the output data from DUT 	============================
// =============================================================================
	// always @(posedge clk ) begin
	// 	if (reset) begin
	// 		cnt_pe_0 <= 0 ;
	// 		for ( rsti0 = 0 ; rsti0 < TB_GPAT_LEN ; rsti0 = rsti0 + 1 ) begin
	// 			dut_if_0 [ rsti0 ]<= 64'd0 ;
	// 			dut_ke_0 [ rsti0 ]<= 64'd0 ;
	// 			dut_bi_0 [ rsti0 ]<= 32'd0 ;
	// 		end
	// 	end
	// 	else begin
	// 		if(p_valid_0)begin
	// 			dut_if_0 [cnt_pe_0]<= p_if_0 ;
	// 			dut_ke_0 [cnt_pe_0]<= p_ke_0 ;
	// 			dut_bi_0 [cnt_pe_0]<= p_bi_0 ;
	// 			cnt_pe_0 <= cnt_pe_0 +1 ;
	// 		end
	// 		else begin
	// 			dut_if_0 [cnt_pe_0]<= dut_if_0 [cnt_pe_0] ;
	// 			dut_ke_0 [cnt_pe_0]<= dut_ke_0 [cnt_pe_0] ;
	// 			dut_bi_0 [cnt_pe_0]<= dut_bi_0 [cnt_pe_0] ;
	// 			cnt_pe_0 <= cnt_pe_0 ;
	// 		end
	// 	end
	// end
		
	//----gen by tbpre_pe.py ----tb DUT output always block start------ 
	//-- PE block -0-
	always @(posedge clk ) begin 
		if (reset) begin 
			cnt_pe_0 <= 0 ;
			for ( rsti0 = 0 ; rsti0 < TB_GPAT_LEN ; rsti0 = rsti0 + 1 ) begin 
				dut_if_0 [ rsti0 ]<= 64'd0 ;
				dut_ke_0 [ rsti0 ]<= 64'd0 ;
				dut_bi_0 [ rsti0 ]<= 32'd0 ;
			end 
		end 
		else begin 
			if(p_valid_0 )begin 
				dut_if_0 [ cnt_pe_0 ]<= p_if_0 ;
				dut_ke_0 [ cnt_pe_0 ]<= p_ke_0 ;
				dut_bi_0 [ cnt_pe_0 ]<= p_bi_0 ;
				cnt_pe_0 <= cnt_pe_0 +1 ;
			end 
			else begin 
				dut_if_0 [ cnt_pe_0 ]<= dut_if_0 [ cnt_pe_0 ] ;
				dut_ke_0 [ cnt_pe_0 ]<= dut_ke_0 [ cnt_pe_0 ] ;
				dut_bi_0 [ cnt_pe_0 ]<= dut_bi_0 [ cnt_pe_0 ] ;
				cnt_pe_0 <= cnt_pe_0  ;
			end 
		end 
	end 
	//-- PE block -1-
	always @(posedge clk ) begin 
		if (reset) begin 
			cnt_pe_1 <= 0 ;
			for ( rsti1 = 0 ; rsti1 < TB_GPAT_LEN ; rsti1 = rsti1 + 1 ) begin 
				dut_if_1 [ rsti1 ]<= 64'd0 ;
				dut_ke_1 [ rsti1 ]<= 64'd0 ;
				dut_bi_1 [ rsti1 ]<= 32'd0 ;
			end 
		end 
		else begin 
			if(p_valid_1 )begin 
				dut_if_1 [ cnt_pe_1 ]<= p_if_1 ;
				dut_ke_1 [ cnt_pe_1 ]<= p_ke_1 ;
				dut_bi_1 [ cnt_pe_1 ]<= p_bi_1 ;
				cnt_pe_1 <= cnt_pe_1 +1 ;
			end 
			else begin 
				dut_if_1 [ cnt_pe_1 ]<= dut_if_1 [ cnt_pe_1 ] ;
				dut_ke_1 [ cnt_pe_1 ]<= dut_ke_1 [ cnt_pe_1 ] ;
				dut_bi_1 [ cnt_pe_1 ]<= dut_bi_1 [ cnt_pe_1 ] ;
				cnt_pe_1 <= cnt_pe_1  ;
			end 
		end 
	end 
	//-- PE block -2-
	always @(posedge clk ) begin 
		if (reset) begin 
			cnt_pe_2 <= 0 ;
			for ( rsti2 = 0 ; rsti2 < TB_GPAT_LEN ; rsti2 = rsti2 + 1 ) begin 
				dut_if_2 [ rsti2 ]<= 64'd0 ;
				dut_ke_2 [ rsti2 ]<= 64'd0 ;
				dut_bi_2 [ rsti2 ]<= 32'd0 ;
			end 
		end 
		else begin 
			if(p_valid_2 )begin 
				dut_if_2 [ cnt_pe_2 ]<= p_if_2 ;
				dut_ke_2 [ cnt_pe_2 ]<= p_ke_2 ;
				dut_bi_2 [ cnt_pe_2 ]<= p_bi_2 ;
				cnt_pe_2 <= cnt_pe_2 +1 ;
			end 
			else begin 
				dut_if_2 [ cnt_pe_2 ]<= dut_if_2 [ cnt_pe_2 ] ;
				dut_ke_2 [ cnt_pe_2 ]<= dut_ke_2 [ cnt_pe_2 ] ;
				dut_bi_2 [ cnt_pe_2 ]<= dut_bi_2 [ cnt_pe_2 ] ;
				cnt_pe_2 <= cnt_pe_2  ;
			end 
		end 
	end 
	//-- PE block -3-
	always @(posedge clk ) begin 
		if (reset) begin 
			cnt_pe_3 <= 0 ;
			for ( rsti3 = 0 ; rsti3 < TB_GPAT_LEN ; rsti3 = rsti3 + 1 ) begin 
				dut_if_3 [ rsti3 ]<= 64'd0 ;
				dut_ke_3 [ rsti3 ]<= 64'd0 ;
				dut_bi_3 [ rsti3 ]<= 32'd0 ;
			end 
		end 
		else begin 
			if(p_valid_3 )begin 
				dut_if_3 [ cnt_pe_3 ]<= p_if_3 ;
				dut_ke_3 [ cnt_pe_3 ]<= p_ke_3 ;
				dut_bi_3 [ cnt_pe_3 ]<= p_bi_3 ;
				cnt_pe_3 <= cnt_pe_3 +1 ;
			end 
			else begin 
				dut_if_3 [ cnt_pe_3 ]<= dut_if_3 [ cnt_pe_3 ] ;
				dut_ke_3 [ cnt_pe_3 ]<= dut_ke_3 [ cnt_pe_3 ] ;
				dut_bi_3 [ cnt_pe_3 ]<= dut_bi_3 [ cnt_pe_3 ] ;
				cnt_pe_3 <= cnt_pe_3  ;
			end 
		end 
	end 
	//-- PE block -4-
	always @(posedge clk ) begin 
		if (reset) begin 
			cnt_pe_4 <= 0 ;
			for ( rsti4 = 0 ; rsti4 < TB_GPAT_LEN ; rsti4 = rsti4 + 1 ) begin 
				dut_if_4 [ rsti4 ]<= 64'd0 ;
				dut_ke_4 [ rsti4 ]<= 64'd0 ;
				dut_bi_4 [ rsti4 ]<= 32'd0 ;
			end 
		end 
		else begin 
			if(p_valid_4 )begin 
				dut_if_4 [ cnt_pe_4 ]<= p_if_4 ;
				dut_ke_4 [ cnt_pe_4 ]<= p_ke_4 ;
				dut_bi_4 [ cnt_pe_4 ]<= p_bi_4 ;
				cnt_pe_4 <= cnt_pe_4 +1 ;
			end 
			else begin 
				dut_if_4 [ cnt_pe_4 ]<= dut_if_4 [ cnt_pe_4 ] ;
				dut_ke_4 [ cnt_pe_4 ]<= dut_ke_4 [ cnt_pe_4 ] ;
				dut_bi_4 [ cnt_pe_4 ]<= dut_bi_4 [ cnt_pe_4 ] ;
				cnt_pe_4 <= cnt_pe_4  ;
			end 
		end 
	end 
	//-- PE block -5-
	always @(posedge clk ) begin 
		if (reset) begin 
			cnt_pe_5 <= 0 ;
			for ( rsti5 = 0 ; rsti5 < TB_GPAT_LEN ; rsti5 = rsti5 + 1 ) begin 
				dut_if_5 [ rsti5 ]<= 64'd0 ;
				dut_ke_5 [ rsti5 ]<= 64'd0 ;
				dut_bi_5 [ rsti5 ]<= 32'd0 ;
			end 
		end 
		else begin 
			if(p_valid_5 )begin 
				dut_if_5 [ cnt_pe_5 ]<= p_if_5 ;
				dut_ke_5 [ cnt_pe_5 ]<= p_ke_5 ;
				dut_bi_5 [ cnt_pe_5 ]<= p_bi_5 ;
				cnt_pe_5 <= cnt_pe_5 +1 ;
			end 
			else begin 
				dut_if_5 [ cnt_pe_5 ]<= dut_if_5 [ cnt_pe_5 ] ;
				dut_ke_5 [ cnt_pe_5 ]<= dut_ke_5 [ cnt_pe_5 ] ;
				dut_bi_5 [ cnt_pe_5 ]<= dut_bi_5 [ cnt_pe_5 ] ;
				cnt_pe_5 <= cnt_pe_5  ;
			end 
		end 
	end 
	//-- PE block -6-
	always @(posedge clk ) begin 
		if (reset) begin 
			cnt_pe_6 <= 0 ;
			for ( rsti6 = 0 ; rsti6 < TB_GPAT_LEN ; rsti6 = rsti6 + 1 ) begin 
				dut_if_6 [ rsti6 ]<= 64'd0 ;
				dut_ke_6 [ rsti6 ]<= 64'd0 ;
				dut_bi_6 [ rsti6 ]<= 32'd0 ;
			end 
		end 
		else begin 
			if(p_valid_6 )begin 
				dut_if_6 [ cnt_pe_6 ]<= p_if_6 ;
				dut_ke_6 [ cnt_pe_6 ]<= p_ke_6 ;
				dut_bi_6 [ cnt_pe_6 ]<= p_bi_6 ;
				cnt_pe_6 <= cnt_pe_6 +1 ;
			end 
			else begin 
				dut_if_6 [ cnt_pe_6 ]<= dut_if_6 [ cnt_pe_6 ] ;
				dut_ke_6 [ cnt_pe_6 ]<= dut_ke_6 [ cnt_pe_6 ] ;
				dut_bi_6 [ cnt_pe_6 ]<= dut_bi_6 [ cnt_pe_6 ] ;
				cnt_pe_6 <= cnt_pe_6  ;
			end 
		end 
	end 
	//-- PE block -7-
	always @(posedge clk ) begin 
		if (reset) begin 
			cnt_pe_7 <= 0 ;
			for ( rsti7 = 0 ; rsti7 < TB_GPAT_LEN ; rsti7 = rsti7 + 1 ) begin 
				dut_if_7 [ rsti7 ]<= 64'd0 ;
				dut_ke_7 [ rsti7 ]<= 64'd0 ;
				dut_bi_7 [ rsti7 ]<= 32'd0 ;
			end 
		end 
		else begin 
			if(p_valid_7 )begin 
				dut_if_7 [ cnt_pe_7 ]<= p_if_7 ;
				dut_ke_7 [ cnt_pe_7 ]<= p_ke_7 ;
				dut_bi_7 [ cnt_pe_7 ]<= p_bi_7 ;
				cnt_pe_7 <= cnt_pe_7 +1 ;
			end 
			else begin 
				dut_if_7 [ cnt_pe_7 ]<= dut_if_7 [ cnt_pe_7 ] ;
				dut_ke_7 [ cnt_pe_7 ]<= dut_ke_7 [ cnt_pe_7 ] ;
				dut_bi_7 [ cnt_pe_7 ]<= dut_bi_7 [ cnt_pe_7 ] ;
				cnt_pe_7 <= cnt_pe_7  ;
			end 
		end 
	end 
	//----tb DUT output always block end------ 
	//---------- 

// =============================================================================



endmodule