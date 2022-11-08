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
	`define IF_PAT "../PAT/2_in.dat"
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

//--------------------------------------------

	wire [64-1 :0 ] check_ifmaparray0 ;
	wire [64-1 :0 ] check_ifmaparray1 ;
	wire [64-1 :0 ] check_ifmaparray2 ;
	wire [64-1 :0 ] check_ifmaparray3 ;
	wire [64-1 :0 ] check_ifmaparray4 ;
	wire [64-1 :0 ] check_ifmaparray5 ;


integer  iix , i1 , i0 ;
	// =============================================================================
	// =======		instance 	===================================================
	// =============================================================================


	schedule_ctrl sch_mod(
		.clk		(	clk	),
		.reset		(	reset	),

		.mast_curr_state	(	fsm_mast_state	),
		.slav_curr_state	(	fsm_slav_state	),

		// .if_store_done 	(		),
		// .ker_store_done 	(		),
		// .bias_store_done (		),

		// .if_store_busy 	(		),
		// .ker_store_busy 	(		),
		// .bias_store_busy (		),

		// .start_if_store		(		),
		// .start_ker_store 	(		),
		// .start_bias_store	(		),

		// .sl_top_done 	(		),
		// .sl_mid_done 	(		),
		// .sl_bott_done 	(		),
		// .flag_fsld_end 	(		),
		// .flag_base_end 	(		)

		.if_store_done 		(	ifstore_done	),
		.if_store_busy 		(	ifstore_busy	),
		.start_if_store		(	ifstore_start	),
		.flag_fsld_end		(	flag_fsld_end_sche	)

	);




	if_store sram_st00 (
		.clk		(	clk	),
		.reset		(	reset	),

		.ifstore_data_din		(	isif_data_dout	),
		.ifstore_empty_n_din	(	ds_empty_n	),
		.ifstore_read_dout		(	ifstore_read_dout	),

		
		.if_store_done	(	ifstore_done	)	,
		.if_store_busy 	(	ifstore_busy	),
		.start_if_store	(	ifstore_start	)

	);

	
	fsm fs01(
		.clk		(	clk	),
		.reset		(	reset	),

		.sl_top_done 	(	sl_top_done 			),
		.sl_mid_done 	(	sl_mid_done 			),
		.sl_bott_done 	(	sl_bott_done 			),
		.flag_fsld_end 	(	flag_fsld_end_sche		),	// from schedule
		.flag_base_end 	(	flag_base_end		),
		.start 	(	gi_start		),

		.outmast_curr_state (	fsm_mast_state	),
		.outslav_curr_state (	fsm_slav_state	)

	);

	get_ins gi01(
		.clk 	(	clk	),
		.reset 	(	reset	),

		.fifo_data_din		(	isif_data_dout		),
		.fifo_strb_din		(	isif_strb_dout		),
		.fifo_last_din		(	isif_last_dout		),
		.fifo_user_din		(	isif_user_dout		),
		.fifo_empty_n_din	(	isif_empty_n		),
		.fifo_read_dout		(	isif_read			),



		.ds_empty_n			(	ds_empty_n	),	// output
		.ds_read			(	tb_ctrl_ds_read		),		// input

		.instr_code00	(	config_param00	),
		.instr_code01	(	config_param01	),
		.instr_code02	(	config_param02	),

		.start_reg		(	gi_start	)



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
	function int unsigned getrand;
		input int unsigned maxvalue ; 
		input int unsigned minvalue ; 
		begin
			getrand = $urandom_range(maxvalue , minvalue);
		end
	endfunction

	




	assign check_ifmaparray0	 = getrand(10 , 15) ;
	assign check_ifmaparray1	 = getrand(20 , 50) ;
	assign check_ifmaparray2	 = getrand(20 , 50);
	assign check_ifmaparray3	 = ifmap[ 180 ] ;
	assign check_ifmaparray4	 = ifmap[ 240 ] ;
	assign check_ifmaparray5	 = ifmap[ 560 ] ;


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

	initial begin // initial pattern and expected result
		wait(reset==1);
		tb_memread_done = 0; 
		//--------- pattern reading start -----------
		$readmemh(`IF_PAT, ifmap);
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
	always@( * )begin
		sl_top_done = ( top_cnt == TOPCNT-1 )? 1'd1 : 1'd0 ;
		sl_mid_done = ( mid_cnt == MIDCNT-1 )? 1'd1 : 1'd0 ;
		sl_bott_done 	 = ( bott_cnt == BOTTCNT-1 )? 1'd1 : 1'd0 ;
		flag_fsld_end	 = ( fsld_cnt == FSLDCNT-1 )? 1'd1 : 1'd0 ;
		flag_base_end	 = ( base_cnt0 == BASERUNDS-1 )? 1'd1 : 1'd0 ;
	end

	always@( posedge clk )begin
		if( reset )begin
			top_cnt <= 'd0;
		end
		else begin
			if( fsm_slav_state == TOP ) begin
				if( top_cnt < TOPCNT) begin	top_cnt <= top_cnt +1 ;	end
				else begin top_cnt <= 0; end
			end
			else begin
				top_cnt <= 0;
			end
		end
	end

	always@( posedge clk )begin
		if( reset )begin
			mid_cnt <= 'd0;
		end
		else begin
			if( fsm_slav_state == MID ) begin
				if( mid_cnt < MIDCNT) begin	mid_cnt <= mid_cnt +1 ;	end
				else begin mid_cnt <= 0; end
			end
			else begin
				mid_cnt <= 0;
			end
		end
	end

	always@( posedge clk )begin
		if( reset )begin
			bott_cnt <= 'd0;
		end
		else begin
			if( fsm_slav_state == BOTT ) begin
				if( bott_cnt < BOTTCNT) begin	bott_cnt <= bott_cnt +1 ;	end
				else begin bott_cnt <= 0; end
			end
			else begin
				bott_cnt <= 0;
			end
		end
	end

	always@( posedge clk )begin
		if( reset )begin
			fsld_cnt <= 'd0;
		end
		else begin
			if( fsm_mast_state == FSLD ) begin
				if( fsld_cnt < FSLDCNT ) begin	fsld_cnt <= fsld_cnt +1 ;	end
				else begin fsld_cnt <= 0; end
			end
			else begin
				fsld_cnt <= 0;
			end
		end
	end

	always@( posedge clk )begin
		if( reset )begin
			base_cnt0 <= 'd0;
		end
		else begin
			if( fsm_mast_state == BASE ) begin
				if( base_cnt0 < BASERUNDS ) begin	
					if( sl_bott_done )begin
						base_cnt0 <= base_cnt0 +1 ;
					end
					else begin
						base_cnt0 <= base_cnt0 ;
					end
					end
				else begin 
					base_cnt0 <= 0; 
				end
			end
			else begin
				base_cnt0 <= 0;
			end
		end
	end
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

		
		//----- data type 1 --------------
	
		for ( i1=0 ; i1<3 ; i1=i1+1 )begin
			@( posedge clk );
			S_AXIS_MM2S_TVALID = 1 ;
			S_AXIS_MM2S_TDATA	= DATA_HEAD ;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );
				S_AXIS_MM2S_TVALID = 1 ;
				S_AXIS_MM2S_TDATA	= DATA_HEAD ;
				S_AXIS_MM2S_TLAST	= 1;
			wait(S_AXIS_MM2S_TREADY);
			@( posedge clk );
				S_AXIS_MM2S_TLAST = 0 ;
				S_AXIS_MM2S_TVALID = 0 ;
			#(getrand(300 , 100)) ;	// max , min
			for( i0=0; i0<(  66  *4) ; i0=i0+1) begin
				@(posedge clk);
				S_AXIS_MM2S_TVALID=1;
				// S_AXIS_MM2S_TDATA = ifmap[i0 + i1*208*4 ]	;
				S_AXIS_MM2S_TDATA = ifmap[i0  ]	;
				if(  i0==(  66  *4  -  1   ) )begin
					S_AXIS_MM2S_TLAST = 1 ;
				end
				wait(S_AXIS_MM2S_TREADY);
				
			end
			// #(`CYCLE*30);
			@(posedge clk);
			S_AXIS_MM2S_TVALID = 0 ;
			S_AXIS_MM2S_TLAST = 0 ;
			#(getrand(58 , 15)) ;

		end

		#( `CYCLE*5 ) ;
		// //----- data type 2 --------------
		// @( posedge clk );
		// 	S_AXIS_MM2S_TVALID = 1 ;
		// 	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
		// wait(S_AXIS_MM2S_TREADY);
		// @( posedge clk );
		// 	S_AXIS_MM2S_TVALID = 1 ;
		// 	S_AXIS_MM2S_TDATA	= DATA_HEAD ;
		// 	S_AXIS_MM2S_TLAST	= 1;
		// wait(S_AXIS_MM2S_TREADY);
		// @( posedge clk );
		// 	S_AXIS_MM2S_TLAST = 0 ;
		// 	S_AXIS_MM2S_TVALID = 0 ;

		// for ( i1=0 ; i1<3 ; i1=i1+1 )begin


		// 	for( i0=0; i0<(66*4) ; i0=i0+1) begin
		// 		@(posedge clk);
		// 		S_AXIS_MM2S_TVALID=1;
		// 		S_AXIS_MM2S_TDATA = ifmap[i0 + i1*208*4 ]	;
		// 		if(  i1 == 2 && i0==(10*4-1) )begin
		// 			S_AXIS_MM2S_TLAST = 1 ;
		// 		end
		// 		wait(S_AXIS_MM2S_TREADY);
		// 	end
		// 	// #(`CYCLE*30);
		// 	@(posedge clk);
		// 	S_AXIS_MM2S_TVALID = 0 ;
		// 	S_AXIS_MM2S_TLAST = 0 ;

		// end

		// #( `CYCLE*5 ) ;


	





	end 


endmodule