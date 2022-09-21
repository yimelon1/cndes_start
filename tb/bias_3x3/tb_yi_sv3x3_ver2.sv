// =================================================================================
// function : 3x3 with 8 PE compute MAC and BIAS addition
// =================================================================================


`define SDFFILE    "./PE_SYN.sdf"	  // Modify your sdf file name
`define VIVA
// `define RTL

`define End_CYCLE  10000      // Modify cycle times once your design need more cycle times!
`ifdef RTL
	`timescale 1ns/100ps
    `define CYCLE 10
	// `include "./pe_8v"
`endif
`ifdef VIVA
	`timescale 1ns/100ps
    `define CYCLE 10
	// `include "./pe_8v"
`endif

`define PATH_LOG "E:/yuan/v_code/proj0728/tb/bias_3x3log.txt"

`ifdef VIVA
	`define KER_DAT "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/2_w.dat"
	`define KSR_0 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_0.dat"
	`define KSR_1 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_1.dat"
	`define KSR_2 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_2.dat"
	`define KSR_3 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_3.dat"
	`define KSR_4 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_4.dat"
	`define KSR_5 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_5.dat"
	`define KSR_6 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_6.dat"
	`define KSR_7 "E:/yuan/v_code/proj0728/tb/svyyy33/PAT/w_sr/wsram_pat_7.dat"
	`define IFMAP_DAT 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/2_in.dat"
	`define PEGD_DAT 	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/pe_out/peout.dat"
	`define BIAS_DAT	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/2_bias.dat"
	`define BIAS_BUF0	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/bias_buffer/2b_buff0.dat"
	`define BIAS_BUF1	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/bias_buffer/2b_buff1.dat"
	`define BIAS_BUF2	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/bias_buffer/2b_buff2.dat"
	`define BIAS_BUF3	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/bias_buffer/2b_buff3.dat"
	`define BIAS_BUF4	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/bias_buffer/2b_buff4.dat"
	`define BIAS_BUF5	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/bias_buffer/2b_buff5.dat"
	`define BIAS_BUF6	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/bias_buffer/2b_buff6.dat"
	`define BIAS_BUF7	"E:/yuan/v_code/proj0728/tb/lay2_yi_pe_pattern/PAT/bias_buffer/2b_buff7.dat"

`else
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
`endif 


//=========================================
//++++
//=============================================

//-----------------------------------------------------------------------------------------------------------



module sv_pe_testbench();

parameter TBITS = 64;
parameter TBYTE = 8;
parameter IFMAP_SIZE   = 173056;
parameter OFMAP_SIZE   = 346112;

reg [31:0] pe_gold [0:511];


localparam LO_STRIDE = 8 ;
localparam KERPART = 8;		// 64ker/8 = 8

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


//  bias buffer 
reg [ 31 : 0 ] bias_pat		[ 0 : 127];
reg [ 31 : 0 ] bias_reg_0 [ 0 : 15 ];
reg [ 31 : 0 ] bias_reg_1 [ 0 : 15 ];
reg [ 31 : 0 ] bias_reg_2 [ 0 : 15 ];
reg [ 31 : 0 ] bias_reg_3 [ 0 : 15 ];
reg [ 31 : 0 ] bias_reg_4 [ 0 : 15 ];
reg [ 31 : 0 ] bias_reg_5 [ 0 : 15 ];
reg [ 31 : 0 ] bias_reg_6 [ 0 : 15 ];
reg [ 31 : 0 ] bias_reg_7 [ 0 : 15 ];

//----bias declare start------ 
reg signed [31:0] bi_con_0 , bi_con_1 , bi_con_2 , bi_con_3 , bi_con_4 , bi_con_5 , bi_con_6 , bi_con_7 ;
reg signed [3:0] bi_offset_0 , bi_offset_1 , bi_offset_2 , bi_offset_3 , bi_offset_4 , bi_offset_5 , bi_offset_6 , bi_offset_7 ;
reg signed [31:0]	bi_con_0_dly0ed  	;
reg signed [31:0]	bi_con_1_dly0ed  	;
reg signed [31:0]	bi_con_2_dly0ed  	;
reg signed [31:0]	bi_con_3_dly0ed  	;
reg signed [31:0]	bi_con_4_dly0ed  	;
reg signed [31:0]	bi_con_5_dly0ed  	;
reg signed [31:0]	bi_con_6_dly0ed  	;
reg signed [31:0]	bi_con_7_dly0ed  	;
reg [3:0]  bi_offset_0_dly0ed  ;
reg [3:0]  bi_offset_1_dly0ed  ;
reg [3:0]  bi_offset_2_dly0ed  ;
reg [3:0]  bi_offset_3_dly0ed  ;
reg [3:0]  bi_offset_4_dly0ed  ;
reg [3:0]  bi_offset_5_dly0ed  ;
reg [3:0]  bi_offset_6_dly0ed  ;
reg [3:0]  bi_offset_7_dly0ed  ;
reg signed [31:0]	bi_con_0_dly0 ;
reg signed [31:0]	bi_con_1_dly0 ;
reg signed [31:0]	bi_con_2_dly0 ;
reg signed [31:0]	bi_con_3_dly0 ;
reg signed [31:0]	bi_con_4_dly0 ;
reg signed [31:0]	bi_con_5_dly0 ;
reg signed [31:0]	bi_con_6_dly0 ;
reg signed [31:0]	bi_con_7_dly0 ;
reg [3:0]  bi_offset_0_dly0  ;
reg [3:0]  bi_offset_1_dly0  ;
reg [3:0]  bi_offset_2_dly0  ;
reg [3:0]  bi_offset_3_dly0  ;
reg [3:0]  bi_offset_4_dly0  ;
reg [3:0]  bi_offset_5_dly0  ;
reg [3:0]  bi_offset_6_dly0  ;
reg [3:0]  bi_offset_7_dly0  ;
//----bias declare end------ 


reg cmput_done ;

reg tb_memread_done ;
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
reg f_flag_ed ;
reg f_flag_ed1 ;
reg f_flag_ed2 ;
reg final_fg_dly0;
reg final_fg_dly1;
reg final_fg_dly2;
reg final_fg_dly3;
reg final_fg_dly4;
reg final_fg_dly5;
reg final_fg_dly6;
reg final_fg_dly7;

reg v_flag	;
reg v_flag_ed		;
reg v_flag_ed1		;

reg valid_fg_dly0	;
reg valid_fg_dly1	;
reg valid_fg_dly2	;
reg valid_fg_dly3	;
reg valid_fg_dly4	;
reg valid_fg_dly5	;
reg valid_fg_dly6	;
reg valid_fg_dly7	;

integer i0 , i1  ,cpt0 , cpt1;
integer kcpt ;

integer k0,k1,k2,k3,k4,k5,k6,k7 ;
integer krr0,krr1,krr2,krr3,krr4,krr5,krr6,krr7 ;
localparam KUNMM = 40 ;
localparam TE_FIR = 36	; //3*3*32/8

wire q_valid [0:7] ;


wire pe_seqout_valid ;
wire signed [ 31 : 0 ] pe_seqout_data ;





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
	$readmemh(`BIAS_DAT, bias_pat);
	$readmemh(`BIAS_BUF0, bias_reg_0);
	$readmemh(`BIAS_BUF1, bias_reg_1);
	$readmemh(`BIAS_BUF2, bias_reg_2);
	$readmemh(`BIAS_BUF3, bias_reg_3);
	$readmemh(`BIAS_BUF4, bias_reg_4);
	$readmemh(`BIAS_BUF5, bias_reg_5);
	$readmemh(`BIAS_BUF6, bias_reg_6);
	$readmemh(`BIAS_BUF7, bias_reg_7);

	for ( i1=0 ; i1<3 ; i1=i1+1 )begin
		for( i0=0; i0<(66*4) ; i0=i0+1) begin
			ifmap_sram_0[ i0+ i1*66*4 ] = ifmap[i0 + i1*208*4 ]	;	// 66col in each row
		end
	end
	#1;
	tb_memread_done = 1;

