;+
; This procedure multiplies two data container's data arrays, returning the product 
;
; @param dc1 {in}{required}{type=data container} data container (spectrum or continuum)
; @param dc2 {in}{required}{type=data container} data container (spectrum or continuum)
;
; @returns float array - product of dc1 and dc2's data arrays
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
;    product = dcmultiply(a,b)
;    plot, product
; </pre>
;
; @version $Id$
;-

function dcmultiply,dc1,dc2

    ; make sure that the two data containers can be added
    if (dcpaircheck(dc1,dc2,msg) ne 1) then message,msg

    return, *dc1.data_ptr * *dc2.data_ptr
    
end
