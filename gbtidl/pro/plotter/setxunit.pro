; docformat = 'rst'

;+
; This procedure sets the units on the X-axis of the plot
; Valid units are 'Channels','Hz'.'kHz','MHz', 'GHz', 'm/s', and 'km/s'
;
; :Params:
;   unit : in, required, type=string
;       unit
; 
; :Keywords:
;   noreshow : in, optional, type=boolean
;       If set, the plotter is not updated with the new units. This is
;       useful if this is embedded in a procedure and you want to delay
;       updating the plotter until several changes have been made. This
;       features is used internally in show_support.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       get,index=1
;       show
;       setxunit,'MHz'
;
;-
pro setxunit, unit, noreshow=noreshow
    common gbtplot_common,mystate,xarray
    if n_elements(unit) eq 0 then begin
       message,'Usage: setxunit, unit',/info
       message,'  unit must be one of "Channels","Hz","kHz","MHz",',/info
       message,'  "GHz","m/s",or "km/s"',/info
       return
    endif
    if (data_valid(*mystate.dc_ptr) le 0) then begin
        ; nothing has been plotted, just set it and return
        parsexunit, unit, scale, type
        mystate.xunit = unit
        mystate.xscale = scale
        mystate.xtype = type
        !g.plotter_axis_type = mystate.xtype
    endif else begin
        if (mystate.xunit ne unit) then begin
            convertxstate, unit, mystate.frame, mystate.veldef, mystate.absrel, mystate.voffset
            if not keyword_set(noreshow) then reshow
        endif
    endelse
    widget_control,mystate.xunits_id,set_value=unit
end
