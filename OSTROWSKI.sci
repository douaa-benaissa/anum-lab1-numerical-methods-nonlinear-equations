function [y, n] = OSTROWSKI(f, df, x0, e)
    nbMax = 100;
    rn  = x0;
    rn1 = x0;
    n = 0;
    converged = %f;

    while n < nbMax
        fx = f(rn);
        if fx == 0 then                  // already exactly at the root
            rn1 = rn;
            converged = %t;
            break
        end
        d = df(rn);
        if d == 0 then
            error("OSTROWSKI: zero derivative at r_n = " + string(rn));
        end

        yn = rn - fx/d;                              // step 1: Newton step
        fy = f(yn);
        rn1 = yn - (fx/(fx - 2*fy)) * (fy/d);        // step 2: correction
        n = n + 1;

        if abs(rn1 - rn) < e then
            converged = %t;
            break
        end
        rn = rn1;
    end

    if ~converged then
        mprintf("OSTROWSKI: tolerance not reached after %d iterations\n", n);
    end
    y = rn1;
endfunction
