;+
; Do a boxcar smooth on a 1D array.
;
; <p>This uses the IDL smooth for odd smoothing widths but even widths
; are handled here since smooth rounds even widths to the next higher
; integer.  Only 1-d arrays are handled here.
;
; @param array {in}{required}{type=1d array} The array to be smoothed.
; @param width {in}{required}{type=integer} The width of the boxcar.
; @keyword edge_truncate {in}{optional}{type=boolean} Same meaning as
; for smooth.
; @keyword nan {in}{optional}{type=boolean} Same meaning as for
; smooth.
; @keyword missing {in}{optional}{type=same type as array}{default=NaN} 
; Same meaning as for smooth.
;
; @returns the smoothed result.
;
; @version $Id$
;-
function doboxcar1d, array, width, edge_truncate=edge_truncate, nan=nan, missing=missing
    compile_opt idl2

    on_error,2

    if n_elements(array) eq 0 or n_elements(width) eq 0 then message,'array and width must be specified'

    if size(array,/n_dimensions) ne 1 then message,'Only 1d arrays are supported'

    if (width mod 2) eq 1 then begin
        return, smooth(array,width,edge_truncate=edge_truncate,nan=nan,missing=missing)
    endif

    nel = n_elements(array)
    if width lt 0 or width gt nel then message,'Width must be positive and smaller than length of array'

    count = 0
    cursum = 0.0d
    halfwidth = width/2

    donan = keyword_set(nan)
    if n_elements(missing) eq 0 then missing = !values.d_nan

    result = array ; make a copy for the output

    istart = halfwidth-1
    iend = nel-1-halfwidth

    for i=0,(width-1) do begin
        if (not donan) or finite(array[i]) then begin
            cursum += array[i]
            count += 1
        endif
    endfor
    
    if count gt 0 then begin
        result[istart] = cursum/count
    endif else begin
        result[istart] = missing
    endelse

    ; remember these for later
    firstCount = count
    firstSum = cursum

    togo = istart-halfwidth+1
    next = togo + width
    for i=istart+1,iend do begin
        if (not donan) or finite(array[togo]) then begin
            cursum -= array[togo]
            count -= 1
        endif
        if (not donan) or finite(array[next]) then begin
            cursum += array[next]
            count += 1
        endif
        if count gt 0 then begin
            result[i] = cursum/count
        endif else begin
            result[i] = missing
        endelse
        togo += 1
        next += 1
    endfor

    ; and the end channels

    if keyword_set(edge_truncate) then begin
        ; high element edge, just keep going,
        ; adding in edges until the end is reached
        endok = (not donan) or finite(array[nel-1])
        for i=iend+1,(nel-1) do begin
            if (not donan) or finite(array[togo]) then begin
                cursum -= array[togo]
                count -= 1
            endif
            if (endok) then begin
                cursum += array[nel-1]
                count += 1
            endif
            if count gt 0 then begin
                result[i] = cursum/count
            endif else begin
                result[i] = missing
            endelse
            togo += 1
        endfor
            
        ; work backwards from the start, adding in 
        ; copies of the edge as necessary
        zerook = (not donan) or finite(array[0])
        togo = width-1
        cursum = firstSum
        count = firstCount
        for i=(istart-1),0,-1 do begin
            if (not donan) or finite(array[togo]) then begin
                cursum -= array[togo]
                count -= 1
            endif
            if (zerook) then begin
                cursum += array[0]
                count += 1
            endif
            if count gt 0 then begin
                result[i] = cursum/count
            endif else begin
                result[i] = missing
            endelse
            togo -= 1
        endfor
        
    endif else begin
        if istart gt 0 then begin
            result[0:(istart-1)] = array[0:(istart)-1]
        endif
        
        result[(iend+1):(nel-1)] = array[(iend+1):(nel-1)]
    endelse

    return, result
end
