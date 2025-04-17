; docformat = 'rst' 

;+
; Clear the stack.  
;
; Normally this simply sets ``!g.acount`` to 0, and this is all that is
; needed for typical use of the stack.  Optionally, the procedure can
; also reset the stack array to zeros and it can shrink the size of
; the stack to it's initial size of 5120 elements.  That could be
; useful if the stack grew to an unexpectedly large size and you want
; to release the memory.  The stack will grow as needed when addstack
; and appendstack are called.  Only the ``!g.acount`` elements are ever
; used.
;
; :Keywords:
;   reset : in, optional, type=boolean
;       When set, the values will be reset to 0. This is not required
;       for typical use of the stack.
;   shrink : in, optional, type=boolean
;       When set, the size of the array will be reset to its initial 
;       size of 5120 elements. This is to reverse any automatic 
;       expansion that may have occurred during previous stack operations.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       addstack,1,100
;       emptystack
;       addstack,1,100000
;       emptystack,/shrink   ; reduce it to 5120 elements
; 
;-
PRO emptystack, reset=reset, shrink=shrink
    compile_opt idl2

    if (keyword_set(shrink)) then begin
        ptr_free, !g.astack
        !g.astack = ptr_new(lonarr(5120))
    endif else begin
        if (keyword_set(reset) and !g.acount gt 0) then begin
            (*!g.astack)[0:(!g.acount-1)] = 0
        endif
    endelse

    !g.acount = 0
END
