


`define SDFFILE    "./PE_SYN.sdf"	  // Modify your sdf file name
`define RTL
// `define GATE
`define End_CYCLE  10000      // Modify cycle times once your design need more cycle times!
`ifdef RTL
	`timescale 1ns/100ps
    `define CYCLE 10
	// `include "./pe_8v"
    
`endif
`ifdef GATE
	`timescale 1ns/1ps
    `define CYCLE 3.3
    
`endif

//=========================================
//++++
//=============================================



// E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT
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
// E:/yuan/v_code/proj0728/tb/sv_pe3x3/PAT/
//-----------------------------------------------------------------------------------------------------------



module sv_pe_testbench();

parameter TBITS = 64;
parameter TBYTE = 8;
parameter IFMAP_SIZE   = 173056;
parameter OFMAP_SIZE   = 346112;

reg [31:0] pe_gold [0:40];


logic               clk = 0;              //input  
logic reset = 0;


logic [63:0] ker_sram_0 [0:2047];
logic [63:0] ker_sram_1 [0:2047];
logic [63:0] ker_sram_2 [0:2047];
logic [63:0] ker_sram_3 [0:2047];
logic [63:0] ker_sram_4 [0:2047];
logic [63:0] ker_sram_5 [0:2047];
logic [63:0] ker_sram_6 [0:2047];
logic [63:0] ker_sram_7 [0:2047];


logic [63:0] ifmap_sram_0 [0:2047];
logic [63:0] ifmap_sram_1 [0:2047];
logic [63:0] ifmap_sram_2 [0:2047];
logic [63:0] ifmap_sram_3 [0:2047];
logic [63:0] ifmap_sram_4 [0:2047];
logic [63:0] ifmap_sram_5 [0:2047];
logic [63:0] ifmap_sram_6 [0:2047];
logic [63:0] ifmap_sram_7 [0:2047];

reg    [TBITS-1 : 0]      ifmap        [0:IFMAP_SIZE-1];
reg    [TBITS-1 : 0]      ofmap_gold   [0:OFMAP_SIZE-1];
reg [63:0 ] ann01 =0 ;
reg [63:0] knn00 [0:7]   ;


reg [ 63 : 0] act_shf [ 0 : 7 ] ;
reg [ 63 : 0] ker_shf [ 0 : 7 ] ;
reg [ 31 : 0] row_sumshf [ 0 : 7 ] ;



reg cv_start ;
reg cv_start_dly0;
reg cv_start_dly1;
reg cv_start_dly2;
reg cv_start_dly3;
reg cv_start_dly4;
reg cv_start_dly5;
reg cv_start_dly6;
reg cv_start_dly7;

reg f_flag ;	// final mac in one iteration 3*3 full channel 
reg final_fg_dly1;
reg final_fg_dly2;
reg final_fg_dly3;
reg final_fg_dly4;
reg final_fg_dly5;
reg final_fg_dly6;
reg final_fg_dly7;

reg v_flag	;
reg valid_fg_dly1	;
reg valid_fg_dly2	;
reg valid_fg_dly3	;
reg valid_fg_dly4	;
reg valid_fg_dly5	;
reg valid_fg_dly6	;
reg valid_fg_dly7	;

integer i0 , i1  ,cpt0;
integer k0,k1,k2,k3,k4,k5,k6,k7 ;
localparam KUNMM = 40 ;
localparam TE_FIR = 36	; //3*3*32/8



always begin #(`CYCLE/2) clk = ~clk; end

