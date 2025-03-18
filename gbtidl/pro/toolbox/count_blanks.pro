;+
; Count the number of blanked values in the data array of the given
; data container.
;
; <p> A blanked value is a NaN, this returns the number of NaNs in the
; given data container.  It returns -1 if the dc argument is not a
; valid data container. The size argument will contain the total
; number of data elements in dc.
;
; @param dc {in}{required}{type=data container} The data container to
; check.
; @param size {out}{optional}{type=integer} The total number of data
; elements in dc (-1 if dc is an invalid data container)
; @returns The total number of blanked values in dc.  Returns -1 if dc
; is not a valid data container.
;
; @version $Id$
;-
function count_blanks, dc, size
    compile_opt idl2

    result = data_valid(dc)
    size = result

    if result gt 0 then result = n_elements(where(finite(*dc.data_ptr,/nan)))

    return, result
end
