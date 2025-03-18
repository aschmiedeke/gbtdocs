;+
; Sets the plotter's Auto Update feedback field as appropriate for
; the current value of !g.frozen.  This should be called after ever
; time that !g.frozen changes state.  Users should use the Auto Update
; menu on the plotter or the freeze and unfreeze procedures to change
; !g.frozen rather than change it directly.  In that case, it is not
; necessary to call this procedure directly.
;
; @private_file
;
; @version $Id$
;-
pro setplotterautoupdate
    common gbtplot_common,mystate,xarray
    if !g.frozen and not mystate.labelFrozen then begin
        if gbtplot() then begin
            widget_control,mystate.autolabel,set_value='Auto Update: Off'
            mystate.labelFrozen = 1
        endif
    endif else begin
        if not !g.frozen and mystate.labelFrozen then begin
            if gbtplot() then begin
                widget_control,mystate.autolabel,set_value='Auto Update: On '
                mystate.labelFrozen = 0
            endif
        endif
    endelse
end
