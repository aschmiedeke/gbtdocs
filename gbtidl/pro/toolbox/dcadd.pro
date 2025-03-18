;+
; This procedure adds two data container's data arrays, returning the sum
;
; @param dc1 {in}{required}{type=data container} data container (spectrum or continuum)
; @param dc2 {in}{required}{type=data container} data container (spectrum or continuum)
;
; @returns float array - sum of two data containers' data
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
;    sum = dcadd(a,b)
;    plot, sum
; </pre>
;
; @version $Id$
;-

function dcadd,dc1,dc2

    ; make sure that the two data containers can be added
    if (dcpaircheck(dc1,dc2,msg) ne 1) then message,msg

    return, *dc1.data_ptr + *dc2.data_ptr
    
end
