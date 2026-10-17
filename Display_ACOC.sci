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