reg [30:0] cycle=0;
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
		$fsdbDumpfile("dla_top.fsdb");
		$fsdbDumpvars(0,"+mda","+packedmda");		//++
		$fsdbDumpMDA();
	`endif
	`ifdef GATE
		$sdf_annotate(`SDFFILE,top_U);
		$fsdbDumpfile("dla_top_SYN.fsdb");
		$fsdbDumpvars();
	`endif
end

initial begin // initial pattern and expected result
	wait(reset==1);
	$readmemh(`KSR_0, ker_sram_0);
	$readmemh(`KSR_1, ker_sram_1);
	$readmemh(`KSR_2, ker_sram_2);
	$readmemh(`KSR_3, ker_sram_3);
	$readmemh(`KSR_4, ker_sram_4);
	$readmemh(`KSR_5, ker_sram_5);
	$readmemh(`KSR_6, ker_sram_6);
	$readmemh(`KSR_7, ker_sram_7);
	$readmemh(`IFMAP_DAT, ifmap);
	$readmemh(`PEGD_DAT, pe_gold);
	for ( i1=0 ; i1<3 ; i1=i1+1 )begin
		for( i0=0; i0<(66*4) ; i0=i0+1) begin
			ifmap_sram_0[ i0+ i1*66*4 ] = ifmap[i0 + i1*208*4 ]	;	// 66col in each row
		end
	end
end
// initial begin

// 	for ( i1=0 ; i1<3 ; i1=i1+1 )begin
// 		for( i0=0; i0<284 ; i0=i0+1) begin
// 			ifmap_sram_0[ i0+ i1*66*4 ] = ifmap[i0 + i1*208*4 ]	;	// 66col in each row
// 		end
// 	end
// end



pe_8e  #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)r0p0(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(		act_shf[0][63-:8]		) ,
	.act_1(		act_shf[0][55-:8]		) ,
	.act_2(		act_shf[0][47-:8]		) ,
	.act_3(		act_shf[0][39-:8]		) ,
	.act_4(		act_shf[0][31-:8]		) ,
	.act_5(		act_shf[0][23-:8]		) ,
	.act_6(		act_shf[0][15-:8]		) ,
	.act_7(		act_shf[0][ 7-:8]		) ,
	.valid_in(	v_flag		) ,
	.final_in(	f_flag		) ,
	//---- kernel ----//
	.ker_0(		ker_shf[0][63-:8]		) ,
	.ker_1(		ker_shf[0][55-:8]		) ,
	.ker_2(		ker_shf[0][47-:8]		) ,
	.ker_3(		ker_shf[0][39-:8]		) ,
	.ker_4(		ker_shf[0][31-:8]		) ,
	.ker_5(		ker_shf[0][23-:8]		) ,
	.ker_6(		ker_shf[0][15-:8]		) ,
	.ker_7(		ker_shf[0][ 7-:8]		) ,
	//-----------------------------------------//
	// .valid_out	(				) ,
	.out_sum	(		row_sumshf[0]		)

);
pe_8e  #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)r0p1(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(		act_shf[1][63-:8]		) ,
	.act_1(		act_shf[1][55-:8]		) ,
	.act_2(		act_shf[1][47-:8]		) ,
	.act_3(		act_shf[1][39-:8]		) ,
	.act_4(		act_shf[1][31-:8]		) ,
	.act_5(		act_shf[1][23-:8]		) ,
	.act_6(		act_shf[1][15-:8]		) ,
	.act_7(		act_shf[1][ 7-:8]		) ,
	.valid_in(	valid_fg_dly1		) ,
	.final_in(	final_fg_dly1		) ,
	//---- kernel ----//
	.ker_0(		ker_shf[1][63-:8]		) ,
	.ker_1(		ker_shf[1][55-:8]		) ,
	.ker_2(		ker_shf[1][47-:8]		) ,
	.ker_3(		ker_shf[1][39-:8]		) ,
	.ker_4(		ker_shf[1][31-:8]		) ,
	.ker_5(		ker_shf[1][23-:8]		) ,
	.ker_6(		ker_shf[1][15-:8]		) ,
	.ker_7(		ker_shf[1][ 7-:8]		) ,
	//-----------------------------------------//
	// .valid_out	(				) ,
	.out_sum	(		row_sumshf[1]		)

);
pe_8e  #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)r0p2(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(		act_shf[2][63-:8]		) ,
	.act_1(		act_shf[2][55-:8]		) ,
	.act_2(		act_shf[2][47-:8]		) ,
	.act_3(		act_shf[2][39-:8]		) ,
	.act_4(		act_shf[2][31-:8]		) ,
	.act_5(		act_shf[2][23-:8]		) ,
	.act_6(		act_shf[2][15-:8]		) ,
	.act_7(		act_shf[2][ 7-:8]		) ,
	.valid_in(	valid_fg_dly2		) ,
	.final_in(	final_fg_dly2		) ,
	//---- kernel ----//
	.ker_0(		ker_shf[2][63-:8]		) ,
	.ker_1(		ker_shf[2][55-:8]		) ,
	.ker_2(		ker_shf[2][47-:8]		) ,
	.ker_3(		ker_shf[2][39-:8]		) ,
	.ker_4(		ker_shf[2][31-:8]		) ,
	.ker_5(		ker_shf[2][23-:8]		) ,
	.ker_6(		ker_shf[2][15-:8]		) ,
	.ker_7(		ker_shf[2][ 7-:8]		) ,
	//-----------------------------------------//
	// .valid_out	(				) ,
	.out_sum	(		row_sumshf[2]		)

);
pe_8e  #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)r0p3(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(		act_shf[3][63-:8]		) ,
	.act_1(		act_shf[3][55-:8]		) ,
	.act_2(		act_shf[3][47-:8]		) ,
	.act_3(		act_shf[3][39-:8]		) ,
	.act_4(		act_shf[3][31-:8]		) ,
	.act_5(		act_shf[3][23-:8]		) ,
	.act_6(		act_shf[3][15-:8]		) ,
	.act_7(		act_shf[3][ 7-:8]		) ,
	.valid_in(	valid_fg_dly3		) ,
	.final_in(	final_fg_dly3		) ,
	//---- kernel ----//
	.ker_0(		ker_shf[3][63-:8]		) ,
	.ker_1(		ker_shf[3][55-:8]		) ,
	.ker_2(		ker_shf[3][47-:8]		) ,
	.ker_3(		ker_shf[3][39-:8]		) ,
	.ker_4(		ker_shf[3][31-:8]		) ,
	.ker_5(		ker_shf[3][23-:8]		) ,
	.ker_6(		ker_shf[3][15-:8]		) ,
	.ker_7(		ker_shf[3][ 7-:8]		) ,
	//-----------------------------------------//
	// .valid_out	(				) ,
	.out_sum	(		row_sumshf[3]		)

);
pe_8e  #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)r0p4(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(		act_shf[4][63-:8]		) ,
	.act_1(		act_shf[4][55-:8]		) ,
	.act_2(		act_shf[4][47-:8]		) ,
	.act_3(		act_shf[4][39-:8]		) ,
	.act_4(		act_shf[4][31-:8]		) ,
	.act_5(		act_shf[4][23-:8]		) ,
	.act_6(		act_shf[4][15-:8]		) ,
	.act_7(		act_shf[4][ 7-:8]		) ,
	.valid_in(	valid_fg_dly4		) ,
	.final_in(	final_fg_dly4		) ,
	//---- kernel ----//
	.ker_0(		ker_shf[4][63-:8]		) ,
	.ker_1(		ker_shf[4][55-:8]		) ,
	.ker_2(		ker_shf[4][47-:8]		) ,
	.ker_3(		ker_shf[4][39-:8]		) ,
	.ker_4(		ker_shf[4][31-:8]		) ,
	.ker_5(		ker_shf[4][23-:8]		) ,
	.ker_6(		ker_shf[4][15-:8]		) ,
	.ker_7(		ker_shf[4][ 7-:8]		) ,
	//-----------------------------------------//
	// .valid_out	(				) ,
	.out_sum	(		row_sumshf[4]		)

);
pe_8e  #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)r0p5(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(		act_shf[5][63-:8]		) ,
	.act_1(		act_shf[5][55-:8]		) ,
	.act_2(		act_shf[5][47-:8]		) ,
	.act_3(		act_shf[5][39-:8]		) ,
	.act_4(		act_shf[5][31-:8]		) ,
	.act_5(		act_shf[5][23-:8]		) ,
	.act_6(		act_shf[5][15-:8]		) ,
	.act_7(		act_shf[5][ 7-:8]		) ,
	.valid_in(	valid_fg_dly5		) ,
	.final_in(	final_fg_dly5		) ,
	//---- kernel ----//
	.ker_0(		ker_shf[5][63-:8]		) ,
	.ker_1(		ker_shf[5][55-:8]		) ,
	.ker_2(		ker_shf[5][47-:8]		) ,
	.ker_3(		ker_shf[5][39-:8]		) ,
	.ker_4(		ker_shf[5][31-:8]		) ,
	.ker_5(		ker_shf[5][23-:8]		) ,
	.ker_6(		ker_shf[5][15-:8]		) ,
	.ker_7(		ker_shf[5][ 7-:8]		) ,
	//-----------------------------------------//
	// .valid_out	(				) ,
	.out_sum	(		row_sumshf[5]		)

);
pe_8e  #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)r0p6(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(		act_shf[6][63-:8]		) ,
	.act_1(		act_shf[6][55-:8]		) ,
	.act_2(		act_shf[6][47-:8]		) ,
	.act_3(		act_shf[6][39-:8]		) ,
	.act_4(		act_shf[6][31-:8]		) ,
	.act_5(		act_shf[6][23-:8]		) ,
	.act_6(		act_shf[6][15-:8]		) ,
	.act_7(		act_shf[6][ 7-:8]		) ,
	.valid_in(	valid_fg_dly6		) ,
	.final_in(	final_fg_dly6		) ,
	//---- kernel ----//
	.ker_0(		ker_shf[6][63-:8]		) ,
	.ker_1(		ker_shf[6][55-:8]		) ,
	.ker_2(		ker_shf[6][47-:8]		) ,
	.ker_3(		ker_shf[6][39-:8]		) ,
	.ker_4(		ker_shf[6][31-:8]		) ,
	.ker_5(		ker_shf[6][23-:8]		) ,
	.ker_6(		ker_shf[6][15-:8]		) ,
	.ker_7(		ker_shf[6][ 7-:8]		) ,
	//-----------------------------------------//
	// .valid_out	(				) ,
	.out_sum	(		row_sumshf[6]		)

);
pe_8e  #(
	.ELE_BITS(	8 	),
	.OUT_BITS(	32	)
)r0p7(
	.clk	(	clk		),
	.reset(		reset		) ,
	.act_0(		act_shf[7][63-:8]		) ,
	.act_1(		act_shf[7][55-:8]		) ,
	.act_2(		act_shf[7][47-:8]		) ,
	.act_3(		act_shf[7][39-:8]		) ,
	.act_4(		act_shf[7][31-:8]		) ,
	.act_5(		act_shf[7][23-:8]		) ,
	.act_6(		act_shf[7][15-:8]		) ,
	.act_7(		act_shf[7][ 7-:8]		) ,
	.valid_in(	valid_fg_dly7		) ,
	.final_in(	final_fg_dly7		) ,
	//---- kernel ----//
	.ker_0(		ker_shf[7][63-:8]		) ,
	.ker_1(		ker_shf[7][55-:8]		) ,
	.ker_2(		ker_shf[7][47-:8]		) ,
	.ker_3(		ker_shf[7][39-:8]		) ,
	.ker_4(		ker_shf[7][31-:8]		) ,
	.ker_5(		ker_shf[7][23-:8]		) ,
	.ker_6(		ker_shf[7][15-:8]		) ,
	.ker_7(		ker_shf[7][ 7-:8]		) ,
	//-----------------------------------------//
	// .valid_out	(				) ,
	.out_sum	(		row_sumshf[7]		)

);






