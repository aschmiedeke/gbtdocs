; docformat = 'rst'

;+
; This procedure scales the data container's data by a scalar value.
;
; Equivalent to:  ``*!g.s[0].data_ptr = *!g.s[0].data_ptr * factor`` 
; 
; 
; :Params:
;   factor : in, required, type=float
;       scale factor
;   buffer : in, optional, type=int
;       The global buffer number containing the data to be scaled
;
; :Examples:
; 
; .. code-block:: IDL
;
;   get,index=1
;   show
;   scale,1.3
;   show
;
; :Uses:
;   :idl:pro:`dcscale`
;
;-
pro scale,factor,buffer
    compile_opt idl2
    on_error,2

    if n_elements(factor) eq 0 then begin
        usage,'scale'
        return
    end

    locbuffer = 0
    if n_elements(buffer) ne 0 then locbuffer = buffer[0]
    if locbuffer gt 15 or locbuffer lt 0 then begin
        message,"illegal buffer value",/info
        return
    endif

    if !g.line then begin
        if (data_valid(!g.s[locbuffer]) le 0) then begin
            message,'No data at indicated buffer',/info
            return
        endif
	dcscale,!g.s[locbuffer],factor
    endif else begin    
        if (data_valid(!g.c[locbuffer]) le 0) then begin
            message,'No data at indicated buffer',/info
            return
        endif
	dcscale,!g.c[locbuffer],factor
    endelse
    if locbuffer eq 0 and !g.frozen eq 0 then show
end
