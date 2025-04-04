; docformat = 'rst'

;+
; This procedure divides the first data container's data array by the second, returning the result. 
;
; :Params:
;   dc1 : in, required, type=data container
;       data container (spectrum or continuum)
;   dc2 : in, required, type=data container
;       data container (spectrum or continuum)
;
; :Returns:
;   float array - division of dc1 data array by dc2 data array
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       get,index=1
;       a = data_new()
;       data_copy,!g.s[0],a
;       show,a
;       get, index=2
;       b = data_new()
;       data_copy,!g.s[0],b
;       show,b
;       div = dcdivide(a,b)
;       plot,div
;
; :Uses:
;   :idl:pro:`dcpaircheck`
; 
;-
function dcdivide,dc1,dc2

    ; make sure that the two data containers can be divided
    if (dcpaircheck(dc1,dc2,msg) ne 1) then message,msg

    return, *dc1.data_ptr / *dc2.data_ptr
    
end
