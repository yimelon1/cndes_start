//---- pe_result mod start------ 
//----pe0_result---------
if( pe0_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin
    if ( pe1_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin
        pe0_test_stay <= pe1_test_stay  ;
    end
    else begin
        pe0_test_stay <= pe0_rsu_stay ;
    end
end
else begin
    pe0_test_stay <= pe0_test_stay  ;
end
//----pe1_result---------
if( pe1_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin
    if ( pe2_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin
        pe1_test_stay <= pe2_test_stay  ;
    end
    else begin
        pe1_test_stay <= pe1_rsu_stay ;
    end
end
else begin
    pe1_test_stay <= pe1_test_stay  ;
end
//----pe2_result---------
if( pe2_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin
    if ( pe3_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin
        pe2_test_stay <= pe3_test_stay  ;
    end
    else begin
        pe2_test_stay <= pe2_rsu_stay ;
    end
end
else begin
    pe2_test_stay <= pe2_test_stay  ;
end
//----pe3_result---------
if( pe3_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin
    if ( pe4_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin
        pe3_test_stay <= pe4_test_stay  ;
    end
    else begin
        pe3_test_stay <= pe3_rsu_stay ;
    end
end
else begin
    pe3_test_stay <= pe3_test_stay  ;
end
//----pe4_result---------
if( pe4_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin
    if ( pe5_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin
        pe4_test_stay <= pe5_test_stay  ;
    end
    else begin
        pe4_test_stay <= pe4_rsu_stay ;
    end
end
else begin
    pe4_test_stay <= pe4_test_stay  ;
end
//----pe5_result---------
if( pe5_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin
    if ( pe6_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin
        pe5_test_stay <= pe6_test_stay  ;
    end
    else begin
        pe5_test_stay <= pe5_rsu_stay ;
    end
end
else begin
    pe5_test_stay <= pe5_test_stay  ;
end
//----pe6_result---------
if( pe6_rsu_stay[ QOUT_BITS + INV_BITS-1  -: 1 ]) begin
    if ( pe7_test_stay[ QOUT_BITS + INV_BITS-1  -: 1 ])begin
        pe6_test_stay <= pe7_test_stay  ;
    end
    else begin
        pe6_test_stay <= pe6_rsu_stay ;
    end
end
else begin
    pe6_test_stay <= pe6_test_stay  ;
end
//---- pe_result mod end------ 