end




//----instance pe with bias start------ 
//----pe row0 col_0---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_0(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[0][63-:8] ) , .act_1( act_shf[0][55-:8] ) , .act_2( act_shf[0][47-:8] ) , .act_3( act_shf[0][39-:8] ) , .act_4( act_shf[0][31-:8] ) , .act_5( act_shf[0][23-:8] ) , .act_6( act_shf[0][15-:8] ) , .act_7( act_shf[0][ 7-:8] ) , .valid_in( valid_fg_dly0 ) ,.final_in( final_fg_dly0 ) ,
//---- kernel ----//
.ker_0( ker_shf[0][63-:8] ) , .ker_1( ker_shf[0][55-:8] ) , .ker_2( ker_shf[0][47-:8] ) , .ker_3( ker_shf[0][39-:8] ) , .ker_4( ker_shf[0][31-:8] ) , .ker_5( ker_shf[0][23-:8] ) , .ker_6( ker_shf[0][15-:8] ) , .ker_7( ker_shf[0][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_0_dly0 ), .bias_offset( bi_offset_0_dly0 ), .valid_out ( q_valid[0] ) ,.out_sum ( row_sumshf[0] ) );
//----pe row0 col_1---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_1(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[1][63-:8] ) , .act_1( act_shf[1][55-:8] ) , .act_2( act_shf[1][47-:8] ) , .act_3( act_shf[1][39-:8] ) , .act_4( act_shf[1][31-:8] ) , .act_5( act_shf[1][23-:8] ) , .act_6( act_shf[1][15-:8] ) , .act_7( act_shf[1][ 7-:8] ) , .valid_in( valid_fg_dly1 ) ,.final_in( final_fg_dly1 ) ,
//---- kernel ----//
.ker_0( ker_shf[1][63-:8] ) , .ker_1( ker_shf[1][55-:8] ) , .ker_2( ker_shf[1][47-:8] ) , .ker_3( ker_shf[1][39-:8] ) , .ker_4( ker_shf[1][31-:8] ) , .ker_5( ker_shf[1][23-:8] ) , .ker_6( ker_shf[1][15-:8] ) , .ker_7( ker_shf[1][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_1_dly0 ), .bias_offset( bi_offset_1_dly0 ), .valid_out ( q_valid[1] ) ,.out_sum ( row_sumshf[1] ) );
//----pe row0 col_2---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_2(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[2][63-:8] ) , .act_1( act_shf[2][55-:8] ) , .act_2( act_shf[2][47-:8] ) , .act_3( act_shf[2][39-:8] ) , .act_4( act_shf[2][31-:8] ) , .act_5( act_shf[2][23-:8] ) , .act_6( act_shf[2][15-:8] ) , .act_7( act_shf[2][ 7-:8] ) , .valid_in( valid_fg_dly2 ) ,.final_in( final_fg_dly2 ) ,
//---- kernel ----//
.ker_0( ker_shf[2][63-:8] ) , .ker_1( ker_shf[2][55-:8] ) , .ker_2( ker_shf[2][47-:8] ) , .ker_3( ker_shf[2][39-:8] ) , .ker_4( ker_shf[2][31-:8] ) , .ker_5( ker_shf[2][23-:8] ) , .ker_6( ker_shf[2][15-:8] ) , .ker_7( ker_shf[2][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_2_dly0 ), .bias_offset( bi_offset_2_dly0 ), .valid_out ( q_valid[2] ) ,.out_sum ( row_sumshf[2] ) );
//----pe row0 col_3---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_3(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[3][63-:8] ) , .act_1( act_shf[3][55-:8] ) , .act_2( act_shf[3][47-:8] ) , .act_3( act_shf[3][39-:8] ) , .act_4( act_shf[3][31-:8] ) , .act_5( act_shf[3][23-:8] ) , .act_6( act_shf[3][15-:8] ) , .act_7( act_shf[3][ 7-:8] ) , .valid_in( valid_fg_dly3 ) ,.final_in( final_fg_dly3 ) ,
//---- kernel ----//
.ker_0( ker_shf[3][63-:8] ) , .ker_1( ker_shf[3][55-:8] ) , .ker_2( ker_shf[3][47-:8] ) , .ker_3( ker_shf[3][39-:8] ) , .ker_4( ker_shf[3][31-:8] ) , .ker_5( ker_shf[3][23-:8] ) , .ker_6( ker_shf[3][15-:8] ) , .ker_7( ker_shf[3][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_3_dly0 ), .bias_offset( bi_offset_3_dly0 ), .valid_out ( q_valid[3] ) ,.out_sum ( row_sumshf[3] ) );
//----pe row0 col_4---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_4(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[4][63-:8] ) , .act_1( act_shf[4][55-:8] ) , .act_2( act_shf[4][47-:8] ) , .act_3( act_shf[4][39-:8] ) , .act_4( act_shf[4][31-:8] ) , .act_5( act_shf[4][23-:8] ) , .act_6( act_shf[4][15-:8] ) , .act_7( act_shf[4][ 7-:8] ) , .valid_in( valid_fg_dly4 ) ,.final_in( final_fg_dly4 ) ,
//---- kernel ----//
.ker_0( ker_shf[4][63-:8] ) , .ker_1( ker_shf[4][55-:8] ) , .ker_2( ker_shf[4][47-:8] ) , .ker_3( ker_shf[4][39-:8] ) , .ker_4( ker_shf[4][31-:8] ) , .ker_5( ker_shf[4][23-:8] ) , .ker_6( ker_shf[4][15-:8] ) , .ker_7( ker_shf[4][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_4_dly0 ), .bias_offset( bi_offset_4_dly0 ), .valid_out ( q_valid[4] ) ,.out_sum ( row_sumshf[4] ) );
//----pe row0 col_5---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_5(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[5][63-:8] ) , .act_1( act_shf[5][55-:8] ) , .act_2( act_shf[5][47-:8] ) , .act_3( act_shf[5][39-:8] ) , .act_4( act_shf[5][31-:8] ) , .act_5( act_shf[5][23-:8] ) , .act_6( act_shf[5][15-:8] ) , .act_7( act_shf[5][ 7-:8] ) , .valid_in( valid_fg_dly5 ) ,.final_in( final_fg_dly5 ) ,
//---- kernel ----//
.ker_0( ker_shf[5][63-:8] ) , .ker_1( ker_shf[5][55-:8] ) , .ker_2( ker_shf[5][47-:8] ) , .ker_3( ker_shf[5][39-:8] ) , .ker_4( ker_shf[5][31-:8] ) , .ker_5( ker_shf[5][23-:8] ) , .ker_6( ker_shf[5][15-:8] ) , .ker_7( ker_shf[5][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_5_dly0 ), .bias_offset( bi_offset_5_dly0 ), .valid_out ( q_valid[5] ) ,.out_sum ( row_sumshf[5] ) );
//----pe row0 col_6---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_6(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[6][63-:8] ) , .act_1( act_shf[6][55-:8] ) , .act_2( act_shf[6][47-:8] ) , .act_3( act_shf[6][39-:8] ) , .act_4( act_shf[6][31-:8] ) , .act_5( act_shf[6][23-:8] ) , .act_6( act_shf[6][15-:8] ) , .act_7( act_shf[6][ 7-:8] ) , .valid_in( valid_fg_dly6 ) ,.final_in( final_fg_dly6 ) ,
//---- kernel ----//
.ker_0( ker_shf[6][63-:8] ) , .ker_1( ker_shf[6][55-:8] ) , .ker_2( ker_shf[6][47-:8] ) , .ker_3( ker_shf[6][39-:8] ) , .ker_4( ker_shf[6][31-:8] ) , .ker_5( ker_shf[6][23-:8] ) , .ker_6( ker_shf[6][15-:8] ) , .ker_7( ker_shf[6][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_6_dly0 ), .bias_offset( bi_offset_6_dly0 ), .valid_out ( q_valid[6] ) ,.out_sum ( row_sumshf[6] ) );
//----pe row0 col_7---------
pe_8e  #(    .ELE_BITS(	8 	),     .OUT_BITS(	32	),     .BIAS_BITS(	32	) 
)pe_r0_col_7(.clk ( clk ),  .reset ( reset ), 
.act_0( act_shf[7][63-:8] ) , .act_1( act_shf[7][55-:8] ) , .act_2( act_shf[7][47-:8] ) , .act_3( act_shf[7][39-:8] ) , .act_4( act_shf[7][31-:8] ) , .act_5( act_shf[7][23-:8] ) , .act_6( act_shf[7][15-:8] ) , .act_7( act_shf[7][ 7-:8] ) , .valid_in( valid_fg_dly7 ) ,.final_in( final_fg_dly7 ) ,
//---- kernel ----//
.ker_0( ker_shf[7][63-:8] ) , .ker_1( ker_shf[7][55-:8] ) , .ker_2( ker_shf[7][47-:8] ) , .ker_3( ker_shf[7][39-:8] ) , .ker_4( ker_shf[7][31-:8] ) , .ker_5( ker_shf[7][23-:8] ) , .ker_6( ker_shf[7][15-:8] ) , .ker_7( ker_shf[7][ 7-:8] ) , //---- bias ----//
.bias_in	( bi_con_7_dly0 ), .bias_offset( bi_offset_7_dly0 ), .valid_out ( q_valid[7] ) ,.out_sum ( row_sumshf[7] ) );
//----instance pe with bias end------ 



