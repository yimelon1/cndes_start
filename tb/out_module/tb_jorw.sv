// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.12.13
// Ver      : 1.0
// Func     : testbench for kernel and bias module read and write 
// ============================================================================


// `define VIVA
`define End_CYCLE  10000      // Modify cycle times once your design need more cycle times!
`define NI_DELAY  2		// NONIDEAL delay latency
`define AFPOS_DELAY  0.5		// NONIDEAL delay latency

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



// `define QUANOT_PAT "../../PAT/ot_buf/quantobuf/Quan_to_buf_col_66.dat"
// `define QUANOT_PAT "../../PAT/ot_buf/quantobuf/Quan_tb_yimod.dat"
`define QUANOT_PAT "../../PAT/ot_buf/quantobuf/QtB_col_30.dat"
`define QTBEND_PAT "../../PAT/ot_buf/quantobuf/QtBend_col_30.dat"


module tb_ot ();
	
parameter TBITS = 64;
parameter TBYTE = 8;

//----		declare clk&reset and other necessary--------
logic clk ;
logic reset ;
logic rstn ;
reg [30:0] cycle=0;
logic tb_memread_done ;
logic done =0 ; // after all function done
//---------------------------------------------------------
//----		declare integer		-----------------------
integer i0 , i1 ;
integer  er ;	
//---------------------------------------------------------
//----		tb signal		----
logic [20-1 : 0]cnt_qtbot ;

logic valid_in = 'dx;
logic  [TBITS-1 : 0] q_64_afq = 64'd0;
logic tst_read_last ;

logic  [8-1 : 0] quanot_pat_ary [ 0 : 4244-1 ];
logic  [8-1 : 0] q8_from_quan = 8'd0;

logic  [64-1 : 0] qtb_glod_ary [ 0 : 4244-1 ];
logic  [64-1 : 0] qtbed_ary [ 0 : 4244-1 ];
//---------------------------------------------------------

//----		instance I/O		----
wire             M_AXIS_S2MM_TVALID			;
reg              M_AXIS_S2MM_TREADY			= 0	;
wire [TBITS-1:0] M_AXIS_S2MM_TDATA			;
wire [TBYTE-1:0] M_AXIS_S2MM_TKEEP			;
wire [1-1:0]     M_AXIS_S2MM_TLAST			;


wire [TBITS-1: 0 ]	osif_data_din			;
wire [TBYTE-1: 0 ]	osif_strb_din			;
wire 				osif_last_din			;
wire 				osif_user_din			;
wire 				osif_full_n				;
wire 				osif_write				;
//---------------------------------------------------------
//----		declare output result		----
logic [12-1 : 0] ot_cnt ;
localparam OUTPUT_DEPTH = 2048;
reg [64-1 : 0] ot_result [0:OUTPUT_DEPTH] ;
//---------------------------------------------------------



// =============================================================================
// ================		module instance		====================================
// =============================================================================
ot_top tot1(	
	.clk 		(	clk	),
	.reset 		( reset	),

	.fifo_full_n	(	osif_full_n	),
	.fifo_write		(	osif_write	),
	.fifo_last		(	osif_last_din	),
	.fifo_data		(	osif_data_din	),
	
	.tst_read_last	( tst_read_last ),

	.valid_in 	(	valid_in	),
	.data_in	(	q8_from_quan	)

);

