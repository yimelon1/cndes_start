


//===   BLOCK RAM wire declare  ==============================================================
localparam KER_SRAM_ADDBITS = 11         ;
localparam KER_SRAM_DATA_WIDTH = 64      ;
localparam IFMAP_SRAM_ADDBITS = 11       ;
localparam IFMAP_SRAM_DATA_WIDTH = 64    ;

//---- BRAM_KER  -------
wire en_sram_ker0 , wea_sram_ker0 ;
wire en_sram_ker1 , wea_sram_ker1 ;
wire en_sram_ker2 , wea_sram_ker2 ;
wire en_sram_ker3 , wea_sram_ker3 ;
wire en_sram_ker4 , wea_sram_ker4 ;
wire en_sram_ker5 , wea_sram_ker5 ;
wire en_sram_ker6 , wea_sram_ker6 ;
wire en_sram_ker7 , wea_sram_ker7 ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ker0  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ker1  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ker2  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ker3  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ker4  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ker5  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ker6  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ker7  ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ker0   ,   dout_sram_ker0 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ker1   ,   dout_sram_ker1 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ker2   ,   dout_sram_ker2 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ker3   ,   dout_sram_ker3 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ker4   ,   dout_sram_ker4 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ker5   ,   dout_sram_ker5 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ker6   ,   dout_sram_ker6 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ker7   ,   dout_sram_ker7 ;



//---- BRAM_IFMAP --------
wire en_sram_ifm0 , wea_sram_ifm0 ;
wire en_sram_ifm1 , wea_sram_ifm1 ;
wire en_sram_ifm2 , wea_sram_ifm2 ;
wire en_sram_ifm3 , wea_sram_ifm3 ;
wire en_sram_ifm4 , wea_sram_ifm4 ;
wire en_sram_ifm5 , wea_sram_ifm5 ;
wire en_sram_ifm6 , wea_sram_ifm6 ;
wire en_sram_ifm7 , wea_sram_ifm7 ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm0  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm1  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm2  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm3  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm4  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm5  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm6  ;
wire [  KER_SRAM_ADDBITS-1  :   0   ]   addr_sram_ifm7  ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm0   ,   dout_sram_ifm0 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm1   ,   dout_sram_ifm1 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm2   ,   dout_sram_ifm2 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm3   ,   dout_sram_ifm3 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm4   ,   dout_sram_ifm4 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm5   ,   dout_sram_ifm5 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm6   ,   dout_sram_ifm6 ;
wire [  KER_SRAM_DATA_WIDTH-1   :   0   ]   din_sram_ifm7   ,   dout_sram_ifm7 ;


//----------------------------------------------------------------


//===   BLOCK RAM declare  ==============================================================
// write first or read first
BRAM_KER K0(
    .clka       (       clk                 ),// input wire clka 
    .ena        (       en_sram_ker0        ),// input wire ena 
    .wea        (       wea_sram_ker0       ),// input wire [0 : 0] wea  
    .addra      (       addr_sram_ker0      ),// input wire [ 11 : 0] addra  
    .dina       (       din_sram_ker0       ),// input wire [ 63 : 0] dina  
    .douta      (       dout_sram_ker0      ) // output wire [ 63: 0] douta  
);

BRAM_KER K1(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ker1        ),// input wire ena
    .wea        (       wea_sram_ker1       ),// input wire [0 : 0] wea
    .addra      (       addr_sram_ker1      ),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ker1       ),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ker1      ) // output wire [ 63: 0] douta
);
BRAM_KER K2(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ker2        ),// input wire ena
    .wea        (       wea_sram_ker2       ),// input wire [0 : 0] wea
    .addra      (       addr_sram_ker2      ),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ker2       ),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ker2      ) // output wire [ 63: 0] douta
);
BRAM_KER K3(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ker3        ),// input wire ena
    .wea        (       wea_sram_ker3       ),// input wire [0 : 0] wea
    .addra      (       addr_sram_ker3      ),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ker3       ),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ker3      ) // output wire [ 63: 0] douta
);
BRAM_KER K4(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ker4        ),// input wire ena
    .wea        (       wea_sram_ker4       ),// input wire [0 : 0] wea
    .addra      (       addr_sram_ker4      ),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ker4       ),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ker4      ) // output wire [ 63: 0] douta
);
BRAM_KER K5(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ker5        ),// input wire ena
    .wea        (       wea_sram_ker5       ),// input wire [0 : 0] wea
    .addra      (       addr_sram_ker5      ),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ker5       ),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ker5      ) // output wire [ 63: 0] douta
);
BRAM_KER K6(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ker6        ),// input wire ena
    .wea        (       wea_sram_ker6       ),// input wire [0 : 0] wea
    .addra      (       addr_sram_ker6      ),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ker6       ),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ker6      ) // output wire [ 63: 0] douta
);
BRAM_KER K7(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ker7        ),// input wire ena
    .wea        (       wea_sram_ker7       ),// input wire [0 : 0] wea
    .addra      (       addr_sram_ker7      ),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ker7       ),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ker7      ) // output wire [ 63: 0] douta
);


BRAM_IF IN0(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ifm0		),// input wire ena
    .wea        (       wea_sram_ifm0		),// input wire [0 : 0] wea
    .addra      (       addr_sram_ifm0		),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ifm0		),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ifm0		) // output wire [ 63: 0] douta
);
BRAM_IF IN1(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ifm1		),// input wire ena
    .wea        (       wea_sram_ifm1		),// input wire [0 : 0] wea
    .addra      (       addr_sram_ifm1		),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ifm1		),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ifm1		) // output wire [ 63: 0] douta
);
BRAM_IF IN2(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ifm2		),// input wire ena
    .wea        (       wea_sram_ifm2		),// input wire [0 : 0] wea
    .addra      (       addr_sram_ifm2		),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ifm2		),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ifm2		) // output wire [ 63: 0] douta
);
BRAM_IF IN3(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ifm3		),// input wire ena
    .wea        (       wea_sram_ifm3		),// input wire [0 : 0] wea
    .addra      (       addr_sram_ifm3		),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ifm3		),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ifm3		) // output wire [ 63: 0] douta
);
BRAM_IF IN4(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ifm4		),// input wire ena
    .wea        (       wea_sram_ifm4		),// input wire [0 : 0] wea
    .addra      (       addr_sram_ifm4		),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ifm4		),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ifm4		) // output wire [ 63: 0] douta
);
BRAM_IF IN5(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ifm5		),// input wire ena
    .wea        (       wea_sram_ifm5		),// input wire [0 : 0] wea
    .addra      (       addr_sram_ifm5		),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ifm5		),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ifm5		) // output wire [ 63: 0] douta
);
BRAM_IF IN6(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ifm6		),// input wire ena
    .wea        (       wea_sram_ifm6		),// input wire [0 : 0] wea
    .addra      (       addr_sram_ifm6		),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ifm6		),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ifm6		) // output wire [ 63: 0] douta
);
BRAM_IF IN7(
    .clka       (       clk                 ),// input wire clka
    .ena        (       en_sram_ifm7		),// input wire ena
    .wea        (       wea_sram_ifm7		),// input wire [0 : 0] wea
    .addra      (       addr_sram_ifm7		),// input wire [ 11 : 0] addra
    .dina       (       din_sram_ifm7		),// input wire [ 63 : 0] dina
    .douta      (       dout_sram_ifm7		) // output wire [ 63: 0] douta
);

//============================================= END OF BLOCK RAM declare ===============