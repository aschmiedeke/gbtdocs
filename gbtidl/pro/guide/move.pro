;+
; Move the data from the in location to the out location.  Anything in
; out is lost.  This uses the value of !g.line.  If it is set (1)
; then the array of line data (!g.s) is used, otherwise the array of
; continuum data (!g.c) is used.  The contents of in are
; emptied and lost.
;
; @param in {in}{required}{type=integer} The buffer to move
; values from.
;
; @param out {in}{required}{type=integer} The buffer to move the
; values to.
;
; @examples
; Move the contents of location 0 to location 10.  Then move the
; contents of 9 to location 0.
; <pre>
;    copy, 0, 10
;    copy, 9, 0
; </pre>
;
; @uses <a href="copy.html">copy</a>
;
; @version $Id$
;-
PRO move, in, out
    compile_opt idl2

    if n_params() ne 2 then begin
        message,'Usage: move, in, out',/info
        return
    endif

    ; argument checking happens in copy
    copy, in, out
    ; wipe out contents of in
    if (!g.line) then begin
        data_free, !g.s[in]
        !g.s[in] = data_new()
    endif else begin
        data_free, !g.c[in]
        !g.c[in] = data_new(/continuum)
    endelse
    
    return
END
    
