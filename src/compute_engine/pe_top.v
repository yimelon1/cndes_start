// ============================================================================
// Designer : Yi_Yuan Chen
// Create   : 2023.03.03
// Ver      : 1.0
// Func     : 512MACs PE top with all 64MAC blocks
//			pass {ker,bias} by reg here 
// ============================================================================

`ifdef FPGA_SRAM_SETTING
	(* use_dsp = "yes" *) 
`else 

`endif 
module pe_top
#(
	parameter TBITS = 64 
	,	TBYTE = 8
	,	PEBLKROW_NUM = 8
)(
	clk			
	,	reset	
	,	cfg_m0_scale 	
	,	cfg_index 		
	,	cfg_z_of_weight	
	,	cfg_z3			

	,	flat_ker_din		
	,	flat_bias_din		
	,	flat_valid_din		
	,	flat_final_din		
	,	flat_act_din	
	

	,	allq_dout			
	,	allvalid_dout		

);
localparam BIAS_BITS = 32;


//==============================================================================
//========    I/O Port declare    ==============================================
//==============================================================================

	input wire clk	;
	input wire reset	;

input wire	[ 32	-1 :0	]	cfg_m0_scale 		;
input wire	[ 8		-1 :0	]	cfg_index 			;
input wire	[ 16	-1 :0	]	cfg_z_of_weight		;
input wire	[ 8		-1 :0	]	cfg_z3				;

input wire	[PEBLKROW_NUM * TBITS-1:0]	flat_ker_din		;
input wire	[PEBLKROW_NUM * BIAS_BITS-1:0]		flat_bias_din		;
input wire	[PEBLKROW_NUM-1:0]			flat_valid_din		;
input wire	[PEBLKROW_NUM-1:0]			flat_final_din		;
input wire	[PEBLKROW_NUM*TBITS-1:0]	flat_act_din		;


output wire [PEBLKROW_NUM*TBITS-1 :0 ]	allq_dout		;
output wire	[PEBLKROW_NUM-1 :0 ]	allvalid_dout	;
//-----------------------------------------------------------------------------

wire				valid_din_r	[0:7]	;
wire				final_din_r	[0:7]	;
wire	[TBITS-1:0]	act_din_r 	[0:7]	;
wire	[TBITS-1:0]	ker_din		[0:7]	;	// for first 64 PE block
wire	[BIAS_BITS	-1:0]	bias_din	[0:7]	;	// for first 64 PE block


wire				valid_forpe	[0:7]	;
wire				final_forpe	[0:7]	;
wire [TBITS-1:0]	act_forpe	[0:7]	;

wire [TBITS-1:0]	frowpe_ker	[0:7]	;
wire [BIAS_BITS-1:0]		frowpe_bias	[0:7]	;

wire [TBITS-1:0]	pass_ker	[0:7][0:7]	;
wire [BIAS_BITS-1:0]		pass_bias	[0:7][0:7]	;

wire	[8-1:0]		q_result	[0:7]	;
wire				q_valid		[0:7]	;

wire [TBITS-1:0]	pkg64_result	[0:7]	;
wire				pkg64_valid		[0:7]	;


reg [32	-1:0]	rcfg_m0_scale 		;
reg [8	-1:0]	rcfg_index 			;
reg [16	-1:0]	rcfg_z_of_weight	;
reg [8	-1:0]	rcfg_z3				;


always @(posedge clk ) begin
	if(reset)begin
		rcfg_m0_scale 		<= 32'h4c138271	;
		rcfg_index 			<= 7	;
		rcfg_z_of_weight	<= 16'd158	;
		rcfg_z3				<= 8'd0	;
	end
	else begin
		rcfg_m0_scale 		<= cfg_m0_scale 	;
		rcfg_index 			<= cfg_index 		;
		rcfg_z_of_weight	<= cfg_z_of_weight	;
		rcfg_z3				<= cfg_z3			;
	end
end



genvar i0 ;
generate
	for (i0 = 0; i0<PEBLKROW_NUM; i0=i0+1) begin		
		assign valid_din_r[i0] = flat_valid_din[ (PEBLKROW_NUM-i0-1 ) -:1 ];
		assign final_din_r[i0] = flat_final_din[ (PEBLKROW_NUM-i0-1 ) -:1 ];
		assign act_din_r[i0] = flat_act_din[ (TBITS*(PEBLKROW_NUM-i0)-1 ) -: TBITS ];
		assign ker_din[i0] = flat_ker_din[ (TBITS*(PEBLKROW_NUM-i0)-1 ) -: TBITS ];
		assign bias_din[i0] = flat_bias_din[ (BIAS_BITS*(PEBLKROW_NUM-i0)-1 ) -: BIAS_BITS ];

		assign allq_dout[(TBITS*(PEBLKROW_NUM-i0) -1 ) -: TBITS ] = pkg64_result[i0]	;
		assign allvalid_dout	[(PEBLKROW_NUM -i0 -1 ) -: 1 ] = pkg64_valid[i0]	;
		// assign allq_dout[(8*(PEBLKROW_NUM-i0) -1 ) -: 8 ] = q_result[i0]	;
		// assign allvalid_dout	[(PEBLKROW_NUM -i0 -1 ) -: 1 ] = q_valid[i0]	;

		assign valid_forpe[i0] 	= valid_din_r [i0]	;
		assign final_forpe[i0] 	= final_din_r [i0]	;
		assign act_forpe[i0] 	= act_din_r [i0]	;
		assign frowpe_ker[i0] 	= ker_din [i0]	;	// for first row PE kernel[i] i=0~7 
		assign frowpe_bias[i0] 	= bias_din [i0]	;	// for first row PE bias[i] i=0~7 
	end
endgenerate


// for (i0 = 0; i0<PEBLKROW_NUM; i0=i0+1) begin		
// 	assign allq_dout[(8*(PEBLKROW_NUM-i0) -1 ) -: 8 ] = q_result[i0]	;
// 	assign q_valid	[(PEBLKROW_NUM -i0 -1 ) -: 1 ] = q_valid[i0]	;
// end
// assign allq_dout = {
// 	q_result[0]
// 	,	q_result[1]
// 	,	q_result[2]
// 	,	q_result[3]
// 	,	q_result[4]
// 	,	q_result[5]
// 	,	q_result[6]
// 	,	q_result[7]
// }

// assign allvalid_dout = {
// 	q_valid[0]
// 	,	q_valid[1]
// 	,	q_valid[2]
// 	,	q_valid[3]
// 	,	q_valid[4]
// 	,	q_valid[5]
// 	,	q_valid[6]
// 	,	q_valid[7]
// }

// wire [64-1:0] pkg_data64 ;
// wire  pkg_valid ;

// pe_qz_pkg #(
// 	.TBITS(	64 	)     ,   .TBYTE(	8	)
// )pepkg0(
// 	.clk ( clk )  
// 	,    .reset ( reset ) 
// 	,	.data8_din		(	q_result[0]		)
// 	,	.valid8_din 	(	q_valid[0]		)
// 	,	.data64_dout	(	pkg64_result[0]	)
// 	,	.valid64_dout	(	pkg64_valid	[0]	)

// );


//----    quan to buffer module instance    -----
genvar gx ;
generate
	for(gx=0; gx< 8 ; gx=gx+1)begin	: inst_pkg
		pe_qz_pkg #(
			.TBITS(	TBITS 	)     ,   .TBYTE(	TBYTE	)
		)pk_0 (
			.clk ( clk )  
			,	.reset ( reset ) 
			,	.data8_din		(	q_result[gx]		)
			,	.valid8_din 	(	q_valid[gx]		)
			,	.data64_dout	(	pkg64_result[gx]	)
			,	.valid64_dout	(	pkg64_valid	[gx]	)
		);
	end
endgenerate

//==============================================================================
//========    instance 512 MAC by PE_blk    ====================================
//==============================================================================
//----instance pe_blk64 generate by pe_instcode.py------ 
// frowpe_ker[i]  // for first row PE kernel[i] i=0~7 
// frowpe_bias[i]  // for first row PE bias[i] i=0~7 
// pass_ker[row_number][i]  // every PE row pass kernel by it's register, so delay 1 cycle . i=0~7 
// pass_bias[row_number][i]  // every PE row pass bias by it's register, so delay 1 cycle . i=0~7 
//----pe row_0---------
pe_blk64  #(    .TBITS(	64 	)     ,   .TBYTE(	8	)     ,   .BIAS_BITS(	32	) 
    )blkpe_r0(.clk ( clk )  ,    .reset ( reset ) 
    , .cfg_m0_scale 		( rcfg_m0_scale 		 )
    , .cfg_index 		( rcfg_index 		 )
    , .cfg_z_of_weight	( rcfg_z_of_weight	 )
    , .cfg_z3			( rcfg_z3			 )
    , .valid_din			( valid_forpe	[0]	 )
    , .final_din			( final_forpe	[0]	 )
    , .act_din			( act_forpe		[0]	 )
    , .ker_din_0	( frowpe_ker[0]	 )
    , .ker_din_1	( frowpe_ker[1]	 )
    , .ker_din_2	( frowpe_ker[2]	 )
    , .ker_din_3	( frowpe_ker[3]	 )
    , .ker_din_4	( frowpe_ker[4]	 )
    , .ker_din_5	( frowpe_ker[5]	 )
    , .ker_din_6	( frowpe_ker[6]	 )
    , .ker_din_7	( frowpe_ker[7]	 )
    , .bias_din_0 ( frowpe_bias[0]	)
    , .bias_din_1 ( frowpe_bias[1]	)
    , .bias_din_2 ( frowpe_bias[2]	)
    , .bias_din_3 ( frowpe_bias[3]	)
    , .bias_din_4 ( frowpe_bias[4]	)
    , .bias_din_5 ( frowpe_bias[5]	)
    , .bias_din_6 ( frowpe_bias[6]	)
    , .bias_din_7 ( frowpe_bias[7]	)
    , .pass_ker_dout_0 ( pass_ker[0][0]	 )
    , .pass_ker_dout_1 ( pass_ker[0][1]	 )
    , .pass_ker_dout_2 ( pass_ker[0][2]	 )
    , .pass_ker_dout_3 ( pass_ker[0][3]	 )
    , .pass_ker_dout_4 ( pass_ker[0][4]	 )
    , .pass_ker_dout_5 ( pass_ker[0][5]	 )
    , .pass_ker_dout_6 ( pass_ker[0][6]	 )
    , .pass_ker_dout_7 ( pass_ker[0][7]	 )
    , .pass_bias_dout_0 ( pass_bias[0][0]	 )
    , .pass_bias_dout_1 ( pass_bias[0][1]	 )
    , .pass_bias_dout_2 ( pass_bias[0][2]	 )
    , .pass_bias_dout_3 ( pass_bias[0][3]	 )
    , .pass_bias_dout_4 ( pass_bias[0][4]	 )
    , .pass_bias_dout_5 ( pass_bias[0][5]	 )
    , .pass_bias_dout_6 ( pass_bias[0][6]	 )
    , .pass_bias_dout_7 ( pass_bias[0][7]	 )
    , .q_result_dout		( q_result[0]		 )
    , .valid_dout		( q_valid[0]		 )
    );
//----pe row_1---------
pe_blk64  #(    .TBITS(	64 	)     ,   .TBYTE(	8	)     ,   .BIAS_BITS(	32	) 
    )blkpe_r1(.clk ( clk )  ,    .reset ( reset ) 
    , .cfg_m0_scale 		( rcfg_m0_scale 		 )
    , .cfg_index 		( rcfg_index 		 )
    , .cfg_z_of_weight	( rcfg_z_of_weight	 )
    , .cfg_z3			( rcfg_z3			 )
    , .valid_din			( valid_forpe	[1]	 )
    , .final_din			( final_forpe	[1]	 )
    , .act_din			( act_forpe		[1]	 )
    , .ker_din_0	( pass_ker[0][0]	)
    , .ker_din_1	( pass_ker[0][1]	)
    , .ker_din_2	( pass_ker[0][2]	)
    , .ker_din_3	( pass_ker[0][3]	)
    , .ker_din_4	( pass_ker[0][4]	)
    , .ker_din_5	( pass_ker[0][5]	)
    , .ker_din_6	( pass_ker[0][6]	)
    , .ker_din_7	( pass_ker[0][7]	)
    , .bias_din_0 ( pass_bias[0][0]	)
    , .bias_din_1 ( pass_bias[0][1]	)
    , .bias_din_2 ( pass_bias[0][2]	)
    , .bias_din_3 ( pass_bias[0][3]	)
    , .bias_din_4 ( pass_bias[0][4]	)
    , .bias_din_5 ( pass_bias[0][5]	)
    , .bias_din_6 ( pass_bias[0][6]	)
    , .bias_din_7 ( pass_bias[0][7]	)
    , .pass_ker_dout_0 ( pass_ker[1][0]	 )
    , .pass_ker_dout_1 ( pass_ker[1][1]	 )
    , .pass_ker_dout_2 ( pass_ker[1][2]	 )
    , .pass_ker_dout_3 ( pass_ker[1][3]	 )
    , .pass_ker_dout_4 ( pass_ker[1][4]	 )
    , .pass_ker_dout_5 ( pass_ker[1][5]	 )
    , .pass_ker_dout_6 ( pass_ker[1][6]	 )
    , .pass_ker_dout_7 ( pass_ker[1][7]	 )
    , .pass_bias_dout_0 ( pass_bias[1][0]	 )
    , .pass_bias_dout_1 ( pass_bias[1][1]	 )
    , .pass_bias_dout_2 ( pass_bias[1][2]	 )
    , .pass_bias_dout_3 ( pass_bias[1][3]	 )
    , .pass_bias_dout_4 ( pass_bias[1][4]	 )
    , .pass_bias_dout_5 ( pass_bias[1][5]	 )
    , .pass_bias_dout_6 ( pass_bias[1][6]	 )
    , .pass_bias_dout_7 ( pass_bias[1][7]	 )
    , .q_result_dout	( q_result[1]		 )
    , .valid_dout		( q_valid[1]		 )
    );
//----pe row_2---------
pe_blk64  #(    .TBITS(	64 	)     ,   .TBYTE(	8	)     ,   .BIAS_BITS(	32	) 
    )blkpe_r2(.clk ( clk )  ,    .reset ( reset ) 
    , .cfg_m0_scale 		( rcfg_m0_scale 		 )
    , .cfg_index 		( rcfg_index 		 )
    , .cfg_z_of_weight	( rcfg_z_of_weight	 )
    , .cfg_z3			( rcfg_z3			 )
    , .valid_din			( valid_forpe	[2]	 )
    , .final_din			( final_forpe	[2]	 )
    , .act_din			( act_forpe		[2]	 )
    , .ker_din_0	( pass_ker[1][0]	)
    , .ker_din_1	( pass_ker[1][1]	)
    , .ker_din_2	( pass_ker[1][2]	)
    , .ker_din_3	( pass_ker[1][3]	)
    , .ker_din_4	( pass_ker[1][4]	)
    , .ker_din_5	( pass_ker[1][5]	)
    , .ker_din_6	( pass_ker[1][6]	)
    , .ker_din_7	( pass_ker[1][7]	)
    , .bias_din_0 ( pass_bias[1][0]	)
    , .bias_din_1 ( pass_bias[1][1]	)
    , .bias_din_2 ( pass_bias[1][2]	)
    , .bias_din_3 ( pass_bias[1][3]	)
    , .bias_din_4 ( pass_bias[1][4]	)
    , .bias_din_5 ( pass_bias[1][5]	)
    , .bias_din_6 ( pass_bias[1][6]	)
    , .bias_din_7 ( pass_bias[1][7]	)
    , .pass_ker_dout_0 ( pass_ker[2][0]	 )
    , .pass_ker_dout_1 ( pass_ker[2][1]	 )
    , .pass_ker_dout_2 ( pass_ker[2][2]	 )
    , .pass_ker_dout_3 ( pass_ker[2][3]	 )
    , .pass_ker_dout_4 ( pass_ker[2][4]	 )
    , .pass_ker_dout_5 ( pass_ker[2][5]	 )
    , .pass_ker_dout_6 ( pass_ker[2][6]	 )
    , .pass_ker_dout_7 ( pass_ker[2][7]	 )
    , .pass_bias_dout_0 ( pass_bias[2][0]	 )
    , .pass_bias_dout_1 ( pass_bias[2][1]	 )
    , .pass_bias_dout_2 ( pass_bias[2][2]	 )
    , .pass_bias_dout_3 ( pass_bias[2][3]	 )
    , .pass_bias_dout_4 ( pass_bias[2][4]	 )
    , .pass_bias_dout_5 ( pass_bias[2][5]	 )
    , .pass_bias_dout_6 ( pass_bias[2][6]	 )
    , .pass_bias_dout_7 ( pass_bias[2][7]	 )
    , .q_result_dout		( q_result[2]		 )
    , .valid_dout		( q_valid[2]		 )
    );
//----pe row_3---------
pe_blk64  #(    .TBITS(	64 	)     ,   .TBYTE(	8	)     ,   .BIAS_BITS(	32	) 
    )blkpe_r3(.clk ( clk )  ,    .reset ( reset ) 
    , .cfg_m0_scale 		( rcfg_m0_scale 		 )
    , .cfg_index 		( rcfg_index 		 )
    , .cfg_z_of_weight	( rcfg_z_of_weight	 )
    , .cfg_z3			( rcfg_z3			 )
    , .valid_din			( valid_forpe	[3]	 )
    , .final_din			( final_forpe	[3]	 )
    , .act_din			( act_forpe		[3]	 )
    , .ker_din_0	( pass_ker[2][0]	)
    , .ker_din_1	( pass_ker[2][1]	)
    , .ker_din_2	( pass_ker[2][2]	)
    , .ker_din_3	( pass_ker[2][3]	)
    , .ker_din_4	( pass_ker[2][4]	)
    , .ker_din_5	( pass_ker[2][5]	)
    , .ker_din_6	( pass_ker[2][6]	)
    , .ker_din_7	( pass_ker[2][7]	)
    , .bias_din_0 ( pass_bias[2][0]	)
    , .bias_din_1 ( pass_bias[2][1]	)
    , .bias_din_2 ( pass_bias[2][2]	)
    , .bias_din_3 ( pass_bias[2][3]	)
    , .bias_din_4 ( pass_bias[2][4]	)
    , .bias_din_5 ( pass_bias[2][5]	)
    , .bias_din_6 ( pass_bias[2][6]	)
    , .bias_din_7 ( pass_bias[2][7]	)
    , .pass_ker_dout_0 ( pass_ker[3][0]	 )
    , .pass_ker_dout_1 ( pass_ker[3][1]	 )
    , .pass_ker_dout_2 ( pass_ker[3][2]	 )
    , .pass_ker_dout_3 ( pass_ker[3][3]	 )
    , .pass_ker_dout_4 ( pass_ker[3][4]	 )
    , .pass_ker_dout_5 ( pass_ker[3][5]	 )
    , .pass_ker_dout_6 ( pass_ker[3][6]	 )
    , .pass_ker_dout_7 ( pass_ker[3][7]	 )
    , .pass_bias_dout_0 ( pass_bias[3][0]	 )
    , .pass_bias_dout_1 ( pass_bias[3][1]	 )
    , .pass_bias_dout_2 ( pass_bias[3][2]	 )
    , .pass_bias_dout_3 ( pass_bias[3][3]	 )
    , .pass_bias_dout_4 ( pass_bias[3][4]	 )
    , .pass_bias_dout_5 ( pass_bias[3][5]	 )
    , .pass_bias_dout_6 ( pass_bias[3][6]	 )
    , .pass_bias_dout_7 ( pass_bias[3][7]	 )
    , .q_result_dout		( q_result[3]		 )
    , .valid_dout		( q_valid[3]		 )
    );
//----pe row_4---------
pe_blk64  #(    .TBITS(	64 	)     ,   .TBYTE(	8	)     ,   .BIAS_BITS(	32	) 
    )blkpe_r4(.clk ( clk )  ,    .reset ( reset ) 
    , .cfg_m0_scale 		( rcfg_m0_scale 		 )
    , .cfg_index 		( rcfg_index 		 )
    , .cfg_z_of_weight	( rcfg_z_of_weight	 )
    , .cfg_z3			( rcfg_z3			 )
    , .valid_din			( valid_forpe	[4]	 )
    , .final_din			( final_forpe	[4]	 )
    , .act_din			( act_forpe		[4]	 )
    , .ker_din_0	( pass_ker[3][0]	)
    , .ker_din_1	( pass_ker[3][1]	)
    , .ker_din_2	( pass_ker[3][2]	)
    , .ker_din_3	( pass_ker[3][3]	)
    , .ker_din_4	( pass_ker[3][4]	)
    , .ker_din_5	( pass_ker[3][5]	)
    , .ker_din_6	( pass_ker[3][6]	)
    , .ker_din_7	( pass_ker[3][7]	)
    , .bias_din_0 ( pass_bias[3][0]	)
    , .bias_din_1 ( pass_bias[3][1]	)
    , .bias_din_2 ( pass_bias[3][2]	)
    , .bias_din_3 ( pass_bias[3][3]	)
    , .bias_din_4 ( pass_bias[3][4]	)
    , .bias_din_5 ( pass_bias[3][5]	)
    , .bias_din_6 ( pass_bias[3][6]	)
    , .bias_din_7 ( pass_bias[3][7]	)
    , .pass_ker_dout_0 ( pass_ker[4][0]	 )
    , .pass_ker_dout_1 ( pass_ker[4][1]	 )
    , .pass_ker_dout_2 ( pass_ker[4][2]	 )
    , .pass_ker_dout_3 ( pass_ker[4][3]	 )
    , .pass_ker_dout_4 ( pass_ker[4][4]	 )
    , .pass_ker_dout_5 ( pass_ker[4][5]	 )
    , .pass_ker_dout_6 ( pass_ker[4][6]	 )
    , .pass_ker_dout_7 ( pass_ker[4][7]	 )
    , .pass_bias_dout_0 ( pass_bias[4][0]	 )
    , .pass_bias_dout_1 ( pass_bias[4][1]	 )
    , .pass_bias_dout_2 ( pass_bias[4][2]	 )
    , .pass_bias_dout_3 ( pass_bias[4][3]	 )
    , .pass_bias_dout_4 ( pass_bias[4][4]	 )
    , .pass_bias_dout_5 ( pass_bias[4][5]	 )
    , .pass_bias_dout_6 ( pass_bias[4][6]	 )
    , .pass_bias_dout_7 ( pass_bias[4][7]	 )
    , .q_result_dout		( q_result[4]		 )
    , .valid_dout		( q_valid[4]		 )
    );
//----pe row_5---------
pe_blk64  #(    .TBITS(	64 	)     ,   .TBYTE(	8	)     ,   .BIAS_BITS(	32	) 
    )blkpe_r5(.clk ( clk )  ,    .reset ( reset ) 
    , .cfg_m0_scale 		( rcfg_m0_scale 		 )
    , .cfg_index 		( rcfg_index 		 )
    , .cfg_z_of_weight	( rcfg_z_of_weight	 )
    , .cfg_z3			( rcfg_z3			 )
    , .valid_din			( valid_forpe	[5]	 )
    , .final_din			( final_forpe	[5]	 )
    , .act_din			( act_forpe		[5]	 )
    , .ker_din_0	( pass_ker[4][0]	)
    , .ker_din_1	( pass_ker[4][1]	)
    , .ker_din_2	( pass_ker[4][2]	)
    , .ker_din_3	( pass_ker[4][3]	)
    , .ker_din_4	( pass_ker[4][4]	)
    , .ker_din_5	( pass_ker[4][5]	)
    , .ker_din_6	( pass_ker[4][6]	)
    , .ker_din_7	( pass_ker[4][7]	)
    , .bias_din_0 ( pass_bias[4][0]	)
    , .bias_din_1 ( pass_bias[4][1]	)
    , .bias_din_2 ( pass_bias[4][2]	)
    , .bias_din_3 ( pass_bias[4][3]	)
    , .bias_din_4 ( pass_bias[4][4]	)
    , .bias_din_5 ( pass_bias[4][5]	)
    , .bias_din_6 ( pass_bias[4][6]	)
    , .bias_din_7 ( pass_bias[4][7]	)
    , .pass_ker_dout_0 ( pass_ker[5][0]	 )
    , .pass_ker_dout_1 ( pass_ker[5][1]	 )
    , .pass_ker_dout_2 ( pass_ker[5][2]	 )
    , .pass_ker_dout_3 ( pass_ker[5][3]	 )
    , .pass_ker_dout_4 ( pass_ker[5][4]	 )
    , .pass_ker_dout_5 ( pass_ker[5][5]	 )
    , .pass_ker_dout_6 ( pass_ker[5][6]	 )
    , .pass_ker_dout_7 ( pass_ker[5][7]	 )
    , .pass_bias_dout_0 ( pass_bias[5][0]	 )
    , .pass_bias_dout_1 ( pass_bias[5][1]	 )
    , .pass_bias_dout_2 ( pass_bias[5][2]	 )
    , .pass_bias_dout_3 ( pass_bias[5][3]	 )
    , .pass_bias_dout_4 ( pass_bias[5][4]	 )
    , .pass_bias_dout_5 ( pass_bias[5][5]	 )
    , .pass_bias_dout_6 ( pass_bias[5][6]	 )
    , .pass_bias_dout_7 ( pass_bias[5][7]	 )
    , .q_result_dout		( q_result[5]		 )
    , .valid_dout		( q_valid[5]		 )
    );
//----pe row_6---------
pe_blk64  #(    .TBITS(	64 	)     ,   .TBYTE(	8	)     ,   .BIAS_BITS(	32	) 
    )blkpe_r6(.clk ( clk )  ,    .reset ( reset ) 
    , .cfg_m0_scale 		( rcfg_m0_scale 		 )
    , .cfg_index 		( rcfg_index 		 )
    , .cfg_z_of_weight	( rcfg_z_of_weight	 )
    , .cfg_z3			( rcfg_z3			 )
    , .valid_din			( valid_forpe	[6]	 )
    , .final_din			( final_forpe	[6]	 )
    , .act_din			( act_forpe		[6]	 )
    , .ker_din_0	( pass_ker[5][0]	)
    , .ker_din_1	( pass_ker[5][1]	)
    , .ker_din_2	( pass_ker[5][2]	)
    , .ker_din_3	( pass_ker[5][3]	)
    , .ker_din_4	( pass_ker[5][4]	)
    , .ker_din_5	( pass_ker[5][5]	)
    , .ker_din_6	( pass_ker[5][6]	)
    , .ker_din_7	( pass_ker[5][7]	)
    , .bias_din_0 ( pass_bias[5][0]	)
    , .bias_din_1 ( pass_bias[5][1]	)
    , .bias_din_2 ( pass_bias[5][2]	)
    , .bias_din_3 ( pass_bias[5][3]	)
    , .bias_din_4 ( pass_bias[5][4]	)
    , .bias_din_5 ( pass_bias[5][5]	)
    , .bias_din_6 ( pass_bias[5][6]	)
    , .bias_din_7 ( pass_bias[5][7]	)
    , .pass_ker_dout_0 ( pass_ker[6][0]	 )
    , .pass_ker_dout_1 ( pass_ker[6][1]	 )
    , .pass_ker_dout_2 ( pass_ker[6][2]	 )
    , .pass_ker_dout_3 ( pass_ker[6][3]	 )
    , .pass_ker_dout_4 ( pass_ker[6][4]	 )
    , .pass_ker_dout_5 ( pass_ker[6][5]	 )
    , .pass_ker_dout_6 ( pass_ker[6][6]	 )
    , .pass_ker_dout_7 ( pass_ker[6][7]	 )
    , .pass_bias_dout_0 ( pass_bias[6][0]	 )
    , .pass_bias_dout_1 ( pass_bias[6][1]	 )
    , .pass_bias_dout_2 ( pass_bias[6][2]	 )
    , .pass_bias_dout_3 ( pass_bias[6][3]	 )
    , .pass_bias_dout_4 ( pass_bias[6][4]	 )
    , .pass_bias_dout_5 ( pass_bias[6][5]	 )
    , .pass_bias_dout_6 ( pass_bias[6][6]	 )
    , .pass_bias_dout_7 ( pass_bias[6][7]	 )
    , .q_result_dout		( q_result[6]		 )
    , .valid_dout		( q_valid[6]		 )
    );
//----pe row_7---------
pe_blk64  #(    .TBITS(	64 	)     ,   .TBYTE(	8	)     ,   .BIAS_BITS(	32	) 
    )blkpe_r7(.clk ( clk )  ,    .reset ( reset ) 
    , .cfg_m0_scale 		( rcfg_m0_scale 		 )
    , .cfg_index 		( rcfg_index 		 )
    , .cfg_z_of_weight	( rcfg_z_of_weight	 )
    , .cfg_z3			( rcfg_z3			 )
    , .valid_din			( valid_forpe	[7]	 )
    , .final_din			( final_forpe	[7]	 )
    , .act_din			( act_forpe		[7]	 )
    , .ker_din_0	( pass_ker[6][0]	)
    , .ker_din_1	( pass_ker[6][1]	)
    , .ker_din_2	( pass_ker[6][2]	)
    , .ker_din_3	( pass_ker[6][3]	)
    , .ker_din_4	( pass_ker[6][4]	)
    , .ker_din_5	( pass_ker[6][5]	)
    , .ker_din_6	( pass_ker[6][6]	)
    , .ker_din_7	( pass_ker[6][7]	)
    , .bias_din_0 ( pass_bias[6][0]	)
    , .bias_din_1 ( pass_bias[6][1]	)
    , .bias_din_2 ( pass_bias[6][2]	)
    , .bias_din_3 ( pass_bias[6][3]	)
    , .bias_din_4 ( pass_bias[6][4]	)
    , .bias_din_5 ( pass_bias[6][5]	)
    , .bias_din_6 ( pass_bias[6][6]	)
    , .bias_din_7 ( pass_bias[6][7]	)
    , .pass_ker_dout_0 ( pass_ker[7][0]	 )
    , .pass_ker_dout_1 ( pass_ker[7][1]	 )
    , .pass_ker_dout_2 ( pass_ker[7][2]	 )
    , .pass_ker_dout_3 ( pass_ker[7][3]	 )
    , .pass_ker_dout_4 ( pass_ker[7][4]	 )
    , .pass_ker_dout_5 ( pass_ker[7][5]	 )
    , .pass_ker_dout_6 ( pass_ker[7][6]	 )
    , .pass_ker_dout_7 ( pass_ker[7][7]	 )
    , .pass_bias_dout_0 ( pass_bias[7][0]	 )
    , .pass_bias_dout_1 ( pass_bias[7][1]	 )
    , .pass_bias_dout_2 ( pass_bias[7][2]	 )
    , .pass_bias_dout_3 ( pass_bias[7][3]	 )
    , .pass_bias_dout_4 ( pass_bias[7][4]	 )
    , .pass_bias_dout_5 ( pass_bias[7][5]	 )
    , .pass_bias_dout_6 ( pass_bias[7][6]	 )
    , .pass_bias_dout_7 ( pass_bias[7][7]	 )
    , .q_result_dout		( q_result[7]		 )
    , .valid_dout		( q_valid[7]		 )
    );
//----instance pe with bias end------ 







endmodule