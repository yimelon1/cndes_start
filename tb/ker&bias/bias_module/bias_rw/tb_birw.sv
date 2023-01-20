// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.10.20
// Ver      : 3.0
// Func     : FSM with instruction get testbench, every state need 10 cycle to done
// 			and test for start instruction on different cycle 
// ============================================================================


// `define VIVA
`define End_CYCLE  500      // Modify cycle times once your design need more cycle times!
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
	`define BIAS_DAT	"../../PAT/2_bias.dat"
`endif




module fsm_check_tb();
	

	parameter TBITS = 64;
	parameter TBYTE = 8;

	parameter IFMAP_SIZE   = 173056;
	parameter TB_ISRAM_DEPTH	=	300 ;

	localparam IFMAP_SRAM_ADDBITS = 11       ;
	localparam IFMAP_SRAM_DATA_WIDTH = 64    ;
//----------------------------------------------------

//----------------------------------------------------


	reg [30:0] cycle=0;

	reg  clk;         
	reg  reset;       


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



//---------- pattern declare-----------------
logic tb_memread_done ;



//--------------------------------------------
//-------------  tb random function test ---------------
	wire [64-1 :0 ] check_ifmaparray0 ;
	wire [64-1 :0 ] check_ifmaparray1 ;
	wire [64-1 :0 ] check_ifmaparray2 ;
	wire [64-1 :0 ] check_ifmaparray3 ;
	wire [64-1 :0 ] check_ifmaparray4 ;
	wire [64-1 :0 ] check_ifmaparray5 ;


integer  iix , i1 , i0 ;



//----------  ker w testbench --------------------
    logic tst_sram_rw ;	
    logic tst_ker_read_done ;	
    logic tst_en_ker_num ;	
    logic [9:0] tst_cp_ker_num ;	// testbench simulate ker_r module
//----------- test kernel store module ------------------------
	logic bias_write_done;
	logic bias_write_busy;
	logic start_bias_write;
//--------------------------------------------------------------
//----------- test kernel read module ------------------------
	logic bias_read_done;
	logic bias_read_busy;
	logic start_bias_read;
//--------------------------------------------------------------


//------------ testbench --------------------
	logic [64-1:0]	bias_array [ 0 : 1024];


// =============================================================================
// =======		instance 	===================================================
// =============================================================================

	bias_top bit001 (
		.clk	(	clk		),
		.reset	(	reset	),

		.bias_write_data_din		(	isif_data_dout	),
		.bias_write_empty_n_din	(	isif_empty_n	),
		.bias_write_read_dout	(	isif_read		),

		.bias_write_done 		(	bias_write_done	),
		.bias_write_busy 		(	bias_write_busy	),
		.start_bias_write		(	start_bias_write	),

		.bias_read_done 			(	bias_read_done 	),
		.bias_read_busy 			(	bias_read_busy 	),
		.start_bias_read			(	start_bias_read	),


		.tst_cp_ker_num			(	tst_cp_ker_num		),
		.tst_en_ker_num			(	tst_en_ker_num		),
		.tst_ker_read_done			(	tst_ker_read_done		),
		.tst_sram_rw			(	tst_sram_rw		)
	
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

// =============================================================
	


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
			$fsdbDumpfile("tbb.fsdb");
			$fsdbDumpvars(0,"+mda","+packedmda");		//++
			$fsdbDumpMDA();
		`elsif GATE
			$sdf_annotate(`SDFFILE,bias_tset);		//$sdf_annotate( PATH of sdf file , "which module you synthesised" );
			$fsdbDumpfile("tbb_SYN.fsdb");
			$fsdbDumpvars();
		`else 
		`endif
	end

	initial begin // initial pattern and expected result
		wait(reset==1);
		tb_memread_done = 0; 
		//--------- pattern reading start -----------
		$readmemh(`BIAS_DAT, bias_array);
		//--------- pattern reading end -----------	
		#1;
		tb_memread_done = 1;

	end