//-------PE output result serial out module -----------------
// //------queue for pe output-------------
getpe_result #(
	.INV_BITS( 1 ),
	.QOUT_BITS( 32 )
) resu_row0(
	.clk 	( clk ),
	.reset 	( reset ),
	.pe0_result (	{		q_valid[0]		,row_sumshf[0]}	),
	.pe1_result (	{		q_valid[1]		,row_sumshf[1]}	),
	.pe2_result (	{		q_valid[2]		,row_sumshf[2]}	),
	.pe3_result (	{		q_valid[3]		,row_sumshf[3]}	),
	.pe4_result (	{		q_valid[4]		,row_sumshf[4]}	),
	.pe5_result (	{		q_valid[5]		,row_sumshf[5]}	),
	.pe6_result (	{		q_valid[6]		,row_sumshf[6]}	),
	.pe7_result (	{		q_valid[7]		,row_sumshf[7]}	),
	.valid_out 		(	pe_seqout_valid	),
	.serial_result	(	pe_seqout_data	)
);
//-------PE output result serial out module -----------------


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

	f_flag_ed 		<= f_flag	;
	f_flag_ed1		<= f_flag_ed ;
	f_flag_ed2		<= f_flag_ed1 ;
	final_fg_dly0	<= f_flag_ed ;
	final_fg_dly1	<= final_fg_dly0 ;
	final_fg_dly2	<= final_fg_dly1 ;
	final_fg_dly3	<= final_fg_dly2 ;
	final_fg_dly4	<= final_fg_dly3 ;
	final_fg_dly5	<= final_fg_dly4 ;
	final_fg_dly6	<= final_fg_dly5 ;
	final_fg_dly7	<= final_fg_dly6 ;


	v_flag_ed	<= v_flag ;
	v_flag_ed1		<= v_flag_ed ;
	valid_fg_dly0	<= v_flag ;
	valid_fg_dly1	<= valid_fg_dly0 ;
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
	cmput_done = 0;
	
	#(`CYCLE*5);
	reset = 0;

	wait( tb_memread_done );
	#1 ;
	@(posedge clk); 
	cv_start =1;

	wait( cv_start_dly1);
		// take 12 address get 1 row data for convolution
	for ( cpt1=0 ; cpt1< LO_STRIDE  ; cpt1=cpt1 + 1 )begin
		for( kcpt=0 ; kcpt< KERPART ; kcpt=kcpt+1 )begin
			for ( cpt0=0 ; cpt0<3 ; cpt0=cpt0+1 )begin
				for( i0=0 ; i0<12 ; i0=i0+1 )begin
					@(negedge clk); 
					ann01 = ifmap_sram_0[ i0 + cpt0*66*4 + cpt1*4];
					// ker_shf[0] = ker_sram_0[ i0 ];

				end
				i0 = 0 ;
			end
			cpt0 =0 ;
		end
		kcpt=0;

	end
	cpt1 = 0 ;

	@(posedge clk); 
	cv_start =0;

	#(`CYCLE*20);
	@(posedge clk); 
	cmput_done = 1;

