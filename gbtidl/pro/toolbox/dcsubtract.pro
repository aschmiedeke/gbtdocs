;+
; This procedure subtracts the second data container's data array from the first, returning the results.
;
; @param dc1 {in}{required}{type=data container} data container (spectrum or continuum)
; @param dc2 {in}{required}{type=data container} data container (spectrum or continuum)
;
; @returns float array: dc2 data subtracted from dc1 data
;
; @uses <a href="../toolbox/dcpaircheck.html">dcpaircheck</a>
;
; @examples
; <pre>
;    get,index=1
;    a = data_new()
;    data_copy,!g.s[0],a
;    show,a
;    get, index=2
;    b = data_new()
;    data_copy,!g.s[0],b
;    show,b
;    diff = dcsubtract(a,b)
;    plot,a
; </pre>
;
; @version $Id$
;-

function dcsubtract,dc1,dc2

    ; check that the two containers can add their data
    if (dcpaircheck(dc1,dc2,msg) ne 1) then message, msg
    
    return,*dc1.data_ptr - *dc2.data_ptr
    
end