always@( posedge clk )begin
	act_shf[0] <= ann01 ;
	act_shf[1] <= act_shf[0] ;
	act_shf[2] <= act_shf[1] ;
	act_shf[3] <= act_shf[2] ;
	act_shf[4] <= act_shf[3] ;
	act_shf[5] <= act_shf[4] ;
	act_shf[6] <= act_shf[5] ;
	act_shf[7] <= act_shf[6] ;

	ker_shf[0] <= knn00 [0] ;
	ker_shf[1] <= knn00 [1] ;
	ker_shf[2] <= knn00 [2] ;
	ker_shf[3] <= knn00 [3] ;
	ker_shf[4] <= knn00 [4] ;
	ker_shf[5] <= knn00 [5] ;
	ker_shf[6] <= knn00 [6] ;
	ker_shf[7] <= knn00 [7] ;

	final_fg_dly1	<= f_flag ;
	final_fg_dly2	<= final_fg_dly1 ;
	final_fg_dly3	<= final_fg_dly2 ;
	final_fg_dly4	<= final_fg_dly3 ;
	final_fg_dly5	<= final_fg_dly4 ;
	final_fg_dly6	<= final_fg_dly5 ;
	final_fg_dly7	<= final_fg_dly6 ;

	valid_fg_dly1	<= v_flag ;
	valid_fg_dly2	<= valid_fg_dly1 ;
	valid_fg_dly3	<= valid_fg_dly2 ;
	valid_fg_dly4	<= valid_fg_dly3 ;
	valid_fg_dly5	<= valid_fg_dly4 ;
	valid_fg_dly6	<= valid_fg_dly5 ;
	valid_fg_dly7	<= valid_fg_dly6 ;
	