end

always@( * )begin
	if( cv_start_dly0 )begin
		// if( i0==11 && cpt0==2 && cpt1==LO_STRIDE-1)begin
		// 	v_flag =0 ;
		// end
		// else begin
		// 	v_flag =1 ;
		// end
		v_flag =1 ;
	end
	else begin
		v_flag =0 ;
	end

end


always@( * )begin
	if( cv_start_dly1 )begin
		if( cpt0 == 2 && i0 == 11 )begin
			f_flag =1 ;	
		end
		else begin
			f_flag =0 ;	
		end
	end
	else begin
		f_flag =0 ;
	end

end


//----bias data combinational start------ 
always@( * )begin
    bi_con_0 = 	(cv_start_dly0 ) ? bias_reg_0[krr0] : 'd0 ;    //for kerSR0--
    bi_offset_0 = (cv_start_dly0 ) ? krr0 : 'd0 ;    //for kerSR0--
    bi_con_1 = 	(cv_start_dly1 ) ? bias_reg_1[krr1] : 'd0 ;    //for kerSR1--
    bi_offset_1 = (cv_start_dly1 ) ? krr1 : 'd0 ;    //for kerSR1--
    bi_con_2 = 	(cv_start_dly2 ) ? bias_reg_2[krr2] : 'd0 ;    //for kerSR2--
    bi_offset_2 = (cv_start_dly2 ) ? krr2 : 'd0 ;    //for kerSR2--
    bi_con_3 = 	(cv_start_dly3 ) ? bias_reg_3[krr3] : 'd0 ;    //for kerSR3--
    bi_offset_3 = (cv_start_dly3 ) ? krr3 : 'd0 ;    //for kerSR3--
    bi_con_4 = 	(cv_start_dly4 ) ? bias_reg_4[krr4] : 'd0 ;    //for kerSR4--
    bi_offset_4 = (cv_start_dly4 ) ? krr4 : 'd0 ;    //for kerSR4--
    bi_con_5 = 	(cv_start_dly5 ) ? bias_reg_5[krr5] : 'd0 ;    //for kerSR5--
    bi_offset_5 = (cv_start_dly5 ) ? krr5 : 'd0 ;    //for kerSR5--
    bi_con_6 = 	(cv_start_dly6 ) ? bias_reg_6[krr6] : 'd0 ;    //for kerSR6--
    bi_offset_6 = (cv_start_dly6 ) ? krr6 : 'd0 ;    //for kerSR6--
    bi_con_7 = 	(cv_start_dly7 ) ? bias_reg_7[krr7] : 'd0 ;    //for kerSR7--
    bi_offset_7 = (cv_start_dly7 ) ? krr7 : 'd0 ;    //for kerSR7--
