;+
; Remove specific values from the stack.
;
; @param index {in}{required}{type=integer} The values to be
; removed. Any value in the stack that matches a value in this
; parameter is removed from the stack.
;
; @examples
; <pre>
;   addstack, 10,30,2
;   delete, [16,18,20]
;   tellstack
;   ; result is ...
;   ; [ 10, 12, 14, 22, 24, 26, 28, 30]
; </pre>
;
; @version $Id$
;-
PRO delete, index
    compile_opt idl2

    if (!g.acount gt 0) then begin
        allStack = (*!g.astack)[0:(!g.acount-1)]
        toBeRemoved = lonarr(!g.acount)
        for i=0,(n_elements(index)-1) do begin
            foundIndex = where(allStack eq index[i], count)
            if (count gt 0) then begin
                toBeRemoved[foundIndex] = -1
            endif
        endfor
        toBeKept = where(toBeRemoved ne -1, count)
        if (count gt 0) then begin
            if (count ne !g.acount) then begin
                !g.acount = count
                (*!g.astack)[0:(!g.acount-1)] = allStack[toBeKept]
            endif
        endif else begin
            !g.acount = 0
        endelse
    endif
END
