;+
; Get a mouse event when the user presses any mouse button.
;
; <p> This returns a mouse event structure when the user presses any
; mouse button.  The default behavior is to bring the plotter window
; to the foreground (show) and to switch to the crosshair cursor.
; Both of these features can be turned off.  If the crosshair state is
; changed during this function, it always returns to the previous
; crosshair state on exit.  Additionally, the "Left Click:" label is
; changed to the "Click a Mouse Button".  Alternatively labels can be
; supplied through the optional label keyword.
;
; <p> See the IDL documentation for the events available from a DRAW_WIDGET.
; Users should use <a href="click.html">click</a> in most cases.
;
; @keyword noshow {in}{optional}{type=boolean} If set, then the plotter
; will not be brought to the foreground (shown).
; @keyword nocrosshair {in}{optional}{type=boolean} If set, the the
; whatever the current crosshair state is, it will not be changed
; during this function.  Normally, this function ensures that the
; crosshairs are on.
; @keyword label {in}{optional}{type=string} A label to use in the
; "Left Click:" field of the plotter.  Defaults to "Click a Mouse
; Button".
;
; @uses <a href="gbtcursormoved.html">gbtcursormoved</a>
;
; @returns mouse event structure.
;
; @private_file
;
; @version $Id$
;-
function gbtcursor, noshow=noshow, nocrosshair=nocrosshair, label=label
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    ok = gbtplot()
    if not ok then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return, -1
    endif

    oldwin = !d.window
    wset,mystate.win_id
    if (not keyword_set(noshow)) then widget_control, mystate.main, /show
    oldCrosshair = mystate.crosshair
    if (not keyword_set(nocrosshair) and oldCrosshair eq 0) then crosshair
    if (n_elements(label) eq 0) then label = "Click a Mouse Button"
    oldLabel = ''
    widget_control, mystate.leftlabel, get_value=oldLabel
    widget_control, mystate.leftlabel, set_value=label

    blocked = 1
    while blocked do begin
        myresult = widget_event(mystate.plot1)
        if myresult.press ne 0 then begin
            blocked = 0
        endif else begin
           data_coord = gbtcursormoved(myresult.x, myresult.y)
        endelse
    endwhile
    if (oldCrosshair ne mystate.crosshair) then crosshair
    widget_control, mystate.leftlabel, set_value=oldLabel
    ; select default window, to get this out of the way
    wset,oldwin
    return, myresult
end
