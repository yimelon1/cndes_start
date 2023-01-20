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