end
//----bias data combinational end------ 
//----bias data seq start------ 
always@(posedge clk )begin
//----bias data for kerSR0 ---------
    bi_con_0_dly0ed <= bi_con_0 ;
    bi_con_0_dly0 <= bi_con_0_dly0ed;
    bi_offset_0_dly0ed <= bi_offset_0;
    bi_offset_0_dly0 <= bi_offset_0_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR1 ---------
    bi_con_1_dly0ed <= bi_con_1 ;
    bi_con_1_dly0 <= bi_con_1_dly0ed;
    bi_offset_1_dly0ed <= bi_offset_1;
    bi_offset_1_dly0 <= bi_offset_1_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR2 ---------
    bi_con_2_dly0ed <= bi_con_2 ;
    bi_con_2_dly0 <= bi_con_2_dly0ed;
    bi_offset_2_dly0ed <= bi_offset_2;
    bi_offset_2_dly0 <= bi_offset_2_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR3 ---------
    bi_con_3_dly0ed <= bi_con_3 ;
    bi_con_3_dly0 <= bi_con_3_dly0ed;
    bi_offset_3_dly0ed <= bi_offset_3;
    bi_offset_3_dly0 <= bi_offset_3_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR4 ---------
    bi_con_4_dly0ed <= bi_con_4 ;
    bi_con_4_dly0 <= bi_con_4_dly0ed;
    bi_offset_4_dly0ed <= bi_offset_4;
    bi_offset_4_dly0 <= bi_offset_4_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR5 ---------
    bi_con_5_dly0ed <= bi_con_5 ;
    bi_con_5_dly0 <= bi_con_5_dly0ed;
    bi_offset_5_dly0ed <= bi_offset_5;
    bi_offset_5_dly0 <= bi_offset_5_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR6 ---------
    bi_con_6_dly0ed <= bi_con_6 ;
    bi_con_6_dly0 <= bi_con_6_dly0ed;
    bi_offset_6_dly0ed <= bi_offset_6;
    bi_offset_6_dly0 <= bi_offset_6_dly0ed;	// cause bias need to Synchronize with final act and ker