end



always@(posedge clk )begin
	cv_start_dly0	<= cv_start			;
	cv_start_dly1	<= cv_start_dly0	;
	cv_start_dly2	<= cv_start_dly1	;
	cv_start_dly3	<= cv_start_dly2	;
	cv_start_dly4	<= cv_start_dly3	;
	cv_start_dly5	<= cv_start_dly4	;
	cv_start_dly6	<= cv_start_dly5	;
	cv_start_dly7	<= cv_start_dly6	;
end


initial begin
	#1;
	#(`CYCLE*2);
	reset = 0;
	#(`CYCLE*3);
	reset = 1;
	cv_start =0;
	f_flag =0 ;
	v_flag = 0 ;
	#(`CYCLE*5);
	reset = 0;
	@(posedge clk); 
	cv_start =1;

	wait( cv_start_dly1);
	v_flag = 1 ;	// take 12 address get 1 row data for convolution
	for ( cpt0=0 ; cpt0<3 ; cpt0=cpt0+1 )begin
		for( i0=0 ; i0<12 ; i0=i0+1 )begin
			@(negedge clk); 
			ann01 = ifmap_sram_0[ i0 + cpt0*66*4 ];
			// ker_shf[0] = ker_sram_0[ i0 ];

		end
	end
	
	
	
	f_flag =1 ;		
	@(negedge clk) ;
	v_flag = 0 ;
	f_flag =0 ;	





