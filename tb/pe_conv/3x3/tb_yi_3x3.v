//=========================================================
// File Name   : tb_v2.v
// Description : top testbench
// Designer    : Ching-Shun Wang
//=========================================================
`timescale 1ns / 100ps
`define CYCLE       50.0


//`define LAY_7
`define LAY_37
//`define CYC_TEST


`define PATH_LOG			"E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/000_LOG/log1x1_01.txt"


`ifdef LAY_7
	`define PAT_WEIGHTS        "E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/00_DAT/cvtr_dat/layer_7/w_7.dat"
	`define PAT_BIAS           "E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/00_DAT/cvtr_dat/layer_7/layer_7_bias.dat"
	`define PAT_IFMAP          "E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/00_DAT/cvtr_dat/layer_7/layer7_ifm4.dat"
	`define PAT_OFMAP          "E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/00_DAT/cvtr_dat/layer_7/layer7_ofm4.dat"
`endif 


`ifdef LAY_37
	`define PAT_WEIGHTS        "E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/00_DAT/cvtr_dat/layer_37/w_37.dat"
	`define PAT_BIAS           "E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/00_DAT/cvtr_dat/layer_37/layer_37_bias.dat"
	`define PAT_IFMAP          "E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/00_DAT/cvtr_dat/layer_37/layer37_ifm.dat"
	`define PAT_OFMAP          "E:/yuan/v_code/908_HW/yi_sim_version_0to58_cvtr/src/tb/00_DAT/cvtr_dat/layer_37/layer37_ofm.dat"
`endif 


module tb();
parameter TBITS = 64;
parameter TBYTE = 8;

//parameter IFMAP_SIZE   = 131072;
//parameter OFMAP_SIZE   = 32768;
//parameter BIAS_SIZE    = 16;			// once
//parameter WEIGHTS_SIZE = 1152;		// once

//localparam  OFMAP_SIZE = 6656 * ROW_ROUNDS ; 
// parameter M  = 32'h4f8058aa;//32'b01100011111111010011110101011101//32'b01111011011110110111100101001001
// parameter ZW =  8'h85;//8'h7f//8'h5a
// parameter ZO =  8'h0;
// parameter index = 6'd7;//6'd9


`ifdef LAY_7 
	parameter CPT_ROUNDS = 1 ;
	parameter IFMAP_SIZE   = 131072;
	localparam	ONCE_KER = 1152	;		//once_ker = 16*9*64/8
	localparam	ONCE_BIAS    = 16		;		// once
	localparam  OFMAP_SIZE = 32768 * CPT_ROUNDS ; 
	localparam	WEIGHTS_SIZE = 	 ONCE_KER * CPT_ROUNDS	;	//once weight 
	localparam	BIAS_SIZE    = ONCE_BIAS * CPT_ROUNDS ;			// once
	//--- config ----//
	parameter CFG_IFMAP = 64'd128;
	parameter CFG_IF_CHANNEL = 64'd64;
	parameter CFG_KER_NUM = 64'd16;
	parameter M  = 32'h4f8058aa;//32'b01100011111111010011110101011101//32'b01111011011110110111100101001001
	parameter ZW =  8'h85;//8'h7f//8'h5a
	parameter ZO =  8'h0;
	parameter index = 6'd7;//6'd9
`endif


`ifdef LAY_37 
	parameter CPT_ROUNDS = 1 ;
	parameter IFMAP_SIZE   = 8192;
	localparam	ONCE_KER = 1152	;		//once_ker = 16*9*64/8
	localparam	ONCE_BIAS    = 4		;		// once
	localparam  OFMAP_SIZE = 128 * CPT_ROUNDS ; 
	localparam	WEIGHTS_SIZE = 	 ONCE_KER * CPT_ROUNDS	;	//once weight 
	localparam	BIAS_SIZE    = ONCE_BIAS * CPT_ROUNDS ;			// once
	//--- config ----//
	parameter CFG_IFMAP = 64'd16;
	parameter CFG_IF_CHANNEL = 64'd256;
	parameter CFG_KER_NUM = 64'd4;
	parameter M  = 32'b01100011111111010011110101011101;  
	parameter ZW =  8'h7f; 
	parameter ZO =  8'h0;
	parameter index = 6'd9; 
