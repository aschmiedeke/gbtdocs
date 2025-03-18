;+
; Function to return the input string, left justified at the desired
; width.  Whitespace is first trimmed from the input string according
; to flag and
; then enough spaces are appended to the input string to pad it out
; to the desired width.  If the input string
; is wider than the desired width, after trimming, it is truncated so that the
; returned string always is of the desired width.
;
; @param in {in}{required}{type=string} The input string to pad.
; @param width {in}{required}{type=integer} The desired width.  Must
; be a positive integer.
; @param flag {in}{optional}{type=integer}{default=0} This is passed
; directly to strtrim to control on in is trimmed prior to padding.
; If flag is 0, trailing whitespace is trimmed, if flag is 1, leading
; whitepsace is trimed, and if flag is 2, both are trimmed.
;
; @returns the padded string
;
; @version $Id$
;-
function leftjustify, in, width, flag
    compile_opt idl2

    if n_elements(flag) eq 0 then flag = 0
    result = strtrim(in,flag)
    inlen = strlen(result)
    if inlen lt width then begin
        for i=inlen,(width-1) do result += ' '
    endif else begin
        result = strmid(in,0,width)
    endelse
    return, result
end