//----bias data for kerSR7 ---------
    bi_con_7_dly0ed <= bi_con_7 ;
    bi_con_7_dly0 <= bi_con_7_dly0ed;
    bi_offset_7_dly0ed <= bi_offset_7;
    bi_offset_7_dly0 <= bi_offset_7_dly0ed;	// cause bias need to Synchronize with final act and ker
end
//----bias data seq end------ 



//----tb ker address count generate start------ 
//----keraddress_0---------
initial begin
    wait( cv_start_dly0);
    while( cv_start_dly0 )begin
        for( krr0=0 ; krr0<KERPART ; krr0=krr0 +1 )begin
            for( k0=0 ; k0<TE_FIR ; k0=k0+1 )begin
                @(posedge  clk);
                knn00 [0] = ker_sram_0 [k0 + krr0*36 ];
            end
            k0=0 ;
        end
        krr0=0 ;
    end
end
//----keraddress_1---------
initial begin
    wait( cv_start_dly1);
    while( cv_start_dly1 )begin
        for( krr1=0 ; krr1<KERPART ; krr1=krr1 +1 )begin
            for( k1=0 ; k1<TE_FIR ; k1=k1+1 )begin
                @(posedge  clk);
                knn00 [1] = ker_sram_1 [k1 + krr1*36 ];
            end
            k1=0 ;
        end
        krr1=0 ;
    end
