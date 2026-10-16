function [y,N] = NEWTON(f, df, x0, e)
    nbMax = 100;
    rn = x0;  
    N = 0 ; 
    converged = %f; 
    while N < nbMax 
        d = df(rn); 
        if d == 0 then
            error("NEWTON: zero derivative at r_n = " + string(rn)); 
        end
        rn1 = rn - f(rn)/d; 
        N = N + 1 ; 
        
        if abs(rn1 - rn) < e then 
            converged = %t ; 
            break 
        end
        rn = rn1;  
    end
    if ~converged then
        mprintf("NEWTON: tolerance not reached after %d iterations\n", N);
    end
    
    y = rn1; 
    
    
endfunction
