;+
; Update the plotter due to a mouse event's xdevice and ydevice
; values.
;
; <p> This updates the tracked position string on the plotter and, if
; the crosshair is active, moves the crosshar to this new position.
; This assumes that wset has already been done on the appropriate window.
; The input positions are converted to data coordinates and returned so
; that they can be used elsewhere.
;
; @param xdevice {in}{required}{type=integer} The mouse.x value.
; @param ydevice {in}{required}{type=integer} The mouse.y value.
; @keyword position_text {out}{optional}{type=string} The new position
; text to use in updating the plotter status field.
; @returns data coordinates as 2-element vector.
;
; @private_file
;
; @version $Id$
;-
function gbtcursormoved, xdevice, ydevice,position_text=position_text
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    oldwin = !d.window
    wset,mystate.win_id
    data_coord = convert_coord(xdevice,ydevice,/to_data,/device)
    position_text = string(data_coord[0],data_coord[1], format='(" X: ",g13.7,1x,"Y:",g13.7)')
    widget_control,mystate.xylabel,set_value=position_text
    if mystate.crosshair eq 1 then begin
        device,copy=[0,0,mystate.xsize,mystate.ysize,0,0,mystate.pix_id]
	; need to turn off histogram mode if it is on, otherwise plots dumps
	; annoying messages to the console
	old_psym = !p.psym
	!p.psym = 0
        plots,[0,mystate.xsize],[ydevice,ydevice],color=!g.crosshaircolor,/device
        plots,[xdevice,xdevice],[0,mystate.ysize],color=!g.crosshaircolor,/device
        ; draw 2x, counteract an apparent wset bug
        plots,[0,mystate.xsize],[ydevice,ydevice],color=!g.crosshaircolor,/device
        plots,[xdevice,xdevice],[0,mystate.ysize],color=!g.crosshaircolor,/device
	!p.psym = old_psym
    endif
    wset,oldwin
    return, data_coord
end
  
