

module if_dout_mux #(
	parameter DATA_WIDTH = 64 
)(
	data_valid
	,	ifsram0_read
	,	ifsram1_read
	,	dinsr_0	
	,	dinsr_1	
	,	dout		
);
	
input wire	data_valid		;
input wire	ifsram0_read	;
input wire	ifsram1_read	;
input wire 	[DATA_WIDTH-1 : 0 ]	dinsr_0	;
input wire 	[DATA_WIDTH-1 : 0 ]	dinsr_1	;
output	reg 	[DATA_WIDTH-1 : 0 ]	dout 		;

	always@(*)begin
		if(data_valid)begin
			if(ifsram0_read)
				dout = dinsr_0;
			else if(ifsram1_read)
				dout = dinsr_1;
			else
				dout = 0;
		end
		else
			dout = 0;
	end


endmodule