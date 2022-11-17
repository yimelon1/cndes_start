// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.10.20
// Ver      : 3.0
// Func     : FSM with instruction get testbench, every state need 10 cycle to done
// 			and test for start instruction on different cycle 
// ============================================================================


// `define VIVA
`define End_CYCLE  5000      // Modify cycle times once your design need more cycle times!
`define NI_DELAY  2		// NONIDEAL delay latency

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

`ifdef RTL
	`define KER_PAT_0 "../PAT/wsram_pat_0.dat"
	`define KER_PAT_1 "../PAT/wsram_pat_1.dat"
	`define KER_PAT_2 "../PAT/wsram_pat_2.dat"
	`define KER_PAT_3 "../PAT/wsram_pat_3.dat"
	`define KER_PAT_4 "../PAT/wsram_pat_4.dat"
	`define KER_PAT_5 "../PAT/wsram_pat_5.dat"
	`define KER_PAT_6 "../PAT/wsram_pat_6.dat"
	`define KER_PAT_7 "../PAT/wsram_pat_7.dat"
`endif




module fsm_check_tb();
	

	parameter TBITS = 64;
	parameter TBYTE = 8;

	parameter IFMAP_SIZE   = 173056;
	parameter TB_ISRAM_DEPTH	=	300 ;

	localparam IFMAP_SRAM_ADDBITS = 11       ;
	localparam IFMAP_SRAM_DATA_WIDTH = 64    ;
//----------------------------------------------------
//-----------	main FSM   -------------------------
	localparam MAST_FSM_BITS 	= 3;
	localparam M_IDLE 	= 3'd0;
	localparam LEFT 	= 3'd1;
	localparam BASE 	= 3'd2;
	localparam RIGHT 	= 3'd3;
	localparam FSLD 	= 3'd7;	// First load sram0


	localparam SLAV_FSM_BITS 	= 3;
	localparam S_IDLE 	= 3'd0;
	localparam TOP 		= 3'd1;
	localparam MID 		= 3'd2;
	localparam BOTT 	= 3'd3;
//----------------------------------------------------


	reg [30:0] cycle=0;

	reg  clk;         
	reg  reset;       

	reg sl_top_done 	;
	reg sl_mid_done 	;
	reg sl_bott_done 	;
	reg flag_fsld_end ;
	reg flag_fsld_end_sche ;
	reg flag_base_end ;
	reg instr_start ;
	

	reg flag_firstload_end	;

	wire [ MAST_FSM_BITS -1 : 0 ] fsm_mast_state ;
	wire [ SLAV_FSM_BITS -1 : 0 ] fsm_slav_state ;


	reg [ 10-1 : 0] top_cnt ;
	reg [ 10-1 : 0] mid_cnt ;
	reg [ 10-1 : 0] bott_cnt ;
	reg [ 10-1 : 0] fsld_cnt ;
	reg [ 10-1 : 0] base_cnt0 ; // master state cnt

	localparam TOPCNT = 10 ;	// configurable
	localparam MIDCNT = 10 ;	// configurable
	localparam BOTTCNT = 10 ;	// configurable
	localparam FSLDCNT = 10 ;	// configurable
	localparam BASERUNDS = 5 ;	// configurable




	logic rstn = 1;
	wire [TBITS-1: 0 ]	isif_data_dout			;
	wire [TBYTE-1: 0 ]	isif_strb_dout			;
	wire 				isif_last_dout			;
	wire 				isif_user_dout			;
	wire 				isif_empty_n			;
	wire 				isif_read				;

	reg              S_AXIS_MM2S_TVALID = 0;
	wire             S_AXIS_MM2S_TREADY;
	reg  [TBITS-1:0] S_AXIS_MM2S_TDATA = 0;
	reg  [TBYTE-1:0] S_AXIS_MM2S_TKEEP = 0;
	reg  [1-1:0]     S_AXIS_MM2S_TLAST = 0;


	wire ifstore_empty_n_din	;
	wire ifstore_read_dout		;
	wire ifstore_done		;
	wire ifstore_busy		;
	wire ifstore_start		;

