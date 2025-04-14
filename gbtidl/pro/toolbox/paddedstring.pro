; docformat = 'rst'

;+
; Format a number as a string, ensuring that it is padded with a
; leading zero so that there are always 2 digits before the optional
; decimal point.
;
; This could be generalized for use with numbers larger than 2 digits
; before the decimal point, but that is all I needed for now.
;
; :Params:
;   number : in, required, type=numeric
;       The number to convert.
; 
; :Keywords:
;   precision : in, optional, type=integer, default=0
;       The number of characters after the decimal point. If precision
;       is 0, no decimal point appears in the returned value.
;
; :Returns:
;   string representation of number at given precision.
;
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