end


initial begin
	wait( cv_start_dly0);
	for( k0=0 ; k0<TE_FIR ; k0=k0+1 )begin
		@(posedge  clk); 
		knn00 [0] = ker_sram_0 [k0 ];
	end

end
initial begin

	wait( cv_start_dly1);
	for( k1=0 ; k1<TE_FIR ; k1=k1+1 )begin
		@(posedge clk); 
		knn00 [1] = ker_sram_1 [k1 ];
	end
end
initial begin
	wait( cv_start_dly2);
		for( k2=0 ; k2<TE_FIR ; k2=k2+1 )begin
			@(posedge clk); 
			knn00 [2] = ker_sram_2 [k2 ];
		end

end
initial begin
	wait( cv_start_dly3);
		for( k3=0 ; k3<TE_FIR ; k3=k3+1 )begin
			@(posedge clk); 
			knn00 [3] = ker_sram_3 [k3 ];
		end

end
initial begin
	wait( cv_start_dly4);
		for( k4=0 ; k4<TE_FIR ; k4=k4+1 )begin
			@(posedge clk); 
			knn00 [4] = ker_sram_0 [k4 ];
		end

end
initial begin
	wait( cv_start_dly5);
		for( k5=0 ; k5<TE_FIR ; k5=k5+1 )begin
			@(posedge clk); 
			knn00 [5] = ker_sram_0 [k5 ];
		end

end
initial begin
	wait( cv_start_dly6);
		for( k6=0 ; k6<TE_FIR ; k6=k6+1 )begin
			@(posedge clk); 
			knn00 [6] = ker_sram_0 [k6 ];
		end

end
initial begin
	wait( cv_start_dly7);
		for( k7=0 ; k7<TE_FIR ; k7=k7+1 )begin
			@(posedge clk); 
			knn00 [7] = ker_sram_0 [k7 ];
		end

end



	// for ( i0 = 0; i0 < 12 ; i0 = i0 + 1 ) begin
		
	// end



endmodule