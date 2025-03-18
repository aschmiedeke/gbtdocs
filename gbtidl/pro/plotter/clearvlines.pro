;+
; Clear all vertical lines and associated text from the plotter.
;
; @keyword noshow {in}{optional}{type=boolean} Don't immediately
; update the plotter..  This is useful if you are stringing several
; plotter calls together.  It keeps the plotter from updating after each
; call.
;
; @keyword idstring {in}{optional}{type=string} Only clear those
; vertical lines that match idstring.  Default is to clear all
; vertical lines.  An empty string matches all vlines and is
; equivalent to omitting this idstring keyword.
;
; @version $Id$
;-
pro clearvlines, noshow=noshow, idstring=idstring
    common gbtplot_common,mystate,xarray
    compile_opt idl2

    if mystate.nvlines eq 0 then return

    if n_elements(idstring) eq 0 then begin
        mystate.nvlines = 0
    endif else begin
        if idstring eq '' then begin
            mystate.nvlines = 0
        endif else begin
            ; construct a mask to be removed
            toremove = where((*mystate.vline_idstring)[0:(mystate.nvlines-1)] eq idstring, count, complement=keptLines,ncomplement=nkept)
            if count eq 0 then return ; nothing to clear
            if count eq mystate.nvlines then begin
                mystate.nvlines = 0 ; everything is cleared
            endif else begin
                if count eq 0 then return ; nothing to clear
                mystate.nvlines = nkept
                newindx = lindgen(nkept)
                (*mystate.vline_pos)[newindx,0] = (*mystate.vline_pos)[keptLines,0]
                (*mystate.vline_pos)[newindx,1] = (*mystate.vline_pos)[keptLines,1]
                (*mystate.vline_txt)[newindx] = (*mystate.vline_txt)[keptLines]
                (*mystate.vline_ynorm)[newindx] = (*mystate.vline_ynorm)[keptLines]
                (*mystate.vline_idstring)[newindx] = (*mystate.vline_idstring)[keptLines]
            endelse
        endelse 
    endelse

    if not keyword_set(noshow) then reshow
end
