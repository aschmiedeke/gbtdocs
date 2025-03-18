;+
; This procedure adds a scalar bias to the data container's data.
;
; <p>Equivalent to:
; <pre>
; !g.s[0].data_ptr = !g.s[0].data_ptr + factor
; </pre>
;
; @param factor {in}{required}{type=float} scalar value to be added
; @param buffer {in}{optional}{type=int} The global buffer number
; containing the data to be adjusted.
;
; @examples
; <pre>
;    getrec,1
;    show
;    bias,1.3  ; all values in the PDC are now larger by 1.3
;    show
;    copy,0,5
;    bias,2.4,5 ; all values in buffer 5 now larger by 2.4
;    show
; </pre>
;
; @uses <a href="../toolbox/dcbias.html">dcbias</a>
;
; @version $Id$
;
;-
pro bias, factor, buffer
    compile_opt idl2
    on_error,2

    if n_elements(factor) eq 0 then begin
        usage,'bias'
        return
    endif
    
    locbuffer = 0
    if n_elements(buffer) ne 0 then locbuffer = buffer[0]
    if locbuffer gt 15 or locbuffer lt 0 then begin
        message,'illegal buffer value',/info
        return
    endif

    if !g.line then begin
        if data_valid(!g.s[locbuffer]) le 0 then begin
            message,'No data at indicated buffer',/info
            return
        endif
        dcbias,!g.s[locbuffer],factor 
    endif else begin    
        if data_valid(!g.c[locbuffer]) le 0 then begin
            message,'No data at indicated buffer',/info
            return
        endif
        dcbias,!g.c[locbuffer],factor 
    endelse    
    if locbuffer eq 0 and !g.frozen eq 0 then show
    
end
