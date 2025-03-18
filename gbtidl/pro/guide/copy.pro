;+
; Copy the data from the in buffer to the out buffer.  Anything in
; out is lost. 
; 
; <p>This uses the value of !g.line.  If it is set (1) then the array
; of line data (!g.s) is used, otherwise the array of continuum data
; (!g.c) is used.  The contents of the in buffer remain unchanged by
; this operation. 
;
; <p>There are 16 buffers total, numbered from 0 through 15.
;
; @param in {in}{required}{type=integer} The buffer to copy values
; from.
;
; @param out {in}{required}{type=integer} The buffer to copy the
; values to. 
;
; @examples
; Copy the contents of buffer 0 to buffer 10.  Then copy the
; contents of 9 to buffer 0.
; <pre>
;    copy, 0, 10
;    copy, 9, 0
; </pre>
;
; @uses <a href="set_data_container.html">set_data_container</a>
;
; @version $Id$
;-
PRO copy, in, out
    compile_opt idl2

    if n_params() ne 2 then begin
        message,'Usage: copy, in, out',/info
        return
    endif

    ; if from=to the do nothing
    if in eq out then return

    ; valid in - out is checked in set_data_container
    if (!g.line) then begin
        if (in gt n_elements(!g.s) or in lt 0) then begin
            message, string((n_elements(!g.s)-1),format='("buffer must be >= 0 and <= ",i2)')
            return
        endif
        set_data_container, !g.s[in], buffer=out
    endif else begin
        if (in gt n_elements(!g.c) or in lt 0) then begin
            message, string((n_elements(!g.c)-1),format='("buffer must be >= 0 and <= ",i2)')
            return
        endif
        set_data_container, !g.c[in], buffer=out
    endelse

    return
END
    
