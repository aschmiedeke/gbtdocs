;+
; Remove the list of over plots from the state.  This is used by
; clearoplots and show.  It is not intended for end-user use.  This is
; needed as separate from just clearoplots because show needs to also
; clear this list and calling clearoplots would lead to a recursive call.
;
; @keyword index {in}{optional}{type=integer} The index numbers to
; clear.  If not set, all oplots are cleared.
;
; @keyword idstring {in}{optional}{type=string} The idstring value
; to use to match in the list.  Only those values matching this string
; are cleared.  If not set, all idstrings match.  Only the first element
; of idstring is used.  No information or warnings are printed if
; there was no matching idstring found.
;
; @keyword count {out}{optional}{type=integer} The number of items cleared.
;
; @hidden_file
;
; @version $Id$
;-
pro clearoplotslist, index=index,idstring=idstring,count=count
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    count = 0

    doIDcheck = n_elements(idstring) gt 0
    if doIDcheck then doIDcheck = strlen(idstring[0]) gt 0

    if (n_elements(index) gt 0) then begin
        lastptr = 0
        thisptr = mystate.oplots_ptr
        thisindex = 0
        lastindex = -1
        indexfound = 0
        while (ptr_valid(thisptr)) do begin
            nextptr = (*thisptr).next
            prevptr = (*thisptr).prev
            indx = where(index eq thisindex,indxcount)
            if (indxcount gt 0) then begin
                okToRemove = 1
                if doIDcheck then begin
                    if (*thisptr).idstring ne idstring then okToRemove = 0
                endif
                if (okToRemove) then begin
                    if (lastindex ge 0) then begin
                        (*lastptr).next = nextptr
                    endif else begin
                        mystate.oplots_ptr = nextptr
                    endelse
                    if ptr_valid(nextptr) then begin
                        (*nextptr).prev = prevptr
                    endif
                    ptr_free, thisptr
                    indexfound += 1
                    count += 1
                endif else begin
                    ; was not removed
                    lastptr = thisptr
                    lastindex += 1
                endelse
            endif else begin
                lastptr = thisptr
                lastindex += 1
            endelse
            thisptr = nextptr
            thisindex += 1
        endwhile
        if (indexfound ne n_elements(index)) then begin
            if (n_elements(index) eq 1) then begin
                message, 'requested index does not exist.',/info
            endif else begin
                message, 'At least one requested index does not exist.',/info
            endelse
        endif
    endif else begin
        thisptr = mystate.oplots_ptr
        lastptr = ptr_new()
        while (ptr_valid(thisptr)) do begin
            nextptr = (*thisptr).next
            okToRemove = 1
            if doIDcheck then begin
                if (*thisptr).idstring ne idstring then okToRemove = 0
            endif
            if okToRemove then begin
                if ptr_valid(lastptr) then begin
                    (*lastptr).next = nextptr
                endif else begin
                    mystate.oplots_ptr = nextptr
                endelse
                ptr_free, thisptr
                count += 1
            endif else begin
                ; was not removed
                lastptr = thisptr
            endelse
            thisptr = nextptr
        endwhile
        if not ptr_valid(mystate.oplots_ptr) then mystate.oplots_ptr = ptr_new()
    endelse
end