OUTPUT_STREAM_if	#(
    .TBITS(	TBITS	),
    .TBYTE(	TBYTE	)
)
o_fifo(
	// AXI4-Stream singals
	.ACLK		(	clk	),
	.ARESETN	(	rstn	),
	.TVALID		(	M_AXIS_S2MM_TVALID			),
	.TREADY		(	M_AXIS_S2MM_TREADY			),
	.TDATA		(	M_AXIS_S2MM_TDATA			),
	.TKEEP		(	M_AXIS_S2MM_TKEEP			),
	.TLAST		(	M_AXIS_S2MM_TLAST			),
	.TUSER		(		),		// no need

	// User signals
	.osif_data_din		(	osif_data_din		),
	.osif_strb_din		(	1'd1 		),
	.osif_last_din		(	osif_last_din		),
	.osif_user_din		(	osif_user_din		),
	.osif_full_n		(	osif_full_n			),
	.osif_write			(	osif_write			)
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

	initial begin // initial pattern and expected result
		wait(reset==1);
		tb_memread_done = 0; 
		//--------- pattern reading start -----------
		$readmemh(`QUANOT_PAT, quanot_pat_ary);
		$readmemh(`QTBEND_PAT, qtb_glod_ary);
		//--------- pattern reading end -----------	
		#1;
		tb_memread_done = 1;

	end

// =============================================================


always @(posedge clk ) begin
	if( reset )begin
		cnt_qtbot <= 10'd0 ;
	end
	else begin
		if( M_AXIS_S2MM_TVALID & M_AXIS_S2MM_TREADY ) begin
			cnt_qtbot <= cnt_qtbot + 1 ;
			qtbed_ary[cnt_qtbot] <= M_AXIS_S2MM_TDATA ;
		end
		else begin
			cnt_qtbot <= cnt_qtbot ;
		end
	end
end
// =============================================================================
// ================		testbench initial control		========================
// =============================================================================

	initial begin
		
		#1;
		reset = 0;
		#( `CYCLE*3 ) ;
		reset = 1;
		//-----------reset signal start ------------------
		valid_in = 1'd0;
		q_64_afq = 64'd0 ;
		q8_from_quan = 8'd0;
		done =0 ;
		M_AXIS_S2MM_TREADY = 1 ;

		//-----------reset signal end ------------------
		#( `CYCLE*4 + `NI_DELAY ) ;
		reset = 0;
		tst_read_last = 0;
		#( `CYCLE*5 ) ;

		//----- wait mem read --------------
		wait(tb_memread_done) ;
		#( `CYCLE*5 ) ;

		//---------------------------------------------
		//----------- now test start ------------------
		for ( i0 = 0 ; i0<1920 ; i0=i0+1) begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				q8_from_quan = quanot_pat_ary[i0] ;
				valid_in = 1'd1 ;
			@(posedge clk); #(`AFPOS_DELAY) ;
				valid_in = 1'd0 ;
			#( `CYCLE*2  ) ;
		end
		
		@(posedge clk); #(`AFPOS_DELAY) ;
				valid_in = 1'd0 ;
		#( `CYCLE*5  ) ;

		//---------------------------------------------
		// for ( i0 = 40 ; i0<80 ; i0=i0+1) begin
		// 	@(posedge clk); #(`AFPOS_DELAY) ;
		// 		q8_from_quan = quanot_pat_ary[i0] ;
		// 		valid_in = 1'd1 ;
		// 		if( ((i0 % 20)==0) & i0!=0 )begin
		// 			tst_read_last = 1 ;
		// 		end
		// 		else begin
		// 			tst_read_last = 0 ;
		// 		end
		// 	@(posedge clk); #(`AFPOS_DELAY) ;
		// 		valid_in = 1'd0 ;
		// 		tst_read_last = 0 ;
		// 	#( `CYCLE*2  ) ;
		// end

		#( `CYCLE*5  ) ;



		#( `CYCLE*5 ) ;
		wait( M_AXIS_S2MM_TLAST ) ;
		done = 1 ;
		

	end


	//---- output result store----
initial begin
	wait( reset ==1  );
	er =0;	
	#( `CYCLE*5 ) ;
	wait( done ==1  );
	
	for( i0=0 ; i0<50 ; i0=i0+1 )begin
		if( qtbed_ary [i0] !== qtb_glod_ary[i0])begin
			er = er + 1 ;
			$display("error = %d  at index = %d \n", er  , i0);
		end
	end
	$display("error = %d  \n", er);
	
	$display("==================\n");
	#( `CYCLE*5 ) ;
	$finish;



end




endmodule