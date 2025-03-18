;+
; This procedure scales a data container by a scalar value
;
; @param dc {in}{required}{type=data container} data container (spectrum or continuum)
; @param factor {in}{required}{type=float} scale factor
;
; @examples
; <pre>
;    get,index=1
;    a = data_new()
;    data_copy,!g.s[0],a
;    show
;    dcscale,a,100
;    show,a
; </pre>
;
; @version $Id$
;-

pro dcscale,dc,factor
	*dc.data_ptr = *dc.data_ptr * factor
end
