; docformat = 'rst'

;+
; This procedure sets the flag that indicates whether the xaxis is in
; absolute units or relative to the value at the reference channel.
;
; :Params:
;   absrel : in, required, type=string
;       The string that determines the setting of the flag. Recognized
;       values are 'Abs' and 'Rel'. This is case-insensitive.
;
;-
pro setabsrel, absrel
    common gbtplot_common,mystate,xarray
    if n_elements(absrel) eq 0 then begin
        message,'Usage: setabsrel, absrel',/info
        return
     endif
    ; make it case insensitive.
    thisAbsrel = strupcase(absrel)
    case thisAbsRel of
       'ABS': thisAbsRel = 'Abs'
       'REL': thisAbsRel = 'Rel'
       else: thisAbsRel = ''
    endcase
    if strlen(thisAbsRel) eq 0 then begin
       message,'Unrecognized argument value, must be either Abs or Rel',/info
       return
    endif
    if (data_valid(*mystate.dc_ptr) le 0) then begin
        ; nothing has been plotted, just set it and return
        mystate.absrel = thisAbsRel
    endif else begin
        if (mystate.absrel ne thisAbsRel) then begin
            convertxstate, mystate.xunit, mystate.frame, mystate.veldef, thisAbsRel, mystate.voffset
            reshow
        endif
    endelse
    widget_control,mystate.absrel_id,set_value=thisAbsRel
end
