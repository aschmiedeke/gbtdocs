;+
; List the displayed data container or a global data container in
; tabular form.  See the documentation for  <a href="../toolbox/dcascii.html#_dcascii">dcascii</a> for an explanation
; of the output.  Use <a href="../plotter/write_ascii.html">write_ascii</a> to save this output to a file.
;
; @param buffer {in}{optional}{type=integer} The global buffer number.
; If not set, it uses the most recently displayed data as shown in 
; the plotter.
;
; @keyword brange {in}{optional}{type=float}{default=all} Beginning of
; the range to use, in units of the current plotter X-axis
;
; @keyword erange {in}{optional}{type=float}{default=all} End of
; the range to use, in units of the current plotter X-axis
;
; @uses <a href="../toolbox/dcascii.html#_dcascii">dcascii</a>
;
; @version $Id$
;-
pro table,buffer,brange=brange,erange=erange
    if n_elements(buffer) eq 0 then begin
        dcascii,brange=brange,erange=erange
    endif else begin
        if buffer lt 0 then begin
            message,'buffer must be >= 0',/info
            return
        endif
        if !g.line then begin
            if buffer ge n_elements(!g.s) then begin
                message,string(n_elements(!g.s),format='("buffer must be < ",i2)'),/info
                return
            endif
            dcascii,!g.s[buffer],brange=brange,erange=erange
        endif else begin
            if buffer ge n_elements(!g.c) then begin
                message,string(n_elements(!g.c),format='("buffer must be < ",i2)'),/info
                return
            endif
            dcascii,!g.c[buffer],brange=brange,erange=erange
        endelse
    endelse
end
