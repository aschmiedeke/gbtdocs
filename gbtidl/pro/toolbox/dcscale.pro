; docformat = 'rst' 

;+
; This procedure scales a data container by a scalar value
;
; :Params:
;   dc : in, required, type=data container
;       data container (spectrum or continuum)
;   factor : in, required, type=float
;       scale factor
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       get,index=1
;       a = data_new()
;       data_copy,!g.s[0],a
;       show
;       dcscale,a,100
;       show,a
;
;-
pro dcscale,dc,factor
	*dc.data_ptr = *dc.data_ptr * factor
end
