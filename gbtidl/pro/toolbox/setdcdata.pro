;+ 
; Convenience function for setting data array of a data container.
;
; @param dc {in}{required}{type=struct} data container (spectrum or continuum)
; @param value {in}{required}{type=float} single float or array float  
; @param elements {in}{optional}{type=long} elements of data to set, one integer, or two element array specifiying range
;
;-
pro setdcdata, dc, value, elements

    if data_valid(dc) eq -1 then message, "Data container must contain valid data"
    
    if n_elements(elements) ne 0 then begin
        ; try to set part of the array
        if n_elements(elements) gt 2 then begin
            message, "elements keyword must be one index, or a two element index specifiying the range"
        endif else begin
            if n_elements(elements) eq 1 then begin
                ; set one data point
                if (elements lt 0) or (elements gt (n_elements(*dc.data_ptr)-1)) then message, "element out of data range"
                if (n_elements(value) ne 1) then message, "attempting to set array of values when elements keyword specifies only one data point to set"
                (*dc.data_ptr)[elements] = value
            endif else begin
                ; set a range of data points
                b = elements[0]
                e = elements[1]
                if (b lt 0) or (b gt (n_elements(*dc.data_ptr)-1)) or (e lt b) or (e gt (n_elements(*dc.data_ptr)-1)) then $
                    message, "elements out of range"
                if (n_elements(value) ne 1) and (n_elements(value) ne (e-b+1)) then message, "range specified by elements keyword does not match length of values to set"    
                (*dc.data_ptr)[b:e] = value
            endelse 
        endelse     
    endif else begin
        ; set the entire array
        *dc.data_ptr = value
    endelse

end  
