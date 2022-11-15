// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.11.10
// Ver      : 4.0
// Func     : test schedule control and fsm for all state
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

	//-------- reset & clk ------------
	reg [30:0] cycle=0;
	reg  clk;         
	reg  reset;       
	//----------------------------------



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


	localparam INST_HEAD = 64'hefef123abbeeff22 ;
	localparam DATA_HEAD = 64'hefef6543dadaff11 ;
	localparam CFG_0 = 64'hffff000000000000 ;
	localparam CFG_1 = 64'heeeeeeeeeeeeeeee ;
	localparam CFG_2 = 64'heeeeeeeeeeeeeeee ;


	wire [ 64-1 : 0 ]	config_param00	;
	wire [ 64-1 : 0 ]	config_param01	;
	wire [ 64-1 : 0 ]	config_param02	;



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


//----------- sim the write sram circuit ----------------
	reg ifstore_done		;
	reg ifstore_busy		;
	reg ifstore_start		;

	reg kerstore_busy	;
	reg kerstore_done	;
	reg kerstore_start	;
	
	reg biasstore_busy	;
	reg biasstore_done	;
	reg biasstore_start	;

	integer  iix , i1 , i0 ;
	integer kerp , birp;


	reg [4:0] cnt09 ;	// support kerstore sim
//------------ turn on FSM signal ------------
	logic tb_gi_start ;
	logic tb_master_done ;





	// =============================================================================
	// =======		instance 	===================================================
	// =============================================================================


	schedule_ctrl sch_mod(
		.clk		(	clk	),
		.reset		(	reset	),

		.mast_curr_state	(	fsm_mast_state	),

		// .if_store_done 	(		),
		// .ker_store_done 	(		),
		// .bias_store_done (		),

		// .if_store_busy 	(		),
		// .ker_store_busy 	(		),
		// .bias_store_busy (		),

		// .start_if_store		(		),
		// .start_ker_store 	(		),
		// .start_bias_store	(		),


		// .flag_master_done 	(		),
		// .flag_fsld_end 	(		)


		//-----------------------------------
		.if_store_done 		(	ifstore_done	),
		.ker_store_done 	(	kerstore_done	),
		.bias_store_done 	(	biasstore_done	),

		.if_store_busy 		(	ifstore_busy	),
		.ker_store_busy 	(	kerstore_busy	),
		.bias_store_busy 	(	biasstore_busy	),

		.start_if_store		(	ifstore_start	),
		.start_ker_store 	(	kerstore_start	),
		.start_bias_store	(	biasstore_start	),


		.flag_fsld_end		(	flag_fsld_end_sche	)

	);



	
	fsm64 fs01(
		.clk		(	clk	),
		.reset		(	reset	),


		.flag_fsld_end 	(	flag_fsld_end_sche		),	// from schedule
		.start			(	tb_gi_start		),
		.master_done 	(	tb_master_done		),

		.outmast_curr_state (	fsm_mast_state	)


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





	// -------------- main FSM testing ------------------------

	//--------- sim for if write sram module ------------------------
	initial begin
		wait(tb_memread_done) ;
		ifstore_busy = 0 ;
		ifstore_done =0 ;
		#( `CYCLE*5 ) ;


		for ( i0=0 ; i0<20 ; i0=i0+1 ) begin
			wait(ifstore_start);
			@(posedge clk) ;
			ifstore_busy = 1 ;
			#( `CYCLE*15 ) ;
			@(posedge clk) ;
			ifstore_done =1 ;
			#2;
			@(posedge clk) ;
			#1 ;
			ifstore_done =0 ;
			ifstore_busy = 0 ;
		end

		

	end
	//--------- sim for kernel write sram module ------------------------


	// initial begin
	// 	wait(tb_memread_done) ;
	// 	kerstore_busy = 0 ;
	// 	kerstore_done =0 ;
	// 	#( `CYCLE*5 ) ;


	// 	for( kerp = 0; kerp<5; kerp=kerp+1)begin
	// 		wait(kerstore_start);
	// 		@(posedge clk);
	// 		kerstore_busy = 1;
	// 		#( `CYCLE*15 ) ;
	// 		@(posedge clk) ;
	// 		kerstore_done =1 ;
	// 		#2;
	// 		@(posedge clk) ;
	// 		#1;
	// 		kerstore_done =0 ;
	// 		kerstore_busy = 0 ;

	// 	end

	// end
	
	initial begin
		wait(tb_memread_done) ;
		biasstore_busy = 0 ;
		biasstore_done =0 ;
		#( `CYCLE*5 ) ;


		for( birp = 0; birp<5; birp=birp+1)begin
			wait(biasstore_start);
			@(posedge clk);
			biasstore_busy = 1;
			#( `CYCLE*15 ) ;
			@(posedge clk) ;
			biasstore_done =1 ;
			#2;
			@(posedge clk) ;
			#1 ;
			biasstore_done =0 ;
			biasstore_busy = 0 ;

		end

	end


	//start test gi circuit
	initial begin
		#1;
		reset = 0;
		#( `CYCLE*3 ) ;
		reset = 1;
	//-----------reset signal start ------------------
		tb_gi_start = 0;
		tb_master_done = 0 ;
	//-----------reset signal end ------------------
		#( `CYCLE*4 + `NI_DELAY ) ;
		reset = 0;
		// #( `CYCLE*5 ) ;
		#(getrand(20 , 5)) ;	// random delay


	//----- instruction --------------
		
		wait(tb_memread_done) ;
		#( `CYCLE*5 ) ;

		
	//----- fsm and schedule test start --------------
	
	
		// #(`CYCLE*30);
		@(posedge clk);
		tb_gi_start = 1;
		#(getrand(58 , 15)) ;	// random delay


		#( `CYCLE*5 ) ;
		wait(flag_fsld_end_sche) ;
		#( `CYCLE*20 ) ;
		@(posedge clk);	#1 ;
		tb_master_done = 1 ;
		@(posedge clk);	#1 ;
		tb_master_done = 0 ;
		tb_gi_start = 0;

		#( `CYCLE*20 ) ;

		@(posedge clk);
		tb_gi_start = 1;
		#(getrand(58 , 15)) ;	// random delay


		#( `CYCLE*5 ) ;
		wait(flag_fsld_end_sche) ;
		#( `CYCLE*20 ) ;
		@(posedge clk);	#1 ;
		tb_master_done = 1 ;
		@(posedge clk);	#1 ;
		tb_master_done = 0 ;
		

	end 


	always @(posedge clk ) begin
		if(reset)begin
			kerstore_busy <= 0;
			
		end
		else begin
			if( kerstore_start & ~kerstore_busy  )begin
				kerstore_busy <= 1'd1 ;
			end
			else if ( kerstore_busy & ~kerstore_done )begin
				kerstore_busy <= kerstore_busy ;
			end
			else if( kerstore_busy & kerstore_done )begin
				kerstore_busy <= 1'd0 ;
			end
			else begin
				kerstore_busy <= kerstore_busy ;
			end
		end
		
	end


	always @(*) begin
		kerstore_done = ( kerstore_busy & (cnt09 == 5'd19)) ? 1'd1 : 1'd0 ;
	end
	
	always @(posedge clk ) begin
		if(reset )begin
			cnt09 <= 5'd0;
		end
		else begin
			if( cnt09 < 19  )begin
				if( kerstore_busy ) begin
					cnt09 <= cnt09 + 5'd1 ;
				end
				else begin
					cnt09 <= cnt09 ;
				end
			end
			else begin
				cnt09 <= 5'd0 ;
			end
			
		end
	end


endmodule