`timescale 1ns/10ps
`define CYCLE      10.0          	            // Modify your clock period here
`define End_CYCLE  100000                       // Modify cycle times once your design need more cycle times!

`define serial32_in_pat "../serial32_in.dat"       // ifm x ker + bias
`define act_sum_in_pat  "../act_sum_in.dat"        // ifm x ker 
`define q3_pat          "../q3.dat"                // ofm

module quantize_tb;

reg	    clk;
reg		reset;
reg		[31:0 ] m0_scale;
reg		[ 7:0 ] index;
reg		[15:0 ] z_of_weight;
reg		[ 7:0 ] z3;
reg     [ 9:0 ] iaddr = 0;
reg     [ 9:0 ] iaddr1 = 0;
reg	    [31:0 ]	serial32_in;
reg	    [31:0 ]	act_sum_in;
reg		[ 7:0 ] q_valid;


reg	    [31:0]	serial32_in_pat	 [0:809];
reg	    [31:0]	act_sum_in_pat	 [0:809];
reg     [7 :0]  q3_pat           [0:809];
reg     [7 :0]  q3_reg           [0:809];

wire    [7 :0]	q_out;

integer p0, err00;

quan2uint8 uut(
	            .clk(clk),
	            .reset(reset),
                // valid_in,
                .serial32_in(serial32_in),
                .act_sum_in(act_sum_in),
                .m0_scale(m0_scale),
                .index(index),
                .z_of_weight(z_of_weight),
                .z3(z3),
                .q_out(q_out),
                .q_valid(q_valid)
);


// =============================================================================
// ================		fsdb dump +mda+packedmda		========================
// ================		Kernel data load readmemh		========================
// =============================================================================
	initial begin
		`ifdef RTL
			$fsdbDumpfile("tbker.fsdb");
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
	$readmemh(`serial32_in_pat, serial32_in_pat);
    $readmemh(`act_sum_in_pat, act_sum_in_pat);
    $readmemh(`q3_pat, q3_pat);
end


always begin #(`CYCLE/2) clk = ~clk; end

always@(posedge clk) begin // generate the stimulus input data
    if( reset )begin
        serial32_in <= 'd0 ;
        act_sum_in  <= 'd0 ;
	end
	else begin
		serial32_in <= serial32_in_pat[iaddr];
        act_sum_in <= act_sum_in_pat[iaddr];
        iaddr <= iaddr + 1;
	end
end

always@(posedge clk) begin
	if( q_valid )begin
        q3_reg[iaddr1] <= q_out;
        iaddr1 <= iaddr1 + 1;
    end
end

initial begin  	// layer 0,  conv output
wait(iaddr1 == 816)
err00 = 0;
for (p0=0; p0<=809; p0=p0+1) begin
	if (q3_pat[p0] == q3_reg[p0]) ;
	else begin
	    err00 = err00 + 1;
		begin 
			$display("WRONG! Pixel %d is wrong!", p0);
			$display("The output data is %h, but the expected data is %h ", q3_reg[p0], q3_pat[p0]);
		end
	end
end
if(err00==0) 
    $display("Congratulations! quantize have been generated successfully! The result is PASS!!\n");
$finish;
end

initial begin
	clk = 1;
	reset = 1;
    z3 = 0;
    m0_scale = 1333811370;
    index = 7;
    z_of_weight = 133;
	#20
	reset = 0;

    #50
    q_valid <= 1;

	#3000 
	$finish;
end

endmodule