end
//----keraddress_2---------
initial begin
    wait( cv_start_dly2);
    while( cv_start_dly2 )begin
        for( krr2=0 ; krr2<KERPART ; krr2=krr2 +1 )begin
            for( k2=0 ; k2<TE_FIR ; k2=k2+1 )begin
                @(posedge  clk);
                knn00 [2] = ker_sram_2 [k2 + krr2*36 ];
            end
            k2=0 ;
        end
        krr2=0 ;
    end
end
//----keraddress_3---------
initial begin
    wait( cv_start_dly3);
    while( cv_start_dly3 )begin
        for( krr3=0 ; krr3<KERPART ; krr3=krr3 +1 )begin
            for( k3=0 ; k3<TE_FIR ; k3=k3+1 )begin
                @(posedge  clk);
                knn00 [3] = ker_sram_3 [k3 + krr3*36 ];
            end
            k3=0 ;
        end
        krr3=0 ;
    end
end
//----keraddress_4---------
initial begin
    wait( cv_start_dly4);
    while( cv_start_dly4 )begin
        for( krr4=0 ; krr4<KERPART ; krr4=krr4 +1 )begin
            for( k4=0 ; k4<TE_FIR ; k4=k4+1 )begin
                @(posedge  clk);
                knn00 [4] = ker_sram_4 [k4 + krr4*36 ];
            end
            k4=0 ;
        end
        krr4=0 ;
    end
end
//----keraddress_5---------
initial begin
    wait( cv_start_dly5);
    while( cv_start_dly5 )begin
        for( krr5=0 ; krr5<KERPART ; krr5=krr5 +1 )begin
            for( k5=0 ; k5<TE_FIR ; k5=k5+1 )begin
                @(posedge  clk);
                knn00 [5] = ker_sram_5 [k5 + krr5*36 ];
            end
            k5=0 ;
        end
        krr5=0 ;
    end
