function [y] = SECANTE(r0, r1, fonc, n)
    rm = r0; 
    rn = r1;
    for k = 1:n
        fm = fonc(rm); 
        fn = fonc(rn); 
        if fn == fm then 
            break 
        end 
        rn1 = rn - (rn - rm)/(fn - fm) * fn; 
        rm = rn; 
        rn = rn1; 
    end
    y = rn;  
endfunction
