;+
; Scale a value and determine the appropriate prefix for the scaled
; result.
;
; This could be more general, but it is only intended to work out
; scaling for Giga, Mega, and kilo (G,M,k).  If thevalues is a vector,
; only the first value is examined and all values are scaled by the
; same factor.
;
; @param thevalues {in}{required}{type=float} The values to be scaled.
; @param scaledvalues {out}{required}{type=float} The scaled values.
; @param prefix {out}{required}{type=string} One of "G", "M" or "k"
; for scalings by 1e9, 1e6, or 1e3 respectively.
;
; @version $Id$
;-
pro scalevals, thevalues, scaledvalues, prefix
    compile_opt idl2
    ; this could be more general, but its only intended to
    ; work out scalings for Giga, Mega, and kilo (G,M,k)
    ; only look at the first value
    prefix = ''
    scaledvalues=thevalues
    if (thevalues[0] ge 1e9) then begin
        scaledvalues = thevalues / 1e9
        prefix = 'G'
    endif else begin
        if (thevalues[0] ge 1e6) then begin
            scaledvalues = thevalues / 1e6
            prefix = 'M'
        endif else begin
            if (thevalues[0] ge 1e3) then begin
                scaledvalues=thevalues / 1e3
                prefix = 'k'
            endif
        endelse
    endelse
    return
end
