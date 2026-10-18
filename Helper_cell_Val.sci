// helper function for the display 
function s = Helper_cell_Val(v, pattern)
    if isnan(v) then
        s = "-"; // the cell conatins no data 
    else
        s = msprintf(pattern, v ); // affect the value to the cell
    end
endfunction
