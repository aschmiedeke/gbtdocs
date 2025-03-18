;+
; Remove the list of over shows from the state.  This is used by
; clearoshows and show.  It is not intended for end-user use.  This is
; needed as separate from just clearoshows because show needs to also
; clear this list and calling clearoshows would lead to a recursive call.
;
; @private_file
;
; @version $Id$
;-
pro clearoshowslist
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    thisptr = mystate.oshows_ptr
    while (ptr_valid(thisptr)) do begin
        nextptr = (*thisptr).next
        data_free, *(*thisptr).dc_ptr
        ptr_free, (*thisptr).dc_ptr
        ptr_free, thisptr
        thisptr = nextptr
    endwhile
    mystate.oshows_ptr = ptr_new()
end
