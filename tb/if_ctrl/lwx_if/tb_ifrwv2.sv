// ============================================================================
// Designer : Wei-Xuan Luo
// Create   : 2022.11.18
// Ver      : 2.0
// Func     : FSM with instruction get testbench, every state need 10 cycle to done
// 			and test for start instruction on different cycle 
// ============================================================================

// `define VIVA
`define End_CYCLE  1000      // Modify cycle times once your design need more cycle times!
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
	`define IF_PAT   "./PAT/tile_in_6x16x32.dat"
	`define GOLD_IF_PAT "./PAT/gold_tile_in_6x16x32.dat"
`endif

module tb_ifrwv2();

	parameter TBITS = 64;
	parameter TBYTE = 8;


    reg [30:0] cycle=0;
	reg  clk;         
	reg  reset; 

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


//---------- pattern declare-----------------
    logic tb_memread_done ;
    reg    [TBITS-1 : 0]      ifmap             [0:2047];
    reg    [TBITS-1 : 0]      gold_ifmap        [0:2047];


    wire [TBITS-1: 0 ] if_write_data_din;		
    wire               if_write_empty_n_din;	
    reg                if_write_read_dout;	

    reg                if_write_start;
    wire               if_write_busy;
    wire               if_write_done;

    reg                if_read_start;
    wire               if_read_busy;
    wire               if_read_done;

    reg                ifsram0_write;
    reg                ifsram1_write;
    reg                ifsram0_read;
    reg                ifsram1_read;


    reg  [2:0]         current_state;

    integer  iix , i1 , i0 ;
    wire row_finish;
    wire change_sram;
    localparam [2:0] 
    IDLE          = 3'd0,
    LOAD          = 3'd1,
    UP_PADDING    = 3'd2,
    THREEROW      = 3'd3,
    TWOROW        = 3'd4,
    ONEROW        = 3'd5,
    DOWN_PADDING  = 3'd6;
// =============================================================================
// =======		instance 	===================================================
// =============================================================================

    ifsram_rw iftest(
        .clk(clk),
        .reset(reset),

        .if_write_data_din(isif_data_dout)		,
        .if_write_empty_n_din(isif_empty_n)		,
        .if_write_read_dout(isif_read)		,

        .if_write_done(if_write_done) 		,
        .if_write_busy(if_write_busy) 		,
        .if_write_start(if_write_start)		,	

        .if_read_done(if_read_done) 		,
        .if_read_busy(if_read_busy) 		,
        .if_read_start(if_read_start)		,

        .ifsram0_read(ifsram0_read)		,
        .ifsram1_read(ifsram1_read)		,
        .ifsram0_write(ifsram0_write)	,
        .ifsram1_write(ifsram1_write)   ,
        .row_finish(row_finish),
        .change_sram(change_sram),
        .current_state(current_state)   


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

// =============================================================================
// ================		fsdb dump +mda+packedmda		========================
// ================		Kernel data load readmemh		========================
// =============================================================================

	initial begin
		`ifdef RTL
			$fsdbDumpfile("tbif.fsdb");
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
        $readmemh(`GOLD_IF_PAT, gold_ifmap); 
    //--------- pattern reading end -----------	
		#1;
		tb_memread_done = 1;  
    end
