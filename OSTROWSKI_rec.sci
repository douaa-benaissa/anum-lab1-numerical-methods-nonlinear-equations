function M = OSTROWSKI_rec(f, df, x0, N)
    M = zeros(N+1, 4);
    x = x0;
    for k = 1:N
        fx  = f(x);
        dfx = df(x);
        y   = x - fx/dfx;    // 1st step (Newton)
        fy  = f(y);
        xnew = y - (fx/(fx - 2*fy)) * (fy/dfx);  // 2nd step
        M(k,:) = [k-1, x, fx, abs(xnew - x)]; //record data
        x = xnew;
    end
    M(N+1,:) = [N, x, f(x), %nan];
endfunction
