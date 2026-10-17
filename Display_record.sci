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
