;+
; List the index information using the first !g.acount values of
; !g.astack as index numbers.
; <p>
; All of the keywords available in <a href="list.html">list</a> are available here, 
; with the same meanings.  These keywords are passed to list through
; the _EXTRA keyword.   See the documentation for list for examples.
;
; @param start {in}{optional}{type=long}{default=0} If set, the first
; element of !g.astack to list.
; @param finish {in}{optional}{type=long}{default=!g.acount-1} If set,
; the last element of !g.astack to list.
; @keyword _EXTRA {in}{optional}{type=extra keywords} Passed to <a href="list.html">list</a>.
;
; @version $Id$
;-
PRO liststack, start, finish, _EXTRA=ex
    compile_opt idl2
    
    if !g.acount le 0 then return ; nothing to list

    ; initialize start, finish params
    if n_elements(start) eq 0 then start = 0
    if n_elements(finish) eq 0 then finish = !g.acount - 1

    thisStart = start
    thisFinish = finish

    if (thisStart gt thisFinish) then begin
        tmp = thisFinish
        thisFinish = thisStart
        thisStart = tmp
    endif

    if thisStart lt 0 then thisStart = 0
    if thisFinish lt 0 then thisFinish = 0
    if thisStart ge !g.acount then thisStart = !g.acount
    if thisFinish ge !g.acount then thisFinish = !g.acount

    list,index=(*!g.astack)[thisStart:thisFinish],_EXTRA=ex

END
