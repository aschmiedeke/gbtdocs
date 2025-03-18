;+
; Supporting code shared by gbtoplot and oplotfn.  This handles
; all of the work after the new overplot struct has been generated
; and is ready to be added to the linked list in mystate.
; It is not intended for end-users.  This code does the first
; plotting of these x,y values - subsequent plotting is done
; in oplotlistitem (used by show_support).
;
; @param ostruct {in}{required}{type=oplot structure}
; @param index {out}{required}{type=integer} The index at
; the end of list where this item is now located.
; @keyword chan {in}{optional}{type=boolean} When set, interpret the x
; values as channels.
; @keyword noshow {in}{optional}{type=boolean} When set, defer
; plotting until later.
;
; @hidden_file
; @version $Id$
;-
pro gbtoplot_support, ostruct, index, chan=chan, noshow=noshow
    compile_opt idl2
    common gbtplot_common, mystate, xarray

    if (not mystate.overplots) then mystate.overplots = 1

    if (ostruct.plotme and keyword_set(chan)) then begin
        parsexunit, mystate.xunit, curscale, curtype
        ostruct.x = convertxvalues(*mystate.dc_ptr, ostruct.x, 1.0d, 0, '', '', 0.d, 0.d, $
                                   curscale, curtype, mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset)
    endif

    ; append to the end of the list
    thisptr = mystate.oplots_ptr
    lastptr = thisptr
    index = 0
    if (ptr_valid(thisptr)) then begin
        while (1) do begin
            index += 1
            if (not ptr_valid((*thisptr).next)) then begin
                ostruct.prev = thisptr
                (*thisptr).next = ptr_new(ostruct)
                break
            endif
            lastptr = thisptr
            thisptr = (*thisptr).next
        endwhile
    endif else begin
        if (ptr_valid(lastptr)) then ostruct.prev = lastptr
        mystate.oplots_ptr = ptr_new(ostruct)
    endelse

    if keyword_set(noshow) then return
    if not ostruct.plotme then return

    ; and plot just this one

    oldwin = !d.window
    wset,mystate.win_id
    if (ostruct.color ge 0) then begin
        oplot,ostruct.x,ostruct.y,color=ostruct.color
        wset,mystate.pix_id
        oplot,ostruct.x,ostruct.y,color=ostruct.color
    endif else begin
        oplot,ostruct.x,ostruct.y
        wset,mystate.pix_id
        oplot,ostruct.x,ostruct.y
    endelse
    ; without this next wset, strangly nothing is seen.  Hmmm.
    wset,mystate.win_id
    wset,oldwin
end
    
