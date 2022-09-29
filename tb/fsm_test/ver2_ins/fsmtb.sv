// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.09.28
// Ver      : 2.0
// Func     : FSM with instruction get testbench, every state need 10 cycle to done
// 			and test for start instruction on different cycle 
// ============================================================================


// `define VIVA
`define End_CYCLE  500      // Modify cycle times once your design need more cycle times!
`define NI_DELAY  2		// NONIDEAL delay latency
`ifdef RTL
	`timescale 1ns/100ps
    `define CYCLE 10	// 100MHz
`endif
`ifdef GATE
	`timescale 1ns/1ps
    `define CYCLE 3.3
`endif
`ifdef VIVA
	`timescale 1ns/100ps
    `define CYCLE 10	// 100MHz
`endif





module fsm_check_tb();
	
	localparam FSM_BITS 	= 5;
	localparam IDLE 		= 5'd0;
	localparam FIRST_LOAD 	= 5'd1;
	localparam CPB_0 		= 5'd2;
	localparam CPB_1 		= 5'd3;
	localparam CPB_2 		= 5'd4;
	localparam CPB_LOADNEW 	= 5'd5;
	localparam CPB_3 		= 5'd6;
	localparam CPB_4 		= 5'd7;


	reg  clk;         
	reg  reset;       

	reg auto_run_next ;
	reg start_run ;
	reg man_reset ;
	reg [30:0] cycle=0;
	
	reg [ FSM_BITS -1  :0 ] fsm_current_state ;
	reg [ FSM_BITS -1  :0 ] fsm_prevous_state ;
	reg [ FSM_BITS -1  :0 ] fsm_curr_state_dly0 ;

	reg flag_firstload_end	;
	reg flag_cpb0_end		;
	reg flag_cpb1_end		;
	reg flag_cpb2_end		;
	reg flag_cpbldnew_end	;
	reg flag_cpb3_end		;
	reg flag_cpb4_end		;
	wire busy;


	// =============================================================================
	// =======		instance 	===================================================
	// =============================================================================

	fsm fs01(
		.clk		(	clk	),
		.reset		(	reset	),
		.auto 		(	auto_run_next	),
		.start 		(	start_run		),
		.man_reset	(	man_reset		),

		.flag_firstload_end	(	flag_firstload_end		),
		.flag_cpb0_end		(	flag_cpb0_end			),
		.flag_cpb1_end		(	flag_cpb1_end			),
		.flag_cpb2_end		(	flag_cpb2_end			),
		.flag_cpbldnew_end	(	flag_cpbldnew_end		),
		.flag_cpb3_end		(	flag_cpb3_end			),
		.flag_cpb4_end		(	flag_cpb4_end			),
		.busy				(	busy					),

		.out_current_state 		(	fsm_current_state	),
		.out_prev_state		(	fsm_prevous_state	)
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
	// =============================================================================



	initial clk = 1;

	always begin #(`CYCLE / 2) clk = ~clk; end

	
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
			$fsdbDumpfile("fsm.fsdb");
			$fsdbDumpvars(0,"+mda","+packedmda");		//++
			$fsdbDumpMDA();
		`elsif GATE
			$sdf_annotate(`SDFFILE,top_U);
			$fsdbDumpfile("dla_top_SYN.fsdb");
			$fsdbDumpvars();
		`else 
		`endif
	end

	always@(posedge clk )begin
		fsm_curr_state_dly0 <= fsm_current_state;
	end

	//start test FSM
	initial begin
		#1;
		reset = 0;
		#( `CYCLE*3 ) ;
		reset = 1;
		flag_firstload_end	= 0		;
		flag_cpb0_end		= 0		;
		flag_cpb1_end		= 0		;
		flag_cpb2_end		= 0		;
		flag_cpbldnew_end	= 0		;
		flag_cpb3_end		= 0		;
		flag_cpb4_end		= 0		;


		auto_run_next		= 0	;
		start_run			= 0	;
		man_reset			= 0	;

		#( `CYCLE*4 + `NI_DELAY ) ;
		reset = 0;

	end 


endmodule