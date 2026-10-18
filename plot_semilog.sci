//helper selecting the drawable points
function [n, lv] = Valid_points(T, col)
    v  = abs(T(:, col));
    k  = find(v > 0); // removes %nan and exact zeros
    n  = T(k, 1);
    lv = log10(v(k));
endfunction

function Plot_one(T, col, style)// draw one curve
    [n, lv] = Valid_points(T, col);
    if isempty(n) then
        return
    end
    plot(n, lv, style);
endfunction

function Plot_convergence(TN, TS, TO, col) // input=record matrix
    if col == 4 then
        ylab = "log10 |x_{n+1} - x_n|";
    else
        ylab = "log10 |f(x_n)|";
    end

// new empty figure
    scf();
    clf();

// the three curves 
    Plot_one(TN, col, "b-o"); // NEWTON
    Plot_one(TS, col, "r-s");// SECANTE
    Plot_one(TO, col, "g-d");// OSTROWSKI

    xgrid();
    xlabel("n");
    ylabel(ylab);
    title("Convergence of the three methods");
    legend("Newton", "Secante", "Ostrowski");
endfunction