localparam INST_HEAD = 64'hefef123abbeeff22 ;
localparam DATA_HEAD = 64'hefef6543dadaff11 ;
localparam CFG_0 = 64'hffff000000000000 ;
localparam CFG_1 = 64'heeeeeeeeeeeeeeee ;
localparam CFG_2 = 64'heeeeeeeeeeeeeeee ;


wire [ 64-1 : 0 ]	config_param00	;
wire [ 64-1 : 0 ]	config_param01	;
wire [ 64-1 : 0 ]	config_param02	;

wire ds_empty_n		;
wire ds_read		;
logic tb_ctrl_ds_read ;

//---------- pattern declare-----------------
logic tb_memread_done ;
reg    [TBITS-1 : 0]      ifmap        [0:IFMAP_SIZE-1];

logic [63:0] ker_sram_0 [0:2047];
logic [63:0] ker_sram_1 [0:2047];
logic [63:0] ker_sram_2 [0:2047];
logic [63:0] ker_sram_3 [0:2047];
logic [63:0] ker_sram_4 [0:2047];
logic [63:0] ker_sram_5 [0:2047];
logic [63:0] ker_sram_6 [0:2047];
logic [63:0] ker_sram_7 [0:2047];


//--------------------------------------------

	wire [64-1 :0 ] check_ifmaparray0 ;
	wire [64-1 :0 ] check_ifmaparray1 ;
	wire [64-1 :0 ] check_ifmaparray2 ;
	wire [64-1 :0 ] check_ifmaparray3 ;
	wire [64-1 :0 ] check_ifmaparray4 ;
	wire [64-1 :0 ] check_ifmaparray5 ;


integer  iix , i1 , i0 ;

//----------  ker w testbench --------------------
	reg tst_sram_rw;
//----declare KER_SRAM start------ 
//----declare KER SRAM_0---------
    reg tst_cen_kersr_0 ;
    reg tst_wen_kersr_0 ;
    reg [ 11 -1 : 0 ] tst_addr__kersr_0 ;
    reg [ 64 -1 : 0 ] dout_kersr_0 ;
//----declare KER SRAM_1---------
    reg tst_cen_kersr_1 ;
    reg tst_wen_kersr_1 ;
    reg [ 11 -1 : 0 ] tst_addr__kersr_1 ;
    reg [ 64 -1 : 0 ] dout_kersr_1 ;
//----declare KER SRAM_2---------
    reg tst_cen_kersr_2 ;
    reg tst_wen_kersr_2 ;
    reg [ 11 -1 : 0 ] tst_addr__kersr_2 ;
    reg [ 64 -1 : 0 ] dout_kersr_2 ;
//----declare KER SRAM_3---------
    reg tst_cen_kersr_3 ;
    reg tst_wen_kersr_3 ;
    reg [ 11 -1 : 0 ] tst_addr__kersr_3 ;
    reg [ 64 -1 : 0 ] dout_kersr_3 ;
//----declare KER SRAM_4---------
    reg tst_cen_kersr_4 ;
    reg tst_wen_kersr_4 ;
    reg [ 11 -1 : 0 ] tst_addr__kersr_4 ;
    reg [ 64 -1 : 0 ] dout_kersr_4 ;
//----declare KER SRAM_5---------
    reg tst_cen_kersr_5 ;
    reg tst_wen_kersr_5 ;
    reg [ 11 -1 : 0 ] tst_addr__kersr_5 ;
    reg [ 64 -1 : 0 ] dout_kersr_5 ;
//----declare KER SRAM_6---------
    reg tst_cen_kersr_6 ;
    reg tst_wen_kersr_6 ;
    reg [ 11 -1 : 0 ] tst_addr__kersr_6 ;
    reg [ 64 -1 : 0 ] dout_kersr_6 ;
//----declare KER SRAM_7---------
    reg tst_cen_kersr_7 ;
    reg tst_wen_kersr_7 ;
    reg [ 11 -1 : 0 ] tst_addr__kersr_7 ;
    reg [ 64 -1 : 0 ] dout_kersr_7 ;