`endif

//---------debug yi 2022.04.08 -----------------
wire	[3:0] 			debug_3x3_current_state ;
reg		[31:0 ] tot_cycle ;
reg		[31:0 ] cpt_cycle ;
//---------debug yi 2022.04.08 -----------------

reg              S_AXIS_MM2S_TVALID = 0;
wire             S_AXIS_MM2S_TREADY;
reg  [TBITS-1:0] S_AXIS_MM2S_TDATA = 0;
reg  [TBYTE-1:0] S_AXIS_MM2S_TKEEP = 0;
reg  [1-1:0]     S_AXIS_MM2S_TLAST = 0;

wire             M_AXIS_S2MM_TVALID;
reg              M_AXIS_S2MM_TREADY = 0;
wire [TBITS-1:0] M_AXIS_S2MM_TDATA;
wire [TBYTE-1:0] M_AXIS_S2MM_TKEEP;
wire [1-1:0]     M_AXIS_S2MM_TLAST;

reg              aclk = 0;
reg              aresetn = 1;

reg              done = 0;
//=========================================================
// yolo_top
//---------------------------------------------------------
yolo_top
#(
        .TBITS(TBITS),
        .TBYTE(TBYTE)
) top_inst (
        .S_AXIS_MM2S_TVALID(S_AXIS_MM2S_TVALID),
        .S_AXIS_MM2S_TREADY(S_AXIS_MM2S_TREADY),
        .S_AXIS_MM2S_TDATA(S_AXIS_MM2S_TDATA),
        .S_AXIS_MM2S_TKEEP(S_AXIS_MM2S_TKEEP),
        .S_AXIS_MM2S_TLAST(S_AXIS_MM2S_TLAST),
        
        .M_AXIS_S2MM_TVALID(M_AXIS_S2MM_TVALID),
        .M_AXIS_S2MM_TREADY(M_AXIS_S2MM_TREADY),
        .M_AXIS_S2MM_TDATA(M_AXIS_S2MM_TDATA),
        .M_AXIS_S2MM_TKEEP(M_AXIS_S2MM_TKEEP),
        .M_AXIS_S2MM_TLAST(M_AXIS_S2MM_TLAST),  // EOL      
        
        .S_AXIS_MM2S_ACLK(aclk),
        .M_AXIS_S2MM_ACLK(aclk),
        .aclk(aclk),
        .aresetn(aresetn)	
); 
//---------------------------------------------------------

reg    [TBITS-1 : 0]      weights_t  [0:WEIGHTS_SIZE-1];
reg    [TBITS-1 : 0]      bias_t     [0:BIAS_SIZE-1];
reg    [TBITS-1 : 0]      ifmap_t    [0:IFMAP_SIZE-1];

reg    [TBITS-1 : 0]      weights_t2;
reg    [31:0]             bias_t2;
reg    [TBITS-1 : 0]      ifmap_t2;
reg    [TBITS-1 : 0]      ofmap_gold_t2;

reg    [TBITS-1 : 0]      ifmap        [0:IFMAP_SIZE-1];
reg    [TBITS-1 : 0]      ofmap_gold   [0:OFMAP_SIZE-1];
reg    [TBITS-1 : 0]      ofmap_gold_t [0:OFMAP_SIZE-1];

reg    [TBITS-1 : 0]      ofmap        [0:OFMAP_SIZE-1];

reg    [19 : 0]           ofmap_cnt;

reg    [TBITS-1 : 0]      weights      [0:WEIGHTS_SIZE-1];
reg    [TBITS-1 : 0]      bias         [0:BIAS_SIZE-1];

reg [63:0 ] cfg_arr [0:7] ;





integer i,k;
integer bias_num;
integer kernel_num;
integer ifmap_num;
integer ofmap_num;
integer error;

integer rounds ;

initial begin  
    $readmemh(`PAT_WEIGHTS   , weights_t);
    $readmemh(`PAT_BIAS      , bias_t);
    $readmemh(`PAT_IFMAP     , ifmap_t);
    
    $readmemh(`PAT_IFMAP     , ifmap);
    $readmemh(`PAT_OFMAP     , ofmap_gold_t);
end

