function A = Approxim_Comp_Order_Conv(T)
    // T => record matrix  [n | xn | f(xn) | dn]
    m = size(T,1) - 1;   // the last row has no dn
    n = T(1:m,1);  
    x = T(1:m,2);  
    d = T(1:m,4);

    r  = %nan*ones(m,1);  // %nan = no data
    lr = %nan*ones(m,1);
    p  = %nan*ones(m,1);

    for k = 2:m         // n = k-1 >= 1
        if d(k-1) > 0 & d(k) > 0 then
            r(k)  = d(k)/d(k-1);   // rn = dn / dn-1
            lr(k) = log(r(k));    // ln(rn)
        end
    end

    for k = 3:m         // n = k-1 >= 2
        if ~isnan(lr(k)) & ~isnan(lr(k-1)) & lr(k-1) <> 0 then
            p(k) = lr(k)/lr(k-1);  // pn = ln(rn) / ln(rn-1)
        end
    end

    A = [n, x, d, r, lr, p];   // m rows, 6 columns
endfunction