// =============================================================


    initial begin
        #1;
		reset = 0;
		#( `CYCLE*3 ) ;
		reset = 1;
        ifsram0_write = 0;
        ifsram1_write = 0;
        //-----------reset signal start ------------------
        S_AXIS_MM2S_TKEEP = 'hff;
		S_AXIS_MM2S_TLAST = 0 ;
        if_write_start = 0;
		if_read_start = 0 ;
        //-----------reset signal end --------------------
        #( `CYCLE*4 + `NI_DELAY ) ;
        reset = 0;
        #( `CYCLE*5 ) ;
        //----- wait mem read --------------
        wait(tb_memread_done) ;
        #( `CYCLE*5 ) ;
        //---------write start--------
        wait(!if_write_busy);
        ifsram0_write = 1;
        @( posedge clk );
        if_write_start = 1;
        #( `CYCLE*3 ) ;
        @( posedge clk );
        if_write_start = 0;
        for( i0 = 0 ; i0 < 192 ; i0 = i0 + 1)begin
			@(posedge clk);
            S_AXIS_MM2S_TVALID = 1;
            S_AXIS_MM2S_TDATA  = ifmap[i0];
            if(i0 == 191)begin
                S_AXIS_MM2S_TLAST = 1 ;
            end
            wait(S_AXIS_MM2S_TREADY);
		end
        @(posedge clk);
        S_AXIS_MM2S_TVALID = 0 ;
		S_AXIS_MM2S_TLAST = 0 ;
        @(posedge clk);
		ifsram0_write = 0;
        //-----------write end-------------
        #( `CYCLE*3 ) ;
        #( `CYCLE*4 + `NI_DELAY ) ;
        //---------read start--------
        wait(!if_read_busy);
        //ifsram0_read= 1;
        @( posedge clk );
        //=================
        current_state = 5;
        //=================
        #1 //delay a cycle
        if_read_start = 1;
        #( `CYCLE*3 );
        @( posedge clk );
        if_read_start = 0;
        #( `CYCLE*3 );
        wait(if_read_done);
        //-----------read end-------------
        #( `CYCLE*3 );
        wait(!if_write_busy);
        ifsram1_write = 1;
        @( posedge clk
        );
        if_write_start = 1;
        #( `CYCLE*3 ) ;
        @( posedge clk );
        if_write_start = 0;
        for( i0 = 192 ; i0 < 192*2 ; i0 = i0 + 1)begin
			@(posedge clk);
            S_AXIS_MM2S_TVALID = 1;
            S_AXIS_MM2S_TDATA  = ifmap[i0];
            if(i0 == 192*2-1)begin
                S_AXIS_MM2S_TLAST = 1 ;
            end
            wait(S_AXIS_MM2S_TREADY);
		end
        @(posedge clk);
        S_AXIS_MM2S_TVALID = 0 ;
		S_AXIS_MM2S_TLAST = 0 ;
        @(posedge clk);
		ifsram1_write = 0 ;

        #( `CYCLE*10) ;
        $finish;

    end


reg [1:0]sram_top;
reg stay_sram_top;

always @(posedge clk)begin
    if(reset)begin
        sram_top <= 0;
		stay_sram_top <= 0;
	end
	else if(if_write_done)
		stay_sram_top <= 0;
	else if(stay_sram_top)
		sram_top <= sram_top;
	else if(sram_top == 0)begin
		if(ifsram0_write)begin
			sram_top <= 1;
			stay_sram_top <= 1;
		end
		else if(ifsram1_write)begin 
			sram_top <= 2;
			stay_sram_top <= 1;
		end
		else 
			sram_top <= sram_top;
	end
	else begin
		if(ifsram0_write)begin
			sram_top <= 2;
			stay_sram_top <= 1;
		end
		else if(ifsram1_write)begin
			sram_top <= 1;
			stay_sram_top <= 1;
		end
		else 
			sram_top <= sram_top;
	end
end





reg change_time;
always @(posedge clk)begin
	if(reset)
		change_time <= 0;
	else if(change_sram)
		change_time <= 1;
	else if(row_finish)
		change_time <= 0;
	else
		change_time <= change_time;
end


always @ (*) begin
	if(if_read_busy)begin
		if(current_state == UP_PADDING || current_state == THREEROW || current_state == DOWN_PADDING)begin
			if(sram_top == 1)begin
				ifsram0_read = 1;
				ifsram1_read = 0;
			end
			else if(sram_top == 2)begin
				ifsram0_read = 0;
				ifsram1_read = 1;
			end
			else begin
				ifsram0_read = 0;
				ifsram1_read = 0;
			end
		end
		else if(current_state >= THREEROW || current_state <= ONEROW)begin
			if(sram_top == 1)begin
				if(change_time)begin
					ifsram0_read = 0;
					ifsram1_read = 1;
				end
				else begin
					ifsram0_read = 1;
					ifsram1_read = 0;
				end
			end
			else if(sram_top == 2)begin
				if(change_time)begin
					ifsram0_read = 1;
					ifsram1_read = 0;
				end
				else begin
					ifsram0_read = 0;
					ifsram1_read = 1;
				end
			end
			else begin
				ifsram0_read = 0;
				ifsram1_read = 0;
			end
		end
		else begin
				ifsram0_read = 0;
				ifsram1_read = 0;
		end
	end
	else begin
				ifsram0_read = 0;
				ifsram1_read = 0;
	end
end

endmodule




//接收資料的code //設 vaild 接收到vaild 才存入
// always @ (posedge clk) begin

// end 
//=============