// ifmap/weights reverse
initial begin
    for(i=0; i<WEIGHTS_SIZE; i=i+1)begin
        weights_t2 = weights_t[i];
        weights[i] = {      weights_t2[ 7 :  0], 
                            weights_t2[15 :  8],
                            weights_t2[23 : 16],
                            weights_t2[31 : 24],
                            weights_t2[39 : 32],
                            weights_t2[47 : 40],
                            weights_t2[55 : 48],
                            weights_t2[63 : 56]
                     };
    end  
    
    for(i=0; i<IFMAP_SIZE; i=i+1)begin
        ifmap_t2 = ifmap_t[i];
        ifmap[i] = {        ifmap_t2[ 7 :  0], 
                            ifmap_t2[15 :  8],
                            ifmap_t2[23 : 16],
                            ifmap_t2[31 : 24],
                            ifmap_t2[39 : 32],
                            ifmap_t2[47 : 40],
                            ifmap_t2[55 : 48],
                            ifmap_t2[63 : 56]
                     };
    end

    for(i=0; i<OFMAP_SIZE; i=i+1)begin
        ofmap_gold_t2 = ofmap_gold_t[i];
        ofmap_gold[i] = {        ofmap_gold_t2[ 7 :  0], 
                                 ofmap_gold_t2[15 :  8],
                                 ofmap_gold_t2[23 : 16],
                                 ofmap_gold_t2[31 : 24],
                                 ofmap_gold_t2[39 : 32],
                                 ofmap_gold_t2[47 : 40],
                                 ofmap_gold_t2[55 : 48],
                                 ofmap_gold_t2[63 : 56]
                     };
    end

	cfg_arr[0] = 64'd0 ;
	cfg_arr[1] = CFG_IFMAP ;
	cfg_arr[2] = CFG_IF_CHANNEL ;
	cfg_arr[3] = CFG_KER_NUM;     // number_of_kernel
	cfg_arr[4] = {32'h00000000, M};      // m
	cfg_arr[5] = {32'h00000000, ZW};     // zw
	cfg_arr[6] = {32'h00000000, ZO};
	cfg_arr[7] = {58'h00000000, index} ;


end



initial begin   
               
    #(`CYCLE*2);
    aresetn = 0;
    #(`CYCLE*3);
    aresetn = 1;
	
	//----- DMA RX signal -------
    #(`CYCLE*10);
    M_AXIS_S2MM_TREADY = 1;

	S_AXIS_MM2S_TKEEP = 'hff;	// set TKEEP signal , you can try TKEEP = 0

	for ( rounds = 0 ; rounds <CPT_ROUNDS ; rounds = rounds + 1 )begin
		//------ switch signal TX-------
		@(posedge aclk);    
		S_AXIS_MM2S_TVALID = 1;
		S_AXIS_MM2S_TDATA = 'h0;
		S_AXIS_MM2S_TLAST  = 1;
		wait(S_AXIS_MM2S_TREADY);

		@(posedge aclk);
		S_AXIS_MM2S_TVALID = 0;
		S_AXIS_MM2S_TDATA  = 'h0;
		S_AXIS_MM2S_TLAST  = 0;
		#(`CYCLE*5);


		//------ config signal TX-------
		// layer config signal
		for ( i = 0 ; i<8 ; i=i+1 )begin
			@( posedge aclk) ;
			S_AXIS_MM2S_TVALID = 1	;
			S_AXIS_MM2S_TDATA  = cfg_arr[i]	;       // layer_id last number of kernel change to 1
			if( i==7 ) S_AXIS_MM2S_TLAST  = 1;
			wait(S_AXIS_MM2S_TREADY);
		end

		
		@(posedge aclk);
		S_AXIS_MM2S_TVALID = 0;
		S_AXIS_MM2S_TDATA  = 'h0;
		S_AXIS_MM2S_TLAST  = 0;

		#(`CYCLE*10);
		
		// Bias
		for(i=0; i<ONCE_BIAS; i=i+1)begin
			@(posedge aclk);
			S_AXIS_MM2S_TVALID = 1;
			S_AXIS_MM2S_TDATA  = bias_t[	i + rounds*ONCE_BIAS	];
			if(i==(ONCE_BIAS-1) )begin
				S_AXIS_MM2S_TLAST = 1;
			end
			#0.1;
			wait(S_AXIS_MM2S_TREADY);
		end
		
		@(posedge aclk);
		S_AXIS_MM2S_TLAST  = 0;
		S_AXIS_MM2S_TVALID = 0;
		S_AXIS_MM2S_TDATA  = 'h0;
		#(`CYCLE*5);

	// repeat rounds kernel and ifmap 
	
		    // Kernel
		for(i=0; i<ONCE_KER; i=i+1)begin
			@(posedge aclk);
			S_AXIS_MM2S_TVALID = 1;
			S_AXIS_MM2S_TDATA  = weights[	i   + rounds*ONCE_KER  ];
			if(i==(ONCE_KER-1) )begin
				S_AXIS_MM2S_TLAST = 1;
			end

			#0.1;
			//if(i == 5) begin S_AXIS_MM2S_TVALID=0; #(`CYCLE*5); end
			//else #0.1;
				
			wait(S_AXIS_MM2S_TREADY);
		end
		
		@(posedge aclk);
		S_AXIS_MM2S_TLAST  = 0;
		S_AXIS_MM2S_TVALID = 0;
		S_AXIS_MM2S_TDATA  = 'h0;
		#(`CYCLE*5);
		
		
		//
		M_AXIS_S2MM_TREADY = 1;
		
		// ifmap
		for(i=0; i<IFMAP_SIZE; i=i+1)begin
			@(posedge aclk);
			S_AXIS_MM2S_TVALID = 1;
			S_AXIS_MM2S_TDATA  = ifmap[i];
			if(i==(IFMAP_SIZE-1) )begin
				S_AXIS_MM2S_TLAST = 1;
			end
			#0.1;
			wait(S_AXIS_MM2S_TREADY);
		end
		
		@(posedge aclk);
		S_AXIS_MM2S_TLAST  = 0;
		S_AXIS_MM2S_TVALID = 0;
		S_AXIS_MM2S_TDATA  = 'h0;
		#(`CYCLE*5);

		wait(M_AXIS_S2MM_TLAST);
		#(`CYCLE*20);
		M_AXIS_S2MM_TREADY = 0;

	end


    wait(M_AXIS_S2MM_TLAST);
    #(`CYCLE*5);
    
    done = 1;
   // $finish;
end


integer fp_w;

initial begin
    fp_w = $fopen(`PATH_LOG, "w");
    
    error = 0;
    wait(done);
    for(ofmap_num=0; ofmap_num<		OFMAP_SIZE		; ofmap_num=ofmap_num+1)begin
		if( ofmap_gold[ofmap_num] !== 64'h3412cdab3412cdab )begin
			if( ofmap_gold[ofmap_num] !== 64'hfefefefefefefefe )begin
				if(ofmap[ofmap_num] !== ofmap_gold[ofmap_num])begin
					$display("error at %d, ofmap= %x  ofmap_gold= %x\n", ofmap_num, ofmap[ofmap_num], ofmap_gold[ofmap_num]);
					error = error + 1;
					$fwrite(fp_w, "error at %d, ofmap= %x  ofmap_gold= %x\n", ofmap_num, ofmap[ofmap_num], ofmap_gold[ofmap_num]);
				end
			end
		end
        
    end
	$display( " total cycle = %d\n" ,tot_cycle);
	$display( " load and output cycle = %d\n" ,cpt_cycle);
    if(error > 0)begin
        $display("QQ, Total error = %d\n", error);
    end else begin
		$display("^__^");

    end

    $fclose(fp_w);
    $finish;
end

always @(posedge aclk)begin
    if(~aresetn)begin
        ofmap_cnt <= 'd0;
    end else begin
        if(M_AXIS_S2MM_TVALID)begin
            ofmap_cnt        <= ofmap_cnt + 1;
            ofmap[ofmap_cnt] <= M_AXIS_S2MM_TDATA;
        end else begin
            ofmap_cnt        <= ofmap_cnt;
        end
    end
end

always begin #(`CYCLE/2) aclk = ~aclk; end


`ifdef CYC_TEST 

	always@( posedge aclk or posedge aresetn )begin
		if( ~aresetn )begin
			tot_cycle <= 0;
			cpt_cycle <= 0;
		end
		else begin
			if( debug_3x3_current_state !== 4'd0 )begin
				tot_cycle <= tot_cycle +1 ;
			end
			else begin
				tot_cycle <= tot_cycle ;
			end

			if( debug_3x3_current_state == 4'd6 || debug_3x3_current_state == 4'd3 || debug_3x3_current_state == 4'd4 || debug_3x3_current_state == 4'd2 )begin
				cpt_cycle <= cpt_cycle +1 ;
			end
			else begin
				cpt_cycle <= cpt_cycle ;
			end
		end

	end

`endif 






endmodule

