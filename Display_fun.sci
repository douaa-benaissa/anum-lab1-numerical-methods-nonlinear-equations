// helper function for the display 
function s = Helper_cell_Val(v, pattern)
    if isnan(v) then
        s = "-"; // the cell conatins no data 
    else
        s = msprintf(pattern, v ); // affect the value to the cell
    end
endfunction

function Display_ACOC (A, name)
    mprintf("\n~~~~ %s : ACOC ~~~~\n", name);
    mprintf("%3s %20s %13s %13s %13s %10s\n", "n", "xn", "dn", "rn", "ln(rn)", "pn");
    for k = 1:size(A,1)
        mprintf("%3d %20s %13s %13s %13s %10s\n", A(k,1), ..
                Helper_cell_Val(A(k,2), "%.15f"), ..
                Helper_cell_Val(A(k,3), "%.3e"), ..
                Helper_cell_Valt(A(k,4), "%.3e"), ..
                Helper_cell_Val(A(k,5), "%.3e"), ..
                Helper_cell_Val(A(k,6), "%.4f"));
    end
endfunction

function Display_record(T, name)
    // name of the method as an argument
    mprintf("\n~~~~ %s : record ~~~~\n", name);
    mprintf("%3s %20s %13s %13s\n", "n", "xn", "f(xn)", "dn");
    for k = 1:size(T,1)
        mprintf("%3d %20s %13s %13s\n", T(k,1), ..
                Helper_cell_Val(T(k,2), "%.15f"), ..
                Helper_cell_Val(T(k,3), "%.3e"), ..
                Helper_cell_Val(T(k,4), "%.3e"));
    end
endfunction
