;+
; This procedure checks both data containers to see if their data arrays can be used
; for mathematical functions, such as dcadd, dcsubtract, etc.
;
; @param dc1 {in}{required}{type=data container} data container (spectrum or continuum)
; @param dc2 {in}{required}{type=data container} data container (spectrum or continuum)
; @param msg {out}{required}{type=string} string containing error if found 
;
; @returns 0 - pair is incompatible; 1 - pair is compatible
;
; @examples
; <pre>
;    get, index=1
;    a = data_new()
;    data_copy,!g.s[0],a
;    show,a
;    get, index=2
;    b = data_new()
;    data_copy,!g.s[0],b
;    show,b
;    status = dcpaircheck(a,b,msg)
;    if (status ne 1) then print, msg 
;    "data containers must contain data of equal length" 
; </pre>
;
; @version $Id$
;-
function dcpaircheck, dc1, dc2, msg

    msg = 'no error'
    
    ; both dc's valid?
    if (data_valid(dc1) le 0) or (data_valid(dc2) le 0) then begin
        msg = "invalid or undefined data structure"
        return, 0
    endif

    ; both data arrays are of same length?
    if (n_elements(*dc1.data_ptr) ne n_elements(*dc2.data_ptr)) then begin
        msg = "data containers must contain data of equal length"
        return, 0
    endif
    
    ; return that the data containers are compatible
    return, 1
    
end
