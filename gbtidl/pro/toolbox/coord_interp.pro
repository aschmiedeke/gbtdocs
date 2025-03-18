;+
; Find the value of the coordinate at the given location, watching for
; large discontinuities due to a coordinate wrap (e.g. time at 24/0 or
; degrees at 360/0).
;
; @param coords {in}{required}{type=2-element array} The values to use
; in the interpolation.  Only the first two values are used.
;
; @param loc {in}{required} The location to find the interpolated
; value at.  Should be between 0 and 1.
;
; @param wrapsat {in}{required} The value that coords wraps back to
; zero at.
;
; @returns The interpolated coordinate value.
;
; @version $Id$
;-
FUNCTION coord_interp, coords, loc, wrapsat
    compile_opt idl2

    result = 0.0d

    diff = coords[1]-coords[0]
    allPos = total(coords ge 0) eq 2
    if (abs(diff) gt wrapsat/2.0) then begin
        ; looks like it wraps
        ; subtract wrapsat from the larger of the two coords
        if (coords[0] gt coords[1]) then begin
            coords[0] = coords[0] - wrapsat
        endif else begin
            coords[1] = coords[1] - wrapsat
        endelse
        diff = coords[1] - coords[0]
    endif
    ; simple linear interpolation
    result = coords[0] + diff * loc
    if (allPos and result lt 0) then begin
        result = result + wrapsat
    endif
    if (result gt wrapsat) then result = result - wrapsat

    return, result
END
