function M = SECANTE_rec(r0, r1, f, n)
    M = zeros(n+2, 4);  // n rows = 0..n+1
    a = r0; b = r1;    // a = current point 
                        // b = next point
    for k = 1:n
        c = b - f(b)*(b - a)/(f(b) - f(a));   // the point after b
        M(k,:) = [k-1, a, f(a), abs(b - a)];  // record a // dn = |b - a|
        a = b; b = c;
    end
    M(n+1,:) = [n,   a, f(a), abs(b - a)];    // rn has a next point => b 
    M(n+2,:) = [n+1, b, f(b), %nan];          // last point = no next step
endfunction
