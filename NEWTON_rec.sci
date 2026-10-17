function M = NEWTON_rec(f, df, x0, N)
    // N as prameter to have the exact number of rows to the matrix 
    M = zeros(N+1, 4); //N+1 rows=> 0...N  // 4 columns=> n | xn | f(xn) | dn
    x = x0;
    for k = 1:N 
        xnew = x - f(x)/df(x);
        M(k,:) = [k-1, x, f(x), abs(xnew - x)];   // the record phase = save data to the matrix
        x = xnew;
    end
    M(N+1,:) = [N, x, f(x), %nan]; // // last iterate = no next step => dn is undefined ( no Xn+1 to calculate with)
endfunction
