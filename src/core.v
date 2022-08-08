
`define BIG_ENDIAN		// when little endian is loaded by sdk or software

`include "./count_yi_v3.v"  // yi build counter module
// ============================================================================
// Ver      : 7.0
// Designer : Yi_Yuan Chen
// Create   : 2021.10.25
// Func     : convert the 3x3 data structure to 1x1 type
// ============================================================================

module core #(
	parameter TRANS_BYTE_SIZE = 8 ,
	parameter TRANS_BITS = 64 
)(
	input wire	clk,
	input wire	reset,

	// to INPUT_STREAM IF

	input wire [TRANS_BITS-1 :0 ]	din_isif_data ,
	input wire 						din_isif_last ,
	input wire [TRANS_BYTE_SIZE-1:0]				din_isif_strb,		//can't be none
	input wire 						din_isif_user,		//can't be none
	input wire						din_isif_empty_n,

	output wire						dout_isif_read ,		// convertor wanna read

	// to OUTPUT_STREAM IF
	input wire						din_osif_full_n,

	output wire [TRANS_BITS-1 :0 ]	dout_osif_data ,
	output wire 					dout_osif_last ,	// the last output data 
	output wire [TRANS_BYTE_SIZE-1:0]				dout_osif_strb,		//can't be none
	output wire 					dout_osif_user,		//can't be none
	output wire						dout_osif_write 	// convertor wanna write
  );

wire [TRANS_BITS-1 :0 ] output_data ;


`ifdef BIG_ENDIAN       
assign endian_trans_data_in ={ 	din_isif_data[ 7 :  0], 
								din_isif_data[15 :  8],
								din_isif_data[23 : 16],
								din_isif_data[31 : 24],
								din_isif_data[39 : 32],
								din_isif_data[47 : 40],
								din_isif_data[55 : 48],
								din_isif_data[63 : 56]
						  };
					
assign endian_trans_data_out ={ 	output_data[ 7 :  0], 
								output_data[15 :  8],
								output_data[23 : 16],
								output_data[31 : 24],
								output_data[39 : 32],
								output_data[47 : 40],
								output_data[55 : 48],
								output_data[63 : 56]
						  }; 
				
`else
assign endian_trans_data_in         = din_isif_data;
assign endian_trans_data_out    	= output_data;
`endif



//=======================================================================================
// ----------   include  another code -------------------------
`include "./bram_inst.v"
//=======================================================================================




//=======================================================================================
//----- FSM declare ------------
    localparam IDLE= 0;
	localparam LOAD_CONFIG = 1;         
    localparam LOAD_BIAS = 2 ;          
    localparam LOAD_KER = 3 ;           
    localparam LOAD_IFMAP = 4 ;         
	localparam RESET_CNT = 5;           
	

    reg [3:0] current_state , next_state ;


always@( posedge clk )begin
    if( reset )begin
        current_state <= IDLE ;
    end
    else begin
        current_state <= next_state ;
    end

end

always@( * )begin
    case( current_state )
        IDLE : next_state = ( start_flag )? LOAD_CONFIG : IDLE ;
        LOAD_CONFIG : next_state = LOAD_BIAS  ;
        LOAD_BIAS : next_state = IDLE ;
        default : next_state = IDLE ;
    endcase
end

wire  start_flag ;

// always@(*) start_flag = ( din_isif_empty_n && current_state== IDLE )? 1'd1 : 1'd0 ;
 assign start_flag = ( din_isif_empty_n && current_state== IDLE )? 1'd1 : 1'd0 ;

//=======================================================================================
wire en_ct ;
assign en_ct = ( current_state == LOAD_BIAS )? 1'd1 : 1'd0 ;
assign end_lb = ( cnt_bias == 20 )? 	1'd1 : 1'd0 ;
wire [  7 : 0 ]cnt_bias ;

count_yi_v3  #(
    .BITS_OF_END_NUMBER ( 8 )
)bias_addr(
	.clk			(	clk		),
	.reset			(	reset	) , 
	.enable			(	en_ct	) , 
	.final_number	(	8'd25	),
	.cnt_q			(	cnt_bias	)	
);




endmodule