//----declare KER_SRAM end------ 


	//----------- test kernel store module ------------------------
	logic ker_store_done;
	logic ker_store_busy;
	logic start_ker_store;
	//--------------------------------------------------------------

	// =============================================================================
	// =======		instance 	===================================================
	// =============================================================================
	ker_tset kt001 (
		.clk	(	clk		),
		.reset	(	reset	),

		.ker_store_data_din		(	isif_data_dout	),
		.ker_store_empty_n_din	(	isif_empty_n	),
		.ker_store_read_dout	(	isif_read	),

		.ker_store_done 		(	ker_store_done	),
		.ker_store_busy 		(	ker_store_busy	),
		.start_ker_store		(	start_ker_store	),

	//----------  ker w testbench --------------------
		.tst_sram_rw		(	tst_sram_rw	),
	//----ker write for tb instance start------ 
	//----test KER SRAM_0---------
		.tst_cen_kersr_0 ( tst_cen_kersr_0 ),
		.tst_wen_kersr_0 ( tst_wen_kersr_0 ),
		.tst_addr__kersr_0 ( tst_addr__kersr_0 ),
		.dout_kersr_0 ( dout_kersr_0 ),
	//----test KER SRAM_1---------
		.tst_cen_kersr_1 ( tst_cen_kersr_1 ),
		.tst_wen_kersr_1 ( tst_wen_kersr_1 ),
		.tst_addr__kersr_1 ( tst_addr__kersr_1 ),
		.dout_kersr_1 ( dout_kersr_1 ),
	//----test KER SRAM_2---------
		.tst_cen_kersr_2 ( tst_cen_kersr_2 ),
		.tst_wen_kersr_2 ( tst_wen_kersr_2 ),
		.tst_addr__kersr_2 ( tst_addr__kersr_2 ),
		.dout_kersr_2 ( dout_kersr_2 ),
	//----test KER SRAM_3---------
		.tst_cen_kersr_3 ( tst_cen_kersr_3 ),
		.tst_wen_kersr_3 ( tst_wen_kersr_3 ),
		.tst_addr__kersr_3 ( tst_addr__kersr_3 ),
		.dout_kersr_3 ( dout_kersr_3 ),
	//----test KER SRAM_4---------
		.tst_cen_kersr_4 ( tst_cen_kersr_4 ),
		.tst_wen_kersr_4 ( tst_wen_kersr_4 ),
		.tst_addr__kersr_4 ( tst_addr__kersr_4 ),
		.dout_kersr_4 ( dout_kersr_4 ),
	//----test KER SRAM_5---------
		.tst_cen_kersr_5 ( tst_cen_kersr_5 ),
		.tst_wen_kersr_5 ( tst_wen_kersr_5 ),
		.tst_addr__kersr_5 ( tst_addr__kersr_5 ),
		.dout_kersr_5 ( dout_kersr_5 ),
	//----test KER SRAM_6---------
		.tst_cen_kersr_6 ( tst_cen_kersr_6 ),
		.tst_wen_kersr_6 ( tst_wen_kersr_6 ),
		.tst_addr__kersr_6 ( tst_addr__kersr_6 ),
		.dout_kersr_6 ( dout_kersr_6 ),
	//----test KER SRAM_7---------
		.tst_cen_kersr_7 ( tst_cen_kersr_7 ),
		.tst_wen_kersr_7 ( tst_wen_kersr_7 ),
		.tst_addr__kersr_7 ( tst_addr__kersr_7 ),
		.dout_kersr_7 ( dout_kersr_7 )
	//----ker write for tb instance end------ 

	);


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


	// =============================================================================
	// ================		random function 		================================
	// =============================================================================
	function int unsigned getrand;
		input int unsigned maxvalue ; 
		input int unsigned minvalue ; 
		begin
			getrand = $urandom_range(maxvalue , minvalue);
		end
	endfunction
	//------------- check random ---------------------
	assign check_ifmaparray0	 = getrand(10 , 15) ;
	assign check_ifmaparray1	 = getrand(20 , 50) ;
	assign check_ifmaparray2	 = getrand(20 , 50);
	assign check_ifmaparray3	 = ifmap[ 180 ] ;
	assign check_ifmaparray4	 = ifmap[ 240 ] ;
	assign check_ifmaparray5	 = ifmap[ 560 ] ;
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

	initial begin
		`ifdef RTL
			$fsdbDumpfile("tbker.fsdb");
			$fsdbDumpvars(0,"+mda","+packedmda");		//++
			$fsdbDumpMDA();
		`elsif GATE
			$sdf_annotate(`SDFFILE,top_U);
			$fsdbDumpfile("dla_top_SYN.fsdb");
			$fsdbDumpvars();
		`else 
		`endif
	end

	initial begin // initial pattern and expected result
		wait(reset==1);
		tb_memread_done = 0; 
		//--------- pattern reading start -----------
		$readmemh(`KER_PAT_0, ker_sram_0);
		$readmemh(`KER_PAT_1, ker_sram_1);
		$readmemh(`KER_PAT_2, ker_sram_2);
		$readmemh(`KER_PAT_3, ker_sram_3);
		$readmemh(`KER_PAT_4, ker_sram_4);
		$readmemh(`KER_PAT_5, ker_sram_5);
		$readmemh(`KER_PAT_6, ker_sram_6);
		$readmemh(`KER_PAT_7, ker_sram_7);
		//--------- pattern reading end -----------	
		#1;
		tb_memread_done = 1;

	end


	always @(posedge clk ) begin
		if (reset) begin
			tb_ctrl_ds_read <= 1'd0 ;
		end
		else begin
			tb_ctrl_ds_read <= ds_empty_n ;
		end
		
	end


	// -------------- main FSM testing ------------------------

	// -------------- main FSM testing ------------------------

	//start test gi circuit
	initial begin
		#1;
		reset = 0;
		#( `CYCLE*3 ) ;
		reset = 1;
		//-----------reset signal start ------------------
		S_AXIS_MM2S_TKEEP = 'hff;
		S_AXIS_MM2S_TLAST = 0 ;
		start_ker_store = 0;
		//-----------reset signal end ------------------
		#( `CYCLE*4 + `NI_DELAY ) ;
		reset = 0;
		#( `CYCLE*5 ) ;


		//----- wait mem read --------------
		wait(tb_memread_done) ;
		#( `CYCLE*5 ) ;
		//------- ker type1 store start -----------------
		wait( ker_store_busy==1'd0 );
		tst_sram_rw = 1 ;
		@( posedge clk );
		start_ker_store = 1;
		#( `CYCLE*3 ) ;
		@( posedge clk );
		start_ker_store = 0;

		for( i0 = 0 ; i0 <8 ; i0 = i0 + 1)begin
			@( posedge clk );
				S_AXIS_MM2S_TLAST = 0 ;
				S_AXIS_MM2S_TVALID = 0 ;
			for( i1=0 ; i1<288 ; i1=i1+1 )begin
				@(posedge clk);
					S_AXIS_MM2S_TVALID=1;
					S_AXIS_MM2S_TDATA = ker_sram_0[ i1  ]	;
					if(  i1==(  287   ) )begin
						S_AXIS_MM2S_TLAST = 1 ;
					end
					wait(S_AXIS_MM2S_TREADY);
			end
			@(posedge clk);
				S_AXIS_MM2S_TVALID = 0 ;
				S_AXIS_MM2S_TLAST = 0 ;
				#(getrand(58 , 15)) ;
		end
		
		@(posedge clk);
		tst_sram_rw = 1 ;
		//------- ker type2 store start -----------------
		wait( ker_store_busy==1'd0 );
		tst_sram_rw = 1 ;
		@( posedge clk );
		start_ker_store = 1;
		#( `CYCLE*3 ) ;
		@( posedge clk );
		start_ker_store = 0;
		
		for( i0 = 0 ; i0 <8 ; i0 = i0 + 1)begin
			@( posedge clk );
				S_AXIS_MM2S_TLAST = 0 ;
				S_AXIS_MM2S_TVALID = 0 ;
			for( i1=0 ; i1<288 ; i1=i1+1 )begin
				@(posedge clk);
					S_AXIS_MM2S_TVALID=1;
					S_AXIS_MM2S_TDATA = ker_sram_0[ i1  ]	;
					if(  (i1==287)    && ( i0 == 7 ) )begin
						S_AXIS_MM2S_TLAST = 1 ;
					end
					wait(S_AXIS_MM2S_TREADY);
			end

		end
		
		@(posedge clk);
			S_AXIS_MM2S_TVALID = 0 ;
			S_AXIS_MM2S_TLAST = 0 ;
			#(getrand(58 , 15)) ;
		@(posedge clk);
		tst_sram_rw = 0 ;

		






	end 


endmodule