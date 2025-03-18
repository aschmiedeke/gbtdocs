;+
; Format a number as a string, ensuring that it is padded with a
; leading zero so that there are always 2 digits before the optional
; decimal point.
;
; This could be generalized for use with numbers larger than 2 digits
; before the decimal point, but that is all I needed for now.
;
; @param number {in}{required}{type=numeric} The number to convert.
; @keyword precision {in}{optional}{type=integer} The number of
; characters after the decimal point.  If precision is 0 (the
; default), no decimal point appears in the returned value.
;
; @returns string representation of number at given precision.
;
; @version $Id$
;-
function paddedstring, number, precision=precision
    compile_opt idl2

    if (not keyword_set(precision)) then precision = 0
    if (precision eq 0) then begin
        tmp = long(number)
        result = string(tmp,format='(i02.2)')
    endif else begin
        width = precision + 3
        fmtstring = string(width,precision,format='("(f0",i1,".",i1,")")')
        result = string(number,format=fmtstring)
    endelse

    return, result

end