// =============================================================



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
		start_bias_write = 0;
		start_bias_read = 0 ;
		tst_cp_ker_num = 0 ;
		tst_ker_read_done = 0 ;
		tst_en_ker_num = 0 ;
		//-----------reset signal end ------------------
		#( `CYCLE*4 + `NI_DELAY ) ;
		reset = 0;
		#( `CYCLE*5 ) ;


		//----- wait mem read --------------
		wait(tb_memread_done) ;
		#( `CYCLE*5 ) ;
		// //------- ker type1 store start -----------------
		// wait( bias_write_busy==1'd0 );
		// tst_sram_rw = 1 ;
		// @( posedge clk );
		// start_bias_write = 1;
		// #( `CYCLE*3 ) ;
		// @( posedge clk );
		// start_bias_write = 0;

		// for( i0 = 0 ; i0 <8 ; i0 = i0 + 1)begin
		// 	@( posedge clk );
		// 		S_AXIS_MM2S_TLAST = 0 ;
		// 		S_AXIS_MM2S_TVALID = 0 ;
		// 	for( i1=0 ; i1<288 ; i1=i1+1 )begin
		// 		@(posedge clk);
		// 			S_AXIS_MM2S_TVALID=1;
		// 			S_AXIS_MM2S_TDATA = bias_sram_0[ i1  ]	;
		// 			if(  i1==(  287   ) )begin
		// 				S_AXIS_MM2S_TLAST = 1 ;
		// 			end
		// 			wait(S_AXIS_MM2S_TREADY);
		// 	end
		// 	@(posedge clk);
		// 		S_AXIS_MM2S_TVALID = 0 ;
		// 		S_AXIS_MM2S_TLAST = 0 ;
		// 		#(getrand(58 , 15)) ;
		// end
		
		// @(posedge clk);
		// tst_sram_rw = 1 ;
		//------- ker type2 store start -----------------
		wait( bias_write_busy==1'd0 );
		tst_sram_rw = 1 ;
		@( posedge clk );
		start_bias_write = 1;
		#( `CYCLE*3 ) ;
		@( posedge clk );
		start_bias_write = 0;
		
		
		@( posedge clk );
			S_AXIS_MM2S_TLAST = 0 ;
			S_AXIS_MM2S_TVALID = 0 ;
		for( i1=0 ; i1<64 ; i1=i1+1 )begin
			@(posedge clk);
				S_AXIS_MM2S_TVALID=1;
				S_AXIS_MM2S_TDATA = bias_array[ i1  ]	;
				if(  (i1==63)    )begin
					S_AXIS_MM2S_TLAST = 1 ;
				end
				wait(S_AXIS_MM2S_TREADY);
		end

		
		@(posedge clk);
			S_AXIS_MM2S_TVALID = 0 ;
			S_AXIS_MM2S_TLAST = 0 ;
			#(getrand(58 , 15)) ;
		@(posedge clk);
		tst_sram_rw = 0 ;

		#(getrand(58 , 15)) ;
		wait( bias_read_busy==1'd0 );
		tst_sram_rw = 0 ;
		@( posedge clk );
		start_bias_read = 1;
		#( `CYCLE*3 ) ;
		@( posedge clk );
		#1 ;
		start_bias_read = 0;
		tst_cp_ker_num = 0;
		tst_en_ker_num = 0;
		#( `CYCLE*5 ) ;

		for( i1=0 ; i1<8 ; i1=i1+1 )begin

			if( i1 == 0 ) begin
				#( `CYCLE*20 ) ;
			end
			else begin
				@( posedge clk );
				#1 ;
				tst_en_ker_num = 1;
				@( posedge clk );
				#1 ;
				tst_en_ker_num = 0;
				tst_cp_ker_num = i1 ;
			end
			
			#( `CYCLE*20 ) ;
		end


		@( posedge clk );
		#1 ;
		tst_ker_read_done = 1 ;

		
		#(getrand(58 , 15)) ;
		wait( bias_read_done==1'd1 );




	end 


// =============================================================================
// ================		kernel sram read data check		========================
// =============================================================================
	// always @(posedge clk ) begin
	// 	dout_kersr_0_dly0 <= dout_kersr_0 ;
	// 	dout_kersr_1_dly0 <= dout_kersr_1 ;
	// 	dout_kersr_2_dly0 <= dout_kersr_2 ;
	// 	dout_kersr_3_dly0 <= dout_kersr_3 ;
	// 	dout_kersr_4_dly0 <= dout_kersr_4 ;
	// 	dout_kersr_5_dly0 <= dout_kersr_5 ;
	// 	dout_kersr_6_dly0 <= dout_kersr_6 ;
	// 	dout_kersr_7_dly0 <= dout_kersr_7 ;

	// 	ksr_valid_0_dly0 <= ksr_valid_0 ;
	// 	ksr_valid_1_dly0 <= ksr_valid_1 ;
	// 	ksr_valid_2_dly0 <= ksr_valid_2 ;
	// 	ksr_valid_3_dly0 <= ksr_valid_3 ;
	// 	ksr_valid_4_dly0 <= ksr_valid_4 ;
	// 	ksr_valid_5_dly0 <= ksr_valid_5 ;
	// 	ksr_valid_6_dly0 <= ksr_valid_6 ;
	// 	ksr_valid_7_dly0 <= ksr_valid_7 ;

	// 	ksr_final_0_dly0 <= ksr_final_0 ;
	// 	ksr_final_1_dly0 <= ksr_final_1 ;
	// 	ksr_final_2_dly0 <= ksr_final_2 ;
	// 	ksr_final_3_dly0 <= ksr_final_3 ;
	// 	ksr_final_4_dly0 <= ksr_final_4 ;
	// 	ksr_final_5_dly0 <= ksr_final_5 ;
	// 	ksr_final_6_dly0 <= ksr_final_6 ;
	// 	ksr_final_7_dly0 <= ksr_final_7 ;
	// end

endmodule