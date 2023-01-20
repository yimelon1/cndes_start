// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2022.12.13
// Ver      : 1.0
// Func     : testbench for kernel and bias module read and write 
// ============================================================================


// `define VIVA
`define End_CYCLE  1500      // Modify cycle times once your design need more cycle times!
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


`define OT_PAT "../../PAT/ot_buf/obuf_col_20.dat"
// `define OT_PAT "../../PAT/ot_buf/obuf_col_31.dat"
// `define OT_PAT "../../PAT/ot_buf/obuf_col_66.dat"

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
logic [20-1 : 0]cnt_qtbot ;
//---------------------------------------------------------
//----		tb signal		----
logic  [TBITS-1 : 0] ot_pat_ary [ 0 : 1024-1 ];

logic valid_in = 'dx;
logic  [TBITS-1 : 0] q_64_afq = 64'd0;
logic tst_read_last ;

logic  [8-1 : 0] quanot_pat_ary [ 0 : 4244-1 ];
logic  [8-1 : 0] q8_from_quan = 8'd0;


logic  [64-1 : 0] qtb_glod_ary [ 0 : 4244-1 ];
logic  [64-1 : 0] qtbed_ary [ 0 : 4244-1 ];
//---------------------------------------------------------
wire [TBITS-1 : 0]	data64_to_ot ;
wire 	valid_to_ot ;
//---------------------------------------------------------
logic ot_fifo_er_alarm ;
logic ot_fifo_empty_n ;
logic ot_fifo_read ;
logic [TBITS-1 : 0]	ot_fifo_data64 ;


// =============================================================================
// ================		module instance		====================================
// =============================================================================
ot_top tot1(	
	.clk 		(	clk	),
	.reset 		( reset	),

	.tst_read_last	( tst_read_last ),

	.valid_in 	(	valid_to_ot		),
	.data_in	(	data64_to_ot	)

);

ot_qtbuf	qtb00(
	.clk 		(	clk	),
	.reset 		( reset	),
	
	.q_out			(	q8_from_quan	),
	.q_valid		(	valid_in		),
	
	.out64bits		(	data64_to_ot	),
	.valid_out		(	valid_to_ot		)

);


yi_fifo  qtbfifo(
	.clk			(	clk		),
	.reset			(	reset	),
	.valid_in 		(	valid_to_ot				),
	.data_in		(	data64_to_ot			),
	.error			(	ot_fifo_er_alarm		),	// we loss output data cause something wrong
	.empty_n		(	ot_fifo_empty_n			),
	.read			(	ot_fifo_read			),
	.data_out		(	ot_fifo_data64			)

);



always @(posedge clk ) begin
	if( reset )begin
		cnt_qtbot <= 10'd0 ;
	end
	else begin
		if( valid_to_ot) begin
			cnt_qtbot <= cnt_qtbot + 1 ;
			qtbed_ary[cnt_qtbot] <= data64_to_ot ;
		end
		else begin
			cnt_qtbot <= cnt_qtbot ;
		end
	end
end


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
		$readmemh(`OT_PAT, ot_pat_ary);
		$readmemh(`QUANOT_PAT, quanot_pat_ary);
		$readmemh(`QTBEND_PAT, qtb_glod_ary);
		//--------- pattern reading end -----------	
		#1;
		tb_memread_done = 1;

	end

// =============================================================

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
		for ( i0 = 0 ; i0<40 ; i0=i0+1) begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				q8_from_quan = quanot_pat_ary[i0] ;
				valid_in = 1'd1 ;
			@(posedge clk); #(`AFPOS_DELAY) ;
				valid_in = 1'd0 ;
			#( `CYCLE*2  ) ;
		end
		#( `CYCLE*5  ) ;


		//---------------------------------------------
		for ( i0 = 40 ; i0<80 ; i0=i0+1) begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				q8_from_quan = quanot_pat_ary[i0] ;
				valid_in = 1'd1 ;
				if( ((i0 % 20)==0) & i0!=0 )begin
					tst_read_last = 1 ;
				end
				else begin
					tst_read_last = 0 ;
				end
			@(posedge clk); #(`AFPOS_DELAY) ;
				valid_in = 1'd0 ;
				tst_read_last = 0 ;
			#( `CYCLE*2  ) ;
		end

		#( `CYCLE*5  ) ;

		for ( i0 = 80 ; i0<129 ; i0=i0+1) begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				q8_from_quan = quanot_pat_ary[i0] ;
				valid_in = 1'd1 ;
			if( i0 ==129-1 )begin
				@(posedge clk); #(`AFPOS_DELAY) ;
				valid_in = 1'd0 ;
			end
			
			// #( `CYCLE*2  ) ;
		end
		#( `CYCLE*5  ) ;
		for ( i0 = 129 ; i0<600 ; i0=i0+1) begin
			@(posedge clk); #(`AFPOS_DELAY) ;
				q8_from_quan = quanot_pat_ary[i0] ;
				valid_in = 1'd1 ;
			if( i0 ==200-1 )begin
				@(posedge clk); #(`AFPOS_DELAY) ;
				valid_in = 1'd0 ;
			end
			
			// #( `CYCLE*2  ) ;
		end

		#( `CYCLE*5 ) ;
		done = 1 ;
		


	end


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