; docformat = 'rst' 

;+
; List the displayed data container or a global data container in
; tabular form. See the documentation for :idl:pro:`dcascii` for
; an explanation of the output. Use :idl:pro:`write_ascii` to save
; this output to a file.
;
; :Params:
;   buffer : in, optional, type=integer
;       The global buffer number. If not set, it uses the most 
;       recently displayed data as shown in the plotter.
;
; :Keywords:
;   brange : in, optional, type=float, default=all
;       Beginning of the range to use, in units of the current 
;       plotter X-axis
;   erange : in, optional, type=float, default=all
;       End of the range to use, in units of the current plotter
;       X-axis
;
; :Uses:
;   :idl:pro:`dcascii`
;
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