end
//----keraddress_6---------
initial begin
    wait( cv_start_dly6);
    while( cv_start_dly6 )begin
        for( krr6=0 ; krr6<KERPART ; krr6=krr6 +1 )begin
            for( k6=0 ; k6<TE_FIR ; k6=k6+1 )begin
                @(posedge  clk);
                knn00 [6] = ker_sram_6 [k6 + krr6*36 ];
            end
            k6=0 ;
        end
        krr6=0 ;
    end
end
//----keraddress_7---------
initial begin
    wait( cv_start_dly7);
    while( cv_start_dly7 )begin
        for( krr7=0 ; krr7<KERPART ; krr7=krr7 +1 )begin
            for( k7=0 ; k7<TE_FIR ; k7=k7+1 )begin
                @(posedge  clk);
                knn00 [7] = ker_sram_7 [k7 + krr7*36 ];
            end
            k7=0 ;
        end
        krr7=0 ;
    end
end
//---- tb ker address count generate end------ 






reg [9:0] pe_ct0 ;
reg signed [ 31 : 0 ] pe0_out_cmp [0:1023] ;
always@(posedge clk)begin
	if(reset )begin
		pe_ct0 <= 0;
	end
	else begin
		if(  q_valid[0] )begin
			pe_ct0 <= pe_ct0 +1;
			pe0_out_cmp[ pe_ct0 ] <= row_sumshf[0] ;
		end
		else if( q_valid[1] )begin
			pe_ct0 <= pe_ct0 +1;
			pe0_out_cmp[ pe_ct0 ] <= row_sumshf[1] ;
		end
		else if( q_valid[2] )begin
			pe_ct0 <= pe_ct0 +1;
			pe0_out_cmp[ pe_ct0 ] <= row_sumshf[2] ;
		end
		else if( q_valid[3] )begin
			pe_ct0 <= pe_ct0 +1;
			pe0_out_cmp[ pe_ct0 ] <= row_sumshf[3] ;
		end
		else if( q_valid[4] )begin
			pe_ct0 <= pe_ct0 +1;
			pe0_out_cmp[ pe_ct0 ] <= row_sumshf[4] ;
		end
		else if( q_valid[5] )begin
			pe_ct0 <= pe_ct0 +1;
			pe0_out_cmp[ pe_ct0 ] <= row_sumshf[5] ;
		end
		else if( q_valid[6] )begin
			pe_ct0 <= pe_ct0 +1;
			pe0_out_cmp[ pe_ct0 ] <= row_sumshf[6] ;
		end
		else if( q_valid[7] )begin
			pe_ct0 <= pe_ct0 +1;
			pe0_out_cmp[ pe_ct0 ] <= row_sumshf[7] ;
		end
	end
end


integer peout_cp ;
reg [ 31 : 0]errorpe =0;
initial begin
	
	wait( cmput_done);
	for( peout_cp = 0; peout_cp<512 ; peout_cp=peout_cp+ 1 )begin
		if( pe0_out_cmp[peout_cp]  !== pe_gold[peout_cp] )begin
			errorpe = errorpe +1 ;
		end
	end
	if(errorpe > 0)begin
		$display("QQ, Total error = %d\n", errorpe);
	end else begin
		$display("^__^");

	end
end



// integer pct0 ;
// integer errpe0 = 0;
// initial begin
// 	wait( cv_start_dly1);
// 	errpe0 = 0;
// 	for( pct0=0 ; pct0<32 ; pct0=pct0+1  )begin
// 		wait( q_valid[0] );
// 		@(posedge clk);
// 		if( q_valid[0] )begin
// 			if ( row_sumshf[0] == pe_gold[ pct0*8 ] )begin
// 				errpe0 <= errpe0 +1 ;
// 			end
// 			else begin
// 				errpe0 <= errpe0  ;
// 			end

// 		end
// 	end
// end

endmodule