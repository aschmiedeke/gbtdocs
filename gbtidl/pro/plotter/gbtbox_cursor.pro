;+
; GBTIDL front end to IDL provided box_cursor to allow it to work with
; the gbtidl plotter.  See the documentation for box_cursor for more
; information on these arguments.
;
; Some times after box_cursor returns (the right mouse button is
; clicked) the gbtidl plotter sees some middle mouse events (this is
; especially true if the right click coincided with movement).  That
; may cause an unanticipated zoom.  I'm not sure how to protect
; against that since I can't tell exactly what's happening there.
;
; @param x0 {in}{out}{optional}{type=float} X value of lower left corner of box
; @param y0 {in}{out}{optional}{type=float} Y value of lower left corner of box
; @param nx {in}{out}{optional}{type=integer} width of box in pixels
; @param ny {in}{out}{optional}{type=integer} height of box in pixels
; @keyword init {in}{optional}{type=boolean} If set, the parameters (x0, y0, nx, 
; and ny) contain the initial values for the box.
; @keyword fixed_size {in}{optional}{type=boolean} If set, nx and ny give the 
; initial size of the box, which can not be changed.
; @keyword message {in}{optional}{type=string} Print a short message during
; operation of the cursor.
;
; @private_file
;-
pro gbtbox_cursor, x0, y0, nx, ny, $
	INIT = init, $
	FIXED_SIZE = fixed_size, $
	MESSAGE = message

    common gbtplot_common,mystate,xarray

    ok = gbtplot()
    if not ok then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return
    endif

    ; select the window
    oldwin = !d.window
    wset, mystate.win_id

    label = "Click right mouse to exit box"
    oldLabel = ''
    widget_control, mystate.leftlabel, get_value=oldLabel, set_value=label

    ; expose it
    widget_control, mystate.main, /show

    ; disable the plotter from responding to events
    mystate.noPlotEvents = 1

    ; invoke standard box_cursor
    box_cursor,x0,y0,nx,ny,init=init,fixed_size=fixed_size, message=message

    widget_control, mystate.leftlabel, set_value=oldLabel

    ; de-select the window
    wset, oldwin

    ; enable it to respond to events
    mystate.noPlotEvents = 0
end
