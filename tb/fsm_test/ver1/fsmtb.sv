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

		@(posedge clk );
		#(`NI_DELAY);
		auto_run_next		= 0	;
		
		#( `CYCLE*3 ) ;
		start_run			= 1	;

		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;

		#( `CYCLE*3 ) ;

		@(posedge clk );
		#(`NI_DELAY);
		flag_firstload_end	= 1		;

		#( `CYCLE*3 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;


		//-------- CPB_0 state --------
		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_0) ;
		#2;

		@(posedge clk );
		#(`NI_DELAY);
		flag_firstload_end	= 0		;
		flag_cpb0_end		= 1		;

		#( `CYCLE*3 ) ;
		#( `CYCLE*3 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;

		//-------- CPB_1 state --------

		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_1) ;
		#2;

		@(posedge clk );
		#(`NI_DELAY);
		flag_cpb0_end		= 0		;
		flag_cpb1_end		= 1		;

		#( `CYCLE*3 ) ;
		#( `CYCLE*3 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;

		//-------- CPB_2 state --------

		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_2) ;
		#2;

		@(posedge clk );
		#(`NI_DELAY);
		flag_cpb1_end		= 0		;
		flag_cpb2_end		= 1		;

		#( `CYCLE*3 ) ;
		#( `CYCLE*3 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;

		//-------- CPB_LOADNEW state --------
		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_LOADNEW) ;
		#2;
		@(posedge clk );
		#(`NI_DELAY);
		flag_cpb2_end		= 0		;
		flag_cpbldnew_end	= 1		;

		#( `CYCLE*3 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;
		
		//-------- CPB_3 state --------
		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_3) ;
		#2;
		@(posedge clk );
		#(`NI_DELAY);
		flag_cpbldnew_end	= 0		;
		flag_cpb3_end		= 1		;
		#( `CYCLE*1 ) ;
		flag_cpb3_end		= 0 	;

		#( `CYCLE*3 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;

		//-------- CPB_4 state --------
		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_4) ;
		#2;

		#( `CYCLE*3 ) ;
		@(posedge clk );
		#(`NI_DELAY);
		flag_cpb4_end		= 1'd1		;


		#( `CYCLE*3 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;



		//-------- CPB_0 state --------
		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_0) ;
		#2;
		@(posedge clk );
		#(`NI_DELAY);
		flag_cpb3_end		= 0		;
		flag_cpb4_end		= 0		;
		flag_cpb0_end		= 0		;



		//-----------auto run start ----------------
		@(posedge clk );
		#(`NI_DELAY);
		auto_run_next		= 0	;
		
		#( `CYCLE*3 ) ;


		//-------- CPB_1 state --------

		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_1) ;
		#2;

		#( `CYCLE*5 ) ;
		@(posedge clk );
		#(`NI_DELAY);
		flag_cpb1_end		= 1		;

		#(`NI_DELAY);
		@(posedge clk );
		flag_cpb1_end		= 0		;


		#( `CYCLE*5 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;

		//-------- CPB_2 state --------

		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_2) ;
		#2;

		@(posedge clk );
		#(`NI_DELAY);
		flag_cpb2_end		= 1		;

		#(`NI_DELAY);
		@(posedge clk );
		flag_cpb2_end		= 0		;


		#( `CYCLE*5 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;

		//-------- CPB_LOADNEW state --------
		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_LOADNEW) ;
		#2;
		#( `CYCLE*5 ) ;
		@(posedge clk );
		flag_cpbldnew_end	= 1		;

		#(`NI_DELAY);
		@(posedge clk );
		flag_cpbldnew_end		= 0		;

		#( `CYCLE*5 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;
		
		//-------- CPB_3 state --------
		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_3) ;
		#2;

		#( `CYCLE*5 ) ;
		@(posedge clk );
		flag_cpb3_end	= 1		;

		#(`NI_DELAY);
		@(posedge clk );
		flag_cpb3_end		= 0		;
		#( `CYCLE*5 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;

		//-------- CPB_4 state --------
		#( `CYCLE*3 ) ;
		wait( fsm_current_state == CPB_4) ;
		#2;

		#( `CYCLE*5 ) ;
		@(posedge clk );
		flag_cpb4_end	= 1		;

		#(`NI_DELAY);
		@(posedge clk );
		flag_cpb4_end		= 0		;
		#( `CYCLE*3 ) ;



		#( `CYCLE*3 ) ;
		start_run			= 1	;
		wait( fsm_curr_state_dly0 !==  fsm_current_state )  ;
		#( `CYCLE*1 ) ;
		start_run			= 0	;
		#( `CYCLE*1 ) ;



	end 


endmodule