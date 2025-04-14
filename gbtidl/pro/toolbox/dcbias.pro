; docformat = 'rst' 

;+
; This procedure adds a bias factor to a data container's data
;
; :Params:
;   dc : in, required, type=data container
;       data container (spectrum or continuum)
;   factor : in, required, type=float
;       bias factor
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       get,index=1
;       a = data_new()
;       data_copy,!g.s[0],a
;       show
;       dcbias,a,25
;       show,a
;
;-
pro dcbias,dc,factor

    compile_opt idl2

    if (data_valid(dc) le 0) then begin
        message, "dcbias: invalid data structure",/info
        message, "Usage: dcbias, dc, factor",/info
        return
    endif

    *dc.data_ptr = *dc.data_ptr + factor

end
